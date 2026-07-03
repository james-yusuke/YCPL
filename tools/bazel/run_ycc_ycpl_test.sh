#!/usr/bin/env bash
set -euo pipefail
trap 'printf "run_ycc_ycpl_test failed at line %d\n" "$LINENO" >&2' ERR

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
if ! "$YCC_YCPL" parse compiler/ycpl >/tmp/ycc-ycpl-project-parse.out 2>/tmp/ycc-ycpl-project-parse.err; then
  cat /tmp/ycc-ycpl-project-parse.out >&2
  cat /tmp/ycc-ycpl-project-parse.err >&2
  exit 1
fi
if ! "$YCC_YCPL" check compiler/ycpl >/tmp/ycc-ycpl-project-check.out 2>/tmp/ycc-ycpl-project-check.err; then
  cat /tmp/ycc-ycpl-project-check.out >&2
  cat /tmp/ycc-ycpl-project-check.err >&2
  exit 1
fi
traversal_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-traversal.XXXXXX")"
cp -R compiler/ycpl "$traversal_dir/ycpl"
mkdir -p "$traversal_dir/ycpl/src/generated/deep"
cat >"$traversal_dir/ycpl/src/generated/deep/smoke.yc" <<'YCPL'
module compiler.ycpl.generated.deep.smoke

fn traversal_smoke() i32 {
    return 7
}
YCPL
"$YCC_YCPL" parse "$traversal_dir/ycpl" >/tmp/ycc-ycpl-traversal-parse.out
if ! grep -q 'files=18' /tmp/ycc-ycpl-traversal-parse.out; then
  printf 'Expected recursive traversal to discover 18 files in %s, got:\n' "$traversal_dir/ycpl" >&2
  cat /tmp/ycc-ycpl-traversal-parse.out >&2
  find "$traversal_dir/ycpl/src" -type f -name '*.yc' | sort >&2
  exit 1
fi
grep -q 'fn_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'body_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'body_tokens=' /tmp/ycc-ycpl-project-parse.out
grep -q 'body_nodes=' /tmp/ycc-ycpl-project-parse.out
grep -q 'node_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'return_exprs=' /tmp/ycc-ycpl-project-parse.out
grep -q 'typed_nodes=' /tmp/ycc-ycpl-project-parse.out
grep -q 'typed_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'main=1' /tmp/ycc-ycpl-project-check.out
grep -q 'body_digest=' /tmp/ycc-ycpl-project-check.out
grep -q 'ret_digest=' /tmp/ycc-ycpl-project-check.out
grep -q 'typed_nodes=' /tmp/ycc-ycpl-project-check.out
grep -q 'typed_digest=' /tmp/ycc-ycpl-project-check.out
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
if [ ! -f "$work_dir/local_return.ll" ]; then
  printf 'Expected self-host driver to emit %s/local_return.ll\n' "$work_dir" >&2
  exit 1
fi
if [ ! -f "$work_dir/project_body.ll" ]; then
  printf 'Expected self-host driver to emit %s/project_body.ll\n' "$work_dir" >&2
  exit 1
fi
grep -q '@ycpl_ast_function_name_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_has_main' "$work_dir/merged.ll"
grep -q '@ycpl_ast_typed_nodes' "$work_dir/merged.ll"
grep -q '@ycpl_ast_typed_digest' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_typed_nodes' "$work_dir/merged.ll"
grep -q '@ycpl_ast_function_bodies' "$work_dir/merged.ll"
grep -q '@ycpl_ast_function_body_tokens' "$work_dir/merged.ll"
grep -q '@ycpl_ast_function_body_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_node_count' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_node_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_return_exprs' "$work_dir/merged.ll"
grep -q '@ycpl_ast_return_expr_digest' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_statement_expr_lowering' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_call_expr_value' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_const_return_0' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_statement_expr_lowering' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_const_return_0' "$work_dir/merged.ll"
grep -q 'statement_nodes' "$work_dir/merged.ll"
grep -q 'expression_nodes' "$work_dir/merged.ll"
grep -q 'project_const_return_functions' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_node_call_probe' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_node_local_return_probe' "$work_dir/merged.ll"
grep -q 'assignment_nodes' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_node_call_probe' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_node_local_return_probe' "$work_dir/local_return.ll"
grep -q 'define i32 @ycpl_node_call_probe' "$work_dir/local_return.ll"
grep -q 'assignment_nodes' "$work_dir/local_return.ll"
grep -q 'call i32 @ycpl_node_call_probe' "$work_dir/local_return.ll"
grep -q 'alloca i32' "$work_dir/local_return.ll"
grep -q 'store i32' "$work_dir/local_return.ll"
grep -q 'load i32' "$work_dir/local_return.ll"
grep -q 'ret i32' "$work_dir/local_return.ll"
grep -q 'define i32 @ycpl_project_statement_expr_lowering' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_call_expr_value' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_const_return_0' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_const_return_0' "$work_dir/project_body.ll"
grep -q 'statement_nodes' "$work_dir/project_body.ll"
grep -q 'expression_nodes' "$work_dir/project_body.ll"
grep -q 'project_const_return_functions' "$work_dir/project_body.ll"
grep -q 'project_body_total' "$work_dir/project_body.ll"

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
grep -q 'alloca i32' "$self_arith_dir/merged.ll"
grep -q 'store i32 2' "$self_arith_dir/merged.ll"
grep -q 'store i32 3' "$self_arith_dir/merged.ll"
grep -q 'load i32' "$self_arith_dir/merged.ll"
grep -q 'mul i32' "$self_arith_dir/merged.ll"
grep -q 'add i32' "$self_arith_dir/merged.ll"
grep -q 'store i32 %addtmp' "$self_arith_dir/merged.ll"
grep -q 'sub i32' "$self_arith_dir/merged.ll"
grep -q 'ret i32 %subtmp' "$self_arith_dir/merged.ll"

self_call_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-call.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/56_self_codegen_call_assignment.yc -o "$self_call_dir" >/dev/null
grep -q 'define i32 @seed' "$self_call_dir/merged.ll"
grep -q 'call i32 @seed' "$self_call_dir/merged.ll"
grep -q 'alloca i32' "$self_call_dir/merged.ll"
grep -q 'store i32 %calltmp' "$self_call_dir/merged.ll"
grep -q 'store i32 %addtmp' "$self_call_dir/merged.ll"
grep -q 'ret i32 %loadtmp' "$self_call_dir/merged.ll"

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

self_call_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-call-native.XXXXXX")"
"$YCC_YCPL" build examples/56_self_codegen_call_assignment.yc -o "$self_call_native_dir" >/dev/null
set +e
"$self_call_native_dir/merged" >/dev/null 2>&1
call_native_status=$?
set -e
if [ "$call_native_status" -ne 13 ]; then
  printf 'Expected self-built call native binary to exit 13, got %d\n' "$call_native_status" >&2
  exit 1
fi
