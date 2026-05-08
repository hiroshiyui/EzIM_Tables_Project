//! Head/tail picker and word-length-aware encoder.
//!
//! Implements the rules documented in `CLAUDE.md`:
//!
//! ## Per-character code selection (picker)
//!
//! When a character has multiple codes, pick in this priority:
//! 1. The first code with length 1 (single key / 字根鍵).
//! 2. Otherwise, the first code that is not entirely numeric digits.
//! 3. Otherwise, the first code in source-file order.
//!
//! ## Word-length encoding
//!
//! | length | output |
//! | ------ | ------ |
//! | 1      | c1.head + c1.tail            (2 keys) |
//! | 2      | c1.head c1.tail c2.head c2.tail (4 keys) |
//! | 3      | c1.head c2.head c3.head      (3 keys) |
//! | 4      | c1.head c2.head c3.head c4.head (4 keys) |
//! | ≥ 5    | first four chars' heads      (4 keys) |
//!
//! "頭" (head) = first key of the selected code, "尾" (tail) = last key.

use std::fmt;

use crate::error::{Error, Result};
use crate::format::{BinaryTable, EntryView};

/// Errors specific to encoding a string. Wrapped into [`Error`] for callers
/// that handle a single result type.
#[derive(Debug, Clone)]
pub enum EncodeError {
    /// No entry was found for the given character.
    UnknownChar(char),
    /// An entry was found but its code was empty (should not happen for a
    /// validly-built table; defensive).
    EmptyCode(char),
}

impl fmt::Display for EncodeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            EncodeError::UnknownChar(c) => write!(f, "character {c:?} not in table"),
            EncodeError::EmptyCode(c) => write!(f, "character {c:?} maps to an empty code"),
        }
    }
}

impl std::error::Error for EncodeError {}

impl From<EncodeError> for Error {
    fn from(e: EncodeError) -> Self {
        Error::Parse {
            line: 0,
            msg: e.to_string(),
        }
    }
}

/// Head and tail keys (single ASCII chars) for a chosen code.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct HeadTail {
    pub head: char,
    pub tail: char,
}

impl HeadTail {
    /// Derive head/tail from a non-empty code string.
    pub fn from_code(code: &str) -> Option<Self> {
        let mut chars = code.chars();
        let head = chars.next()?;
        let tail = code.chars().next_back().unwrap_or(head);
        Some(Self { head, tail })
    }
}

impl BinaryTable {
    /// Pick the canonical code entry for a single character per the picker
    /// rules, returning the matching [`EntryView`]. Returns `None` if the
    /// character is not in the table.
    pub fn pick_entry_for_char(&self, ch: char) -> Result<Option<EntryView<'_>>> {
        // Encode the char to a UTF-8 buffer, then look up by text.
        let mut buf = [0u8; 4];
        let s = ch.encode_utf8(&mut buf);
        let entries = self.entries_for_text(s)?;
        Ok(pick(&entries).copied())
    }

    /// Pick the canonical (head, tail) for a single character.
    pub fn pick_codes(&self, ch: char) -> Result<Option<HeadTail>> {
        let Some(ev) = self.pick_entry_for_char(ch)? else {
            return Ok(None);
        };
        Ok(HeadTail::from_code(ev.code))
    }

    /// Encode a UTF-8 string per the word-length rules. Returns the EZ key
    /// sequence as a `String` of ASCII characters. Empty input yields `""`.
    pub fn encode(&self, s: &str) -> std::result::Result<String, EncodeError> {
        let chars: Vec<char> = s.chars().collect();
        if chars.is_empty() {
            return Ok(String::new());
        }

        // Resolve each char's HeadTail once.
        let mut ht: Vec<HeadTail> = Vec::with_capacity(chars.len().min(4).max(2));
        let take = chars.len().min(4); // we never need more than the first 4
        let upto = match chars.len() {
            1 | 2 => chars.len(),
            _ => take,
        };
        for &c in &chars[..upto] {
            let ev = self
                .pick_entry_for_char(c)
                .map_err(|_| EncodeError::UnknownChar(c))?
                .ok_or(EncodeError::UnknownChar(c))?;
            let h = HeadTail::from_code(ev.code).ok_or(EncodeError::EmptyCode(c))?;
            ht.push(h);
        }

        let mut out = String::new();
        match chars.len() {
            1 => {
                out.push(ht[0].head);
                out.push(ht[0].tail);
            }
            2 => {
                out.push(ht[0].head);
                out.push(ht[0].tail);
                out.push(ht[1].head);
                out.push(ht[1].tail);
            }
            3 => {
                out.push(ht[0].head);
                out.push(ht[1].head);
                out.push(ht[2].head);
            }
            4 => {
                for h in &ht {
                    out.push(h.head);
                }
            }
            _ => {
                // 5+ chars: first 4 heads
                for h in &ht {
                    out.push(h.head);
                }
            }
        }
        Ok(out)
    }
}

