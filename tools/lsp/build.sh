#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT_DIR="$ROOT_DIR/tools/lsp"
ECC="$ROOT_DIR/build/ecc"
OUT_DIR="$PROJECT_DIR/build"

mkdir -p "$OUT_DIR"
(cd "$PROJECT_DIR" && "$ECC" build)

LL_FILE="$(find "$OUT_DIR" -name '*.ll' | head -1)"
if [ -z "$LL_FILE" ]; then
  printf 'No LLVM IR generated in %s\n' "$OUT_DIR" >&2
  exit 1
fi

llc -filetype=obj "$LL_FILE" -o "$OUT_DIR/YCPL-lsp.o"
clang "$OUT_DIR/YCPL-lsp.o" -o "$OUT_DIR/YCPL-lsp" -lm

printf '%s\n' "$OUT_DIR/YCPL-lsp"
