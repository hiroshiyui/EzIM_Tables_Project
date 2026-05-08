//! Binary `ez.dat` format — writer, reader, on-disk layout.
//!
//! All multi-byte integers are little-endian. The format is deterministic:
//! given the same source `SourceTable`, [`write`] produces byte-for-byte
//! identical output.
//!
//! ## Layout
//!
//! ```text
//! +--------------------------------------------------+
//! | Header (128 B, fixed)                            |
//! +--------------------------------------------------+
//! | String pool : NUL-terminated UTF-8 strings       |
//! +--------------------------------------------------+
//! | Code pool   : NUL-terminated ASCII strings       |
//! +--------------------------------------------------+
//! | Entries     : packed Entry records (12 B each),  |
//! |               ordered by source-file appearance  |
//! +--------------------------------------------------+
//! | by-code idx : u32[n_entries], sorted by          |
//! |               (code, source-order)               |
//! +--------------------------------------------------+
//! | by-text idx : u32[n_entries], sorted by          |
//! |               (text, source-order)               |
//! +--------------------------------------------------+
//! ```
//!
//! ### Header (128 B)
//!
//! | offset | size | field            |
//! | ------:| ----:| ---------------- |
//! |   0    |  8   | magic `EZIMTBL\0`|
//! |   8    |  4   | format_version (u32, currently 1) |
//! |  12    |  4   | flags (u32) |
//! |  16    | 32   | source_hash (FNV-1a 64-bit in bytes 0..8, zeros after; reserved for SHA-256 later) |
//! |  48    |  4   | n_entries (u32) |
//! |  52    |  4   | n_strings (u32) — distinct texts |
//! |  56    |  4   | n_codes (u32) — distinct codes |
//! |  60    |  4   | string_pool_off (u32) |
//! |  64    |  4   | string_pool_len (u32) |
//! |  68    |  4   | code_pool_off (u32) |
//! |  72    |  4   | code_pool_len (u32) |
//! |  76    |  4   | entries_off (u32) |
//! |  80    |  4   | by_code_idx_off (u32) |
//! |  84    |  4   | by_text_idx_off (u32) |
//! |  88    |  4   | file_size (u32) |
//! |  92    | 36   | reserved (zero) |
//!
//! ### Entry (12 B)
//!
//! | offset | size | field |
//! | ------:| ----:| ----- |
//! |  0     | 4    | code_off (u32) |
//! |  4     | 4    | string_off (u32) |
//! |  8     | 1    | code_len (u8) |
//! |  9     | 1    | str_charlen (u8) |
//! |  10    | 2    | flags (u16) — bit 0: is_phrase, bit 1: code_is_all_numeric |

use std::collections::BTreeMap;
use std::fs;
use std::path::Path;

use crate::error::{Error, Result};
use crate::source::{RawEntry, SourceTable};

pub const MAGIC: &[u8; 8] = b"EZIMTBL\0";
pub const FORMAT_VERSION: u32 = 1;
pub const HEADER_SIZE: usize = 128;
pub const ENTRY_SIZE: usize = 12;

pub const FLAG_IS_PHRASE: u16 = 1 << 0;
pub const FLAG_CODE_ALL_NUMERIC: u16 = 1 << 1;

/// Deterministic 64-bit FNV-1a hash. Stored in the first 8 bytes of the
/// 32-byte `source_hash` field; remaining bytes are zero. The field is sized
/// for SHA-256 so we can migrate later without changing the layout.
pub fn fnv1a64(data: &[u8]) -> u64 {
    let mut h: u64 = 0xcbf2_9ce4_8422_2325;
    for &b in data {
        h ^= b as u64;
        h = h.wrapping_mul(0x0000_0100_0000_01B3);
    }
    h
}

// ---------------------------------------------------------------------------
// Writer
// ---------------------------------------------------------------------------

