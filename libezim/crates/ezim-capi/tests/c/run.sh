#!/usr/bin/env bash
# Build libezim, build a fresh ez.dat, compile smoke.c against the cdylib,
# then run it.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(cd "$HERE/../../../.." && pwd)"
SRC_TABLE="$WORKSPACE/../ezsource12-3/origtable/ez.orig-utf8.txt"

cd "$WORKSPACE"

echo "==> cargo build"
cargo build -q --release -p ezim-capi -p ezim-table-builder

DAT="$WORKSPACE/target/release/ez.dat"
CHAR_W="$WORKSPACE/target/release/char-weights.dat"
PHRASE_W="$WORKSPACE/target/release/phrase-weights.dat"
CHAR_CSV="$WORKSPACE/../85rest01.csv"
PHRASE_CSV="$WORKSPACE/../85rest02.csv"

echo "==> build ez.dat at $DAT"
"$WORKSPACE/target/release/ezim-table-builder" build "$SRC_TABLE" "$DAT" >/dev/null

if [[ -f "$CHAR_CSV" ]]; then
    echo "==> build char-weights.dat at $CHAR_W"
    "$WORKSPACE/target/release/ezim-table-builder" weights "$CHAR_CSV" "$CHAR_W" >/dev/null
fi
if [[ -f "$PHRASE_CSV" ]]; then
    echo "==> build phrase-weights.dat at $PHRASE_W"
    "$WORKSPACE/target/release/ezim-table-builder" phrase-weights "$PHRASE_CSV" "$PHRASE_W" >/dev/null
fi

LIBDIR="$WORKSPACE/target/release"
HEADER="$WORKSPACE/headers"
BIN="$WORKSPACE/target/release/c-smoke"

SESS_BIN="$WORKSPACE/target/release/c-smoke-session"

echo "==> compile smoke.c"
"${CC:-cc}" -std=c11 -Wall -Wextra -O2 \
    -I "$HEADER" \
    "$HERE/smoke.c" \
    -L "$LIBDIR" -lezim \
    -Wl,-rpath,"$LIBDIR" \
    -o "$BIN"

echo "==> compile smoke_session.c"
"${CC:-cc}" -std=c11 -Wall -Wextra -O2 \
    -I "$HEADER" \
    "$HERE/smoke_session.c" \
    -L "$LIBDIR" -lezim \
    -Wl,-rpath,"$LIBDIR" \
    -o "$SESS_BIN"

echo "==> run smoke"
"$BIN" "$DAT"

echo
echo "==> run smoke_session"
"$SESS_BIN" "$DAT" "$CHAR_W" "$PHRASE_W"
