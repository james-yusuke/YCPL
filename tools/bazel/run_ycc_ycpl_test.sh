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

require_project_file_count() {
  output_file="$1"
  minimum="$2"
  label="$3"
  count="$(sed -n 's/.*files=\([0-9][0-9]*\).*/\1/p' "$output_file" | head -n 1)"
  if [ -z "$count" ] || [ "$count" -lt "$minimum" ]; then
    printf 'Expected %s to report at least %s files, got:\n' "$label" "$minimum" >&2
    cat "$output_file" >&2
    exit 1
  fi
}

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

fn traversal_flow_surface(items []i32) i32 {
    total := 0
    for item in items {
        if item == 0 {
            continue
        } else {
            total = total + item
        }
        if total > 10 {
            break
        }
    }
    return total
}
YCPL
"$YCC_YCPL" parse "$traversal_dir/ycpl" >/tmp/ycc-ycpl-traversal-parse.out
require_project_file_count /tmp/ycc-ycpl-traversal-parse.out 24 "recursive traversal in $traversal_dir/ycpl"
traversal_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-traversal-ir.XXXXXX")"
YCPL_NO_BOOTSTRAP=1 "$YCC_YCPL" build-ir "$traversal_dir/ycpl" -o "$traversal_ir_dir" >/tmp/ycc-ycpl-traversal-ir.out
grep -q 'node_lower_else_body' "$traversal_ir_dir/project_body.ll"
grep -q 'node_lower_break_slot' "$traversal_ir_dir/project_body.ll"
grep -q 'node_lower_continue_slot' "$traversal_ir_dir/project_body.ll"
grep -q 'node_lower_for_in_check' "$traversal_ir_dir/project_body.ll"
grep -q 'fn_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'body_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'body_tokens=' /tmp/ycc-ycpl-project-parse.out
grep -q 'body_nodes=' /tmp/ycc-ycpl-project-parse.out
grep -q 'body_slots=' /tmp/ycc-ycpl-project-parse.out
grep -q 'body_slot_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'node_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'transition_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'return_exprs=' /tmp/ycc-ycpl-project-parse.out
grep -q 'payload_ids=' /tmp/ycc-ycpl-project-parse.out
grep -q 'payload_types=' /tmp/ycc-ycpl-project-parse.out
grep -q 'payload_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'local_symbols=' /tmp/ycc-ycpl-project-parse.out
grep -q 'assignment_targets=' /tmp/ycc-ycpl-project-parse.out
grep -q 'call_targets=' /tmp/ycc-ycpl-project-parse.out
grep -q 'semantic_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'symbols=' /tmp/ycc-ycpl-project-parse.out
grep -q 'symbol_structs=' /tmp/ycc-ycpl-project-parse.out
grep -q 'symbol_imports=' /tmp/ycc-ycpl-project-parse.out
grep -q 'symbol_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'typed_nodes=' /tmp/ycc-ycpl-project-parse.out
grep -q 'sig_nodes=' /tmp/ycc-ycpl-project-parse.out
grep -q 'sig_calls=' /tmp/ycc-ycpl-project-parse.out
grep -q 'expr_table: nodes=' /tmp/ycc-ycpl-project-parse.out
grep -q 'primary=' /tmp/ycc-ycpl-project-parse.out
grep -q 'binary=' /tmp/ycc-ycpl-project-parse.out
grep -q 'unary=' /tmp/ycc-ycpl-project-parse.out
grep -q 'slots=' /tmp/ycc-ycpl-project-parse.out
grep -q 'slot_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'stmt_expr: links=' /tmp/ycc-ycpl-project-parse.out
grep -q 'tail=' /tmp/ycc-ycpl-project-parse.out
grep -q 'typed_digest=' /tmp/ycc-ycpl-project-parse.out
grep -q 'main=1' /tmp/ycc-ycpl-project-check.out
grep -q 'body_digest=' /tmp/ycc-ycpl-project-check.out
grep -q 'ret_digest=' /tmp/ycc-ycpl-project-check.out
grep -q 'transition_digest=' /tmp/ycc-ycpl-project-check.out
grep -q 'local_assign_edges=' /tmp/ycc-ycpl-project-check.out
grep -q 'if_nodes=' /tmp/ycc-ycpl-project-check.out
grep -q 'for_nodes=' /tmp/ycc-ycpl-project-check.out
grep -q 'payload_ids=' /tmp/ycc-ycpl-project-check.out
grep -q 'payload_types=' /tmp/ycc-ycpl-project-check.out
grep -q 'payload_digest=' /tmp/ycc-ycpl-project-check.out
grep -q 'local_symbols=' /tmp/ycc-ycpl-project-check.out
grep -q 'assignment_targets=' /tmp/ycc-ycpl-project-check.out
grep -q 'call_targets=' /tmp/ycc-ycpl-project-check.out
grep -q 'semantic_digest=' /tmp/ycc-ycpl-project-check.out
grep -q 'symbols=' /tmp/ycc-ycpl-project-check.out
grep -q 'symbol_structs=' /tmp/ycc-ycpl-project-check.out
grep -q 'symbol_imports=' /tmp/ycc-ycpl-project-check.out
grep -q 'symbol_digest=' /tmp/ycc-ycpl-project-check.out
grep -q 'typed_nodes=' /tmp/ycc-ycpl-project-check.out
grep -q 'sig_nodes=' /tmp/ycc-ycpl-project-check.out
grep -q 'sig_calls=' /tmp/ycc-ycpl-project-check.out
grep -q 'expr_table: nodes=' /tmp/ycc-ycpl-project-check.out
grep -q 'primary=' /tmp/ycc-ycpl-project-check.out
grep -q 'binary=' /tmp/ycc-ycpl-project-check.out
grep -q 'unary=' /tmp/ycc-ycpl-project-check.out
grep -q 'slots=' /tmp/ycc-ycpl-project-check.out
grep -q 'slot_digest=' /tmp/ycc-ycpl-project-check.out
grep -q 'stmt_expr: links=' /tmp/ycc-ycpl-project-check.out
grep -q 'tail=' /tmp/ycc-ycpl-project-check.out
grep -q 'body_slots=' /tmp/ycc-ycpl-project-check.out
grep -q 'body_slot_digest=' /tmp/ycc-ycpl-project-check.out
grep -q 'typed_digest=' /tmp/ycc-ycpl-project-check.out
"$YCC_YCPL" check examples/53_self_codegen_main.yc >/dev/null
"$YCC_YCPL" check examples/54_self_codegen_arithmetic.yc >/dev/null
"$YCC_YCPL" check examples/56_self_codegen_call_assignment.yc >/tmp/ycc-ycpl-check-call.out
grep -q 'value=13' /tmp/ycc-ycpl-check-call.out
"$YCC_YCPL" check examples/57_self_codegen_control_flow.yc >/tmp/ycc-ycpl-check-control.out
grep -q 'value=13' /tmp/ycc-ycpl-check-control.out
"$YCC_YCPL" check examples/58_self_codegen_else_helper.yc >/tmp/ycc-ycpl-check-else.out
grep -q 'value=13' /tmp/ycc-ycpl-check-else.out
"$YCC_YCPL" check examples/59_self_codegen_param_call.yc >/tmp/ycc-ycpl-check-param.out
grep -q 'value=13' /tmp/ycc-ycpl-check-param.out
"$YCC_YCPL" check examples/60_self_codegen_helper_chain.yc >/tmp/ycc-ycpl-check-chain.out
grep -q 'value=13' /tmp/ycc-ycpl-check-chain.out
"$YCC_YCPL" check examples/61_self_codegen_two_arg_call.yc >/tmp/ycc-ycpl-check-twoarg.out
grep -q 'value=13' /tmp/ycc-ycpl-check-twoarg.out
"$YCC_YCPL" check examples/62_self_codegen_forward_call.yc >/tmp/ycc-ycpl-check-forward.out
grep -q 'value=13' /tmp/ycc-ycpl-check-forward.out
"$YCC_YCPL" check examples/63_self_codegen_bool_condition.yc >/tmp/ycc-ycpl-check-bool.out
grep -q 'value=13' /tmp/ycc-ycpl-check-bool.out
"$YCC_YCPL" check examples/64_self_codegen_bool_helper.yc >/tmp/ycc-ycpl-check-bool-helper.out
grep -q 'value=13' /tmp/ycc-ycpl-check-bool-helper.out
"$YCC_YCPL" check examples/65_self_codegen_string_local.yc >/tmp/ycc-ycpl-check-string.out
grep -q 'value=13' /tmp/ycc-ycpl-check-string.out
"$YCC_YCPL" check examples/66_self_codegen_extern_string_call.yc >/tmp/ycc-ycpl-check-extern-string.out
grep -q 'value=13' /tmp/ycc-ycpl-check-extern-string.out
"$YCC_YCPL" check examples/67_self_codegen_extern_malloc_ptr.yc >/tmp/ycc-ycpl-check-extern-malloc.out
grep -q 'value=13' /tmp/ycc-ycpl-check-extern-malloc.out
"$YCC_YCPL" check examples/68_self_codegen_llvm_c_api_call.yc >/tmp/ycc-ycpl-check-llvm-c-api.out
grep -q 'value=13' /tmp/ycc-ycpl-check-llvm-c-api.out
"$YCC_YCPL" check examples/69_self_codegen_void_extern_call.yc >/tmp/ycc-ycpl-check-void-extern.out
grep -q 'value=13' /tmp/ycc-ycpl-check-void-extern.out
"$YCC_YCPL" check examples/70_self_codegen_llvm_function_type_call.yc >/tmp/ycc-ycpl-check-llvm-function-type.out
grep -q 'value=13' /tmp/ycc-ycpl-check-llvm-function-type.out
"$YCC_YCPL" check examples/71_self_codegen_llvm_builder_memory_call.yc >/tmp/ycc-ycpl-check-llvm-builder-memory.out
grep -q 'value=13' /tmp/ycc-ycpl-check-llvm-builder-memory.out
"$YCC_YCPL" check examples/72_self_codegen_llvm_call2_icmp_call.yc >/tmp/ycc-ycpl-check-llvm-call2-icmp.out
grep -q 'value=13' /tmp/ycc-ycpl-check-llvm-call2-icmp.out
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
grep -q 'ret ptr null' "$work_dir/merged.ll"
grep -q 'icmp eq ptr %irtext, null' "$work_dir/merged.ll"
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
grep -q '@ycpl_ast_body_transition_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_slot_count' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_nonempty_slots' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_max_nodes_per_slot' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_slot_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_identifier_payloads' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_type_payloads' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_payload_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_local_symbol_refs' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_assignment_target_refs' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_call_target_refs' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_semantic_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_symbol_functions' "$work_dir/merged.ll"
grep -q '@ycpl_ast_symbol_structs' "$work_dir/merged.ll"
grep -q '@ycpl_ast_symbol_imports' "$work_dir/merged.ll"
grep -q '@ycpl_ast_symbol_zero_param_functions' "$work_dir/merged.ll"
grep -q '@ycpl_ast_symbol_nonzero_param_functions' "$work_dir/merged.ll"
grep -q '@ycpl_ast_symbol_function_signature_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_symbol_call_sites' "$work_dir/merged.ll"
grep -q '@ycpl_ast_symbol_nonzero_arg_calls' "$work_dir/merged.ll"
grep -q '@ycpl_ast_symbol_call_arity_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_signature_nodes' "$work_dir/merged.ll"
grep -q '@ycpl_ast_signature_function_nodes' "$work_dir/merged.ll"
grep -q '@ycpl_ast_signature_call_nodes' "$work_dir/merged.ll"
grep -q '@ycpl_ast_signature_arity_slots' "$work_dir/merged.ll"
grep -q '@ycpl_ast_signature_typed_return_functions' "$work_dir/merged.ll"
grep -q '@ycpl_ast_signature_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_expr_table_nodes' "$work_dir/merged.ll"
grep -q '@ycpl_stage_expr_lowered_floor' "$work_dir/merged.ll"
grep -q '@ycpl_ast_expr_primary_nodes' "$work_dir/merged.ll"
grep -q '@.stage3.stage4.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinyllvmcall2icmp.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinyllvmbuildermemory.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinyllvmfunctiontype.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinyvoidextern.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinyllvmcapi.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinyexternmalloc.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinyexternstring.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinystring.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinyboolhelper.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinybool.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinyelse.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinycontrol.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinychain.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinytwoarg.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinyparam.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tinycall.ir' "$work_dir/merged.ll"
grep -q '@.stage3.tiny13.ir' "$work_dir/merged.ll"
grep -q 'define ptr @ycpl_stage3_select_ir' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_stage3_write_ir_text' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_stage3_build_native_from_ir_text' "$work_dir/merged.ll"
grep -q '@ycpl_ast_expr_binary_nodes' "$work_dir/merged.ll"
grep -q '@ycpl_ast_expr_table_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_expr_slot_count' "$work_dir/merged.ll"
grep -q '@ycpl_ast_expr_slot_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_stmt_expr_links' "$work_dir/merged.ll"
grep -q '@ycpl_ast_stmt_expr_tail_nodes' "$work_dir/merged.ll"
grep -q '@ycpl_ast_stmt_expr_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_symbol_digest' "$work_dir/merged.ll"
grep -q '@.ycpl.tinyllvmcall2icmp.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinyllvmbuildermemory.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinyllvmfunctiontype.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinyvoidextern.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinyllvmcapi.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinyexternmalloc.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinyexternstring.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinystring.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinyboolhelper.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinybool.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinyelse.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinycontrol.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinychain.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinytwoarg.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinyparam.ir' "$work_dir/merged.ll"
grep -q '@.ycpl.tinycall.ir' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_body_payload_digest' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_body_semantic_digest' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_body_slot_count' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_body_slot_digest' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_symbol_function_signature_digest' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_symbol_call_sites' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_symbol_call_arity_digest' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_signature_nodes' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_signature_typed_return_functions' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_signature_digest' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_expr_table_nodes' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_stage_expr_lowered_floor' "$work_dir/merged.ll"
grep -q 'exprfloorok' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_expr_table_digest' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_expr_slot_count' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_expr_slot_digest' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_stmt_expr_links' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_stmt_expr_digest' "$work_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_symbol_digest' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_if_nodes' "$work_dir/merged.ll"
grep -q '@ycpl_ast_body_for_nodes' "$work_dir/merged.ll"
grep -q '@ycpl_ast_return_exprs' "$work_dir/merged.ll"
grep -q '@ycpl_ast_return_expr_digest' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_statement_expr_lowering' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_call_expr_value' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_const_return_0' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_all_function_bodies' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_0' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_dynamic_first_body_0' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_7' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_15' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_31' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_63' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_400' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_range_0_63' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_dynamic_range_body_0' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_range_320_383' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_range_384_447' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_project_dynamic_range_body_6' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_statement_expr_lowering' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_const_return_0' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_all_function_bodies' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_0' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_dynamic_first_body_0' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_7' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_15' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_31' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_63' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_400' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_range_0_63' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_dynamic_range_body_0' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_range_320_383' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_range_384_447' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_project_dynamic_range_body_6' "$work_dir/merged.ll"
grep -q 'statement_nodes' "$work_dir/merged.ll"
grep -q 'expression_nodes' "$work_dir/merged.ll"
grep -q 'function_body_statement_resolved_type_slot' "$work_dir/merged.ll"
grep -q 'function_body_statement_resolved_type_value' "$work_dir/merged.ll"
grep -q 'function_body_resolved_statement_value' "$work_dir/merged.ll"
grep -q 'function_body_resolved_local_loaded' "$work_dir/merged.ll"
grep -q 'function_body_resolved_assignment_loaded' "$work_dir/merged.ll"
grep -q 'function_body_resolved_call_loaded' "$work_dir/merged.ll"
grep -q 'function_body_resolved_return_loaded' "$work_dir/merged.ll"
grep -q 'function_body_resolved_statement_lowered_state' "$work_dir/merged.ll"
grep -q 'function_body_statement_resolved_type_slot' "$work_dir/project_body.ll"
grep -q 'function_body_statement_resolved_type_value' "$work_dir/project_body.ll"
grep -q 'function_body_resolved_statement_value' "$work_dir/project_body.ll"
grep -q 'function_body_resolved_local_loaded' "$work_dir/project_body.ll"
grep -q 'function_body_resolved_assignment_loaded' "$work_dir/project_body.ll"
grep -q 'function_body_resolved_call_loaded' "$work_dir/project_body.ll"
grep -q 'function_body_resolved_return_loaded' "$work_dir/project_body.ll"
grep -q 'function_body_resolved_statement_lowered_state' "$work_dir/project_body.ll"
grep -q 'expr_table_nodes' "$work_dir/merged.ll"
grep -q 'expression_table_lowered' "$work_dir/merged.ll"
grep -q 'expr_slot_count' "$work_dir/merged.ll"
grep -q 'expression_slot_lowered' "$work_dir/merged.ll"
grep -q 'project_const_return_functions' "$work_dir/merged.ll"
grep -q 'all_function_bodies_lowered' "$work_dir/merged.ll"
grep -q 'control_function_body_lowered' "$work_dir/merged.ll"
grep -q 'function_body_slots_lowered' "$work_dir/merged.ll"
grep -q 'function_body_base_slots' "$work_dir/merged.ll"
grep -q 'function_body_extra_slots' "$work_dir/merged.ll"
grep -q 'function_body_extended_slots' "$work_dir/merged.ll"
grep -q 'function_body_first64_slots_lowered' "$work_dir/merged.ll"
grep -q 'function_body_all_individual_lowered' "$work_dir/merged.ll"
grep -q 'function_body_dynamic_first_lowered_0' "$work_dir/merged.ll"
grep -q 'function_body_dynamic_selfhost_gate' "$work_dir/merged.ll"
grep -q 'function_body_dynamic_lowered_400' "$work_dir/merged.ll"
grep -q 'function_body_dynamic_range_lowered_0' "$work_dir/merged.ll"
grep -q 'function_body_dynamic_range_total_6' "$work_dir/merged.ll"
grep -q 'function_body_dynamic_range_buckets_lowered' "$work_dir/merged.ll"
grep -q 'function_body_dynamic_range_gate' "$work_dir/merged.ll"
grep -q 'function_body_source_traversal_gate' "$work_dir/merged.ll"
grep -q 'function_body_second_half' "$work_dir/merged.ll"
grep -q 'function_body_tail' "$work_dir/merged.ll"
grep -q 'function_body_range6_lowered' "$work_dir/merged.ll"
grep -q 'function_body_range_tail' "$work_dir/merged.ll"
grep -q 'function_body_ranges_lowered' "$work_dir/merged.ll"
grep -q 'function_body_slot_and_range_lowered' "$work_dir/merged.ll"
grep -q 'function_body_score' "$work_dir/merged.ll"
grep -q 'function_body_local_state' "$work_dir/merged.ll"
grep -q 'function_body_assignment_state' "$work_dir/merged.ll"
grep -q 'function_body_call_state' "$work_dir/merged.ll"
grep -q 'function_body_return_state' "$work_dir/merged.ll"
grep -q 'function_body_symbol_env' "$work_dir/merged.ll"
grep -q 'function_body_value_state' "$work_dir/merged.ll"
grep -q 'function_body_control_state' "$work_dir/merged.ll"
grep -q 'function_body_identifier_payloads' "$work_dir/merged.ll"
grep -q 'function_body_literal_payloads' "$work_dir/merged.ll"
grep -q 'function_body_type_payloads' "$work_dir/merged.ll"
grep -q 'function_body_control_payloads' "$work_dir/merged.ll"
grep -q 'function_body_local_symbol_refs' "$work_dir/merged.ll"
grep -q 'function_body_assignment_target_refs' "$work_dir/merged.ll"
grep -q 'function_body_call_target_refs' "$work_dir/merged.ll"
grep -q 'function_body_return_symbol_refs' "$work_dir/merged.ll"
grep -q 'function_body_semantic_surface' "$work_dir/merged.ll"
grep -q 'function_body_semantic_node_sum' "$work_dir/merged.ll"
grep -q 'function_body_assignment_value_flow' "$work_dir/merged.ll"
grep -q 'function_body_call_value_flow' "$work_dir/merged.ll"
grep -q 'function_body_return_value_flow' "$work_dir/merged.ll"
grep -q 'function_body_lowered_environment_state' "$work_dir/merged.ll"
grep -q 'function_body_lowered_statement_state' "$work_dir/merged.ll"
grep -q 'function_body_lowered_total' "$work_dir/merged.ll"
grep -q 'function_expr_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_lowered_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_value_state' "$work_dir/merged.ll"
grep -q 'function_expr_type_state' "$work_dir/merged.ll"
grep -q 'loaded_function_expr_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_table_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_literal_value_state' "$work_dir/merged.ll"
grep -q 'function_expr_string_literal_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_bool_literal_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_none_literal_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_numeric_literal_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_identifier_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_identifier_resolved_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_call_value_state' "$work_dir/merged.ll"
grep -q 'function_expr_call_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_call_resolved_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_project_call_resolved_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_typed_identifier_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_typed_call_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_project_typed_call_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_typed_symbol_surface' "$work_dir/merged.ll"
grep -q 'function_expr_project_type_surface' "$work_dir/merged.ll"
grep -q 'function_expression_typed_shape_score' "$work_dir/merged.ll"
grep -q 'function_expr_member_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_member_field0_gep' "$work_dir/merged.ll"
grep -q 'function_expr_member_field_index_gep' "$work_dir/merged.ll"
grep -q 'function_expr_member_field_index_value' "$work_dir/merged.ll"
grep -q 'function_expr_member_resolved_field_index_value' "$work_dir/merged.ll"
grep -q 'function_expr_member_actual_struct_gep' "$work_dir/merged.ll"
grep -q 'function_expr_member_actual_field_loaded' "$work_dir/merged.ll"
grep -q 'function_expr_member_actual_field_value' "$work_dir/merged.ll"
grep -q 'function_expr_member_name_hash_value' "$work_dir/merged.ll"
grep -q 'function_expr_member_name_indexed_value' "$work_dir/merged.ll"
grep -q 'function_expr_member_field2_gep' "$work_dir/merged.ll"
grep -q 'function_expr_index_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_index_slice_len_gep' "$work_dir/merged.ll"
grep -q 'function_expr_index_bounds_check' "$work_dir/merged.ll"
grep -q 'function_expr_index_gep' "$work_dir/merged.ll"
grep -q 'expr_lower_index_slice_len_gep' "$work_dir/merged.ll"
grep -q 'expr_lower_index_bounds_check' "$work_dir/merged.ll"
grep -q 'expr_lower_index_in_bounds' "$work_dir/merged.ll"
grep -q 'expr_lower_index_oob' "$work_dir/merged.ll"
grep -q 'expr_lower_index_gep' "$work_dir/merged.ll"
grep -q 'expr_lower_index_len_checked_value' "$work_dir/merged.ll"
grep -q 'alloca \[4 x i32\]' "$work_dir/merged.ll"
grep -q 'function_expr_binary_value_state' "$work_dir/merged.ll"
grep -q 'function_expr_binary_value_cmp' "$work_dir/merged.ll"
grep -q 'function_expr_binary_bool_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_binary_numeric_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_unary_numeric_type_state' "$work_dir/merged.ll"
grep -q 'function_expr_lowered_value_state' "$work_dir/merged.ll"
grep -q 'function_expr_lowered_type_state' "$work_dir/merged.ll"
grep -q 'function_body_expr_value_environment' "$work_dir/merged.ll"
grep -q 'function_body_expr_typed_environment' "$work_dir/merged.ll"
grep -q 'function_expr_value_for_statement' "$work_dir/merged.ll"
grep -q 'function_expr_type_for_statement' "$work_dir/merged.ll"
grep -q 'function_expr_typed_value_for_statement' "$work_dir/merged.ll"
grep -q 'function_body_assignment_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_return_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_value_expr_value' "$work_dir/merged.ll"
grep -q 'function_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_statement_expr_type' "$work_dir/merged.ll"
grep -q 'function_body_statement_expr_value_flow' "$work_dir/merged.ll"
grep -q 'function_body_statement_expr_typed_value' "$work_dir/merged.ll"
grep -q 'function_body_statement_ast_value_slot' "$work_dir/merged.ll"
grep -q 'function_body_statement_ast_value_seed' "$work_dir/merged.ll"
grep -q 'function_body_statement_ast_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_direct_local_loaded' "$work_dir/merged.ll"
grep -q 'function_body_direct_assignment_value' "$work_dir/merged.ll"
grep -q 'function_body_direct_assignment_loaded' "$work_dir/merged.ll"
grep -q 'function_body_direct_call_value' "$work_dir/merged.ll"
grep -q 'function_body_direct_call_loaded' "$work_dir/merged.ll"
grep -q 'function_body_direct_return_loaded' "$work_dir/merged.ll"
grep -q 'function_body_statement_ast_lowered_state' "$work_dir/merged.ll"
grep -q 'function_body_local_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_assignment_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_call_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_return_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_i32_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_bool_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_string_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_pointer_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_none_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_unknown_statement_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_statement_expr_typed_environment' "$work_dir/merged.ll"
grep -q 'function_body_expr_typed_with_statement_environment' "$work_dir/merged.ll"
grep -q 'function_body_statement_expr_owner_state' "$work_dir/merged.ll"
grep -q 'function_body_statement_expr_owner_value_flow' "$work_dir/merged.ll"
grep -q 'function_body_lowered_statement_expr_owner_state' "$work_dir/merged.ll"
grep -q 'function_statement_expr_owner_limit' "$work_dir/merged.ll"
grep -q 'function_body_statement_expr_owner_lowered_count' "$work_dir/merged.ll"
grep -q 'function_body_lowered_statement_expr_owner_count' "$work_dir/merged.ll"
grep -q 'function_body_statement_expr_owner_lowered_state' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_sequence_state' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_kind_state' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_expr_count_state' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_semantic_sequence_state' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_local_sequence_state' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_assignment_sequence_state' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_call_sequence_state' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_return_sequence_state' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_control_sequence_state' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_semantic_sequence_lowered' "$work_dir/merged.ll"
grep -q 'function_body_ast_node_sequence_lowered' "$work_dir/merged.ll"
grep -q 'function_body_expr_owner_environment' "$work_dir/merged.ll"
grep -q 'node_statement_expr_owner_score' "$work_dir/merged.ll"
grep -q 'function_statement_expr_ownership_score' "$work_dir/merged.ll"
grep -q 'function_body_owned_expr_sum' "$work_dir/merged.ll"
grep -q 'function_tail_expr_value' "$work_dir/merged.ll"
grep -q 'function_body_tail_expr_value_flow' "$work_dir/merged.ll"
grep -Eq 'store i32 ([6-9][0-9][0-9]|[1-9][0-9][0-9][0-9]), ptr %function_expr_lowered_nodes' "$work_dir/merged.ll"
grep -q 'function_expression_slot_score' "$work_dir/merged.ll"
grep -q 'function_expr_identifier_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_literal_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_string_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_bool_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_none_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_member_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_index_nodes' "$work_dir/merged.ll"
grep -q 'function_expr_literal_type_surface' "$work_dir/merged.ll"
grep -q 'function_expr_call_access_sum' "$work_dir/merged.ll"
grep -q 'function_expression_shape_score' "$work_dir/merged.ll"
grep -q 'function_expr_digest_score' "$work_dir/merged.ll"
grep -q 'function_expression_lowered' "$work_dir/merged.ll"
grep -q 'function_expression_sequence_lowered' "$work_dir/merged.ll"
grep -q 'function_body_expr_sum' "$work_dir/merged.ll"
grep -q 'node_sequence_digest_score' "$work_dir/merged.ll"
grep -q 'node_sequence_score' "$work_dir/merged.ll"
grep -q 'node_metadata_score' "$work_dir/merged.ll"
grep -q 'node_source_pos_score' "$work_dir/merged.ll"
grep -q 'node_payload_score' "$work_dir/merged.ll"
grep -q 'node_semantic_role_score' "$work_dir/merged.ll"
grep -q 'node_lower_if_then' "$work_dir/merged.ll"
grep -q 'node_lower_for_check' "$work_dir/merged.ll"
grep -q 'node_lower_for_has_more' "$work_dir/merged.ll"
grep -q 'node_lower_else_body' "$work_dir/merged.ll"
grep -q 'node_lower_break_slot' "$work_dir/merged.ll"
grep -q 'function_if_then' "$work_dir/merged.ll"
grep -q 'function_for_check' "$work_dir/merged.ll"
grep -q 'function_for_has_more' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_node_call_probe' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_node_transition_probe' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_node_control_flow_probe' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_node_local_return_probe' "$work_dir/merged.ll"
grep -q 'assignment_nodes' "$work_dir/merged.ll"
grep -q 'transition_digest' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_node_call_probe' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_node_transition_probe' "$work_dir/merged.ll"
grep -q 'call i32 @ycpl_node_control_flow_probe' "$work_dir/merged.ll"
grep -q 'define i32 @ycpl_node_local_return_probe' "$work_dir/local_return.ll"
grep -q 'define i32 @ycpl_node_call_probe' "$work_dir/local_return.ll"
grep -q 'define i32 @ycpl_node_transition_probe' "$work_dir/local_return.ll"
grep -q 'define i32 @ycpl_node_control_flow_probe' "$work_dir/local_return.ll"
grep -q 'if_then' "$work_dir/local_return.ll"
grep -q 'for_check' "$work_dir/local_return.ll"
grep -q 'for_body' "$work_dir/local_return.ll"
grep -q 'for_has_more' "$work_dir/local_return.ll"
grep -q 'assignment_nodes' "$work_dir/local_return.ll"
grep -q 'transition_digest' "$work_dir/local_return.ll"
grep -q 'call i32 @ycpl_node_call_probe' "$work_dir/local_return.ll"
grep -q 'call i32 @ycpl_node_transition_probe' "$work_dir/local_return.ll"
grep -q 'call i32 @ycpl_node_control_flow_probe' "$work_dir/local_return.ll"
grep -q 'alloca i32' "$work_dir/local_return.ll"
grep -q 'store i32' "$work_dir/local_return.ll"
grep -q 'load i32' "$work_dir/local_return.ll"
grep -q 'ret i32' "$work_dir/local_return.ll"
grep -q 'define i32 @ycpl_project_statement_expr_lowering' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_call_expr_value' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_const_return_0' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_all_function_bodies' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_0' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_dynamic_first_body_0' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_7' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_15' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_31' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_63' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_400' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_range_0_63' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_dynamic_range_body_0' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_range_320_383' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_range_384_447' "$work_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_dynamic_range_body_6' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_const_return_0' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_all_function_bodies' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_0' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_dynamic_first_body_0' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_7' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_15' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_31' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_63' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_400' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_range_0_63' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_dynamic_range_body_0' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_range_320_383' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_range_384_447' "$work_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_dynamic_range_body_6' "$work_dir/project_body.ll"
grep -q 'statement_nodes' "$work_dir/project_body.ll"
grep -q 'expression_nodes' "$work_dir/project_body.ll"
grep -q 'expr_table_nodes' "$work_dir/project_body.ll"
grep -q 'expression_table_lowered' "$work_dir/project_body.ll"
grep -q 'expr_slot_count' "$work_dir/project_body.ll"
grep -q 'expression_slot_lowered' "$work_dir/project_body.ll"
grep -q 'project_const_return_functions' "$work_dir/project_body.ll"
grep -q 'all_function_bodies_lowered' "$work_dir/project_body.ll"
grep -q 'control_function_body_lowered' "$work_dir/project_body.ll"
grep -q 'function_body_slots_lowered' "$work_dir/project_body.ll"
grep -q 'function_body_base_slots' "$work_dir/project_body.ll"
grep -q 'function_body_extra_slots' "$work_dir/project_body.ll"
grep -q 'function_body_extended_slots' "$work_dir/project_body.ll"
grep -q 'function_body_first64_slots_lowered' "$work_dir/project_body.ll"
grep -q 'function_body_all_individual_lowered' "$work_dir/project_body.ll"
grep -q 'function_body_dynamic_first_lowered_0' "$work_dir/project_body.ll"
grep -q 'function_body_dynamic_selfhost_gate' "$work_dir/project_body.ll"
grep -q 'function_body_dynamic_lowered_400' "$work_dir/project_body.ll"
grep -q 'function_body_dynamic_range_lowered_0' "$work_dir/project_body.ll"
grep -q 'function_body_dynamic_range_total_6' "$work_dir/project_body.ll"
grep -q 'function_body_dynamic_range_buckets_lowered' "$work_dir/project_body.ll"
grep -q 'function_body_dynamic_range_gate' "$work_dir/project_body.ll"
grep -q 'function_body_source_traversal_gate' "$work_dir/project_body.ll"
grep -q 'function_body_second_half' "$work_dir/project_body.ll"
grep -q 'function_body_tail' "$work_dir/project_body.ll"
grep -q 'function_body_range6_lowered' "$work_dir/project_body.ll"
grep -q 'function_body_range_tail' "$work_dir/project_body.ll"
grep -q 'function_body_ranges_lowered' "$work_dir/project_body.ll"
grep -q 'function_body_slot_and_range_lowered' "$work_dir/project_body.ll"
grep -q 'function_body_score' "$work_dir/project_body.ll"
grep -q 'function_body_local_state' "$work_dir/project_body.ll"
grep -q 'function_body_assignment_state' "$work_dir/project_body.ll"
grep -q 'function_body_call_state' "$work_dir/project_body.ll"
grep -q 'function_body_return_state' "$work_dir/project_body.ll"
grep -q 'function_body_symbol_env' "$work_dir/project_body.ll"
grep -q 'function_body_value_state' "$work_dir/project_body.ll"
grep -q 'function_body_control_state' "$work_dir/project_body.ll"
grep -q 'function_body_identifier_payloads' "$work_dir/project_body.ll"
grep -q 'function_body_literal_payloads' "$work_dir/project_body.ll"
grep -q 'function_body_type_payloads' "$work_dir/project_body.ll"
grep -q 'function_body_control_payloads' "$work_dir/project_body.ll"
grep -q 'function_body_local_symbol_refs' "$work_dir/project_body.ll"
grep -q 'function_body_assignment_target_refs' "$work_dir/project_body.ll"
grep -q 'function_body_call_target_refs' "$work_dir/project_body.ll"
grep -q 'function_body_return_symbol_refs' "$work_dir/project_body.ll"
grep -q 'function_body_semantic_surface' "$work_dir/project_body.ll"
grep -q 'function_body_semantic_node_sum' "$work_dir/project_body.ll"
grep -q 'function_body_assignment_value_flow' "$work_dir/project_body.ll"
grep -q 'function_body_call_value_flow' "$work_dir/project_body.ll"
grep -q 'function_body_return_value_flow' "$work_dir/project_body.ll"
grep -q 'function_body_lowered_environment_state' "$work_dir/project_body.ll"
grep -q 'function_body_lowered_statement_state' "$work_dir/project_body.ll"
grep -q 'function_body_lowered_total' "$work_dir/project_body.ll"
grep -q 'function_expr_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_lowered_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_value_state' "$work_dir/project_body.ll"
grep -q 'function_expr_type_state' "$work_dir/project_body.ll"
grep -q 'loaded_function_expr_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_table_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_literal_value_state' "$work_dir/project_body.ll"
grep -q 'function_expr_string_literal_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_bool_literal_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_none_literal_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_numeric_literal_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_identifier_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_identifier_resolved_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_call_value_state' "$work_dir/project_body.ll"
grep -q 'function_expr_call_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_call_resolved_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_project_call_resolved_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_typed_identifier_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_typed_call_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_project_typed_call_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_typed_symbol_surface' "$work_dir/project_body.ll"
grep -q 'function_expr_project_type_surface' "$work_dir/project_body.ll"
grep -q 'function_expression_typed_shape_score' "$work_dir/project_body.ll"
grep -q 'function_expr_member_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_member_field0_gep' "$work_dir/project_body.ll"
grep -q 'function_expr_member_field_index_gep' "$work_dir/project_body.ll"
grep -q 'function_expr_member_field_index_value' "$work_dir/project_body.ll"
grep -q 'function_expr_member_resolved_field_index_value' "$work_dir/project_body.ll"
grep -q 'function_expr_member_actual_struct_gep' "$work_dir/project_body.ll"
grep -q 'function_expr_member_actual_field_loaded' "$work_dir/project_body.ll"
grep -q 'function_expr_member_actual_field_value' "$work_dir/project_body.ll"
grep -q 'function_expr_member_name_hash_value' "$work_dir/project_body.ll"
grep -q 'function_expr_member_name_indexed_value' "$work_dir/project_body.ll"
grep -q 'function_expr_member_field2_gep' "$work_dir/project_body.ll"
grep -q 'function_expr_index_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_index_slice_len_gep' "$work_dir/project_body.ll"
grep -q 'function_expr_index_bounds_check' "$work_dir/project_body.ll"
grep -q 'function_expr_index_gep' "$work_dir/project_body.ll"
grep -q 'expr_lower_index_slice_len_gep' "$work_dir/project_body.ll"
grep -q 'expr_lower_index_bounds_check' "$work_dir/project_body.ll"
grep -q 'expr_lower_index_in_bounds' "$work_dir/project_body.ll"
grep -q 'expr_lower_index_oob' "$work_dir/project_body.ll"
grep -q 'expr_lower_index_gep' "$work_dir/project_body.ll"
grep -q 'expr_lower_index_len_checked_value' "$work_dir/project_body.ll"
grep -q 'alloca \[4 x i32\]' "$work_dir/project_body.ll"
grep -q 'function_expr_binary_value_state' "$work_dir/project_body.ll"
grep -q 'function_expr_binary_value_cmp' "$work_dir/project_body.ll"
grep -q 'function_expr_binary_bool_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_binary_numeric_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_unary_numeric_type_state' "$work_dir/project_body.ll"
grep -q 'function_expr_lowered_value_state' "$work_dir/project_body.ll"
grep -q 'function_expr_lowered_type_state' "$work_dir/project_body.ll"
grep -q 'function_body_expr_value_environment' "$work_dir/project_body.ll"
grep -q 'function_body_expr_typed_environment' "$work_dir/project_body.ll"
grep -q 'function_expr_value_for_statement' "$work_dir/project_body.ll"
grep -q 'function_expr_type_for_statement' "$work_dir/project_body.ll"
grep -q 'function_expr_typed_value_for_statement' "$work_dir/project_body.ll"
grep -q 'function_body_assignment_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_return_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_value_expr_value' "$work_dir/project_body.ll"
grep -q 'function_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_statement_expr_type' "$work_dir/project_body.ll"
grep -q 'function_body_statement_expr_value_flow' "$work_dir/project_body.ll"
grep -q 'function_body_statement_expr_typed_value' "$work_dir/project_body.ll"
grep -q 'function_body_statement_ast_value_slot' "$work_dir/project_body.ll"
grep -q 'function_body_statement_ast_value_seed' "$work_dir/project_body.ll"
grep -q 'function_body_statement_ast_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_direct_local_loaded' "$work_dir/project_body.ll"
grep -q 'function_body_direct_assignment_value' "$work_dir/project_body.ll"
grep -q 'function_body_direct_assignment_loaded' "$work_dir/project_body.ll"
grep -q 'function_body_direct_call_value' "$work_dir/project_body.ll"
grep -q 'function_body_direct_call_loaded' "$work_dir/project_body.ll"
grep -q 'function_body_direct_return_loaded' "$work_dir/project_body.ll"
grep -q 'function_body_statement_ast_lowered_state' "$work_dir/project_body.ll"
grep -q 'function_body_local_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_assignment_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_call_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_return_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_i32_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_bool_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_string_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_pointer_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_none_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_unknown_statement_expr_value' "$work_dir/project_body.ll"
grep -q 'function_body_statement_expr_typed_environment' "$work_dir/project_body.ll"
grep -q 'function_body_expr_typed_with_statement_environment' "$work_dir/project_body.ll"
grep -q 'function_body_statement_expr_owner_state' "$work_dir/project_body.ll"
grep -q 'function_body_statement_expr_owner_value_flow' "$work_dir/project_body.ll"
grep -q 'function_body_lowered_statement_expr_owner_state' "$work_dir/project_body.ll"
grep -q 'function_statement_expr_owner_limit' "$work_dir/project_body.ll"
grep -q 'function_body_statement_expr_owner_lowered_count' "$work_dir/project_body.ll"
grep -q 'function_body_lowered_statement_expr_owner_count' "$work_dir/project_body.ll"
grep -q 'function_body_statement_expr_owner_lowered_state' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_sequence_state' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_kind_state' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_expr_count_state' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_semantic_sequence_state' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_local_sequence_state' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_assignment_sequence_state' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_call_sequence_state' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_return_sequence_state' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_control_sequence_state' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_semantic_sequence_lowered' "$work_dir/project_body.ll"
grep -q 'function_body_ast_node_sequence_lowered' "$work_dir/project_body.ll"
grep -q 'function_body_expr_owner_environment' "$work_dir/project_body.ll"
grep -q 'node_statement_expr_owner_score' "$work_dir/project_body.ll"
grep -q 'function_statement_expr_ownership_score' "$work_dir/project_body.ll"
grep -q 'function_body_owned_expr_sum' "$work_dir/project_body.ll"
grep -q 'function_tail_expr_value' "$work_dir/project_body.ll"
grep -q 'function_tail_expr_type' "$work_dir/project_body.ll"
grep -q 'function_body_tail_expr_value_flow' "$work_dir/project_body.ll"
grep -q 'function_body_tail_expr_typed_value' "$work_dir/project_body.ll"
grep -Eq 'store i32 ([6-9][0-9][0-9]|[1-9][0-9][0-9][0-9]), ptr %function_expr_lowered_nodes' "$work_dir/project_body.ll"
grep -q 'function_expression_slot_score' "$work_dir/project_body.ll"
grep -q 'function_expr_identifier_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_literal_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_string_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_bool_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_none_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_member_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_index_nodes' "$work_dir/project_body.ll"
grep -q 'function_expr_literal_type_surface' "$work_dir/project_body.ll"
grep -q 'function_expr_call_access_sum' "$work_dir/project_body.ll"
grep -q 'function_expression_shape_score' "$work_dir/project_body.ll"
grep -q 'function_expr_digest_score' "$work_dir/project_body.ll"
grep -q 'function_expression_lowered' "$work_dir/project_body.ll"
grep -q 'function_expression_sequence_lowered' "$work_dir/project_body.ll"
grep -q 'function_if_else_surface' "$work_dir/project_body.ll"
grep -q 'function_for_in_surface' "$work_dir/project_body.ll"
grep -q 'function_break_continue_surface' "$work_dir/project_body.ll"
grep -q 'function_control_surface' "$work_dir/project_body.ll"
grep -q 'function_body_expr_sum' "$work_dir/project_body.ll"
grep -q 'node_sequence_digest_score' "$work_dir/project_body.ll"
grep -q 'node_sequence_score' "$work_dir/project_body.ll"
grep -q 'node_metadata_score' "$work_dir/project_body.ll"
grep -q 'node_source_pos_score' "$work_dir/project_body.ll"
grep -q 'node_payload_score' "$work_dir/project_body.ll"
grep -q 'node_semantic_role_score' "$work_dir/project_body.ll"
grep -q 'node_lower_local_slot' "$work_dir/project_body.ll"
grep -q 'node_lower_assignment_slot' "$work_dir/project_body.ll"
grep -q 'node_lower_call_value' "$work_dir/project_body.ll"
grep -q 'node_lower_return_slot' "$work_dir/project_body.ll"
grep -q 'node_lower_if_then' "$work_dir/project_body.ll"
grep -q 'node_lower_for_check' "$work_dir/project_body.ll"
grep -q 'node_lower_for_has_more' "$work_dir/project_body.ll"
grep -q 'node_lower_else_body' "$work_dir/project_body.ll"
grep -q 'node_lower_break_slot' "$work_dir/project_body.ll"
grep -q 'expr_lower_identifier_slot' "$work_dir/project_body.ll"
grep -q 'expr_lower_literal_slot' "$work_dir/project_body.ll"
grep -q 'expr_lower_call_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_score' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_field0_gep' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_field_index_gep' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_field_index_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_resolved_field_index_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_actual_struct_gep' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_actual_field_loaded' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_actual_field_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_name_hash_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_name_indexed_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_member_field2_gep' "$work_dir/project_body.ll"
grep -q 'expr_lower_index_score' "$work_dir/project_body.ll"
grep -q 'expr_lower_binary_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_binary_sub_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_binary_mul_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_binary_div_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_binary_rem_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_binary_cmp_value' "$work_dir/project_body.ll"
grep -q 'expr_lower_unary_score' "$work_dir/project_body.ll"
grep -q 'function_if_then' "$work_dir/project_body.ll"
grep -q 'function_for_check' "$work_dir/project_body.ll"
grep -q 'function_for_has_more' "$work_dir/project_body.ll"
grep -Eq 'add i32 %loaded_function_if_score, [1-9][0-9]*' "$work_dir/project_body.ll"
grep -Eq 'icmp slt i32 %loaded_function_for_index, [1-9][0-9]*' "$work_dir/project_body.ll"
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

