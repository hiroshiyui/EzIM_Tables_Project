//! C ABI for char-weights / phrase-weights handles.

use std::ffi::CStr;
use std::os::raw::c_char;
use std::path::PathBuf;

use ezim_core::char_weights::CharWeights;
use ezim_core::phrase_weights::PhraseWeights;

use crate::{set_last_error, EzimStatus, EZIM_ERR_FORMAT, EZIM_ERR_INVALID, EZIM_ERR_IO, EZIM_OK};

/// Opaque handle around a [`CharWeights`] file.
pub struct EzimCharWeights {
    inner: CharWeights,
}

/// Opaque handle around a [`PhraseWeights`] file.
pub struct EzimPhraseWeights {
    inner: PhraseWeights,
}

impl EzimCharWeights {
    /// # Safety
    /// Caller guarantees the handle outlives the produced reference.
    pub(crate) unsafe fn inner_static_ref(&self) -> &'static CharWeights {
        let ptr: *const CharWeights = &self.inner;
        unsafe { &*ptr }
    }
}

impl EzimPhraseWeights {
    /// # Safety
    /// Caller guarantees the handle outlives the produced reference.
    pub(crate) unsafe fn inner_static_ref(&self) -> &'static PhraseWeights {
        let ptr: *const PhraseWeights = &self.inner;
        unsafe { &*ptr }
    }
}

/// Open a `char-weights.dat` file.
///
/// # Safety
/// `path` must be a valid NUL-terminated UTF-8 string. `out` must be
/// writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_char_weights_open(
    path: *const c_char,
    out: *mut *mut EzimCharWeights,
) -> EzimStatus {
    if path.is_null() || out.is_null() {
        set_last_error("null pointer to ezim_char_weights_open");
        return EZIM_ERR_INVALID;
    }
    let cs = unsafe { CStr::from_ptr(path) };
    let s = match cs.to_str() {
        Ok(s) => s,
        Err(_) => {
            set_last_error("path is not valid UTF-8");
            return EZIM_ERR_INVALID;
        }
    };
    match CharWeights::open(PathBuf::from(s)) {
        Ok(cw) => {
            let boxed = Box::new(EzimCharWeights { inner: cw });
            unsafe { *out = Box::into_raw(boxed) };
            EZIM_OK
        }
        Err(e) => {
            set_last_error(format!("char weights open failed: {e}"));
            if matches!(e, ezim_core::Error::Io(_)) {
                EZIM_ERR_IO
            } else {
                EZIM_ERR_FORMAT
            }
        }
    }
}

/// Free a char-weights handle. Safe to call with NULL.
///
/// # Safety
/// `cw` must have been returned by [`ezim_char_weights_open`].
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_char_weights_free(cw: *mut EzimCharWeights) {
    if !cw.is_null() {
        let _ = unsafe { Box::from_raw(cw) };
    }
}

/// Open a `phrase-weights.dat` file.
///
/// # Safety
/// `path` must be NUL-terminated UTF-8. `out` must be writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_phrase_weights_open(
    path: *const c_char,
    out: *mut *mut EzimPhraseWeights,
) -> EzimStatus {
    if path.is_null() || out.is_null() {
        set_last_error("null pointer to ezim_phrase_weights_open");
        return EZIM_ERR_INVALID;
    }
    let cs = unsafe { CStr::from_ptr(path) };
    let s = match cs.to_str() {
        Ok(s) => s,
        Err(_) => {
            set_last_error("path is not valid UTF-8");
            return EZIM_ERR_INVALID;
        }
    };
    match PhraseWeights::open(PathBuf::from(s)) {
        Ok(pw) => {
            let boxed = Box::new(EzimPhraseWeights { inner: pw });
            unsafe { *out = Box::into_raw(boxed) };
            EZIM_OK
        }
        Err(e) => {
            set_last_error(format!("phrase weights open failed: {e}"));
            if matches!(e, ezim_core::Error::Io(_)) {
                EZIM_ERR_IO
            } else {
                EZIM_ERR_FORMAT
            }
        }
    }
}

/// Free a phrase-weights handle. Safe to call with NULL.
///
/// # Safety
/// `pw` must have been returned by [`ezim_phrase_weights_open`].
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ezim_phrase_weights_free(pw: *mut EzimPhraseWeights) {
    if !pw.is_null() {
        let _ = unsafe { Box::from_raw(pw) };
    }
}
