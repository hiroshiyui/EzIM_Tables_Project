//! C ABI for the session state machine.

use std::ffi::CString;
use std::os::raw::{c_char, c_int};
use std::ptr;

use ezim_core::format::BinaryTable;
use ezim_session::{Key, Session};

use crate::{
    set_last_error, EzimStatus, EzimTable, EZIM_ERR_INTERNAL, EZIM_ERR_INVALID, EZIM_OK,
};

// ---------------------------------------------------------------------------
// C key representation
// ---------------------------------------------------------------------------

pub const EZIM_KEY_CHAR: i32 = 0;
pub const EZIM_KEY_BACKSPACE: i32 = 1;
pub const EZIM_KEY_ESCAPE: i32 = 2;
pub const EZIM_KEY_SPACE: i32 = 3;
pub const EZIM_KEY_ENTER: i32 = 4;
pub const EZIM_KEY_SELECT: i32 = 5;
pub const EZIM_KEY_PAGE_NEXT: i32 = 6;
pub const EZIM_KEY_PAGE_PREV: i32 = 7;

/// `value` is interpreted as:
///  - Unicode codepoint when `kind == EZIM_KEY_CHAR`
///  - 1-based candidate index when `kind == EZIM_KEY_SELECT`
///  - ignored otherwise
#[repr(C)]
#[derive(Clone, Copy)]
pub struct EzimKey {
    pub kind: i32,
    pub value: u32,
}

impl EzimKey {
    fn to_session_key(self) -> Option<Key> {
        match self.kind {
            EZIM_KEY_CHAR => char::from_u32(self.value).map(Key::Char),
            EZIM_KEY_BACKSPACE => Some(Key::Backspace),
            EZIM_KEY_ESCAPE => Some(Key::Escape),
            EZIM_KEY_SPACE => Some(Key::Space),
            EZIM_KEY_ENTER => Some(Key::Enter),
            EZIM_KEY_SELECT => {
                if self.value > 255 {
                    None
                } else {
                    Some(Key::Select(self.value as u8))
                }
            }
            EZIM_KEY_PAGE_NEXT => Some(Key::PageNext),
            EZIM_KEY_PAGE_PREV => Some(Key::PagePrev),
            _ => None,
        }
    }
}

// ---------------------------------------------------------------------------
// EzimSession
// ---------------------------------------------------------------------------

/// Opaque session handle. Borrows the table; the table must outlive the
/// session.
pub struct EzimSession {
    /// Lifetime is fudged to `'static`; the real lifetime is tied to
    /// `_table_ptr` which the C caller is contractually obliged to keep
    /// alive. See `ezim_session_new` for the safety contract.
    inner: Session<'static>,
    /// Held purely to document/track the borrow; never dereferenced after
    /// construction.
    _table_ptr: *const EzimTable,
    buffer_c: CString,
    candidates_c: Vec<CString>,
    pending_commit: Option<CString>,
}

impl EzimSession {
    fn refresh_view(&mut self) {
        self.buffer_c = CString::new(self.inner.buffer()).unwrap_or_default();
        self.candidates_c = self
            .inner
            .current_page()
            .iter()
            .filter_map(|s| CString::new(s.as_str()).ok())
            .collect();
    }
}

/// Create a new session bound to a table.
///
/// # Safety
/// `t` must be a valid handle returned by `ezim_table_open` and must remain
/// valid (not freed) until [`ezim_session_free`] is called on the resulting
/// session. `out` must be a valid writable pointer.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_new(
    t: *const EzimTable,
    out: *mut *mut EzimSession,
) -> EzimStatus {
    if t.is_null() || out.is_null() {
        set_last_error("null pointer to ezim_session_new");
        return EZIM_ERR_INVALID;
    }
    // SAFETY: caller upholds that `t` outlives the returned session.
    let table_ref: &'static BinaryTable = unsafe { &(*t).inner_static_ref() };
    let inner = Session::new(table_ref);
    let mut sess = Box::new(EzimSession {
        inner,
        _table_ptr: t,
        buffer_c: CString::default(),
        candidates_c: Vec::new(),
        pending_commit: None,
    });
    sess.refresh_view();
    unsafe { *out = Box::into_raw(sess) };
    EZIM_OK
}

/// Free a session handle. Safe to call with NULL.
///
/// # Safety
/// `s` must have been returned by [`ezim_session_new`] and not freed yet.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_free(s: *mut EzimSession) {
    if !s.is_null() {
        let _ = unsafe { Box::from_raw(s) };
    }
}

