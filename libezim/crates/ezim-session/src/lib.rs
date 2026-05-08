//! Session state machine for libezim.
//!
//! A [`Session`] borrows a [`BinaryTable`] and maintains the per-user state
//! that an IME framework needs:
//!
//! - **buffer** — the raw EZ keys typed so far (the preedit text).
//! - **candidates** — texts whose code exactly matches the buffer, in
//!   source-file order.
//! - **page** — current page within the candidate list.
//!
//! ## State diagram
//!
//! ```text
//! [Idle (buffer empty)]
//!     │ Char(k)
//!     ▼
//! [Composing (buffer non-empty)]──── Backspace ───▶ shorter buffer (or back to Idle)
//!     │ Space / Enter / Select(n)
//!     ▼
//! commits a candidate, returns to Idle
//!     │ Escape
//!     ▼
//! [Idle]
//! ```
//!
//! There is no separate "Selecting" state — the candidate list is always
//! current with the buffer; selection just commits a row.

use ezim_core::char_weights::CharWeights;
use ezim_core::format::BinaryTable;
use ezim_core::phrase_weights::PhraseWeights;

pub mod key;
pub use key::Key;

/// Default page size — 9 candidates fits the conventional 1-9 number-row.
pub const DEFAULT_PAGE_SIZE: usize = 9;

/// Maximum number of EZ keys we will accept into the buffer. Per M1 stats,
/// the longest valid code in the source table is 4 keys; extra keys past
/// the cap are silently consumed (the buffer will not grow further until
/// the user backspaces or commits).
pub const DEFAULT_MAX_BUFFER_LEN: usize = 4;

/// Outcome of [`Session::handle_key`].
#[derive(Debug, Default, Clone, PartialEq, Eq)]
pub struct StepOutcome {
    /// Text the host application should commit (insert into the document).
    pub commit: Option<String>,
    /// Whether the IME consumed the key. If `false`, the host should pass
    /// the key through to the application as a normal keystroke.
    pub consumed: bool,
}

/// Per-user IME session.
pub struct Session<'t> {
    table: &'t BinaryTable,
    buffer: String,
    candidates: Vec<String>,
    page: usize,
    page_size: usize,
    max_buffer_len: usize,
    char_weights: Option<&'t CharWeights>,
    phrase_weights: Option<&'t PhraseWeights>,
}

impl<'t> Session<'t> {
    pub fn new(table: &'t BinaryTable) -> Self {
        Self {
            table,
            buffer: String::new(),
            candidates: Vec::new(),
            page: 0,
            page_size: DEFAULT_PAGE_SIZE,
            max_buffer_len: DEFAULT_MAX_BUFFER_LEN,
            char_weights: None,
            phrase_weights: None,
        }
    }

    pub fn with_page_size(mut self, page_size: usize) -> Self {
        assert!(page_size >= 1, "page_size must be >= 1");
        self.page_size = page_size;
        self
    }

    /// Attach corpus-derived rank tables. When set, [`Session`] orders
    /// candidates for any code by ascending rank (lower = more frequent),
    /// consulting [`CharWeights`] for single-character candidates and
    /// [`PhraseWeights`] for multi-character ones. Candidates absent from
    /// the corpus are placed after ranked entries; ties (and absent rows)
    /// fall back to original source-file order.
    ///
    /// Either argument may be `None` if the host only has one corpus.
    pub fn with_weights(
        mut self,
        char_weights: Option<&'t CharWeights>,
        phrase_weights: Option<&'t PhraseWeights>,
    ) -> Self {
        self.set_weights(char_weights, phrase_weights);
        self
    }

    /// Mutating counterpart of [`with_weights`] for use after construction
    /// (e.g. when an FFI host wants to attach weights to an existing
    /// session). Refreshes the candidate list immediately so the new
    /// ordering is reflected without waiting for the next keystroke.
    pub fn set_weights(
        &mut self,
        char_weights: Option<&'t CharWeights>,
        phrase_weights: Option<&'t PhraseWeights>,
    ) {
        self.char_weights = char_weights;
        self.phrase_weights = phrase_weights;
        self.refresh_candidates();
    }