/// Serialize a [`SourceTable`] into the binary format. The `source_bytes`
/// argument is the raw bytes of the source `.txt`, used to compute the
/// content hash stored in the header.
pub fn write(table: &SourceTable, source_bytes: &[u8]) -> Vec<u8> {
    // 1. Build string pool & code pool with first-seen offsets.
    let mut string_pool = Vec::<u8>::new();
    let mut string_off: BTreeMap<&str, u32> = BTreeMap::new();
    let mut code_pool = Vec::<u8>::new();
    let mut code_off: BTreeMap<&str, u32> = BTreeMap::new();

    // First-seen insertion order — deterministic given source order.
    for e in &table.entries {
        if !string_off.contains_key(e.text.as_str()) {
            let off = string_pool.len() as u32;
            string_pool.extend_from_slice(e.text.as_bytes());
            string_pool.push(0);
            string_off.insert(e.text.as_str(), off);
        }
        if !code_off.contains_key(e.code.as_str()) {
            let off = code_pool.len() as u32;
            code_pool.extend_from_slice(e.code.as_bytes());
            code_pool.push(0);
            code_off.insert(e.code.as_str(), off);
        }
    }

    let n_entries = table.entries.len();
    let n_strings = string_off.len();
    let n_codes = code_off.len();

    // 2. Compute section offsets.
    let header_off = 0usize;
    let string_pool_offset = HEADER_SIZE;
    let code_pool_offset = string_pool_offset + string_pool.len();
    let entries_offset = code_pool_offset + code_pool.len();
    let by_code_idx_offset = entries_offset + n_entries * ENTRY_SIZE;
    let by_text_idx_offset = by_code_idx_offset + n_entries * 4;
    let file_size = by_text_idx_offset + n_entries * 4;

    let _ = header_off;

    // 3. Build entries (in original source order) and the two indices.
    struct EntryRec {
        code_off: u32,
        string_off: u32,
        code_len: u8,
        str_charlen: u8,
        flags: u16,
    }

    let mut entries = Vec::<EntryRec>::with_capacity(n_entries);
    for e in &table.entries {
        let mut flags = 0u16;
        if e.is_phrase() {
            flags |= FLAG_IS_PHRASE;
        }
        if e.code_is_all_numeric() {
            flags |= FLAG_CODE_ALL_NUMERIC;
        }
        entries.push(EntryRec {
            code_off: code_off[e.code.as_str()],
            string_off: string_off[e.text.as_str()],
            code_len: e.code.len() as u8,
            str_charlen: e.text.chars().count().min(255) as u8,
            flags,
        });
    }

    // by-code index: stable sort entry indices by code-bytes.
    let mut by_code: Vec<u32> = (0..n_entries as u32).collect();
    by_code.sort_by(|&a, &b| {
        let ea = &table.entries[a as usize];
        let eb = &table.entries[b as usize];
        ea.code.cmp(&eb.code).then_with(|| a.cmp(&b))
    });

    // by-text index: stable sort entry indices by text-bytes.
    let mut by_text: Vec<u32> = (0..n_entries as u32).collect();
    by_text.sort_by(|&a, &b| {
        let ea = &table.entries[a as usize];
        let eb = &table.entries[b as usize];
        ea.text.cmp(&eb.text).then_with(|| a.cmp(&b))
    });

    // 4. Emit bytes.
    let mut out = vec![0u8; file_size];

    // Header.
    out[0..8].copy_from_slice(MAGIC);
    write_u32(&mut out, 8, FORMAT_VERSION);
    write_u32(&mut out, 12, 0); // flags
    let h = fnv1a64(source_bytes);
    out[16..24].copy_from_slice(&h.to_le_bytes());
    // bytes 24..48 already zero.
    write_u32(&mut out, 48, n_entries as u32);
    write_u32(&mut out, 52, n_strings as u32);
    write_u32(&mut out, 56, n_codes as u32);
    write_u32(&mut out, 60, string_pool_offset as u32);
    write_u32(&mut out, 64, string_pool.len() as u32);
    write_u32(&mut out, 68, code_pool_offset as u32);
    write_u32(&mut out, 72, code_pool.len() as u32);
    write_u32(&mut out, 76, entries_offset as u32);
    write_u32(&mut out, 80, by_code_idx_offset as u32);
    write_u32(&mut out, 84, by_text_idx_offset as u32);
    write_u32(&mut out, 88, file_size as u32);
    // bytes 92..128 reserved zero.

    // String pool.
    out[string_pool_offset..string_pool_offset + string_pool.len()]
        .copy_from_slice(&string_pool);
    // Code pool.
    out[code_pool_offset..code_pool_offset + code_pool.len()].copy_from_slice(&code_pool);

    // Entries.
    for (i, e) in entries.iter().enumerate() {
        let off = entries_offset + i * ENTRY_SIZE;
        write_u32(&mut out, off, e.code_off);
        write_u32(&mut out, off + 4, e.string_off);
        out[off + 8] = e.code_len;
        out[off + 9] = e.str_charlen;
        write_u16(&mut out, off + 10, e.flags);
    }

    // by-code index.
    for (i, &idx) in by_code.iter().enumerate() {
        write_u32(&mut out, by_code_idx_offset + i * 4, idx);
    }
    // by-text index.
    for (i, &idx) in by_text.iter().enumerate() {
        write_u32(&mut out, by_text_idx_offset + i * 4, idx);
    }

    out
}