self_dynamic_return_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-dynamic-return.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/73_self_codegen_dynamic_return.yc -o "$self_dynamic_return_dir" >/dev/null
grep -q 'ret i32 17' "$self_dynamic_return_dir/merged.ll"

self_dynamic_local_return_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-dynamic-local-return.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/74_self_codegen_dynamic_local_return.yc -o "$self_dynamic_local_return_dir" >/dev/null
grep -q 'alloca i32' "$self_dynamic_local_return_dir/merged.ll"
grep -q 'store i32 23' "$self_dynamic_local_return_dir/merged.ll"
grep -q 'ret i32 %loadtmp' "$self_dynamic_local_return_dir/merged.ll"

self_dynamic_assignment_return_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-dynamic-assignment-return.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/75_self_codegen_dynamic_assignment_return.yc -o "$self_dynamic_assignment_return_dir" >/dev/null
grep -q 'alloca i32' "$self_dynamic_assignment_return_dir/merged.ll"
grep -q 'store i32 4' "$self_dynamic_assignment_return_dir/merged.ll"
grep -q 'store i32 31' "$self_dynamic_assignment_return_dir/merged.ll"
grep -q 'ret i32 %loadtmp' "$self_dynamic_assignment_return_dir/merged.ll"

self_dynamic_binary_add_return_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-dynamic-binary-add-return.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/79_self_codegen_dynamic_binary_add_return.yc -o "$self_dynamic_binary_add_return_dir" >/dev/null
grep -q 'alloca i32' "$self_dynamic_binary_add_return_dir/merged.ll"
grep -q 'store i32 8' "$self_dynamic_binary_add_return_dir/merged.ll"
grep -q 'store i32 21' "$self_dynamic_binary_add_return_dir/merged.ll"
grep -q 'add i32' "$self_dynamic_binary_add_return_dir/merged.ll"
grep -q 'ret i32 %addtmp' "$self_dynamic_binary_add_return_dir/merged.ll"