/// Drive the session with a single key event.
///
/// Returns:
/// - `1` if the key was consumed by the IME
/// - `0` if the key should pass through to the application
/// - negative on error (caller can read `ezim_last_error`)
///
/// After a successful call, retrieve any produced commit text via
/// [`ezim_session_take_commit`].
///
/// # Safety
/// `s` must be valid.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_handle_key(s: *mut EzimSession, key: EzimKey) -> c_int {
    if s.is_null() {
        set_last_error("null session in ezim_session_handle_key");
        return EZIM_ERR_INVALID;
    }
    let sess = unsafe { &mut *s };
    let Some(rk) = key.to_session_key() else {
        set_last_error("invalid key kind/value");
        return EZIM_ERR_INVALID;
    };
    let outcome = sess.inner.handle_key(rk);
    if let Some(commit) = outcome.commit {
        sess.pending_commit = CString::new(commit).ok();
    }
    sess.refresh_view();
    if outcome.consumed { 1 } else { 0 }
}

/// If the most recent [`ezim_session_handle_key`] call produced a commit,
/// transfer ownership to the caller. `*out` is set to NULL when there is
/// nothing to commit; otherwise free with [`crate::ezim_string_free`].
///
/// # Safety
/// All pointers must be valid.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_take_commit(
    s: *mut EzimSession,
    out: *mut *mut c_char,
) -> EzimStatus {
    if s.is_null() || out.is_null() {
        set_last_error("null pointer to ezim_session_take_commit");
        return EZIM_ERR_INVALID;
    }
    let sess = unsafe { &mut *s };
    match sess.pending_commit.take() {
        Some(cs) => unsafe { *out = cs.into_raw() },
        None => unsafe { *out = ptr::null_mut() },
    }
    EZIM_OK
}

/// Returns the current preedit (raw key buffer) as a NUL-terminated UTF-8
/// string. Pointer is owned by the session and is invalidated by the next
/// [`ezim_session_handle_key`] or [`ezim_session_cancel`] call.
///
/// # Safety
/// `s` must be valid.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_buffer(s: *const EzimSession) -> *const c_char {
    if s.is_null() {
        return c"".as_ptr();
    }
    unsafe { (*s).buffer_c.as_ptr() }
}

/// Returns the number of candidates on the current page.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_cand_count(s: *const EzimSession) -> usize {
    if s.is_null() {
        return 0;
    }
    unsafe { (*s).candidates_c.len() }
}

/// Returns the candidate at zero-based index `i` on the current page, or
/// NULL if out of range. Pointer is invalidated on the next mutation.
///
/// # Safety
/// `s` must be valid.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_cand_at(s: *const EzimSession, i: usize) -> *const c_char {
    if s.is_null() {
        return ptr::null();
    }
    let sess = unsafe { &*s };
    sess.candidates_c
        .get(i)
        .map(|cs| cs.as_ptr())
        .unwrap_or(ptr::null())
}

/// Total candidate count across all pages (not just the current page).
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_total_cand_count(s: *const EzimSession) -> usize {
    if s.is_null() {
        return 0;
    }
    unsafe { (*s).inner.candidates().len() }
}

/// Zero-based index of the current page.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_page(s: *const EzimSession) -> usize {
    if s.is_null() {
        return 0;
    }
    unsafe { (*s).inner.page() }
}

/// Total number of pages. Zero when there are no candidates.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_page_count(s: *const EzimSession) -> usize {
    if s.is_null() {
        return 0;
    }
    unsafe { (*s).inner.page_count() }
}

/// Cancel the current composition (clears buffer and candidates). Returns
/// `EZIM_OK` always; included for symmetry.
///
/// # Safety
/// `s` must be valid.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_session_cancel(s: *mut EzimSession) -> EzimStatus {
    if s.is_null() {
        set_last_error("null session in ezim_session_cancel");
        return EZIM_ERR_INVALID;
    }
    let sess = unsafe { &mut *s };
    sess.inner.cancel();
    sess.pending_commit = None;
    sess.refresh_view();
    EZIM_OK
}

/// Internal helper trait — must NOT cross the FFI boundary; it just gives us
/// a place to do the lifetime fudge in one spot, with documentation.
trait TableInnerStaticRef {
    /// # Safety
    /// Caller guarantees the underlying table outlives the produced reference.
    unsafe fn inner_static_ref(&self) -> &'static BinaryTable;
}

impl TableInnerStaticRef for EzimTable {
    unsafe fn inner_static_ref(&self) -> &'static BinaryTable {
        let ptr: *const BinaryTable = self.inner_ptr();
        // SAFETY: contract documented on `ezim_session_new`.
        unsafe { &*ptr.cast::<BinaryTable>() }
    }
}

#[doc(hidden)]
#[allow(unused)]
fn _force_internal_used() -> EzimStatus {
    EZIM_ERR_INTERNAL
}