fn write_u32(buf: &mut [u8], off: usize, v: u32) {
    buf[off..off + 4].copy_from_slice(&v.to_le_bytes());
}
fn write_u16(buf: &mut [u8], off: usize, v: u16) {
    buf[off..off + 2].copy_from_slice(&v.to_le_bytes());
}

// ---------------------------------------------------------------------------
// Reader
// ---------------------------------------------------------------------------

/// Owned, parsed view of an `ez.dat` buffer. Cheap to construct (does header
/// validation only); pool/entry access is zero-copy into the underlying bytes.
pub struct BinaryTable {
    bytes: Vec<u8>,
    header: Header,
}

#[derive(Debug, Clone, Copy)]
struct Header {
    n_entries: u32,
    n_strings: u32,
    n_codes: u32,
    string_pool_off: u32,
    string_pool_len: u32,
    code_pool_off: u32,
    code_pool_len: u32,
    entries_off: u32,
    by_code_idx_off: u32,
    by_text_idx_off: u32,
    file_size: u32,
    source_hash_lo: u64,
}

#[derive(Debug, Clone, Copy)]
pub struct EntryView<'a> {
    pub code: &'a str,
    pub text: &'a str,
    pub flags: u16,
}

impl<'a> EntryView<'a> {
    pub fn is_phrase(&self) -> bool {
        self.flags & FLAG_IS_PHRASE != 0
    }
    pub fn code_is_all_numeric(&self) -> bool {
        self.flags & FLAG_CODE_ALL_NUMERIC != 0
    }
}

impl BinaryTable {
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
                "unsupported format_version {format_version} (expected {FORMAT_VERSION})"
            )));
        }
        let header = Header {
            source_hash_lo: read_u64(&bytes, 16),
            n_entries: read_u32(&bytes, 48),
            n_strings: read_u32(&bytes, 52),
            n_codes: read_u32(&bytes, 56),
            string_pool_off: read_u32(&bytes, 60),
            string_pool_len: read_u32(&bytes, 64),
            code_pool_off: read_u32(&bytes, 68),
            code_pool_len: read_u32(&bytes, 72),
            entries_off: read_u32(&bytes, 76),
            by_code_idx_off: read_u32(&bytes, 80),
            by_text_idx_off: read_u32(&bytes, 84),
            file_size: read_u32(&bytes, 88),
        };

        if header.file_size as usize != bytes.len() {
            return Err(parse_err(&format!(
                "file_size {} does not match buffer length {}",
                header.file_size,
                bytes.len()
            )));
        }
        // Bounds check sections.
        let n = header.n_entries as usize;
        let need = header.entries_off as usize + n * ENTRY_SIZE;
        if need > bytes.len() {
            return Err(parse_err("entries section out of bounds"));
        }
        let need = header.by_code_idx_off as usize + n * 4;
        if need > bytes.len() {
            return Err(parse_err("by-code index out of bounds"));
        }
        let need = header.by_text_idx_off as usize + n * 4;
        if need > bytes.len() {
            return Err(parse_err("by-text index out of bounds"));
        }

        Ok(Self { bytes, header })
    }

    pub fn n_entries(&self) -> usize {
        self.header.n_entries as usize
    }
    pub fn n_strings(&self) -> usize {
        self.header.n_strings as usize
    }
    pub fn n_codes(&self) -> usize {
        self.header.n_codes as usize
    }
    pub fn source_hash_lo(&self) -> u64 {
        self.header.source_hash_lo
    }

    fn string_pool(&self) -> &[u8] {
        let s = self.header.string_pool_off as usize;
        let e = s + self.header.string_pool_len as usize;
        &self.bytes[s..e]
    }
    fn code_pool(&self) -> &[u8] {
        let s = self.header.code_pool_off as usize;
        let e = s + self.header.code_pool_len as usize;
        &self.bytes[s..e]
    }

    fn read_cstr<'a>(pool: &'a [u8], off: u32, max_len: u8) -> Result<&'a str> {
        let off = off as usize;
        if off + max_len as usize >= pool.len() {
            return Err(parse_err("string offset/length out of bounds"));
        }
        let bytes = &pool[off..off + max_len as usize];
        std::str::from_utf8(bytes).map_err(|_| parse_err("invalid UTF-8 in string pool"))
    }

    /// Get an entry by its source-order index.
    pub fn entry(&self, idx: usize) -> Result<EntryView<'_>> {
        if idx >= self.n_entries() {
            return Err(parse_err("entry index out of range"));
        }
        let off = self.header.entries_off as usize + idx * ENTRY_SIZE;
        let code_off = read_u32(&self.bytes, off);
        let string_off = read_u32(&self.bytes, off + 4);
        let code_len = self.bytes[off + 8];
        let str_charlen = self.bytes[off + 9];
        let _ = str_charlen;
        let flags = read_u16(&self.bytes, off + 10);

        let code = Self::read_cstr(self.code_pool(), code_off, code_len)?;
        // For texts we need a UTF-8 byte length, not the char count we stored.
        // Recover it by scanning to NUL.
        let text = read_cstr_to_nul(self.string_pool(), string_off as usize)?;

        Ok(EntryView { code, text, flags })
    }

    /// Iterate all entries in source-file order.
    pub fn iter(&self) -> impl Iterator<Item = Result<EntryView<'_>>> {
        (0..self.n_entries()).map(move |i| self.entry(i))
    }

    /// All entries that match `code` exactly, in source-file order.
    pub fn entries_for_code(&self, code: &str) -> Result<Vec<EntryView<'_>>> {
        let n = self.n_entries();
        let by_code_off = self.header.by_code_idx_off as usize;
        let probe = |i: usize| -> Result<&str> {
            let entry_idx = read_u32(&self.bytes, by_code_off + i * 4) as usize;
            Ok(self.entry(entry_idx)?.code)
        };
        // Manual lower-bound binary search.
        let (mut lo, mut hi) = (0usize, n);
        while lo < hi {
            let mid = (lo + hi) / 2;
            let c = probe(mid)?;
            if c < code {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }
        let start = lo;
        // Walk forward while equal.
        let mut hits = Vec::new();
        let mut i = start;
        while i < n {
            let entry_idx = read_u32(&self.bytes, by_code_off + i * 4) as usize;
            let ev = self.entry(entry_idx)?;
            if ev.code != code {
                break;
            }
            hits.push((entry_idx, ev));
            i += 1;
        }
        // Sort hits by source-order entry_idx so the result respects file order.
        hits.sort_by_key(|&(idx, _)| idx);
        Ok(hits.into_iter().map(|(_, ev)| ev).collect())
    }

    /// All entries that match `text` exactly (used for char→codes), in source order.
    pub fn entries_for_text(&self, text: &str) -> Result<Vec<EntryView<'_>>> {
        let n = self.n_entries();
        let by_text_off = self.header.by_text_idx_off as usize;
        let probe = |i: usize| -> Result<&str> {
            let entry_idx = read_u32(&self.bytes, by_text_off + i * 4) as usize;
            Ok(self.entry(entry_idx)?.text)
        };
        let (mut lo, mut hi) = (0usize, n);
        while lo < hi {
            let mid = (lo + hi) / 2;
            let t = probe(mid)?;
            if t < text {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }
        let mut hits = Vec::new();
        let mut i = lo;
        while i < n {
            let entry_idx = read_u32(&self.bytes, by_text_off + i * 4) as usize;
            let ev = self.entry(entry_idx)?;
            if ev.text != text {
                break;
            }
            hits.push((entry_idx, ev));
            i += 1;
        }
        hits.sort_by_key(|&(idx, _)| idx);
        Ok(hits.into_iter().map(|(_, ev)| ev).collect())
    }
}

