//! libezim C ABI (Phase 2 — lookup surface).
//!
//! Conventions:
//!  - All strings are UTF-8, NUL-terminated.
//!  - Out-strings allocated by the library must be freed with
//!    [`ezim_string_free`]. Iterators must be freed with
//!    [`ezim_cand_free`]. Tables with [`ezim_table_free`].
//!  - Every fallible function returns an [`EzimStatus`] (i32).
//!  - On error, a thread-local message is set; retrieve via
//!    [`ezim_last_error`]. The pointer is valid until the next call
//!    on the same thread that produces an error.

#![deny(unsafe_op_in_unsafe_fn)]

use std::cell::RefCell;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_void};
use std::path::PathBuf;
use std::ptr;

use ezim_core::format::BinaryTable;

pub mod session;

// ---------------------------------------------------------------------------
// Versioning
// ---------------------------------------------------------------------------

/// Semantic ABI version. Bump the major if any signature changes incompatibly.
pub const EZIM_ABI_VERSION: u32 = 1;

const EZIM_VERSION_STRING: &str = concat!("libezim ", env!("CARGO_PKG_VERSION"), "\0");

/// Returns the ABI version of this library. Callers should `static_assert`
/// or check at runtime that it matches the version they were compiled
/// against.
#[unsafe(no_mangle)]
pub extern "C" fn ezim_abi_version() -> u32 {
    EZIM_ABI_VERSION
}

/// Returns a NUL-terminated, library-owned version string. Do not free.
#[unsafe(no_mangle)]
pub extern "C" fn ezim_version_string() -> *const c_char {
    EZIM_VERSION_STRING.as_ptr() as *const c_char
}

// ---------------------------------------------------------------------------
// Status codes
// ---------------------------------------------------------------------------

pub type EzimStatus = c_int;
pub const EZIM_OK: EzimStatus = 0;
pub const EZIM_ERR_INVALID: EzimStatus = -1; // null pointer, bad UTF-8, etc.
pub const EZIM_ERR_IO: EzimStatus = -2;
pub const EZIM_ERR_FORMAT: EzimStatus = -3;
pub const EZIM_ERR_NOT_FOUND: EzimStatus = -4;
pub const EZIM_ERR_ENCODE: EzimStatus = -5;
pub const EZIM_ERR_INTERNAL: EzimStatus = -99;

// ---------------------------------------------------------------------------
// Thread-local error
// ---------------------------------------------------------------------------

thread_local! {
    static LAST_ERROR: RefCell<Option<CString>> = const { RefCell::new(None) };
}

fn set_last_error<S: Into<Vec<u8>>>(msg: S) {
    let mut bytes = msg.into();
    // Avoid embedded NULs.
    bytes.retain(|&b| b != 0);
    let c = CString::new(bytes).unwrap_or_else(|_| CString::new("error").unwrap());
    LAST_ERROR.with(|slot| {
        *slot.borrow_mut() = Some(c);
    });
}

fn clear_last_error() {
    LAST_ERROR.with(|slot| {
        *slot.borrow_mut() = None;
    });
}

/// Returns the last error message set on this thread, or an empty string.
/// The returned pointer is valid until the next library call on this thread
/// that updates the error state.
#[unsafe(no_mangle)]
pub extern "C" fn ezim_last_error() -> *const c_char {
    LAST_ERROR.with(|slot| match slot.borrow().as_ref() {
        Some(cs) => cs.as_ptr(),
        None => c"".as_ptr(),
    })
}

// ---------------------------------------------------------------------------
// EzimTable
// ---------------------------------------------------------------------------

/// Opaque handle around a [`BinaryTable`].
pub struct EzimTable {
    inner: BinaryTable,
}

impl EzimTable {
    /// Internal: pointer to the inner table for use by `session` module's
    /// lifetime fudge. Not exported to C.
    pub(crate) fn inner_ptr(&self) -> *const BinaryTable {
        &self.inner as *const BinaryTable
    }
}