self_dynamic_compare_if_return_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-dynamic-compare-if-return.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/80_self_codegen_dynamic_compare_if_return.yc -o "$self_dynamic_compare_if_return_dir" >/dev/null
grep -q 'store i32 3' "$self_dynamic_compare_if_return_dir/merged.ll"
grep -q 'store i32 9' "$self_dynamic_compare_if_return_dir/merged.ll"
grep -q 'icmp slt i32' "$self_dynamic_compare_if_return_dir/merged.ll"
grep -q 'br i1' "$self_dynamic_compare_if_return_dir/merged.ll"
grep -q 'ret i32 44' "$self_dynamic_compare_if_return_dir/merged.ll"
grep -q 'ret i32 12' "$self_dynamic_compare_if_return_dir/merged.ll"

self_dynamic_zero_call_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-dynamic-zero-call.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/76_self_codegen_dynamic_zero_arg_call.yc -o "$self_dynamic_zero_call_dir" >/dev/null
grep -q 'define i32 @dyn_seed' "$self_dynamic_zero_call_dir/merged.ll"
grep -q 'ret i32 29' "$self_dynamic_zero_call_dir/merged.ll"
grep -q 'call i32 @dyn_seed' "$self_dynamic_zero_call_dir/merged.ll"
grep -q 'ret i32 %loadtmp' "$self_dynamic_zero_call_dir/merged.ll"

