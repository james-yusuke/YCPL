#!/usr/bin/env bash
set -euo pipefail
trap 'printf "run_self_host_stage_test failed at line %d\n" "$LINENO" >&2' ERR

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
traversal_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-stage-traversal.XXXXXX")"
cp -R compiler/ycpl "$traversal_dir/ycpl"
mkdir -p "$traversal_dir/ycpl/src/generated/deep"
cat >"$traversal_dir/ycpl/src/generated/deep/smoke.yc" <<'YCPL'
module compiler.ycpl.generated.deep.smoke

fn traversal_smoke() i32 {
    return 7
}
YCPL
"$YCC_YCPL" parse "$traversal_dir/ycpl" >/tmp/ycpl-stage-traversal-parse.out
if ! grep -q 'files=18' /tmp/ycpl-stage-traversal-parse.out; then
  printf 'Expected recursive traversal to discover 18 files in %s, got:\n' "$traversal_dir/ycpl" >&2
  cat /tmp/ycpl-stage-traversal-parse.out >&2
  find "$traversal_dir/ycpl/src" -type f -name '*.yc' | sort >&2
  exit 1
fi
grep -q 'files=17' /tmp/ycpl-stage-parse.out
grep -q 'files=17' /tmp/ycpl-stage-check.out
grep -q 'fn_digest=' /tmp/ycpl-stage-parse.out
grep -q 'body_digest=' /tmp/ycpl-stage-parse.out
grep -q 'body_tokens=' /tmp/ycpl-stage-parse.out
grep -q 'body_nodes=' /tmp/ycpl-stage-parse.out
grep -q 'node_digest=' /tmp/ycpl-stage-parse.out
grep -q 'return_exprs=' /tmp/ycpl-stage-parse.out
grep -q 'typed_nodes=' /tmp/ycpl-stage-parse.out
grep -q 'typed_digest=' /tmp/ycpl-stage-parse.out
grep -q 'main=1' /tmp/ycpl-stage-check.out
grep -q 'body_digest=' /tmp/ycpl-stage-check.out
grep -q 'ret_digest=' /tmp/ycpl-stage-check.out
grep -q 'typed_nodes=' /tmp/ycpl-stage-check.out
grep -q 'typed_digest=' /tmp/ycpl-stage-check.out

strict_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-ir.XXXXXX")"
YCPL_NO_BOOTSTRAP=1 "$YCC_YCPL" build-ir compiler/ycpl -o "$strict_ir_dir" >/tmp/ycpl-strict-ir.out
if [ ! -f "$strict_ir_dir/merged.ll" ]; then
  printf 'Expected strict self-host project build-ir to emit %s/merged.ll\n' "$strict_ir_dir" >&2
  cat /tmp/ycpl-strict-ir.out >&2
  exit 1
fi
if [ ! -f "$strict_ir_dir/local_return.ll" ]; then
  printf 'Expected strict self-host project build-ir to emit %s/local_return.ll\n' "$strict_ir_dir" >&2
  cat /tmp/ycpl-strict-ir.out >&2
  exit 1
fi
if [ ! -f "$strict_ir_dir/project_body.ll" ]; then
  printf 'Expected strict self-host project build-ir to emit %s/project_body.ll\n' "$strict_ir_dir" >&2
  cat /tmp/ycpl-strict-ir.out >&2
  exit 1