/// Open a binary `.dat` table.
///
/// # Safety
/// `path` must be a valid NUL-terminated UTF-8 string. `out` must be a valid
/// pointer to a writable `*mut EzimTable` location.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_table_open(
    path: *const c_char,
    out: *mut *mut EzimTable,
) -> EzimStatus {
    if path.is_null() || out.is_null() {
        set_last_error("null pointer to ezim_table_open");
        return EZIM_ERR_INVALID;
    }
    clear_last_error();
    let cs = unsafe { CStr::from_ptr(path) };
    let s = match cs.to_str() {
        Ok(s) => s,
        Err(_) => {
            set_last_error("path is not valid UTF-8");
            return EZIM_ERR_INVALID;
        }
    };
    match BinaryTable::open(PathBuf::from(s)) {
        Ok(bt) => {
            let boxed = Box::new(EzimTable { inner: bt });
            unsafe { *out = Box::into_raw(boxed) };
            EZIM_OK
        }
        Err(e) => {
            set_last_error(format!("open failed: {e}"));
            // Best-effort classification.
            if matches!(e, ezim_core::Error::Io(_)) {
                EZIM_ERR_IO
            } else {
                EZIM_ERR_FORMAT
            }
        }
    }
}

/// Free a table handle. Safe to call with NULL.
///
/// # Safety
/// `t` must have been returned by [`ezim_table_open`] and not freed yet.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_table_free(t: *mut EzimTable) {
    if !t.is_null() {
        let _ = unsafe { Box::from_raw(t) };
    }
}

// ---------------------------------------------------------------------------
// Encode
// ---------------------------------------------------------------------------

/// Encode a UTF-8 string into its EZ key sequence.
///
/// On success, `*out_codes` is set to a heap-allocated NUL-terminated string
/// the caller must free with [`ezim_string_free`].
///
/// # Safety
/// All pointers must be valid. `utf8` must be NUL-terminated UTF-8.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_encode(
    t: *const EzimTable,
    utf8: *const c_char,
    out_codes: *mut *mut c_char,
) -> EzimStatus {
    if t.is_null() || utf8.is_null() || out_codes.is_null() {
        set_last_error("null pointer to ezim_encode");
        return EZIM_ERR_INVALID;
    }
    clear_last_error();
    let table = unsafe { &(*t).inner };
    let cs = unsafe { CStr::from_ptr(utf8) };
    let s = match cs.to_str() {
        Ok(s) => s,
        Err(_) => {
            set_last_error("input is not valid UTF-8");
            return EZIM_ERR_INVALID;
        }
    };
    match table.encode(s) {
        Ok(out) => {
            let cs = match CString::new(out) {
                Ok(cs) => cs,
                Err(_) => {
                    set_last_error("internal NUL byte in encoded output");
                    return EZIM_ERR_INTERNAL;
                }
            };
            unsafe { *out_codes = cs.into_raw() };
            EZIM_OK
        }
        Err(e) => {
            set_last_error(format!("{e}"));
            EZIM_ERR_ENCODE
        }
    }
}

// ---------------------------------------------------------------------------
// Pick codes
// ---------------------------------------------------------------------------

/// Pick the canonical (head, tail) keys for a single Unicode codepoint.
///
/// On success, `*out_head_tail` is a heap-allocated NUL-terminated 3-byte
/// string `"ht\0"` (head, tail). Free with [`ezim_string_free`]. If the
/// character is not in the table, returns `EZIM_ERR_NOT_FOUND`.
///
/// # Safety
/// All pointers must be valid.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_pick_codes(
    t: *const EzimTable,
    codepoint: u32,
    out_head_tail: *mut *mut c_char,
) -> EzimStatus {
    if t.is_null() || out_head_tail.is_null() {
        set_last_error("null pointer to ezim_pick_codes");
        return EZIM_ERR_INVALID;
    }
    clear_last_error();
    let table = unsafe { &(*t).inner };
    let Some(ch) = char::from_u32(codepoint) else {
        set_last_error("invalid Unicode codepoint");
        return EZIM_ERR_INVALID;
    };
    match table.pick_codes(ch) {
        Ok(Some(ht)) => {
            let buf = format!("{}{}", ht.head, ht.tail);
            let cs = CString::new(buf).expect("ASCII head/tail");
            unsafe { *out_head_tail = cs.into_raw() };
            EZIM_OK
        }
        Ok(None) => {
            set_last_error(format!("character {ch:?} not in table"));
            EZIM_ERR_NOT_FOUND
        }
        Err(e) => {
            set_last_error(format!("{e}"));
            EZIM_ERR_INTERNAL
        }
    }
}

