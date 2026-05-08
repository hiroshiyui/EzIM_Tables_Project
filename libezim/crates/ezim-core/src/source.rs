//! Parser for `ez.orig-utf8.txt` and friends.
//!
//! Format: one entry per line, `<code>\t<string>\n`.
//!  - `code` is ASCII (a–z, digits, and the punctuation keys `'` `,` `.` `;` `` ` `` `/` `\` `=` `-` `*`).
//!  - `string` is one or more UTF-8 characters (single char or a phrase).
//!
//! File order is significant — rule #3 of the picker depends on it — so the
//! parser preserves it exactly.

use std::fs::File;
use std::io::{BufRead, BufReader, Read};
use std::path::Path;

use crate::error::{Error, Result};

#[derive(Debug, Clone)]
pub struct RawEntry {
    pub code: String,
    pub text: String,
    /// 1-based line number in the source file.
    pub line: usize,
}

impl RawEntry {
    pub fn char_len(&self) -> usize {
        self.text.chars().count()
    }

    pub fn is_phrase(&self) -> bool {
        self.char_len() > 1
    }

    pub fn code_is_all_numeric(&self) -> bool {
        !self.code.is_empty() && self.code.bytes().all(|b| b.is_ascii_digit())
    }
}

#[derive(Debug, Default, Clone)]
pub struct SourceTable {
    pub entries: Vec<RawEntry>,
}

impl SourceTable {
    pub fn open<P: AsRef<Path>>(path: P) -> Result<Self> {
        let f = File::open(path)?;
        Self::from_reader(BufReader::new(f))
    }

    pub fn from_reader<R: Read>(reader: BufReader<R>) -> Result<Self> {
        let mut entries = Vec::new();
        for (i, line) in reader.lines().enumerate() {
            let line_no = i + 1;
            let line = line?;
            // Skip blank lines silently; they aren't expected but shouldn't hard-fail.
            if line.is_empty() {
                continue;
            }
            let Some((code, text)) = line.split_once('\t') else {
                return Err(Error::Parse {
                    line: line_no,
                    msg: format!("missing TAB separator in {line:?}"),
                });
            };
            if code.is_empty() {
                return Err(Error::Parse {
                    line: line_no,
                    msg: "empty code".into(),
                });
            }
            if text.is_empty() {
                return Err(Error::Parse {
                    line: line_no,
                    msg: "empty text".into(),
                });
            }
            if !code.is_ascii() {
                return Err(Error::Parse {
                    line: line_no,
                    msg: format!("non-ASCII code {code:?}"),
                });
            }
            entries.push(RawEntry {
                code: code.to_string(),
                text: text.to_string(),
                line: line_no,
            });
        }
        Ok(Self { entries })
    }

    pub fn len(&self) -> usize {
        self.entries.len()
    }

    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn parse(s: &str) -> Result<SourceTable> {
        SourceTable::from_reader(BufReader::new(s.as_bytes()))
    }

    #[test]
    fn parses_simple_lines() {
        let t = parse("'\t是\n''\t比\n76\t七\n").unwrap();
        assert_eq!(t.len(), 3);
        assert_eq!(t.entries[0].code, "'");
        assert_eq!(t.entries[0].text, "是");
        assert!(t.entries[2].code_is_all_numeric());
        assert!(!t.entries[0].code_is_all_numeric());
    }

    #[test]
    fn detects_phrases() {
        let t = parse("''2x\t比較\n8/\t公\n").unwrap();
        assert!(t.entries[0].is_phrase());
        assert_eq!(t.entries[0].char_len(), 2);
        assert!(!t.entries[1].is_phrase());
    }

    #[test]
    fn rejects_missing_tab() {
        let err = parse("nofield\n").unwrap_err();
        assert!(matches!(err, Error::Parse { .. }));
    }

    #[test]
    fn rejects_empty_code() {
        assert!(parse("\tfoo\n").is_err());
    }
}