fi
grep -q 'define i32 @main' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_ast_fn_' "$strict_ir_dir/merged.ll"
grep -q 'declare i32 @puts' "$strict_ir_dir/merged.ll"
grep -q 'br i1' "$strict_ir_dir/merged.ll"
grep -q 'br label %loop' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_function_name_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_has_main' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_has_main' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_typed_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_typed_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_typed_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_function_bodies' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_function_body_tokens' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_function_body_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_function_bodies' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_node_count' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_node_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_body_node_count' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_return_exprs' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_return_expr_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_return_exprs' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_statement_expr_lowering' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_call_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_const_return_0' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_statement_expr_lowering' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_const_return_0' "$strict_ir_dir/merged.ll"
grep -q 'statement_nodes' "$strict_ir_dir/merged.ll"
grep -q 'expression_nodes' "$strict_ir_dir/merged.ll"
grep -q 'project_const_return_functions' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_node_call_probe' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_node_local_return_probe' "$strict_ir_dir/merged.ll"
grep -q 'assignment_nodes' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_node_call_probe' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_node_local_return_probe' "$strict_ir_dir/local_return.ll"
grep -q 'define i32 @ycpl_node_call_probe' "$strict_ir_dir/local_return.ll"
grep -q 'assignment_nodes' "$strict_ir_dir/local_return.ll"
grep -q 'call i32 @ycpl_node_call_probe' "$strict_ir_dir/local_return.ll"
grep -q 'alloca i32' "$strict_ir_dir/local_return.ll"
grep -q 'store i32' "$strict_ir_dir/local_return.ll"
grep -q 'load i32' "$strict_ir_dir/local_return.ll"
grep -q 'ret i32' "$strict_ir_dir/local_return.ll"
grep -q 'define i32 @ycpl_project_statement_expr_lowering' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_call_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_const_return_0' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_const_return_0' "$strict_ir_dir/project_body.ll"
grep -q 'statement_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'expression_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'project_const_return_functions' "$strict_ir_dir/project_body.ll"
grep -q 'project_body_total' "$strict_ir_dir/project_body.ll"

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
  export PATH="$(dirname "$LLC_BIN"):$PATH"
  "$LLC_BIN" -filetype=obj "$strict_ir_dir/merged.ll" -o "$strict_ir_dir/merged.o"
fi

strict_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-native.XXXXXX")"
YCPL_NO_BOOTSTRAP=1 "$YCC_YCPL" build compiler/ycpl -o "$strict_native_dir" >/tmp/ycpl-strict-native.out
if [ ! -x "$strict_native_dir/merged" ]; then
  printf 'Expected strict self-host project build to emit %s/merged\n' "$strict_native_dir" >&2
  cat /tmp/ycpl-strict-native.out >&2
  exit 1
fi
"$strict_native_dir/merged" parse compiler/ycpl >/tmp/ycpl-strict-native-parse.out
"$strict_native_dir/merged" check compiler/ycpl >/tmp/ycpl-strict-native-check.out
grep -q 'files=17' /tmp/ycpl-strict-native-parse.out
grep -q 'files=17' /tmp/ycpl-strict-native-check.out
grep -q 'fn_digest=' /tmp/ycpl-strict-native-parse.out
grep -q 'body_digest=' /tmp/ycpl-strict-native-parse.out
grep -q 'body_nodes=' /tmp/ycpl-strict-native-parse.out
grep -q 'return_exprs=' /tmp/ycpl-strict-native-parse.out
grep -q 'typed_nodes=' /tmp/ycpl-strict-native-parse.out
grep -q 'typed_digest=' /tmp/ycpl-strict-native-parse.out
grep -q 'main=1' /tmp/ycpl-strict-native-check.out
grep -q 'body_digest=' /tmp/ycpl-strict-native-check.out
grep -q 'ret_digest=' /tmp/ycpl-strict-native-check.out
grep -q 'typed_nodes=' /tmp/ycpl-strict-native-check.out
grep -q 'typed_digest=' /tmp/ycpl-strict-native-check.out

strict_stage3_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir compiler/ycpl -o "$strict_stage3_ir_dir" >/tmp/ycpl-strict-stage3-ir.out
if [ ! -f "$strict_stage3_ir_dir/merged.ll" ]; then
  printf 'Expected strict stage2 compiler to emit %s/merged.ll\n' "$strict_stage3_ir_dir" >&2
  cat /tmp/ycpl-strict-stage3-ir.out >&2
  exit 1
fi
grep -q 'define i32 @main' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_function_name_digest' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_typed_digest' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_function_body_digest' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_node_digest' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_return_expr_digest' "$strict_stage3_ir_dir/merged.ll"

strict_tiny42_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-tiny42-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/53_self_codegen_main.yc -o "$strict_tiny42_ir_dir" >/tmp/ycpl-strict-tiny42-ir.out
grep -q 'ret i32 42' "$strict_tiny42_ir_dir/merged.ll"