// ---------------------------------------------------------------------------
// Lookup iterator
// ---------------------------------------------------------------------------

/// Opaque iterator over candidate strings for a code lookup.
pub struct EzimCandIter {
    items: Vec<CString>,
    cursor: usize,
}

/// Look up all candidate strings for an EZ key sequence.
///
/// On success, `*out` is set to an iterator handle the caller must free
/// with [`ezim_cand_free`].
///
/// # Safety
/// All pointers must be valid. `code` must be NUL-terminated ASCII.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_lookup(
    t: *const EzimTable,
    code: *const c_char,
    out: *mut *mut EzimCandIter,
) -> EzimStatus {
    if t.is_null() || code.is_null() || out.is_null() {
        set_last_error("null pointer to ezim_lookup");
        return EZIM_ERR_INVALID;
    }
    clear_last_error();
    let table = unsafe { &(*t).inner };
    let cs = unsafe { CStr::from_ptr(code) };
    let s = match cs.to_str() {
        Ok(s) => s,
        Err(_) => {
            set_last_error("code is not valid UTF-8");
            return EZIM_ERR_INVALID;
        }
    };
    let entries = match table.entries_for_code(s) {
        Ok(v) => v,
        Err(e) => {
            set_last_error(format!("{e}"));
            return EZIM_ERR_FORMAT;
        }
    };
    let items: Vec<CString> = entries
        .into_iter()
        .filter_map(|e| CString::new(e.text).ok())
        .collect();
    let it = Box::new(EzimCandIter { items, cursor: 0 });
    unsafe { *out = Box::into_raw(it) };
    EZIM_OK
}

/// Returns the next candidate as a NUL-terminated UTF-8 string, or NULL when
/// the iterator is exhausted. The pointer is valid until [`ezim_cand_free`]
/// is called.
///
/// # Safety
/// `it` must be a valid pointer returned by [`ezim_lookup`].
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_cand_next(it: *mut EzimCandIter) -> *const c_char {
    if it.is_null() {
        return ptr::null();
    }
    let it = unsafe { &mut *it };
    if it.cursor >= it.items.len() {
        return ptr::null();
    }
    let p = it.items[it.cursor].as_ptr();
    it.cursor += 1;
    p
}

/// Free an iterator. Safe to call with NULL.
///
/// # Safety
/// `it` must have been returned by [`ezim_lookup`] and not freed yet.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_cand_free(it: *mut EzimCandIter) {
    if !it.is_null() {
        let _ = unsafe { Box::from_raw(it) };
    }
}

// ---------------------------------------------------------------------------
// Free heap-allocated strings produced by the library.
// ---------------------------------------------------------------------------

/// Free a string previously returned in an out-param by this library.
/// Safe to call with NULL. Do not call this on `ezim_version_string()`
/// or `ezim_last_error()` — those are library-owned.
///
/// # Safety
/// `s` must have been produced by an out-param of this library and not freed yet.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_string_free(s: *mut c_char) {
    if !s.is_null() {
        let _ = unsafe { CString::from_raw(s) };
    }
}

// Suppress unused warning when used only as a marker type.
#[allow(dead_code)]
fn _opaque_marker() -> *const c_void {
    ptr::null()
}