    pub fn with_max_buffer_len(mut self, max_buffer_len: usize) -> Self {
        self.max_buffer_len = max_buffer_len.max(1);
        self
    }

    // --- accessors ----------------------------------------------------

    /// The raw key buffer — this is the preedit text shown to the user.
    pub fn buffer(&self) -> &str {
        &self.buffer
    }

    /// All candidates matching the current buffer, in source-file order.
    pub fn candidates(&self) -> &[String] {
        &self.candidates
    }

    /// Number of pages of candidates (≥ 1 when there are candidates, else 0).
    pub fn page_count(&self) -> usize {
        if self.candidates.is_empty() {
            0
        } else {
            self.candidates.len().div_ceil(self.page_size)
        }
    }

    /// Zero-based current page index.
    pub fn page(&self) -> usize {
        self.page
    }

    pub fn page_size(&self) -> usize {
        self.page_size
    }

    /// Slice of candidates on the current page.
    pub fn current_page(&self) -> &[String] {
        if self.candidates.is_empty() {
            return &[];
        }
        let start = self.page * self.page_size;
        let end = (start + self.page_size).min(self.candidates.len());
        &self.candidates[start..end]
    }

    pub fn is_idle(&self) -> bool {
        self.buffer.is_empty()
    }

    // --- driver -------------------------------------------------------

    /// Drive the state machine with a single key event.
    pub fn handle_key(&mut self, k: Key) -> StepOutcome {
        match k {
            Key::Char(c) => self.on_char(c),
            Key::Backspace => self.on_backspace(),
            Key::Escape => self.on_escape(),
            Key::Space | Key::Enter => self.on_commit_first(),
            Key::Select(n) => self.on_select(n),
            Key::PageNext => self.on_page_next(),
            Key::PagePrev => self.on_page_prev(),
        }
    }

    /// Drop any in-flight composition without committing anything.
    pub fn cancel(&mut self) {
        self.buffer.clear();
        self.candidates.clear();
        self.page = 0;
    }

    /// Commit the first candidate immediately (if any), return to idle.
    pub fn commit_first(&mut self) -> Option<String> {
        let out = self.candidates.first().cloned();
        if out.is_some() {
            self.cancel();
        }
        out
    }

    /// Commit the candidate at 1-based index on the current page.
    pub fn commit_page_index(&mut self, idx_one_based: usize) -> Option<String> {
        if idx_one_based == 0 {
            return None;
        }
        let page = self.current_page();
        let i = idx_one_based - 1;
        let out = page.get(i).cloned();
        if out.is_some() {
            self.cancel();
        }
        out
    }

    // --- internals ----------------------------------------------------

    fn on_char(&mut self, c: char) -> StepOutcome {
        if !is_valid_ez_key(c) {
            return StepOutcome {
                commit: None,
                consumed: false,
            };
        }
        if self.buffer.chars().count() >= self.max_buffer_len {
            // Cap reached — consume but don't grow.
            return StepOutcome {
                commit: None,
                consumed: true,
            };
        }
        self.buffer.push(c);
        self.refresh_candidates();
        StepOutcome {
            commit: None,
            consumed: true,
        }
    }

    fn on_backspace(&mut self) -> StepOutcome {
        if self.buffer.is_empty() {
            return StepOutcome {
                commit: None,
                consumed: false,
            };
        }
        self.buffer.pop();
        self.refresh_candidates();
        StepOutcome {
            commit: None,
            consumed: true,
        }
    }

    fn on_escape(&mut self) -> StepOutcome {
        if self.buffer.is_empty() {
            return StepOutcome {
                commit: None,
                consumed: false,
            };
        }
        self.cancel();
        StepOutcome {
            commit: None,
            consumed: true,
        }
    }