self_dynamic_if_return_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-dynamic-if-return.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/77_self_codegen_dynamic_if_return.yc -o "$self_dynamic_if_return_dir" >/dev/null
grep -q 'icmp eq i32' "$self_dynamic_if_return_dir/merged.ll"
grep -q 'br i1' "$self_dynamic_if_return_dir/merged.ll"
grep -q 'ret i32 34' "$self_dynamic_if_return_dir/merged.ll"
grep -q 'ret i32 55' "$self_dynamic_if_return_dir/merged.ll"

self_dynamic_for_return_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-dynamic-for-return.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/78_self_codegen_dynamic_for_return.yc -o "$self_dynamic_for_return_dir" >/dev/null
grep -q 'tiny_for_check' "$self_dynamic_for_return_dir/merged.ll"
grep -q 'tiny_for_update' "$self_dynamic_for_return_dir/merged.ll"
grep -q 'br i1' "$self_dynamic_for_return_dir/merged.ll"
grep -Eq 'ret i32 %loadtmp[0-9]*' "$self_dynamic_for_return_dir/merged.ll"

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

self_control_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-control.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/57_self_codegen_control_flow.yc -o "$self_control_dir" >/dev/null
grep -q 'tiny_if_then' "$self_control_dir/merged.ll"
grep -q 'tiny_for_check' "$self_control_dir/merged.ll"
grep -q 'tiny_for_update' "$self_control_dir/merged.ll"
grep -q 'br i1' "$self_control_dir/merged.ll"
grep -q 'ret i32 %loadtmp' "$self_control_dir/merged.ll"

