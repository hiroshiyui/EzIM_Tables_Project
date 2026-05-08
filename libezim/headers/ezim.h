/* ezim.h — C API for libezim
 *
 * libezim is a Rust implementation of the 輕鬆 (EZ) input method. This
 * header is hand-curated; keep it in sync with crates/ezim-capi/src/lib.rs
 * (see the version pin near the top).
 *
 * License: GPL-3.0-only.
 */

#ifndef EZIM_H_
#define EZIM_H_

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -------------------------------------------------------------------------
 * Versioning
 * ------------------------------------------------------------------------- */

#define EZIM_ABI_VERSION_REQUIRED 1u

/** Returns the ABI version of the linked library. */
uint32_t    ezim_abi_version(void);

/** Returns a NUL-terminated, library-owned version string (do not free). */
const char *ezim_version_string(void);

/* -------------------------------------------------------------------------
 * Status codes (returned by every fallible function)
 * ------------------------------------------------------------------------- */

typedef int32_t EzimStatus;

#define EZIM_OK            0
#define EZIM_ERR_INVALID  -1   /* null pointer, invalid UTF-8, bad arg */
#define EZIM_ERR_IO       -2
#define EZIM_ERR_FORMAT   -3
#define EZIM_ERR_NOT_FOUND -4
#define EZIM_ERR_ENCODE   -5
#define EZIM_ERR_INTERNAL -99

/**
 * Returns the last error message set on this thread, or an empty string.
 * The pointer is valid until the next library call on this thread that
 * updates the error state. Library-owned; do not free.
 */
const char *ezim_last_error(void);

/* -------------------------------------------------------------------------
 * Opaque handles
 * ------------------------------------------------------------------------- */

typedef struct EzimTable    EzimTable;
typedef struct EzimCandIter EzimCandIter;

/* -------------------------------------------------------------------------
 * Table lifecycle
 * ------------------------------------------------------------------------- */

/**
 * Open a binary `.dat` table from disk.
 *
 * On success, `*out` receives a fresh handle. The caller must free it with
 * `ezim_table_free`.
 *
 * Returns: EZIM_OK | EZIM_ERR_INVALID | EZIM_ERR_IO | EZIM_ERR_FORMAT
 */
EzimStatus  ezim_table_open(const char *path, EzimTable **out);

/** Free a table handle. Safe to call with NULL. */
void        ezim_table_free(EzimTable *t);

/* -------------------------------------------------------------------------
 * Encoding
 * ------------------------------------------------------------------------- */

/**
 * Encode a UTF-8 string into its EZ key sequence per the取碼規則 documented
 * in the project's CLAUDE.md.
 *
 * On success, `*out_codes` is a heap-allocated NUL-terminated string.
 * Free it with `ezim_string_free`.
 *
 * Returns: EZIM_OK | EZIM_ERR_INVALID | EZIM_ERR_ENCODE
 */
EzimStatus  ezim_encode(const EzimTable *t,
                        const char       *utf8,
                        char            **out_codes);

/**
 * Pick the canonical (head, tail) keys for a single Unicode codepoint.
 *
 * On success, `*out_head_tail` is a heap-allocated NUL-terminated 3-byte
 * string "ht\0" (head, tail). Free it with `ezim_string_free`.
 *
 * Returns: EZIM_OK | EZIM_ERR_INVALID | EZIM_ERR_NOT_FOUND
 */
EzimStatus  ezim_pick_codes(const EzimTable *t,
                            uint32_t          codepoint,
                            char            **out_head_tail);

/* -------------------------------------------------------------------------
 * Reverse lookup
 * ------------------------------------------------------------------------- */

/**
 * Look up all candidates for an EZ key sequence. Candidates are returned in
 * source-file order (the canonical EZ ordering).
 *
 * On success, `*out` receives an iterator. Iterate by calling
 * `ezim_cand_next` until it returns NULL, then free with `ezim_cand_free`.
 *
 * Returns: EZIM_OK | EZIM_ERR_INVALID | EZIM_ERR_FORMAT
 */
EzimStatus  ezim_lookup(const EzimTable *t,
                        const char       *code,
                        EzimCandIter   **out);

/**
 * Returns the next candidate as a NUL-terminated UTF-8 string, or NULL when
 * exhausted. The pointer is valid until `ezim_cand_free` is called.
 */
const char *ezim_cand_next(EzimCandIter *it);

/** Free an iterator. Safe to call with NULL. */
void        ezim_cand_free(EzimCandIter *it);

/* -------------------------------------------------------------------------
 * Session API (state machine: preedit, candidates, paging)
 * ------------------------------------------------------------------------- */

typedef struct EzimSession EzimSession;

/* Key kinds for EzimKey.kind. */
#define EZIM_KEY_CHAR       0  /* value = Unicode codepoint */
#define EZIM_KEY_BACKSPACE  1
#define EZIM_KEY_ESCAPE     2
#define EZIM_KEY_SPACE      3
#define EZIM_KEY_ENTER      4
#define EZIM_KEY_SELECT     5  /* value = 1-based index on current page */
#define EZIM_KEY_PAGE_NEXT  6
#define EZIM_KEY_PAGE_PREV  7

typedef struct {
    int32_t  kind;
    uint32_t value;
} EzimKey;

/**
 * Create a session bound to a table. The table must outlive the session.
 * Returns: EZIM_OK | EZIM_ERR_INVALID
 */
EzimStatus  ezim_session_new(const EzimTable *t, EzimSession **out);

/** Free a session handle. Safe to call with NULL. */
void        ezim_session_free(EzimSession *s);

/**
 * Drive the session with a key event. Returns:
 *   1  — key consumed
 *   0  — key should pass through to the application
 *  <0  — error (see ezim_last_error)
 *
 * After a successful call, retrieve any commit text via
 * `ezim_session_take_commit`.
 */
int32_t     ezim_session_handle_key(EzimSession *s, EzimKey key);

/**
 * If the most recent `ezim_session_handle_key` produced a commit, transfer
 * ownership of the string to the caller. `*out` is NULL when there is
 * nothing to commit; otherwise free with `ezim_string_free`.
 */
EzimStatus  ezim_session_take_commit(EzimSession *s, char **out);

/**
 * Returns the current preedit (raw key buffer) as a NUL-terminated UTF-8
 * string. Owned by the session; invalidated on the next mutation.
 */
const char *ezim_session_buffer(const EzimSession *s);

/** Number of candidates on the current page. */
size_t      ezim_session_cand_count(const EzimSession *s);

/**
 * Candidate at zero-based index on the current page, or NULL if out of
 * range. Invalidated on the next mutation.
 */
const char *ezim_session_cand_at(const EzimSession *s, size_t i);

/** Total candidates across all pages. */
size_t      ezim_session_total_cand_count(const EzimSession *s);

/** Zero-based index of the current page. */
size_t      ezim_session_page(const EzimSession *s);

/** Total number of pages (0 when there are no candidates). */
size_t      ezim_session_page_count(const EzimSession *s);

/** Cancel the composition (clear buffer and candidates). */
EzimStatus  ezim_session_cancel(EzimSession *s);

/* -------------------------------------------------------------------------
 * Memory management for library-allocated strings
 * ------------------------------------------------------------------------- */

/**
 * Free a string previously returned in an out-param by this library.
 * Safe to call with NULL. Do NOT call on `ezim_version_string()` or
 * `ezim_last_error()` — those are library-owned.
 */
void        ezim_string_free(char *s);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* EZIM_H_ */
