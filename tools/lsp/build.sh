#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT_DIR="${YCPL_LSP_PROJECT_DIR:-$ROOT_DIR/tools/lsp}"
YCC="${YCC:-$ROOT_DIR/build/ycc}"
LLC="${LLC:-llc}"
CLANG="${CLANG:-clang}"
LINKFLAGS="${LINKFLAGS:--no-pie}"
OUT_DIR="${YCPL_LSP_OUT_DIR:-$PROJECT_DIR/build}"

mkdir -p "$OUT_DIR"
(cd "$PROJECT_DIR" && "$YCC" build)

LL_FILE="$(find "$OUT_DIR" -name '*.ll' | head -1)"
if [ -z "$LL_FILE" ]; then
  printf 'No LLVM IR generated in %s\n' "$OUT_DIR" >&2
  exit 1
fi

"$LLC" -filetype=obj "$LL_FILE" -o "$OUT_DIR/YCPL-lsp.o"
"$CLANG" $LINKFLAGS "$OUT_DIR/YCPL-lsp.o" -o "$OUT_DIR/YCPL-lsp" -lm

printf '%s\n' "$OUT_DIR/YCPL-lsp"
