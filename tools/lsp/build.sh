#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT_DIR="${YCPL_LSP_PROJECT_DIR:-$ROOT_DIR/tools/lsp}"
YCC="${YCC:-$ROOT_DIR/build/ycc}"
OUT_DIR="${YCPL_LSP_OUT_DIR:-$PROJECT_DIR/build}"

if [ -z "${LINKFLAGS+x}" ]; then
  case "$(uname -s)" in
    Darwin)
      LINKFLAGS=""
      ;;
    *)
      LINKFLAGS="--no-pie"
      ;;
  esac
fi

llvm_bindir() {
  if [ -n "${LLVM_BINDIR:-}" ]; then
    printf '%s\n' "$LLVM_BINDIR"
    return 0
  fi
  if [ -n "${LLVM_CONFIG:-}" ] && [ -x "$LLVM_CONFIG" ]; then
    "$LLVM_CONFIG" --bindir
    return 0
  fi
  for candidate in \
    /opt/homebrew/opt/llvm@22/bin/llvm-config \
    /opt/homebrew/opt/llvm/bin/llvm-config \
    /usr/local/opt/llvm@22/bin/llvm-config \
    /usr/local/opt/llvm/bin/llvm-config \
    /usr/lib/llvm-22/bin/llvm-config
  do
    if [ -x "$candidate" ]; then
      "$candidate" --bindir
      return 0
    fi
  done
  if command -v llvm-config-22 >/dev/null 2>&1; then
    llvm-config-22 --bindir
    return 0
  fi
  if command -v llvm-config22 >/dev/null 2>&1; then
    llvm-config22 --bindir
    return 0
  fi
  if command -v llvm-config >/dev/null 2>&1; then
    llvm-config --bindir
    return 0
  fi
  return 1
}

LLVM_BIN="$(llvm_bindir || true)"
LLC="${LLC:-${LLVM_BIN:+${LLVM_BIN}/llc}}"
CLANG="${CLANG:-${LLVM_BIN:+${LLVM_BIN}/clang}}"
LLC="${LLC:-llc}"
CLANG="${CLANG:-clang}"

mkdir -p "$OUT_DIR"
(cd "$PROJECT_DIR" && "$YCC" build-ir)

LL_FILE="$(find "$OUT_DIR" -name '*.ll' | head -1)"
if [ -z "$LL_FILE" ]; then
  printf 'No LLVM IR generated in %s\n' "$OUT_DIR" >&2
  exit 1
fi

"$LLC" -filetype=obj "$LL_FILE" -o "$OUT_DIR/YCPL-lsp.o"
"$CLANG" $LINKFLAGS "$OUT_DIR/YCPL-lsp.o" -o "$OUT_DIR/YCPL-lsp" -lm

printf '%s\n' "$OUT_DIR/YCPL-lsp"