strict_tiny13_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-tiny13-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/54_self_codegen_arithmetic.yc -o "$strict_tiny13_ir_dir" >/tmp/ycpl-strict-tiny13-ir.out
grep -q 'ret i32 13' "$strict_tiny13_ir_dir/merged.ll"

renamed_tiny_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-renamed-tiny.XXXXXX")"
renamed_tiny="$renamed_tiny_dir/renamed_arithmetic.yc"
cp examples/54_self_codegen_arithmetic.yc "$renamed_tiny"
strict_renamed_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-renamed-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir "$renamed_tiny" -o "$strict_renamed_ir_dir" >/tmp/ycpl-strict-renamed-ir.out
grep -q 'ret i32 13' "$strict_renamed_ir_dir/merged.ll"

if [ -n "$LLC_BIN" ]; then
  "$LLC_BIN" -filetype=obj "$strict_stage3_ir_dir/merged.ll" -o "$strict_stage3_ir_dir/merged.o"

  strict_stage3_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-native.XXXXXX")"
  "$strict_native_dir/merged" build compiler/ycpl -o "$strict_stage3_native_dir" >/tmp/ycpl-strict-stage3-native.out
  if [ ! -x "$strict_stage3_native_dir/merged" ]; then
    printf 'Expected strict stage2 compiler to emit native %s/merged\n' "$strict_stage3_native_dir" >&2
    cat /tmp/ycpl-strict-stage3-native.out >&2
    exit 1
  fi
  "$strict_stage3_native_dir/merged" >/tmp/ycpl-strict-stage3-native-run.out
  grep -q 'YCPL stage3 AST IR' /tmp/ycpl-strict-stage3-native-run.out

  strict_tiny_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-tiny-native.XXXXXX")"
  "$strict_native_dir/merged" build "$renamed_tiny" -o "$strict_tiny_native_dir" >/tmp/ycpl-strict-tiny-native.out
  set +e
  "$strict_tiny_native_dir/merged" >/dev/null 2>&1
  strict_tiny_status=$?
  set -e
  if [ "$strict_tiny_status" -ne 13 ]; then
    printf 'Expected strict generated compiler tiny native to exit 13, got %d\n' "$strict_tiny_status" >&2
    exit 1
  fi

  llvm_bindir="$(dirname "$LLC_BIN")"
  if [ -x "$llvm_bindir/clang" ]; then
    strict_bindir_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-bindir-native.XXXXXX")"
    PATH="/usr/bin:/bin" LLVM_BINDIR="$llvm_bindir" "$strict_native_dir/merged" build "$renamed_tiny" -o "$strict_bindir_native_dir" >/tmp/ycpl-strict-bindir-native.out
    set +e
    "$strict_bindir_native_dir/merged" >/dev/null 2>&1
    strict_bindir_status=$?
    set -e
    if [ "$strict_bindir_status" -ne 13 ]; then
      printf 'Expected strict generated compiler LLVM_BINDIR native to exit 13, got %d\n' "$strict_bindir_status" >&2
      exit 1
    fi
  fi
fi

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
grep -q 'files=17' /tmp/ycpl-stage2-parse.out
grep -q 'files=17' /tmp/ycpl-stage2-check.out
grep -q 'fn_digest=' /tmp/ycpl-stage2-parse.out
grep -q 'body_digest=' /tmp/ycpl-stage2-parse.out
grep -q 'body_nodes=' /tmp/ycpl-stage2-parse.out
grep -q 'return_exprs=' /tmp/ycpl-stage2-parse.out
grep -q 'typed_nodes=' /tmp/ycpl-stage2-parse.out
grep -q 'typed_digest=' /tmp/ycpl-stage2-parse.out
grep -q 'main=1' /tmp/ycpl-stage2-check.out
grep -q 'body_digest=' /tmp/ycpl-stage2-check.out
grep -q 'ret_digest=' /tmp/ycpl-stage2-check.out
grep -q 'typed_nodes=' /tmp/ycpl-stage2-check.out
grep -q 'typed_digest=' /tmp/ycpl-stage2-check.out

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
