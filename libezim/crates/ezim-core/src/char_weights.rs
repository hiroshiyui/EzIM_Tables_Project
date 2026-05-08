//! Binary `char-weights.dat` — per-character usage-frequency rank.
//!
//! Each entry maps a Unicode codepoint to a `u32` *rank* (1-based, smaller =
//! more frequent). The file is sorted by codepoint so lookups are O(log n)
//! via binary search. Characters not in the file have no rank — callers
//! should treat them as least-priority.
//!
//! ## Layout
//!
//! ```text
//! +--------------------------------------------------+
//! | Header (64 B, fixed)                             |
//! +--------------------------------------------------+
//! | Entries : packed (codepoint u32, rank u32)       |
//! |           sorted by codepoint ascending          |
//! +--------------------------------------------------+
//! ```
//!
//! ### Header (64 B)
//!
//! | offset | size | field                                     |
//! | ------:| ----:| ----------------------------------------- |
//! |  0     | 8    | magic `EZIMWGT\0`                         |
//! |  8     | 4    | format_version (u32, currently 1)         |
//! | 12     | 4    | flags (u32)                               |
//! | 16     | 32   | source_hash (FNV-1a 64-bit in bytes 0..8) |
//! | 48     | 4    | n_entries (u32)                           |
//! | 52     | 4    | entries_off (u32, currently 64)           |
//! | 56     | 4    | file_size (u32)                           |
//! | 60     | 4    | reserved (zero)                           |

use std::fs;
use std::path::Path;

use crate::error::{Error, Result};
use crate::format::fnv1a64;

pub const MAGIC: &[u8; 8] = b"EZIMWGT\0";
pub const FORMAT_VERSION: u32 = 1;
pub const HEADER_SIZE: usize = 64;
pub const ENTRY_SIZE: usize = 8;

/// Serialize a list of (char, rank) entries. The list does not need to be
/// pre-sorted; this function sorts and dedupes (keeping the lowest rank).
pub fn write(entries: &[(char, u32)], source_bytes: &[u8]) -> Vec<u8> {
    // Sort + dedupe by codepoint, keeping smallest rank on collision.
    let mut owned: Vec<(u32, u32)> = entries
        .iter()
        .map(|(c, r)| (*c as u32, *r))
        .collect();
    owned.sort_by(|a, b| a.0.cmp(&b.0).then_with(|| a.1.cmp(&b.1)));
    owned.dedup_by_key(|e| e.0);

    let n = owned.len();
    let entries_off = HEADER_SIZE;
    let file_size = entries_off + n * ENTRY_SIZE;

    let mut out = vec![0u8; file_size];
    out[0..8].copy_from_slice(MAGIC);
    write_u32(&mut out, 8, FORMAT_VERSION);
    write_u32(&mut out, 12, 0);
    let h = fnv1a64(source_bytes);
    out[16..24].copy_from_slice(&h.to_le_bytes());
    write_u32(&mut out, 48, n as u32);
    write_u32(&mut out, 52, entries_off as u32);
    write_u32(&mut out, 56, file_size as u32);

    for (i, (cp, rank)) in owned.iter().enumerate() {
        let off = entries_off + i * ENTRY_SIZE;
        write_u32(&mut out, off, *cp);
        write_u32(&mut out, off + 4, *rank);
    }

    out
}

/// Read-only view over a `char-weights.dat` buffer.
pub struct CharWeights {
    bytes: Vec<u8>,
    n_entries: usize,
    entries_off: usize,
    source_hash_lo: u64,
}

impl CharWeights {
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
        let file_size = read_u32(&bytes, 56) as usize;
        let source_hash_lo = read_u64(&bytes, 16);
        if file_size != bytes.len() {
            return Err(parse_err("file_size mismatch"));
        }
        if entries_off + n_entries * ENTRY_SIZE > bytes.len() {
            return Err(parse_err("entries section out of bounds"));
        }
        Ok(Self {
            bytes,
            n_entries,
            entries_off,
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
        let cp = read_u32(&self.bytes, off);
        let rank = read_u32(&self.bytes, off + 4);
        (cp, rank)
    }

    /// Returns the rank for `ch` if present (1-based; smaller = more frequent).
    pub fn rank(&self, ch: char) -> Option<u32> {
        let needle = ch as u32;
        let (mut lo, mut hi) = (0usize, self.n_entries);
        while lo < hi {
            let mid = (lo + hi) / 2;
            let (cp, rank) = self.entry_at(mid);
            if cp < needle {
                lo = mid + 1;
            } else if cp > needle {
                hi = mid;
            } else {
                return Some(rank);
            }
        }
        None
    }

    /// Iterate all (char, rank) pairs in codepoint order.
    pub fn iter(&self) -> impl Iterator<Item = (char, u32)> + '_ {
        (0..self.n_entries).map(move |i| {
            let (cp, rank) = self.entry_at(i);
            (char::from_u32(cp).unwrap_or('\u{FFFD}'), rank)
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
        let entries = vec![('的', 1u32), ('一', 2), ('是', 3)];
        let bytes = write(&entries, b"source");
        let cw = CharWeights::from_bytes(bytes).unwrap();
        assert_eq!(cw.n_entries(), 3);
        assert_eq!(cw.rank('的'), Some(1));
        assert_eq!(cw.rank('一'), Some(2));
        assert_eq!(cw.rank('是'), Some(3));
        assert_eq!(cw.rank('〇'), None);
    }

    #[test]
    fn dedupe_keeps_smallest_rank() {
        let entries = vec![('的', 5), ('的', 1), ('的', 3)];
        let bytes = write(&entries, b"x");
        let cw = CharWeights::from_bytes(bytes).unwrap();
        assert_eq!(cw.n_entries(), 1);
        assert_eq!(cw.rank('的'), Some(1));
    }

    #[test]
    fn rejects_bad_magic() {
        let mut buf = vec![0u8; 128];
        buf[0..8].copy_from_slice(b"NOTEZIMW");
        assert!(CharWeights::from_bytes(buf).is_err());
    }
}