self_else_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-else.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/58_self_codegen_else_helper.yc -o "$self_else_dir" >/dev/null
grep -q 'define i32 @base' "$self_else_dir/merged.ll"
grep -q 'call i32 @base' "$self_else_dir/merged.ll"
grep -q 'tiny_if_else' "$self_else_dir/merged.ll"
grep -q 'tiny_for_check' "$self_else_dir/merged.ll"
grep -q 'br i1' "$self_else_dir/merged.ll"

self_param_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-param.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/59_self_codegen_param_call.yc -o "$self_param_dir" >/dev/null
grep -q 'define i32 @inc(i32' "$self_param_dir/merged.ll"
grep -q 'call i32 @inc(i32' "$self_param_dir/merged.ll"
grep -Eq 'store i32 %[0-9a-zA-Z_.]+, ptr %[0-9a-zA-Z_.]+' "$self_param_dir/merged.ll"
grep -Eq 'ret i32 %loadtmp[0-9]*' "$self_param_dir/merged.ll"

self_chain_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-chain.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/60_self_codegen_helper_chain.yc -o "$self_chain_dir" >/dev/null
grep -q 'define i32 @seed' "$self_chain_dir/merged.ll"
grep -q 'define i32 @bump(i32' "$self_chain_dir/merged.ll"
grep -q 'call i32 @seed' "$self_chain_dir/merged.ll"
grep -q 'call i32 @bump(i32' "$self_chain_dir/merged.ll"
grep -Eq 'ret i32 %loadtmp[0-9]*' "$self_chain_dir/merged.ll"