/// Apply the picker priority over a slice of entries (assumed to be all for
/// the same character, in source-file order).
fn pick<'a, 'b>(entries: &'a [EntryView<'b>]) -> Option<&'a EntryView<'b>> {
    // Rule 1: single-key code.
    if let Some(e) = entries.iter().find(|e| e.code.chars().count() == 1) {
        return Some(e);
    }
    // Rule 2: not all-numeric.
    if let Some(e) = entries.iter().find(|e| !e.code_is_all_numeric()) {
        return Some(e);
    }
    // Rule 3: first by source order.
    entries.first()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::format::write;
    use crate::SourceTable;
    use std::io::BufReader;

    /// Source data covering every example needed by the CLAUDE.md spec.
    const SRC: &str = "\
'\t是
''\t比
''\t艷
''2x\t比較
'1\t斷
76\t七
j'\t七
m'\t七
16\t一
m\t一
8\t八
86\t八
8/\t公
,b\t報
ma\t醋
e=\t侮
mx\t髮
b'\t肥
ek\t汰
yb\t病
,'\t包
mq\t磚
e;\t薄
m;x\t礡
";

    fn build_table() -> BinaryTable {
        let st = SourceTable::from_reader(BufReader::new(SRC.as_bytes())).unwrap();
        let bytes = write(&st, SRC.as_bytes());
        BinaryTable::from_bytes(bytes).unwrap()
    }

    // --- picker rules ---------------------------------------------------

    #[test]
    fn picker_rule_1_prefers_single_key() {
        let bt = build_table();
        // 一 has codes "16" and "m" in that order. Single-key "m" wins.
        let h = bt.pick_codes('一').unwrap().unwrap();
        assert_eq!(h, HeadTail { head: 'm', tail: 'm' });
    }

    #[test]
    fn picker_rule_2_avoids_all_numeric() {
        let bt = build_table();
        // 七 has codes ["76", "j'", "m'"]. 76 is all-numeric → skip → "j'" wins.
        let h = bt.pick_codes('七').unwrap().unwrap();
        assert_eq!(h, HeadTail { head: 'j', tail: '\'' });
    }

    #[test]
    fn picker_rule_3_falls_back_to_file_order() {
        let bt = build_table();
        // 比 has only one code "''" → picks it. head=', tail='.
        let h = bt.pick_codes('比').unwrap().unwrap();
        assert_eq!(h, HeadTail { head: '\'', tail: '\'' });
    }

    #[test]
    fn picker_unknown_char_returns_none() {
        let bt = build_table();
        assert!(bt.pick_codes('〇').unwrap().is_none());
    }

    // --- encoding rules ------------------------------------------------

    #[test]
    fn encode_single_char_emits_head_and_tail() {
        let bt = build_table();
        // 一 → m → "mm"
        assert_eq!(bt.encode("一").unwrap(), "mm");
        // 七 → j' → "j'"
        assert_eq!(bt.encode("七").unwrap(), "j'");
        // 八 → 8 → "88"
        assert_eq!(bt.encode("八").unwrap(), "88");
    }

    #[test]
    fn encode_two_char_word_uses_head_and_tail_of_each() {
        let bt = build_table();
        // 比較 → 比(') 比(') 較(... not in our SRC) — instead use a known pair:
        // 比比 → ' ' ' '  → "''''" (head/tail of ' for both)
        assert_eq!(bt.encode("比比").unwrap(), "''''");
        // 七一 → 七(j,') 一(m,m) → "j'mm"
        assert_eq!(bt.encode("七一").unwrap(), "j'mm");
    }

    #[test]
    fn encode_three_char_word_uses_three_heads() {
        let bt = build_table();
        // 八一七 → 8 m j → "8mj"
        assert_eq!(bt.encode("八一七").unwrap(), "8mj");
    }

    #[test]
    fn encode_four_char_word_uses_four_heads() {
        let bt = build_table();
        // 八一七公 → 8 m j 8 → "8mj8"
        assert_eq!(bt.encode("八一七公").unwrap(), "8mj8");
    }

    /// THE canonical example from CLAUDE.md.
    #[test]
    fn encode_canonical_example_baichi_qigongbao() {
        let bt = build_table();
        // 八一七公報 (5 chars) → first 4 heads → 8 m j 8 → "8mj8"
        assert_eq!(bt.encode("八一七公報").unwrap(), "8mj8");
    }

    #[test]
    fn encode_six_or_more_still_takes_only_first_four_heads() {
        let bt = build_table();
        // 八一七公報報 (6 chars) → still first 4 heads → "8mj8"
        assert_eq!(bt.encode("八一七公報報").unwrap(), "8mj8");
    }

    #[test]
    fn encode_unknown_char_errors() {
        let bt = build_table();
        let err = bt.encode("八〇").unwrap_err();
        match err {
            EncodeError::UnknownChar(c) => assert_eq!(c, '〇'),
            _ => panic!("wrong error variant: {err:?}"),
        }
    }

    #[test]
    fn encode_empty_string_is_empty() {
        let bt = build_table();
        assert_eq!(bt.encode("").unwrap(), "");
    }
}
