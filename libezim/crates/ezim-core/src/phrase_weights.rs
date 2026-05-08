//! Binary `phrase-weights.dat` — per-phrase usage-frequency rank.
//!
//! Like [`crate::char_weights`] but keyed by variable-length UTF-8 strings
//! (詞目). Entries are sorted by string bytes for O(log n) binary search.
//!
//! ## Layout
//!
//! ```text
//! +--------------------------------------------------+
//! | Header (96 B, fixed)                             |
//! +--------------------------------------------------+
//! | Entries : packed (text_off u32, rank u32)        |
//! |           sorted by text bytes ascending         |
//! +--------------------------------------------------+
//! | String pool : NUL-terminated UTF-8 strings       |
//! +--------------------------------------------------+
//! ```
//!
//! ### Header (96 B)
//!
//! | offset | size | field |
//! | ------:| ----:| ----- |
//! |  0     | 8    | magic `EZIMPWT\0` |
//! |  8     | 4    | format_version (u32, currently 1) |
//! | 12     | 4    | flags (u32) |
//! | 16     | 32   | source_hash (FNV-1a 64 in bytes 0..8) |
//! | 48     | 4    | n_entries (u32) |
//! | 52     | 4    | entries_off (u32) |
//! | 56     | 4    | string_pool_off (u32) |
//! | 60     | 4    | string_pool_len (u32) |
//! | 64     | 4    | file_size (u32) |
//! | 68     | 28   | reserved |

use std::collections::BTreeMap;
use std::fs;
use std::path::Path;

use crate::error::{Error, Result};
use crate::format::fnv1a64;

pub const MAGIC: &[u8; 8] = b"EZIMPWT\0";
pub const FORMAT_VERSION: u32 = 1;
pub const HEADER_SIZE: usize = 96;
pub const ENTRY_SIZE: usize = 8;

/// Serialize a list of (phrase, rank) entries. Sorts and dedupes on
/// collision (keeps the smallest rank).
pub fn write(entries: &[(&str, u32)], source_bytes: &[u8]) -> Vec<u8> {
    // Dedupe: lowest rank wins.
    let mut by_text: BTreeMap<&str, u32> = BTreeMap::new();
    for (text, rank) in entries {
        by_text
            .entry(text)
            .and_modify(|r| {
                if *rank < *r {
                    *r = *rank
                }
            })
            .or_insert(*rank);
    }

    let n = by_text.len();
    let entries_off = HEADER_SIZE;
    let string_pool_off = entries_off + n * ENTRY_SIZE;

    // Build string pool & record offsets in iteration order (sorted by text
    // bytes, since BTreeMap iterates in key order).
    let mut string_pool = Vec::<u8>::new();
    let mut entry_records: Vec<(u32, u32)> = Vec::with_capacity(n);
    for (text, rank) in &by_text {
        let off = string_pool.len() as u32;
        string_pool.extend_from_slice(text.as_bytes());
        string_pool.push(0);
        entry_records.push((off, *rank));
    }

    let file_size = string_pool_off + string_pool.len();

    let mut out = vec![0u8; file_size];
    out[0..8].copy_from_slice(MAGIC);
    write_u32(&mut out, 8, FORMAT_VERSION);
    write_u32(&mut out, 12, 0);
    let h = fnv1a64(source_bytes);
    out[16..24].copy_from_slice(&h.to_le_bytes());
    write_u32(&mut out, 48, n as u32);
    write_u32(&mut out, 52, entries_off as u32);
    write_u32(&mut out, 56, string_pool_off as u32);
    write_u32(&mut out, 60, string_pool.len() as u32);
    write_u32(&mut out, 64, file_size as u32);

    for (i, (text_off, rank)) in entry_records.iter().enumerate() {
        let off = entries_off + i * ENTRY_SIZE;
        write_u32(&mut out, off, *text_off);
        write_u32(&mut out, off + 4, *rank);
    }
    out[string_pool_off..string_pool_off + string_pool.len()].copy_from_slice(&string_pool);

    out
}

/// Read-only view over a `phrase-weights.dat` buffer.
pub struct PhraseWeights {
    bytes: Vec<u8>,
    n_entries: usize,
    entries_off: usize,
    string_pool_off: usize,
    string_pool_len: usize,
    source_hash_lo: u64,
}

impl PhraseWeights {
    pub fn open<P: AsRef<Path>>(path: P) -> Result<Self> {
        let bytes = fs::read(path)?;
        Self::from_bytes(bytes)
    }