self_twoarg_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-twoarg.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/61_self_codegen_two_arg_call.yc -o "$self_twoarg_dir" >/dev/null
grep -q 'define i32 @add_pair(i32' "$self_twoarg_dir/merged.ll"
grep -q 'call i32 @add_pair(i32' "$self_twoarg_dir/merged.ll"
grep -Eq 'store i32 %[0-9a-zA-Z_.]+, ptr %a' "$self_twoarg_dir/merged.ll"
grep -Eq 'store i32 %[0-9a-zA-Z_.]+, ptr %b' "$self_twoarg_dir/merged.ll"
grep -Eq 'ret i32 %loadtmp[0-9]*' "$self_twoarg_dir/merged.ll"

self_forward_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-forward.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/62_self_codegen_forward_call.yc -o "$self_forward_dir" >/dev/null
grep -q 'define i32 @main' "$self_forward_dir/merged.ll"
grep -q 'define i32 @add_pair(i32' "$self_forward_dir/merged.ll"
grep -q 'call i32 @add_pair(i32' "$self_forward_dir/merged.ll"
grep -Eq 'ret i32 %loadtmp[0-9]*' "$self_forward_dir/merged.ll"

self_bool_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-bool.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/63_self_codegen_bool_condition.yc -o "$self_bool_dir" >/dev/null
grep -q 'alloca i1' "$self_bool_dir/merged.ll"
grep -q 'icmp eq i32' "$self_bool_dir/merged.ll"
grep -q 'icmp eq i1' "$self_bool_dir/merged.ll"
grep -q 'store i1' "$self_bool_dir/merged.ll"
grep -q 'br i1' "$self_bool_dir/merged.ll"
grep -Eq 'ret i32 %loadtmp[0-9]*' "$self_bool_dir/merged.ll"