// Parse helpers.
fn read_u16(buf: &[u8], off: usize) -> u16 {
    u16::from_le_bytes(buf[off..off + 2].try_into().unwrap())
}
fn read_u32(buf: &[u8], off: usize) -> u32 {
    u32::from_le_bytes(buf[off..off + 4].try_into().unwrap())
}
fn read_u64(buf: &[u8], off: usize) -> u64 {
    u64::from_le_bytes(buf[off..off + 8].try_into().unwrap())
}

fn read_cstr_to_nul(pool: &[u8], off: usize) -> Result<&str> {
    if off >= pool.len() {
        return Err(parse_err("string offset out of bounds"));
    }
    let rest = &pool[off..];
    let nul = rest
        .iter()
        .position(|&b| b == 0)
        .ok_or_else(|| parse_err("unterminated string in pool"))?;
    std::str::from_utf8(&rest[..nul]).map_err(|_| parse_err("invalid UTF-8 in string pool"))
}

fn parse_err(msg: &str) -> Error {
    Error::Parse {
        line: 0,
        msg: msg.to_string(),
    }
}

/// Convenience: round-trip helper for callers (and tests) that want a
/// [`SourceTable`]-equivalent flat list back from a [`BinaryTable`].
pub fn collect_raw(bt: &BinaryTable) -> Result<Vec<RawEntry>> {
    let mut out = Vec::with_capacity(bt.n_entries());
    for (i, ev) in bt.iter().enumerate() {
        let ev = ev?;
        out.push(RawEntry {
            code: ev.code.to_string(),
            text: ev.text.to_string(),
            line: i + 1, // line numbers aren't preserved across the binary boundary
        });
    }
    Ok(out)
}
