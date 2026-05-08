//! Key event types accepted by [`crate::Session::handle_key`].

/// Input event from the host IME framework.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Key {
    /// A printable key. Only valid EZ keys (lowercase letters, digits,
    /// and EZ punctuation) modify the buffer; other chars pass through.
    Char(char),
    /// Erase the last key from the buffer.
    Backspace,
    /// Cancel the current composition.
    Escape,
    /// Commit the first candidate (or no-op if buffer is empty).
    Space,
    /// Same as `Space` for now; reserved for distinct semantics later.
    Enter,
    /// Select a candidate by 1-based index on the current page (e.g. 1..=9).
    Select(u8),
    /// Advance to the next page of candidates.
    PageNext,
    /// Go to the previous page of candidates.
    PagePrev,
}