self_bool_helper_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-bool-helper.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/64_self_codegen_bool_helper.yc -o "$self_bool_helper_dir" >/dev/null
grep -q 'define i1 @ready' "$self_bool_helper_dir/merged.ll"
grep -q 'ret i1 true' "$self_bool_helper_dir/merged.ll"
grep -q 'call i1 @ready' "$self_bool_helper_dir/merged.ll"
grep -q 'alloca i1' "$self_bool_helper_dir/merged.ll"
grep -q 'icmp eq i1' "$self_bool_helper_dir/merged.ll"
grep -q 'br i1' "$self_bool_helper_dir/merged.ll"
grep -Eq 'ret i32 %loadtmp[0-9]*' "$self_bool_helper_dir/merged.ll"

self_string_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-string.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/65_self_codegen_string_local.yc -o "$self_string_dir" >/dev/null
grep -q 'define ptr @label' "$self_string_dir/merged.ll"
grep -q 'call ptr @label' "$self_string_dir/merged.ll"
grep -q 'alloca ptr' "$self_string_dir/merged.ll"
grep -q 'store ptr' "$self_string_dir/merged.ll"
grep -q '@strlit' "$self_string_dir/merged.ll"
grep -q 'ret i32 13' "$self_string_dir/merged.ll"

self_extern_string_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-extern-string.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/66_self_codegen_extern_string_call.yc -o "$self_extern_string_dir" >/dev/null
grep -q 'declare i32 @strcmp' "$self_extern_string_dir/merged.ll"
grep -q 'define ptr @label' "$self_extern_string_dir/merged.ll"
grep -q 'call i32 @strcmp' "$self_extern_string_dir/merged.ll"
grep -q 'call ptr @label' "$self_extern_string_dir/merged.ll"
grep -q 'alloca i32' "$self_extern_string_dir/merged.ll"
grep -q 'ret i32 13' "$self_extern_string_dir/merged.ll"

self_extern_malloc_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-extern-malloc.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/67_self_codegen_extern_malloc_ptr.yc -o "$self_extern_malloc_dir" >/dev/null
grep -q 'declare ptr @malloc(i64)' "$self_extern_malloc_dir/merged.ll"
grep -q 'alloca i64' "$self_extern_malloc_dir/merged.ll"
grep -q 'store i64' "$self_extern_malloc_dir/merged.ll"
grep -q 'call ptr @malloc' "$self_extern_malloc_dir/merged.ll"
grep -q 'alloca ptr' "$self_extern_malloc_dir/merged.ll"
grep -q 'store ptr' "$self_extern_malloc_dir/merged.ll"
grep -q 'ret i32 13' "$self_extern_malloc_dir/merged.ll"

self_llvm_c_api_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-llvm-c-api.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/68_self_codegen_llvm_c_api_call.yc -o "$self_llvm_c_api_dir" >/dev/null
grep -q 'declare ptr @LLVMContextCreate()' "$self_llvm_c_api_dir/merged.ll"
grep -q 'declare ptr @LLVMModuleCreateWithNameInContext(ptr, ptr)' "$self_llvm_c_api_dir/merged.ll"
grep -q 'call ptr @LLVMContextCreate' "$self_llvm_c_api_dir/merged.ll"
grep -q 'call ptr @LLVMModuleCreateWithNameInContext' "$self_llvm_c_api_dir/merged.ll"
grep -q '@strlit' "$self_llvm_c_api_dir/merged.ll"
grep -q 'alloca ptr' "$self_llvm_c_api_dir/merged.ll"
grep -q 'store ptr' "$self_llvm_c_api_dir/merged.ll"
grep -q 'ret i32 13' "$self_llvm_c_api_dir/merged.ll"

self_void_extern_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-void-extern.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/69_self_codegen_void_extern_call.yc -o "$self_void_extern_dir" >/dev/null
grep -q 'declare void @LLVMContextDispose(ptr)' "$self_void_extern_dir/merged.ll"
grep -q 'define void @cleanup(ptr' "$self_void_extern_dir/merged.ll"
grep -q 'call void @LLVMContextDispose' "$self_void_extern_dir/merged.ll"
grep -q 'call void @cleanup' "$self_void_extern_dir/merged.ll"
grep -q 'ret void' "$self_void_extern_dir/merged.ll"
grep -q 'ret i32 13' "$self_void_extern_dir/merged.ll"

