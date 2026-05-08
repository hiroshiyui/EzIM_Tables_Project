/* C smoke test for libezim's C ABI.
 *
 * Builds the table from ../../../../ezsource12-3/origtable/ez.orig-utf8.txt
 * (handled by the runner script run.sh), then exercises the API:
 *   - version checks
 *   - open table
 *   - encode "八一七公報" → expects "8mj8"
 *   - pick_codes for '七' → expects "j'"
 *   - lookup "8" → expects "八" as the first candidate
 *   - error path: encode unknown codepoint
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

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s <path-to-ez.dat>\n", argv[0]);
        return 2;
    }

    CHECK(ezim_abi_version() == EZIM_ABI_VERSION_REQUIRED, "ABI version matches header");
    printf("info: %s\n", ezim_version_string());

    EzimTable *t = NULL;
    EzimStatus st = ezim_table_open(argv[1], &t);
    if (st != EZIM_OK) {
        fprintf(stderr, "FAIL: ezim_table_open: %s\n", ezim_last_error());
        return 1;
    }
    CHECK(t != NULL, "table handle non-null");

    /* encode */
    char *codes = NULL;
    st = ezim_encode(t, "八一七公報", &codes);
    CHECK(st == EZIM_OK, "encode 八一七公報 returns OK");
    CHECK(codes != NULL && strcmp(codes, "8mj8") == 0, "encode 八一七公報 == \"8mj8\"");
    ezim_string_free(codes);
    codes = NULL;

    st = ezim_encode(t, "一", &codes);
    CHECK(st == EZIM_OK && strcmp(codes, "mm") == 0, "encode 一 == \"mm\"");
    ezim_string_free(codes);
    codes = NULL;

    /* pick_codes */
    char *ht = NULL;
    st = ezim_pick_codes(t, 0x4E03 /* 七 */, &ht);
    CHECK(st == EZIM_OK && strcmp(ht, "j'") == 0, "pick_codes(七) == \"j'\"");
    ezim_string_free(ht);
    ht = NULL;

    /* lookup */
    EzimCandIter *it = NULL;
    st = ezim_lookup(t, "8", &it);
    CHECK(st == EZIM_OK && it != NULL, "lookup(\"8\") returns iterator");
    const char *first = ezim_cand_next(it);
    CHECK(first != NULL && strcmp(first, "八") == 0, "first candidate for \"8\" is 八");
    /* drain — no further candidates expected for \"8\" */
    int extra = 0;
    while (ezim_cand_next(it) != NULL) extra++;
    CHECK(extra == 0, "no extra candidates for \"8\"");
    ezim_cand_free(it);
    it = NULL;

    /* error path: an emoji is guaranteed not in the table */
    st = ezim_encode(t, "八\xF0\x9F\x8E\x89", &codes); /* 八🎉 */
    CHECK(st == EZIM_ERR_ENCODE, "encode of unknown char returns EZIM_ERR_ENCODE");
    const char *msg = ezim_last_error();
    CHECK(msg && msg[0] != '\0', "last_error message is non-empty");
    if (msg) printf("info: last_error = %s\n", msg);

    ezim_table_free(t);

    if (failures > 0) {
        fprintf(stderr, "\n%d check(s) failed.\n", failures);
        return 1;
    }
    printf("\nall checks passed.\n");
    return 0;
}
