//! ezim-core — encoding and lookup engine for the EZ input method.
//!
//! See `libezim/DESIGN.md` for the architecture. This crate is the data-path:
//! parsing the source table, the head/tail picker, the word-length-aware
//! encoder, and (later) the binary `.dat` reader.

pub mod encoding;
pub mod error;
pub mod format;
pub mod source;

pub use encoding::{EncodeError, HeadTail};
pub use error::{Error, Result};
pub use format::{BinaryTable, EntryView};
pub use source::{RawEntry, SourceTable};