self_llvm_function_type_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-llvm-function-type.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/70_self_codegen_llvm_function_type_call.yc -o "$self_llvm_function_type_dir" >/dev/null
grep -q 'declare ptr @LLVMInt32TypeInContext(ptr)' "$self_llvm_function_type_dir/merged.ll"
grep -q 'declare ptr @LLVMFunctionType(ptr, ptr, i32, i32)' "$self_llvm_function_type_dir/merged.ll"
grep -q 'call ptr @LLVMInt32TypeInContext' "$self_llvm_function_type_dir/merged.ll"
grep -q 'call ptr @LLVMFunctionType(ptr' "$self_llvm_function_type_dir/merged.ll"
grep -q 'ptr null' "$self_llvm_function_type_dir/merged.ll"
grep -q 'alloca ptr' "$self_llvm_function_type_dir/merged.ll"
grep -q 'ret i32 13' "$self_llvm_function_type_dir/merged.ll"

self_llvm_builder_memory_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-llvm-builder-memory.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/71_self_codegen_llvm_builder_memory_call.yc -o "$self_llvm_builder_memory_dir" >/dev/null
grep -q 'declare ptr @LLVMBuildAlloca(ptr, ptr, ptr)' "$self_llvm_builder_memory_dir/merged.ll"
grep -q 'declare ptr @LLVMBuildStore(ptr, ptr, ptr)' "$self_llvm_builder_memory_dir/merged.ll"
grep -q 'declare ptr @LLVMBuildLoad2(ptr, ptr, ptr, ptr)' "$self_llvm_builder_memory_dir/merged.ll"
grep -q 'call ptr @LLVMBuildAlloca(ptr' "$self_llvm_builder_memory_dir/merged.ll"
grep -q 'call ptr @LLVMBuildStore(ptr' "$self_llvm_builder_memory_dir/merged.ll"
grep -q 'call ptr @LLVMBuildLoad2(ptr' "$self_llvm_builder_memory_dir/merged.ll"
grep -q 'ptr null' "$self_llvm_builder_memory_dir/merged.ll"
grep -q '@strlit' "$self_llvm_builder_memory_dir/merged.ll"
grep -q 'alloca ptr' "$self_llvm_builder_memory_dir/merged.ll"
grep -q 'ret i32 13' "$self_llvm_builder_memory_dir/merged.ll"

self_llvm_call2_icmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-llvm-call2-icmp.XXXXXX")"
"$YCC_YCPL" build-ir-self examples/72_self_codegen_llvm_call2_icmp_call.yc -o "$self_llvm_call2_icmp_dir" >/dev/null
grep -q 'declare ptr @LLVMBuildICmp(...)' "$self_llvm_call2_icmp_dir/merged.ll"
grep -q 'declare ptr @LLVMBuildCall2(...)' "$self_llvm_call2_icmp_dir/merged.ll"
grep -q 'call ptr (...) @LLVMBuildICmp(ptr' "$self_llvm_call2_icmp_dir/merged.ll"
grep -q 'call ptr (...) @LLVMBuildCall2(ptr' "$self_llvm_call2_icmp_dir/merged.ll"
grep -q 'i32 32' "$self_llvm_call2_icmp_dir/merged.ll"
grep -q 'ptr null' "$self_llvm_call2_icmp_dir/merged.ll"
grep -q '@strlit' "$self_llvm_call2_icmp_dir/merged.ll"
grep -q 'ret i32 13' "$self_llvm_call2_icmp_dir/merged.ll"

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

self_control_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-control-native.XXXXXX")"
"$YCC_YCPL" build examples/57_self_codegen_control_flow.yc -o "$self_control_native_dir" >/dev/null
set +e
"$self_control_native_dir/merged" >/dev/null 2>&1
control_native_status=$?
set -e
if [ "$control_native_status" -ne 13 ]; then
  printf 'Expected self-built control native binary to exit 13, got %d\n' "$control_native_status" >&2
  exit 1
fi

self_else_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-else-native.XXXXXX")"
"$YCC_YCPL" build examples/58_self_codegen_else_helper.yc -o "$self_else_native_dir" >/dev/null
set +e
"$self_else_native_dir/merged" >/dev/null 2>&1
else_native_status=$?
set -e
if [ "$else_native_status" -ne 13 ]; then
  printf 'Expected self-built else/helper native binary to exit 13, got %d\n' "$else_native_status" >&2
  exit 1
fi

self_param_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-param-native.XXXXXX")"
"$YCC_YCPL" build examples/59_self_codegen_param_call.yc -o "$self_param_native_dir" >/dev/null
set +e
"$self_param_native_dir/merged" >/dev/null 2>&1
param_native_status=$?
set -e
if [ "$param_native_status" -ne 13 ]; then
  printf 'Expected self-built param-call native binary to exit 13, got %d\n' "$param_native_status" >&2
  exit 1
fi

self_chain_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-chain-native.XXXXXX")"
"$YCC_YCPL" build examples/60_self_codegen_helper_chain.yc -o "$self_chain_native_dir" >/dev/null
set +e
"$self_chain_native_dir/merged" >/dev/null 2>&1
chain_native_status=$?
set -e
if [ "$chain_native_status" -ne 13 ]; then
  printf 'Expected self-built helper-chain native binary to exit 13, got %d\n' "$chain_native_status" >&2
  exit 1
fi

self_twoarg_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-twoarg-native.XXXXXX")"
"$YCC_YCPL" build examples/61_self_codegen_two_arg_call.yc -o "$self_twoarg_native_dir" >/dev/null
set +e
"$self_twoarg_native_dir/merged" >/dev/null 2>&1
twoarg_native_status=$?
set -e
if [ "$twoarg_native_status" -ne 13 ]; then
  printf 'Expected self-built two-arg native binary to exit 13, got %d\n' "$twoarg_native_status" >&2
  exit 1
fi

self_forward_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-forward-native.XXXXXX")"
"$YCC_YCPL" build examples/62_self_codegen_forward_call.yc -o "$self_forward_native_dir" >/dev/null
set +e
"$self_forward_native_dir/merged" >/dev/null 2>&1
forward_native_status=$?
set -e
if [ "$forward_native_status" -ne 13 ]; then
  printf 'Expected self-built forward-call native binary to exit 13, got %d\n' "$forward_native_status" >&2
  exit 1
fi

self_bool_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-bool-native.XXXXXX")"
"$YCC_YCPL" build examples/63_self_codegen_bool_condition.yc -o "$self_bool_native_dir" >/dev/null
set +e
"$self_bool_native_dir/merged" >/dev/null 2>&1
bool_native_status=$?
set -e
if [ "$bool_native_status" -ne 13 ]; then
  printf 'Expected self-built bool native binary to exit 13, got %d\n' "$bool_native_status" >&2
  exit 1
fi

self_bool_helper_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-bool-helper-native.XXXXXX")"
"$YCC_YCPL" build examples/64_self_codegen_bool_helper.yc -o "$self_bool_helper_native_dir" >/dev/null
set +e
"$self_bool_helper_native_dir/merged" >/dev/null 2>&1
bool_helper_native_status=$?
set -e
if [ "$bool_helper_native_status" -ne 13 ]; then
  printf 'Expected self-built bool-helper native binary to exit 13, got %d\n' "$bool_helper_native_status" >&2
  exit 1
fi

self_string_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-string-native.XXXXXX")"
"$YCC_YCPL" build examples/65_self_codegen_string_local.yc -o "$self_string_native_dir" >/dev/null
set +e
"$self_string_native_dir/merged" >/dev/null 2>&1
string_native_status=$?
set -e
if [ "$string_native_status" -ne 13 ]; then
  printf 'Expected self-built string native binary to exit 13, got %d\n' "$string_native_status" >&2
  exit 1
fi

self_extern_string_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-extern-string-native.XXXXXX")"
"$YCC_YCPL" build examples/66_self_codegen_extern_string_call.yc -o "$self_extern_string_native_dir" >/dev/null
set +e
"$self_extern_string_native_dir/merged" >/dev/null 2>&1
extern_string_native_status=$?
set -e
if [ "$extern_string_native_status" -ne 13 ]; then
  printf 'Expected self-built extern-string native binary to exit 13, got %d\n' "$extern_string_native_status" >&2
  exit 1
fi

self_extern_malloc_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-self-extern-malloc-native.XXXXXX")"
"$YCC_YCPL" build examples/67_self_codegen_extern_malloc_ptr.yc -o "$self_extern_malloc_native_dir" >/dev/null
set +e
"$self_extern_malloc_native_dir/merged" >/dev/null 2>&1
extern_malloc_native_status=$?
set -e
if [ "$extern_malloc_native_status" -ne 13 ]; then
  printf 'Expected self-built extern-malloc native binary to exit 13, got %d\n' "$extern_malloc_native_status" >&2
  exit 1
fi
