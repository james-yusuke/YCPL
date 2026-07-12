#!/usr/bin/env bash
set -euo pipefail

RUNFILES_ROOT="${TEST_SRCDIR}/${TEST_WORKSPACE}"

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

export YCC="${RUNFILES_ROOT}/ycc"
export LLC="${LLC:-${LLVM_BIN:+${LLVM_BIN}/llc}}"
export CLANG="${CLANG:-${LLVM_BIN:+${LLVM_BIN}/clang}}"

if [ ! -x "$YCC" ]; then
  printf 'Missing Bazel-built ycc: %s\n' "$YCC" >&2
  exit 1
fi
if [ -z "$LLC" ]; then
  LLC=llc
fi
if [ -z "$CLANG" ]; then
  CLANG=clang
fi
if ! command -v "$LLC" >/dev/null 2>&1; then
  printf 'Missing llc command: %s\n' "$LLC" >&2
  exit 1
fi
if ! command -v "$CLANG" >/dev/null 2>&1; then
  printf 'Missing clang command: %s\n' "$CLANG" >&2
  exit 1
fi

cd "$RUNFILES_ROOT"
exec tests/run_bootstrap_regression.sh
