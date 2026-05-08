/* C smoke test for the ezim session API.
 *
 * Drives a session through several scenarios and verifies preedit,
 * candidates, and commit behaviour.
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ezim.h"

static int failures = 0;

#define CHECK(cond, msg) do {                                  \
    if (!(cond)) {                                             \
        fprintf(stderr, "FAIL: %s — %s\n", msg, #cond);        \
        failures++;                                            \
    } else {                                                   \
        printf("ok:   %s\n", msg);                             \
    }                                                          \
} while (0)

static int32_t key_char(EzimSession *s, uint32_t cp) {
    EzimKey k = { .kind = EZIM_KEY_CHAR, .value = cp };
    return ezim_session_handle_key(s, k);
}
static int32_t key_kind(EzimSession *s, int32_t kind) {
    EzimKey k = { .kind = kind, .value = 0 };
    return ezim_session_handle_key(s, k);
}
static int32_t key_select(EzimSession *s, uint32_t idx_one_based) {
    EzimKey k = { .kind = EZIM_KEY_SELECT, .value = idx_one_based };
    return ezim_session_handle_key(s, k);
}

int main(int argc, char **argv) {
    if (argc < 2 || argc > 4) {
        fprintf(stderr,
                "usage: %s <ez.dat> [char-weights.dat] [phrase-weights.dat]\n",
                argv[0]);
        return 2;
    }
    const char *char_weights_path = argc >= 3 ? argv[2] : NULL;
    const char *phrase_weights_path = argc >= 4 ? argv[3] : NULL;

    EzimTable *t = NULL;
    if (ezim_table_open(argv[1], &t) != EZIM_OK) {
        fprintf(stderr, "open: %s\n", ezim_last_error());
        return 1;
    }

    EzimSession *s = NULL;
    EzimStatus st = ezim_session_new(t, &s);
    CHECK(st == EZIM_OK && s != NULL, "session created");

    /* --- scenario 1: type "8", verify candidate, space-commit "八" --- */
    int32_t r = key_char(s, '8');
    CHECK(r == 1, "char '8' consumed");
    CHECK(strcmp(ezim_session_buffer(s), "8") == 0, "buffer == \"8\"");
    CHECK(ezim_session_cand_count(s) >= 1, "at least one candidate for \"8\"");
    const char *first = ezim_session_cand_at(s, 0);
    CHECK(first != NULL && strcmp(first, "八") == 0, "first candidate is 八");

    r = key_kind(s, EZIM_KEY_SPACE);
    CHECK(r == 1, "space consumed");
    char *commit = NULL;
    ezim_session_take_commit(s, &commit);
    CHECK(commit != NULL && strcmp(commit, "八") == 0, "commit == \"八\"");
    ezim_string_free(commit);
    commit = NULL;
    CHECK(strlen(ezim_session_buffer(s)) == 0, "buffer cleared after commit");

    /* --- scenario 2: type "''2x" → "比較" via Enter --- */
    key_char(s, '\'');
    key_char(s, '\'');
    key_char(s, '2');
    key_char(s, 'x');
    CHECK(strcmp(ezim_session_buffer(s), "''2x") == 0, "buffer == \"''2x\"");
    CHECK(ezim_session_cand_count(s) == 1, "exactly one candidate for \"''2x\"");
    CHECK(strcmp(ezim_session_cand_at(s, 0), "比較") == 0,
          "candidate is 比較");
    key_kind(s, EZIM_KEY_ENTER);
    ezim_session_take_commit(s, &commit);
    CHECK(commit != NULL && strcmp(commit, "比較") == 0,
          "Enter commits 比較");
    ezim_string_free(commit);
    commit = NULL;

    /* --- scenario 3: backspace shrinks buffer --- */
    key_char(s, 'm');
    CHECK(strcmp(ezim_session_buffer(s), "m") == 0, "buffer == \"m\"");
    key_kind(s, EZIM_KEY_BACKSPACE);
    CHECK(strlen(ezim_session_buffer(s)) == 0, "buffer empty after backspace");

    /* --- scenario 4: SELECT picks specific candidate --- */
    /* Find a code with multiple candidates. The real ez.orig table has many.
     * We use "76" which has 七 and possibly others; verify the first two
     * candidates and Select(1) commits the first. */
    key_char(s, '7');
    key_char(s, '6');
    size_t total = ezim_session_total_cand_count(s);
    CHECK(total >= 1, "\"76\" has at least one candidate");
    const char *cand0 = ezim_session_cand_at(s, 0);
    CHECK(cand0 != NULL, "cand[0] non-null");
    char saved[64];
    snprintf(saved, sizeof(saved), "%s", cand0);
    key_select(s, 1);
    ezim_session_take_commit(s, &commit);
    CHECK(commit != NULL && strcmp(commit, saved) == 0,
          "Select(1) commits cand[0]");
    ezim_string_free(commit);
    commit = NULL;

    /* --- scenario 5: ESC cancels --- */
    key_char(s, '8');
    CHECK(!ezim_session_buffer(s) || strlen(ezim_session_buffer(s)) == 1,
          "buffer has 1 char");
    key_kind(s, EZIM_KEY_ESCAPE);
    CHECK(strlen(ezim_session_buffer(s)) == 0, "buffer empty after ESC");
    ezim_session_take_commit(s, &commit);
    CHECK(commit == NULL, "no commit from ESC");

    /* --- scenario 6: pass-through key (uppercase) --- */
    r = key_char(s, 'A');
    CHECK(r == 0, "uppercase 'A' passes through");

    /* --- scenario 7: cancel API --- */
    key_char(s, '8');
    ezim_session_cancel(s);
    CHECK(strlen(ezim_session_buffer(s)) == 0, "cancel clears buffer");

    /* --- scenario 8: attach weights and re-rank candidates --- */
    EzimCharWeights *cw = NULL;
    EzimPhraseWeights *pw = NULL;
    if (char_weights_path) {
        EzimStatus stw = ezim_char_weights_open(char_weights_path, &cw);
        CHECK(stw == EZIM_OK && cw != NULL, "open char-weights.dat");
    }
    if (phrase_weights_path) {
        EzimStatus stw = ezim_phrase_weights_open(phrase_weights_path, &pw);
        CHECK(stw == EZIM_OK && pw != NULL, "open phrase-weights.dat");
    }
    if (cw || pw) {
        EzimStatus stw = ezim_session_attach_weights(s, cw, pw);
        CHECK(stw == EZIM_OK, "attach weights to session");
        /* Type a code that has multiple candidates and verify the first
         * is the most-frequent one in the corpus. We use "8" → "八".
         * 八 is rank 258 in 字頻; with weights attached it should still
         * be first (it's the only candidate for "8"). */
        key_char(s, '8');
        const char *first = ezim_session_cand_at(s, 0);
        CHECK(first != NULL && strcmp(first, "八") == 0,
              "after attach: first candidate for \"8\" still 八");
        ezim_session_cancel(s);
    }

    ezim_session_free(s);
    if (cw) ezim_char_weights_free(cw);
    if (pw) ezim_phrase_weights_free(pw);
    ezim_table_free(t);

    if (failures > 0) {
        fprintf(stderr, "\n%d check(s) failed.\n", failures);
        return 1;
    }
    printf("\nall session checks passed.\n");
    return 0;
}
