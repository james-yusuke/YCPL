#!/usr/bin/env bash
set -euo pipefail

RUNFILES_ROOT="${TEST_SRCDIR}/${TEST_WORKSPACE}"
YCC_YCPL="${RUNFILES_ROOT}/ycc-ycpl"
YCC="${RUNFILES_ROOT}/ycc"

if [ ! -x "$YCC_YCPL" ]; then
  printf 'Missing Bazel-built ycc-ycpl: %s\n' "$YCC_YCPL" >&2
  exit 1
fi
if [ ! -x "$YCC" ]; then
  printf 'Missing Bazel-built bootstrap ycc: %s\n' "$YCC" >&2
  exit 1
fi

export YCPL_BOOTSTRAP_YCC="$YCC"

cd "$RUNFILES_ROOT"

"$YCC_YCPL" parse compiler/ycpl >/tmp/ycpl-stage-parse.out
"$YCC_YCPL" check compiler/ycpl >/tmp/ycpl-stage-check.out
grep -q 'files=11' /tmp/ycpl-stage-parse.out
grep -q 'files=11' /tmp/ycpl-stage-check.out

strict_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-ir.XXXXXX")"
YCPL_NO_BOOTSTRAP=1 "$YCC_YCPL" build-ir compiler/ycpl -o "$strict_ir_dir" >/tmp/ycpl-strict-ir.out
if [ ! -f "$strict_ir_dir/merged.ll" ]; then
  printf 'Expected strict self-host project build-ir to emit %s/merged.ll\n' "$strict_ir_dir" >&2
  cat /tmp/ycpl-strict-ir.out >&2
  exit 1
fi
grep -q 'define i32 @main' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_ast_fn_' "$strict_ir_dir/merged.ll"
grep -q 'declare i32 @puts' "$strict_ir_dir/merged.ll"
grep -q 'br i1' "$strict_ir_dir/merged.ll"
grep -q 'br label %loop' "$strict_ir_dir/merged.ll"

find_llc() {
  if [ -n "${LLC:-}" ] && [ -x "$LLC" ]; then
    printf '%s\n' "$LLC"
    return 0
  fi
  for candidate in \
    /opt/homebrew/opt/llvm/bin/llc \
    /opt/homebrew/opt/llvm@22/bin/llc \
    /usr/local/opt/llvm/bin/llc \
    /usr/lib/llvm-22/bin/llc; do
    if [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  command -v llc || true
}

LLC_BIN="$(find_llc)"
if [ -n "$LLC_BIN" ]; then
  "$LLC_BIN" -filetype=obj "$strict_ir_dir/merged.ll" -o "$strict_ir_dir/merged.o"
fi

strict_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-native.XXXXXX")"
YCPL_NO_BOOTSTRAP=1 "$YCC_YCPL" build compiler/ycpl -o "$strict_native_dir" >/tmp/ycpl-strict-native.out
if [ ! -x "$strict_native_dir/merged" ]; then
  printf 'Expected strict self-host project build to emit %s/merged\n' "$strict_native_dir" >&2
  cat /tmp/ycpl-strict-native.out >&2
  exit 1
fi
"$strict_native_dir/merged" >/tmp/ycpl-strict-native-run.out

stage2_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-stage2.XXXXXX")"
(
  cd compiler/ycpl
  "$YCC_YCPL" build -o "$stage2_dir" >/tmp/ycpl-stage2-build.out
)
STAGE2="$stage2_dir/ycc-ycpl"
if [ ! -x "$STAGE2" ]; then
  printf 'Expected stage2 binary at %s\n' "$STAGE2" >&2
  cat /tmp/ycpl-stage2-build.out >&2
  exit 1
fi

"$STAGE2" parse compiler/ycpl >/tmp/ycpl-stage2-parse.out
"$STAGE2" check compiler/ycpl >/tmp/ycpl-stage2-check.out
grep -q 'files=11' /tmp/ycpl-stage2-parse.out
grep -q 'files=11' /tmp/ycpl-stage2-check.out

if "$STAGE2" check examples/55_self_codegen_unknown_failure.yc >/tmp/ycpl-stage2-negative.out 2>&1; then
  printf 'Expected stage2 checker to reject unknown local symbol\n' >&2
  exit 1
fi
grep -q 'unknown local symbol' /tmp/ycpl-stage2-negative.out

native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-stage2-native.XXXXXX")"
YCPL_NO_BOOTSTRAP=1 "$STAGE2" build examples/54_self_codegen_arithmetic.yc -o "$native_dir" >/tmp/ycpl-stage2-native.out
set +e
"$native_dir/merged" >/dev/null 2>&1
native_status=$?
set -e
if [ "$native_status" -ne 13 ]; then
  printf 'Expected stage2 strict native smoke binary to exit 13, got %d\n' "$native_status" >&2
  exit 1
fi
