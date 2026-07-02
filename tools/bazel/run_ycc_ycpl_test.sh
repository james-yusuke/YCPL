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

"$YCC_YCPL" lex examples/01_hello.yc >/dev/null
"$YCC_YCPL" check examples/53_self_codegen_main.yc >/dev/null
"$YCC_YCPL" check examples/54_self_codegen_arithmetic.yc >/dev/null
if "$YCC_YCPL" check examples/55_self_codegen_unknown_failure.yc >/tmp/ycc-ycpl-check-failure.out 2>&1; then
  printf 'Expected ycc-ycpl check to reject unknown local symbol\n' >&2
  exit 1
fi
if ! grep -q 'unknown local symbol' /tmp/ycc-ycpl-check-failure.out; then
  printf 'Expected unknown local diagnostic, got:\n' >&2
  cat /tmp/ycc-ycpl-check-failure.out >&2
  exit 1
fi

for file in examples/*.yc; do
  case "$file" in
    *_failure.yc)
      continue
      ;;
  esac
  "$YCC_YCPL" parse "$file" >/dev/null
done

expect_failure() {
  local file="$1"
  local needle="$2"
  local out
  out="$("$YCC_YCPL" parse "$file" 2>&1)" && {
    printf 'Expected parse failure for %s\n' "$file" >&2
    exit 1
  }

  case "$out" in
    *"$needle"*)
      ;;
    *)
      printf 'Expected diagnostic containing "%s" for %s, got:\n%s\n' "$needle" "$file" "$out" >&2
      exit 1
      ;;
  esac
}

expect_failure examples/41_unclosed_string_failure.yc "unterminated string literal"
expect_failure examples/42_unclosed_comment_failure.yc "unclosed block comment"
expect_failure examples/43_invalid_char_failure.yc "invalid char literal"
expect_failure examples/44_unexpected_eof_failure.yc "expected '}' to end block"
expect_failure examples/47_malformed_call_failure.yc "unclosed parenthesis"
expect_failure examples/51_malformed_struct_literal_failure.yc "expected '}' to end block"
expect_failure examples/52_misplaced_else_failure.yc "misplaced else"

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-selfhost.XXXXXX")"
"$YCC_YCPL" build-ir compiler/ycpl -o "$work_dir" >/dev/null
if [ ! -f "$work_dir/merged.ll" ]; then
  printf 'Expected self-host driver to emit %s/merged.ll\n' "$work_dir" >&2
  exit 1
fi

self_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-ir.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/53_self_codegen_main.yc -o "$self_ir_dir" >/dev/null
if [ ! -f "$self_ir_dir/merged.ll" ]; then
  printf 'Expected YCPL self codegen to emit %s/merged.ll\n' "$self_ir_dir" >&2
  exit 1
fi
if ! grep -q 'define i32 @main' "$self_ir_dir/merged.ll"; then
  printf 'Expected self-generated IR to define i32 @main\n' >&2
  cat "$self_ir_dir/merged.ll" >&2
  exit 1
fi
if ! grep -q 'ret i32 42' "$self_ir_dir/merged.ll"; then
  printf 'Expected self-generated IR to return 42\n' >&2
  cat "$self_ir_dir/merged.ll" >&2
  exit 1
fi

self_arith_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-arith.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/54_self_codegen_arithmetic.yc -o "$self_arith_dir" >/dev/null
if ! grep -q 'ret i32 13' "$self_arith_dir/merged.ll"; then
  printf 'Expected arithmetic self-generated IR to return 13\n' >&2
  cat "$self_arith_dir/merged.ll" >&2
  exit 1
fi

self_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-native.XXXXXX")"
"$YCC_YCPL" build examples/54_self_codegen_arithmetic.yc -o "$self_native_dir" >/dev/null
set +e
"$self_native_dir/merged" >/dev/null 2>&1
native_status=$?
set -e
if [ "$native_status" -ne 13 ]; then
  printf 'Expected self-built native binary to exit 13, got %d\n' "$native_status" >&2
  exit 1
fi