    fn on_commit_first(&mut self) -> StepOutcome {
        if self.buffer.is_empty() {
            return StepOutcome {
                commit: None,
                consumed: false,
            };
        }
        match self.commit_first() {
            Some(s) => StepOutcome {
                commit: Some(s),
                consumed: true,
            },
            None => {
                // Composing with no candidates — consume the space/enter and
                // drop the buffer (matches typical IME behaviour for a dead
                // composition).
                self.cancel();
                StepOutcome {
                    commit: None,
                    consumed: true,
                }
            }
        }
    }

    fn on_select(&mut self, n: u8) -> StepOutcome {
        if self.buffer.is_empty() {
            return StepOutcome {
                commit: None,
                consumed: false,
            };
        }
        match self.commit_page_index(n as usize) {
            Some(s) => StepOutcome {
                commit: Some(s),
                consumed: true,
            },
            None => StepOutcome {
                commit: None,
                consumed: true, // out-of-range selection is consumed, no-op
            },
        }
    }

    fn on_page_next(&mut self) -> StepOutcome {
        let pc = self.page_count();
        if pc <= 1 {
            return StepOutcome {
                commit: None,
                consumed: !self.buffer.is_empty(),
            };
        }
        self.page = (self.page + 1) % pc;
        StepOutcome {
            commit: None,
            consumed: true,
        }
    }

    fn on_page_prev(&mut self) -> StepOutcome {
        let pc = self.page_count();
        if pc <= 1 {
            return StepOutcome {
                commit: None,
                consumed: !self.buffer.is_empty(),
            };
        }
        self.page = if self.page == 0 { pc - 1 } else { self.page - 1 };
        StepOutcome {
            commit: None,
            consumed: true,
        }
    }

    fn refresh_candidates(&mut self) {
        self.page = 0;
        self.candidates.clear();
        if self.buffer.is_empty() {
            return;
        }
        let Ok(entries) = self.table.entries_for_code(&self.buffer) else {
            return;
        };

        // Source-file order is the baseline. If weights are attached,
        // we additionally sort by ascending rank (lower = more frequent),
        // with absent-from-corpus entries placed after ranked ones and
        // ties broken by source-file order via the stable sort.
        if self.char_weights.is_none() && self.phrase_weights.is_none() {
            self.candidates
                .extend(entries.into_iter().map(|e| e.text.to_string()));
            return;
        }
        let mut ranked: Vec<(u32, String)> = entries
            .into_iter()
            .map(|e| {
                let text = e.text.to_string();
                let rank = rank_for(
                    &text,
                    self.char_weights,
                    self.phrase_weights,
                );
                (rank, text)
            })
            .collect();
        // Stable sort preserves source-file order for equal ranks
        // (including the u32::MAX bucket for absent entries).
        ranked.sort_by_key(|&(r, _)| r);
        self.candidates.extend(ranked.into_iter().map(|(_, t)| t));
    }
}

/// Resolve the rank of a candidate text by consulting the right corpus.
/// Single Unicode-codepoint texts go to [`CharWeights`]; multi-codepoint
/// texts (phrases) go to [`PhraseWeights`]. Absent entries return
/// `u32::MAX` so they sort *after* every ranked entry under ascending
/// order.
fn rank_for(
    text: &str,
    char_weights: Option<&CharWeights>,
    phrase_weights: Option<&PhraseWeights>,
) -> u32 {
    let is_single = text.chars().take(2).count() == 1;
    if is_single {
        if let (Some(cw), Some(ch)) = (char_weights, text.chars().next()) {
            if let Some(r) = cw.rank(ch) {
                return r;
            }
        }
    } else if let Some(pw) = phrase_weights {
        if let Some(r) = pw.rank(text) {
            return r;
        }
    }
    u32::MAX
}

/// Whether a character is a valid EZ key (would be added to the buffer).
///
/// Accepts: lowercase ASCII letters, ASCII digits, and the EZ punctuation
/// keys `'` `,` `.` `;` `` ` `` `/` `\` `=` `-` `*`.
pub fn is_valid_ez_key(c: char) -> bool {
    matches!(
        c,
        'a'..='z' | '0'..='9'
            | '\'' | ',' | '.' | ';' | '`'
            | '/' | '\\' | '=' | '-' | '*'
    )
}