    pub fn from_bytes(bytes: Vec<u8>) -> Result<Self> {
        if bytes.len() < HEADER_SIZE {
            return Err(parse_err("file shorter than header"));
        }
        if &bytes[0..8] != MAGIC {
            return Err(parse_err("bad magic"));
        }
        let format_version = read_u32(&bytes, 8);
        if format_version != FORMAT_VERSION {
            return Err(parse_err(&format!(
                "unsupported format_version {format_version}"
            )));
        }
        let n_entries = read_u32(&bytes, 48) as usize;
        let entries_off = read_u32(&bytes, 52) as usize;
        let string_pool_off = read_u32(&bytes, 56) as usize;
        let string_pool_len = read_u32(&bytes, 60) as usize;
        let file_size = read_u32(&bytes, 64) as usize;
        let source_hash_lo = read_u64(&bytes, 16);
        if file_size != bytes.len() {
            return Err(parse_err("file_size mismatch"));
        }
        if entries_off + n_entries * ENTRY_SIZE > bytes.len() {
            return Err(parse_err("entries section out of bounds"));
        }
        if string_pool_off + string_pool_len > bytes.len() {
            return Err(parse_err("string pool out of bounds"));
        }
        Ok(Self {
            bytes,
            n_entries,
            entries_off,
            string_pool_off,
            string_pool_len,
            source_hash_lo,
        })
    }

    pub fn n_entries(&self) -> usize {
        self.n_entries
    }
    pub fn source_hash_lo(&self) -> u64 {
        self.source_hash_lo
    }

    fn entry_at(&self, i: usize) -> (u32, u32) {
        let off = self.entries_off + i * ENTRY_SIZE;
        let text_off = read_u32(&self.bytes, off);
        let rank = read_u32(&self.bytes, off + 4);
        (text_off, rank)
    }

    fn text_at(&self, text_off: u32) -> Option<&str> {
        let pool_start = self.string_pool_off;
        let pool_end = pool_start + self.string_pool_len;
        let start = pool_start + text_off as usize;
        if start >= pool_end {
            return None;
        }
        let nul = self.bytes[start..pool_end].iter().position(|&b| b == 0)?;
        std::str::from_utf8(&self.bytes[start..start + nul]).ok()
    }

    /// Rank of a phrase (1-based; smaller = more frequent).
    pub fn rank(&self, phrase: &str) -> Option<u32> {
        let needle = phrase.as_bytes();
        let (mut lo, mut hi) = (0usize, self.n_entries);
        while lo < hi {
            let mid = (lo + hi) / 2;
            let (text_off, rank) = self.entry_at(mid);
            let mid_text = self.text_at(text_off)?;
            match mid_text.as_bytes().cmp(needle) {
                std::cmp::Ordering::Less => lo = mid + 1,
                std::cmp::Ordering::Greater => hi = mid,
                std::cmp::Ordering::Equal => return Some(rank),
            }
        }
        None
    }

    pub fn iter(&self) -> impl Iterator<Item = (&str, u32)> + '_ {
        (0..self.n_entries).filter_map(move |i| {
            let (text_off, rank) = self.entry_at(i);
            self.text_at(text_off).map(|t| (t, rank))
        })
    }
}

fn write_u32(buf: &mut [u8], off: usize, v: u32) {
    buf[off..off + 4].copy_from_slice(&v.to_le_bytes());
}
fn read_u32(buf: &[u8], off: usize) -> u32 {
    u32::from_le_bytes(buf[off..off + 4].try_into().unwrap())
}
fn read_u64(buf: &[u8], off: usize) -> u64 {
    u64::from_le_bytes(buf[off..off + 8].try_into().unwrap())
}
fn parse_err(msg: &str) -> Error {
    Error::Parse {
        line: 0,
        msg: msg.to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn roundtrip_basic() {
        let entries = vec![("的", 1u32), ("一", 3), ("比較", 2)];
        let bytes = write(&entries, b"src");
        let pw = PhraseWeights::from_bytes(bytes).unwrap();
        assert_eq!(pw.n_entries(), 3);
        assert_eq!(pw.rank("的"), Some(1));
        assert_eq!(pw.rank("比較"), Some(2));
        assert_eq!(pw.rank("一"), Some(3));
        assert_eq!(pw.rank("八一七公報"), None);
    }

    #[test]
    fn dedupe_keeps_smallest_rank() {
        let entries = vec![("的", 9), ("的", 1), ("的", 5)];
        let bytes = write(&entries, b"x");
        let pw = PhraseWeights::from_bytes(bytes).unwrap();
        assert_eq!(pw.n_entries(), 1);
        assert_eq!(pw.rank("的"), Some(1));
    }

    #[test]
    fn iter_yields_sorted_by_bytes() {
        let entries = vec![("比較", 2), ("一", 3), ("的", 1)];
        let bytes = write(&entries, b"x");
        let pw = PhraseWeights::from_bytes(bytes).unwrap();
        let texts: Vec<&str> = pw.iter().map(|(t, _)| t).collect();
        let mut sorted = texts.clone();
        sorted.sort();
        assert_eq!(texts, sorted);
    }

    #[test]
    fn rejects_bad_magic() {
        let mut buf = vec![0u8; 200];
        buf[0..8].copy_from_slice(b"NOPHRASE");
        assert!(PhraseWeights::from_bytes(buf).is_err());
    }
}
