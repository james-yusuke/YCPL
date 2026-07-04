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
"$YCC_YCPL" parse "$traversal_dir/ycpl" >/tmp/ycpl-stage-traversal-parse.out
if ! grep -q 'files=23' /tmp/ycpl-stage-traversal-parse.out; then
  printf 'Expected recursive traversal to discover 23 files in %s, got:\n' "$traversal_dir/ycpl" >&2
  cat /tmp/ycpl-stage-traversal-parse.out >&2
  find "$traversal_dir/ycpl/src" -type f -name '*.yc' | sort >&2
  exit 1
fi
traversal_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-stage-traversal-ir.XXXXXX")"
YCPL_NO_BOOTSTRAP=1 "$YCC_YCPL" build-ir "$traversal_dir/ycpl" -o "$traversal_ir_dir" >/tmp/ycpl-stage-traversal-ir.out
grep -q 'node_lower_else_body' "$traversal_ir_dir/project_body.ll"
grep -q 'node_lower_break_slot' "$traversal_ir_dir/project_body.ll"
grep -q 'node_lower_continue_slot' "$traversal_ir_dir/project_body.ll"
grep -q 'node_lower_for_in_check' "$traversal_ir_dir/project_body.ll"
grep -q 'files=22' /tmp/ycpl-stage-parse.out
grep -q 'files=22' /tmp/ycpl-stage-check.out
grep -q 'fn_digest=' /tmp/ycpl-stage-parse.out
grep -q 'body_digest=' /tmp/ycpl-stage-parse.out
grep -q 'body_tokens=' /tmp/ycpl-stage-parse.out
grep -q 'body_nodes=' /tmp/ycpl-stage-parse.out
grep -q 'body_slots=' /tmp/ycpl-stage-parse.out
grep -q 'body_slot_digest=' /tmp/ycpl-stage-parse.out
grep -q 'node_digest=' /tmp/ycpl-stage-parse.out
grep -q 'transition_digest=' /tmp/ycpl-stage-parse.out
grep -q 'return_exprs=' /tmp/ycpl-stage-parse.out
grep -q 'payload_ids=' /tmp/ycpl-stage-parse.out
grep -q 'payload_types=' /tmp/ycpl-stage-parse.out
grep -q 'payload_digest=' /tmp/ycpl-stage-parse.out
grep -q 'local_symbols=' /tmp/ycpl-stage-parse.out
grep -q 'assignment_targets=' /tmp/ycpl-stage-parse.out
grep -q 'call_targets=' /tmp/ycpl-stage-parse.out
grep -q 'semantic_digest=' /tmp/ycpl-stage-parse.out
grep -q 'symbols=' /tmp/ycpl-stage-parse.out
grep -q 'symbol_structs=' /tmp/ycpl-stage-parse.out
grep -q 'symbol_imports=' /tmp/ycpl-stage-parse.out
grep -q 'symbol_digest=' /tmp/ycpl-stage-parse.out
grep -q 'typed_nodes=' /tmp/ycpl-stage-parse.out
grep -q 'sig_nodes=' /tmp/ycpl-stage-parse.out
grep -q 'sig_calls=' /tmp/ycpl-stage-parse.out
grep -q 'expr_table: nodes=' /tmp/ycpl-stage-parse.out
grep -q 'primary=' /tmp/ycpl-stage-parse.out
grep -q 'binary=' /tmp/ycpl-stage-parse.out
grep -q 'unary=' /tmp/ycpl-stage-parse.out
grep -q 'slots=' /tmp/ycpl-stage-parse.out
grep -q 'slot_digest=' /tmp/ycpl-stage-parse.out
grep -q 'stmt_expr: links=' /tmp/ycpl-stage-parse.out
grep -q 'tail=' /tmp/ycpl-stage-parse.out
grep -q 'typed_digest=' /tmp/ycpl-stage-parse.out
grep -q 'main=1' /tmp/ycpl-stage-check.out
grep -q 'body_digest=' /tmp/ycpl-stage-check.out
grep -q 'ret_digest=' /tmp/ycpl-stage-check.out
grep -q 'transition_digest=' /tmp/ycpl-stage-check.out
grep -q 'local_assign_edges=' /tmp/ycpl-stage-check.out
grep -q 'if_nodes=' /tmp/ycpl-stage-check.out
grep -q 'for_nodes=' /tmp/ycpl-stage-check.out
grep -q 'payload_ids=' /tmp/ycpl-stage-check.out
grep -q 'payload_types=' /tmp/ycpl-stage-check.out
grep -q 'payload_digest=' /tmp/ycpl-stage-check.out
grep -q 'local_symbols=' /tmp/ycpl-stage-check.out
grep -q 'assignment_targets=' /tmp/ycpl-stage-check.out
grep -q 'call_targets=' /tmp/ycpl-stage-check.out
grep -q 'semantic_digest=' /tmp/ycpl-stage-check.out
grep -q 'symbols=' /tmp/ycpl-stage-check.out
grep -q 'symbol_structs=' /tmp/ycpl-stage-check.out
grep -q 'symbol_imports=' /tmp/ycpl-stage-check.out
grep -q 'symbol_digest=' /tmp/ycpl-stage-check.out
grep -q 'typed_nodes=' /tmp/ycpl-stage-check.out
grep -q 'sig_nodes=' /tmp/ycpl-stage-check.out
grep -q 'sig_calls=' /tmp/ycpl-stage-check.out
grep -q 'expr_table: nodes=' /tmp/ycpl-stage-check.out
grep -q 'primary=' /tmp/ycpl-stage-check.out
grep -q 'binary=' /tmp/ycpl-stage-check.out
grep -q 'unary=' /tmp/ycpl-stage-check.out
grep -q 'slots=' /tmp/ycpl-stage-check.out
grep -q 'slot_digest=' /tmp/ycpl-stage-check.out
grep -q 'stmt_expr: links=' /tmp/ycpl-stage-check.out
grep -q 'tail=' /tmp/ycpl-stage-check.out
grep -q 'body_slots=' /tmp/ycpl-stage-check.out
grep -q 'body_slot_digest=' /tmp/ycpl-stage-check.out
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
grep -q 'ret ptr null' "$strict_ir_dir/merged.ll"
grep -q 'icmp eq ptr %irtext, null' "$strict_ir_dir/merged.ll"
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
grep -q '@ycpl_ast_body_transition_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_slot_count' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_nonempty_slots' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_max_nodes_per_slot' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_slot_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_identifier_payloads' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_type_payloads' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_payload_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_local_symbol_refs' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_assignment_target_refs' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_call_target_refs' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_semantic_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_symbol_functions' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_symbol_structs' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_symbol_imports' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_symbol_zero_param_functions' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_symbol_nonzero_param_functions' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_symbol_function_signature_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_symbol_call_sites' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_symbol_nonzero_arg_calls' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_symbol_call_arity_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_signature_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_signature_function_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_signature_call_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_signature_arity_slots' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_signature_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_expr_table_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_stage_expr_lowered_floor' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_expr_primary_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_expr_binary_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_expr_table_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_expr_slot_count' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_expr_slot_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_stmt_expr_links' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_stmt_expr_tail_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_stmt_expr_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_symbol_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_body_payload_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_body_semantic_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_body_slot_count' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_body_slot_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_symbol_function_signature_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_symbol_call_sites' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_symbol_call_arity_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_signature_nodes' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_signature_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_expr_table_nodes' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_stage_expr_lowered_floor' "$strict_ir_dir/merged.ll"
grep -q 'exprfloorok' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_expr_table_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_expr_slot_count' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_expr_slot_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_stmt_expr_links' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_stmt_expr_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_symbol_digest' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_if_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_for_nodes' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_return_exprs' "$strict_ir_dir/merged.ll"
grep -q '@ycpl_ast_return_expr_digest' "$strict_ir_dir/merged.ll"
grep -q 'load i32, ptr @ycpl_ast_return_exprs' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_statement_expr_lowering' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_call_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_const_return_0' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_all_function_bodies' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_0' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_dynamic_first_body_0' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_7' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_15' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_31' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_63' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_400' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_range_0_63' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_dynamic_range_body_0' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_range_320_383' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_function_body_range_384_447' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_project_dynamic_range_body_6' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_statement_expr_lowering' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_const_return_0' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_all_function_bodies' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_0' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_dynamic_first_body_0' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_7' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_15' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_31' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_63' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_400' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_range_0_63' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_dynamic_range_body_0' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_range_320_383' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_function_body_range_384_447' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_project_dynamic_range_body_6' "$strict_ir_dir/merged.ll"
grep -q 'statement_nodes' "$strict_ir_dir/merged.ll"
grep -q 'expression_nodes' "$strict_ir_dir/merged.ll"
grep -q 'expr_table_nodes' "$strict_ir_dir/merged.ll"
grep -q 'expression_table_lowered' "$strict_ir_dir/merged.ll"
grep -q 'expr_slot_count' "$strict_ir_dir/merged.ll"
grep -q 'expression_slot_lowered' "$strict_ir_dir/merged.ll"
grep -q 'project_const_return_functions' "$strict_ir_dir/merged.ll"
grep -q 'all_function_bodies_lowered' "$strict_ir_dir/merged.ll"
grep -q 'control_function_body_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_slots_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_base_slots' "$strict_ir_dir/merged.ll"
grep -q 'function_body_extra_slots' "$strict_ir_dir/merged.ll"
grep -q 'function_body_extended_slots' "$strict_ir_dir/merged.ll"
grep -q 'function_body_first64_slots_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_all_individual_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_dynamic_first_lowered_0' "$strict_ir_dir/merged.ll"
grep -q 'function_body_dynamic_selfhost_gate' "$strict_ir_dir/merged.ll"
grep -q 'function_body_dynamic_lowered_400' "$strict_ir_dir/merged.ll"
grep -q 'function_body_dynamic_range_lowered_0' "$strict_ir_dir/merged.ll"
grep -q 'function_body_dynamic_range_total_6' "$strict_ir_dir/merged.ll"
grep -q 'function_body_dynamic_range_buckets_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_dynamic_range_gate' "$strict_ir_dir/merged.ll"
grep -q 'function_body_second_half' "$strict_ir_dir/merged.ll"
grep -q 'function_body_tail' "$strict_ir_dir/merged.ll"
grep -q 'function_body_range6_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_range_tail' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ranges_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_slot_and_range_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_score' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_lowered_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_value_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_literal_value_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_call_value_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_binary_value_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_binary_value_cmp' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_lowered_value_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_expr_value_environment' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_value_for_statement' "$strict_ir_dir/merged.ll"
grep -q 'function_body_assignment_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_return_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_value_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_expr_value_flow' "$strict_ir_dir/merged.ll"
grep -q 'function_statement_expr_ownership_score' "$strict_ir_dir/merged.ll"
grep -q 'function_body_owned_expr_sum' "$strict_ir_dir/merged.ll"
grep -q 'function_tail_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_tail_expr_value_flow' "$strict_ir_dir/merged.ll"
grep -Eq 'store i32 ([6-9][0-9][0-9]|[1-9][0-9][0-9][0-9]), ptr %function_expr_lowered_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expression_slot_score' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_digest_score' "$strict_ir_dir/merged.ll"
grep -q 'function_expression_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_expression_sequence_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_expr_sum' "$strict_ir_dir/merged.ll"
grep -q 'node_sequence_digest_score' "$strict_ir_dir/merged.ll"
grep -q 'node_sequence_score' "$strict_ir_dir/merged.ll"
grep -q 'node_metadata_score' "$strict_ir_dir/merged.ll"
grep -q 'node_source_pos_score' "$strict_ir_dir/merged.ll"
grep -q 'node_payload_score' "$strict_ir_dir/merged.ll"
grep -q 'node_semantic_role_score' "$strict_ir_dir/merged.ll"
grep -q 'node_lower_if_then' "$strict_ir_dir/merged.ll"
grep -q 'node_lower_for_check' "$strict_ir_dir/merged.ll"
grep -q 'node_lower_for_has_more' "$strict_ir_dir/merged.ll"
grep -q 'node_lower_else_body' "$strict_ir_dir/merged.ll"
grep -q 'node_lower_break_slot' "$strict_ir_dir/merged.ll"
grep -q 'function_if_then' "$strict_ir_dir/merged.ll"
grep -q 'function_for_check' "$strict_ir_dir/merged.ll"
grep -q 'function_for_has_more' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_node_call_probe' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_node_transition_probe' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_node_control_flow_probe' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_node_local_return_probe' "$strict_ir_dir/merged.ll"
grep -q 'assignment_nodes' "$strict_ir_dir/merged.ll"
grep -q 'transition_digest' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_node_call_probe' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_node_transition_probe' "$strict_ir_dir/merged.ll"
grep -q 'call i32 @ycpl_node_control_flow_probe' "$strict_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_node_local_return_probe' "$strict_ir_dir/local_return.ll"
grep -q 'define i32 @ycpl_node_call_probe' "$strict_ir_dir/local_return.ll"
grep -q 'define i32 @ycpl_node_transition_probe' "$strict_ir_dir/local_return.ll"
grep -q 'define i32 @ycpl_node_control_flow_probe' "$strict_ir_dir/local_return.ll"
grep -q 'if_then' "$strict_ir_dir/local_return.ll"
grep -q 'for_check' "$strict_ir_dir/local_return.ll"
grep -q 'for_body' "$strict_ir_dir/local_return.ll"
grep -q 'for_has_more' "$strict_ir_dir/local_return.ll"
grep -q 'assignment_nodes' "$strict_ir_dir/local_return.ll"
grep -q 'transition_digest' "$strict_ir_dir/local_return.ll"
grep -q 'call i32 @ycpl_node_call_probe' "$strict_ir_dir/local_return.ll"
grep -q 'call i32 @ycpl_node_transition_probe' "$strict_ir_dir/local_return.ll"
grep -q 'call i32 @ycpl_node_control_flow_probe' "$strict_ir_dir/local_return.ll"
grep -q 'alloca i32' "$strict_ir_dir/local_return.ll"
grep -q 'store i32' "$strict_ir_dir/local_return.ll"
grep -q 'load i32' "$strict_ir_dir/local_return.ll"
grep -q 'ret i32' "$strict_ir_dir/local_return.ll"
grep -q 'define i32 @ycpl_project_statement_expr_lowering' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_call_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_const_return_0' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_all_function_bodies' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_0' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_dynamic_first_body_0' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_7' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_15' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_31' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_63' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_400' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_range_0_63' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_dynamic_range_body_0' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_range_320_383' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_function_body_range_384_447' "$strict_ir_dir/project_body.ll"
grep -q 'define i32 @ycpl_project_dynamic_range_body_6' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_const_return_0' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_all_function_bodies' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_0' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_dynamic_first_body_0' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_7' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_15' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_31' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_63' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_400' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_range_0_63' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_dynamic_range_body_0' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_range_320_383' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_function_body_range_384_447' "$strict_ir_dir/project_body.ll"
grep -q 'call i32 @ycpl_project_dynamic_range_body_6' "$strict_ir_dir/project_body.ll"
grep -q 'statement_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'expression_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'expr_table_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'expression_table_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'expr_slot_count' "$strict_ir_dir/project_body.ll"
grep -q 'expression_slot_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'project_const_return_functions' "$strict_ir_dir/project_body.ll"
grep -q 'all_function_bodies_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'control_function_body_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_slots_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_base_slots' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_extra_slots' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_extended_slots' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_first64_slots_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_all_individual_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_dynamic_first_lowered_0' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_dynamic_selfhost_gate' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_dynamic_lowered_400' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_dynamic_range_lowered_0' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_dynamic_range_total_6' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_dynamic_range_buckets_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_dynamic_range_gate' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_second_half' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_tail' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_range6_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_range_tail' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ranges_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_slot_and_range_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_score' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_local_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_assignment_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_call_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_return_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_symbol_env' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_control_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_assignment_value_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_call_value_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_return_value_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_lowered_environment_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_lowered_statement_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_lowered_total' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_lowered_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_literal_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_call_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_binary_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_binary_value_cmp' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_lowered_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_expr_value_environment' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_value_for_statement' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_assignment_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_return_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_value_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_expr_value_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_statement_expr_ownership_score' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_owned_expr_sum' "$strict_ir_dir/project_body.ll"
grep -q 'function_tail_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_tail_expr_value_flow' "$strict_ir_dir/project_body.ll"
grep -Eq 'store i32 ([6-9][0-9][0-9]|[1-9][0-9][0-9][0-9]), ptr %function_expr_lowered_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expression_slot_score' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_digest_score' "$strict_ir_dir/project_body.ll"
grep -q 'function_expression_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_expression_sequence_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_if_else_surface' "$strict_ir_dir/project_body.ll"
grep -q 'function_for_in_surface' "$strict_ir_dir/project_body.ll"
grep -q 'function_break_continue_surface' "$strict_ir_dir/project_body.ll"
grep -q 'function_control_surface' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_expr_sum' "$strict_ir_dir/project_body.ll"
grep -q 'node_sequence_digest_score' "$strict_ir_dir/project_body.ll"
grep -q 'node_sequence_score' "$strict_ir_dir/project_body.ll"
grep -q 'node_metadata_score' "$strict_ir_dir/project_body.ll"
grep -q 'node_source_pos_score' "$strict_ir_dir/project_body.ll"
grep -q 'node_payload_score' "$strict_ir_dir/project_body.ll"
grep -q 'node_semantic_role_score' "$strict_ir_dir/project_body.ll"
grep -q 'node_lower_local_slot' "$strict_ir_dir/project_body.ll"
grep -q 'node_lower_assignment_slot' "$strict_ir_dir/project_body.ll"
grep -q 'node_lower_call_value' "$strict_ir_dir/project_body.ll"
grep -q 'node_lower_return_slot' "$strict_ir_dir/project_body.ll"
grep -q 'node_lower_if_then' "$strict_ir_dir/project_body.ll"
grep -q 'node_lower_for_check' "$strict_ir_dir/project_body.ll"
grep -q 'node_lower_for_has_more' "$strict_ir_dir/project_body.ll"
grep -q 'node_lower_else_body' "$strict_ir_dir/project_body.ll"
grep -q 'node_lower_break_slot' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_identifier_slot' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_literal_slot' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_call_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_member_score' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_index_score' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_binary_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_binary_sub_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_binary_mul_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_binary_div_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_binary_rem_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_binary_cmp_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_unary_score' "$strict_ir_dir/project_body.ll"
grep -q 'function_if_then' "$strict_ir_dir/project_body.ll"
grep -q 'function_for_check' "$strict_ir_dir/project_body.ll"
grep -q 'function_for_has_more' "$strict_ir_dir/project_body.ll"
grep -Eq 'add i32 %loaded_function_if_score, [1-9][0-9]*' "$strict_ir_dir/project_body.ll"
grep -Eq 'icmp slt i32 %loaded_function_for_index, [1-9][0-9]*' "$strict_ir_dir/project_body.ll"
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
grep -q 'files=22' /tmp/ycpl-strict-native-parse.out
grep -q 'files=22' /tmp/ycpl-strict-native-check.out
grep -q 'fn_digest=' /tmp/ycpl-strict-native-parse.out
grep -q 'body_digest=' /tmp/ycpl-strict-native-parse.out
grep -q 'body_nodes=' /tmp/ycpl-strict-native-parse.out
grep -q 'body_slots=' /tmp/ycpl-strict-native-parse.out
grep -q 'return_exprs=' /tmp/ycpl-strict-native-parse.out
grep -q 'typed_nodes=' /tmp/ycpl-strict-native-parse.out
grep -q 'sig_nodes=' /tmp/ycpl-strict-native-parse.out
grep -q 'expr_nodes=' /tmp/ycpl-strict-native-parse.out
grep -q 'expr_slots=' /tmp/ycpl-strict-native-parse.out
grep -q 'typed_digest=' /tmp/ycpl-strict-native-parse.out
grep -q 'symbols=' /tmp/ycpl-strict-native-parse.out
grep -q 'symbol_digest=' /tmp/ycpl-strict-native-parse.out
grep -q 'main=1' /tmp/ycpl-strict-native-check.out
grep -q 'body_digest=' /tmp/ycpl-strict-native-check.out
grep -q 'ret_digest=' /tmp/ycpl-strict-native-check.out
grep -q 'typed_nodes=' /tmp/ycpl-strict-native-check.out
grep -q 'sig_nodes=' /tmp/ycpl-strict-native-check.out
grep -q 'expr_nodes=' /tmp/ycpl-strict-native-check.out
grep -q 'expr_slots=' /tmp/ycpl-strict-native-check.out
grep -q 'body_slots=' /tmp/ycpl-strict-native-check.out
grep -q 'typed_digest=' /tmp/ycpl-strict-native-check.out
grep -q 'symbols=' /tmp/ycpl-strict-native-check.out
grep -q 'symbol_digest=' /tmp/ycpl-strict-native-check.out

strict_unknown_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-unknown-ir.XXXXXX")"
set +e
"$strict_native_dir/merged" build-ir examples/55_self_codegen_unknown_failure.yc -o "$strict_unknown_ir_dir" >/tmp/ycpl-strict-unknown-ir.out 2>&1
strict_unknown_rc=$?
set -e
if [ "$strict_unknown_rc" -eq 0 ]; then
  printf 'Expected strict generated compiler to reject unsupported build-ir input\n' >&2
  cat /tmp/ycpl-strict-unknown-ir.out >&2
  exit 1
fi
grep -q 'failed to write stage IR' /tmp/ycpl-strict-unknown-ir.out

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
grep -q '@ycpl_ast_body_transition_digest' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_slot_digest' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_if_nodes' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_body_for_nodes' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_return_expr_digest' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_expr_table_digest' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_stage_expr_lowered_floor' "$strict_stage3_ir_dir/merged.ll"
grep -q 'exprfloorok' "$strict_stage3_ir_dir/merged.ll"
grep -q '@ycpl_ast_expr_slot_digest' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.stage4.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyelse.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinycontrol.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinychain.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinytwoarg.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyparam.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinycall.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tiny13.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q 'define ptr @ycpl_stage3_select_ir' "$strict_stage3_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_stage3_write_ir_text' "$strict_stage3_ir_dir/merged.ll"
grep -q 'define i32 @ycpl_stage3_build_native_from_ir_text' "$strict_stage3_ir_dir/merged.ll"
grep -q 'define i32 @main(i32 %argc, ptr %argv)' "$strict_stage3_ir_dir/merged.ll"

strict_tiny42_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-tiny42-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/53_self_codegen_main.yc -o "$strict_tiny42_ir_dir" >/tmp/ycpl-strict-tiny42-ir.out
grep -q 'ret i32 42' "$strict_tiny42_ir_dir/merged.ll"

strict_tiny13_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-tiny13-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/54_self_codegen_arithmetic.yc -o "$strict_tiny13_ir_dir" >/tmp/ycpl-strict-tiny13-ir.out
grep -q 'ret i32 13' "$strict_tiny13_ir_dir/merged.ll"

strict_call_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-call-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/56_self_codegen_call_assignment.yc -o "$strict_call_ir_dir" >/tmp/ycpl-strict-call-ir.out
grep -q 'define i32 @seed' "$strict_call_ir_dir/merged.ll"
grep -q 'call i32 @seed' "$strict_call_ir_dir/merged.ll"
grep -q 'store i32 %calltmp' "$strict_call_ir_dir/merged.ll"
grep -q 'ret i32 %loadtmp' "$strict_call_ir_dir/merged.ll"

strict_control_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-control-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/57_self_codegen_control_flow.yc -o "$strict_control_ir_dir" >/tmp/ycpl-strict-control-ir.out
grep -q 'tiny_if_then' "$strict_control_ir_dir/merged.ll"
grep -q 'tiny_for_check' "$strict_control_ir_dir/merged.ll"
grep -q 'tiny_for_update' "$strict_control_ir_dir/merged.ll"
grep -q 'br i1' "$strict_control_ir_dir/merged.ll"
grep -q 'ret i32 %result' "$strict_control_ir_dir/merged.ll"

strict_else_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-else-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/58_self_codegen_else_helper.yc -o "$strict_else_ir_dir" >/tmp/ycpl-strict-else-ir.out
grep -q 'define i32 @base' "$strict_else_ir_dir/merged.ll"
grep -q 'call i32 @base' "$strict_else_ir_dir/merged.ll"
grep -q 'tiny_if_else' "$strict_else_ir_dir/merged.ll"
grep -q 'tiny_for_check' "$strict_else_ir_dir/merged.ll"
grep -q 'ret i32 %result' "$strict_else_ir_dir/merged.ll"

strict_param_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-param-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/59_self_codegen_param_call.yc -o "$strict_param_ir_dir" >/tmp/ycpl-strict-param-ir.out
grep -q 'define i32 @inc(i32' "$strict_param_ir_dir/merged.ll"
grep -q 'call i32 @inc(i32' "$strict_param_ir_dir/merged.ll"
grep -Eq 'store i32 %[0-9a-zA-Z_.]+, ptr %[0-9a-zA-Z_.]+' "$strict_param_ir_dir/merged.ll"
grep -Eq 'ret i32 %loadtmp[0-9]*' "$strict_param_ir_dir/merged.ll"

strict_chain_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-chain-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/60_self_codegen_helper_chain.yc -o "$strict_chain_ir_dir" >/tmp/ycpl-strict-chain-ir.out
grep -q 'define i32 @seed' "$strict_chain_ir_dir/merged.ll"
grep -q 'define i32 @bump(i32' "$strict_chain_ir_dir/merged.ll"
grep -q 'call i32 @seed' "$strict_chain_ir_dir/merged.ll"
grep -q 'call i32 @bump(i32' "$strict_chain_ir_dir/merged.ll"
grep -Eq 'ret i32 %loadtmp[0-9]*' "$strict_chain_ir_dir/merged.ll"

strict_twoarg_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-twoarg-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/61_self_codegen_two_arg_call.yc -o "$strict_twoarg_ir_dir" >/tmp/ycpl-strict-twoarg-ir.out
grep -q 'define i32 @add_pair(i32' "$strict_twoarg_ir_dir/merged.ll"
grep -q 'call i32 @add_pair(i32' "$strict_twoarg_ir_dir/merged.ll"
grep -q 'ret i32 %loadtmp' "$strict_twoarg_ir_dir/merged.ll"

strict_forward_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-forward-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/62_self_codegen_forward_call.yc -o "$strict_forward_ir_dir" >/tmp/ycpl-strict-forward-ir.out
grep -q 'define i32 @add_pair(i32' "$strict_forward_ir_dir/merged.ll"
grep -q 'call i32 @add_pair(i32' "$strict_forward_ir_dir/merged.ll"
grep -q 'ret i32 %loadtmp' "$strict_forward_ir_dir/merged.ll"

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
  "$strict_stage3_native_dir/merged" parse compiler/ycpl >/tmp/ycpl-strict-stage3-native-parse.out
  "$strict_stage3_native_dir/merged" check compiler/ycpl >/tmp/ycpl-strict-stage3-native-check.out
  grep -q 'files=22' /tmp/ycpl-strict-stage3-native-parse.out
  grep -q 'typed_nodes=' /tmp/ycpl-strict-stage3-native-parse.out
  grep -q 'expr_nodes=' /tmp/ycpl-strict-stage3-native-parse.out
  grep -q 'main=1' /tmp/ycpl-strict-stage3-native-check.out
  strict_stage3_unknown_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-unknown-ir.XXXXXX")"
  set +e
  "$strict_stage3_native_dir/merged" build-ir examples/55_self_codegen_unknown_failure.yc -o "$strict_stage3_unknown_ir_dir" >/tmp/ycpl-strict-stage3-unknown-ir.out 2>&1
  strict_stage3_unknown_rc=$?
  set -e
  if [ "$strict_stage3_unknown_rc" -eq 0 ]; then
    printf 'Expected strict stage3 compiler to reject unsupported build-ir input\n' >&2
    cat /tmp/ycpl-strict-stage3-unknown-ir.out >&2
    exit 1
  fi
  grep -q 'failed to write selected IR' /tmp/ycpl-strict-stage3-unknown-ir.out
  strict_stage4_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage4-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir compiler/ycpl -o "$strict_stage4_ir_dir" >/tmp/ycpl-strict-stage4-ir.out
  grep -q 'YCPL stage4 AST IR' "$strict_stage4_ir_dir/merged.ll"
  grep -q '@ycpl_stage4_ast_expr_nodes' "$strict_stage4_ir_dir/merged.ll"
  "$LLC_BIN" -filetype=obj "$strict_stage4_ir_dir/merged.ll" -o "$strict_stage4_ir_dir/merged.o"
  strict_stage3_tiny_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-tiny-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir "$renamed_tiny" -o "$strict_stage3_tiny_ir_dir" >/tmp/ycpl-strict-stage3-tiny-ir.out
  grep -q 'ret i32 13' "$strict_stage3_tiny_ir_dir/merged.ll"
  strict_stage3_call_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-call-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/56_self_codegen_call_assignment.yc -o "$strict_stage3_call_ir_dir" >/tmp/ycpl-strict-stage3-call-ir.out
  grep -q 'define i32 @seed' "$strict_stage3_call_ir_dir/merged.ll"
  grep -q 'call i32 @seed' "$strict_stage3_call_ir_dir/merged.ll"
  grep -q 'store i32 %calltmp' "$strict_stage3_call_ir_dir/merged.ll"
  grep -q 'ret i32 %loadtmp' "$strict_stage3_call_ir_dir/merged.ll"
  strict_stage3_control_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-control-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/57_self_codegen_control_flow.yc -o "$strict_stage3_control_ir_dir" >/tmp/ycpl-strict-stage3-control-ir.out
  grep -q 'tiny_if_then' "$strict_stage3_control_ir_dir/merged.ll"
  grep -q 'tiny_for_check' "$strict_stage3_control_ir_dir/merged.ll"
  grep -q 'tiny_for_update' "$strict_stage3_control_ir_dir/merged.ll"
  grep -q 'br i1' "$strict_stage3_control_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_control_ir_dir/merged.ll"
  strict_stage3_else_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-else-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/58_self_codegen_else_helper.yc -o "$strict_stage3_else_ir_dir" >/tmp/ycpl-strict-stage3-else-ir.out
  grep -q 'define i32 @base' "$strict_stage3_else_ir_dir/merged.ll"
  grep -q 'call i32 @base' "$strict_stage3_else_ir_dir/merged.ll"
  grep -q 'tiny_if_else' "$strict_stage3_else_ir_dir/merged.ll"
  grep -q 'tiny_for_check' "$strict_stage3_else_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_else_ir_dir/merged.ll"
  strict_stage3_param_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-param-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/59_self_codegen_param_call.yc -o "$strict_stage3_param_ir_dir" >/tmp/ycpl-strict-stage3-param-ir.out
  grep -q 'define i32 @inc(i32' "$strict_stage3_param_ir_dir/merged.ll"
  grep -q 'call i32 @inc(i32' "$strict_stage3_param_ir_dir/merged.ll"
  grep -Eq 'store i32 %[0-9a-zA-Z_.]+, ptr %[0-9a-zA-Z_.]+' "$strict_stage3_param_ir_dir/merged.ll"
  grep -Eq 'ret i32 %loadtmp[0-9]*' "$strict_stage3_param_ir_dir/merged.ll"
  strict_stage3_chain_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-chain-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/60_self_codegen_helper_chain.yc -o "$strict_stage3_chain_ir_dir" >/tmp/ycpl-strict-stage3-chain-ir.out
  grep -q 'define i32 @seed' "$strict_stage3_chain_ir_dir/merged.ll"
  grep -q 'define i32 @bump(i32' "$strict_stage3_chain_ir_dir/merged.ll"
  grep -q 'call i32 @seed' "$strict_stage3_chain_ir_dir/merged.ll"
  grep -q 'call i32 @bump(i32' "$strict_stage3_chain_ir_dir/merged.ll"
  grep -Eq 'ret i32 %loadtmp[0-9]*' "$strict_stage3_chain_ir_dir/merged.ll"
  strict_stage3_twoarg_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-twoarg-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/61_self_codegen_two_arg_call.yc -o "$strict_stage3_twoarg_ir_dir" >/tmp/ycpl-strict-stage3-twoarg-ir.out
  grep -q 'define i32 @add_pair(i32' "$strict_stage3_twoarg_ir_dir/merged.ll"
  grep -q 'call i32 @add_pair(i32' "$strict_stage3_twoarg_ir_dir/merged.ll"
  grep -q 'ret i32 %loadtmp' "$strict_stage3_twoarg_ir_dir/merged.ll"
  strict_stage3_forward_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-forward-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/62_self_codegen_forward_call.yc -o "$strict_stage3_forward_ir_dir" >/tmp/ycpl-strict-stage3-forward-ir.out
  grep -q 'define i32 @add_pair(i32' "$strict_stage3_forward_ir_dir/merged.ll"
  grep -q 'call i32 @add_pair(i32' "$strict_stage3_forward_ir_dir/merged.ll"
  grep -q 'ret i32 %loadtmp' "$strict_stage3_forward_ir_dir/merged.ll"
  strict_stage4_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage4-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build compiler/ycpl -o "$strict_stage4_native_dir" >/tmp/ycpl-strict-stage4-native.out
  if [ ! -x "$strict_stage4_native_dir/merged" ]; then
    printf 'Expected strict stage3 compiler to emit native %s/merged\n' "$strict_stage4_native_dir" >&2
    cat /tmp/ycpl-strict-stage4-native.out >&2
    exit 1
  fi
  "$strict_stage4_native_dir/merged" >/tmp/ycpl-strict-stage4-native-run.out
  grep -q 'YCPL stage4 AST IR' /tmp/ycpl-strict-stage4-native-run.out
  "$strict_stage4_native_dir/merged" parse compiler/ycpl >/tmp/ycpl-strict-stage4-native-parse.out
  "$strict_stage4_native_dir/merged" check compiler/ycpl >/tmp/ycpl-strict-stage4-native-check.out
  grep -q 'files=22' /tmp/ycpl-strict-stage4-native-parse.out
  grep -q 'typed_nodes=' /tmp/ycpl-strict-stage4-native-parse.out
  grep -q 'expr_nodes=' /tmp/ycpl-strict-stage4-native-parse.out
  grep -q 'main=1' /tmp/ycpl-strict-stage4-native-check.out
  strict_stage5_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage5-ir.XXXXXX")"
  "$strict_stage4_native_dir/merged" build-ir compiler/ycpl -o "$strict_stage5_ir_dir" >/tmp/ycpl-strict-stage5-ir.out
  grep -q 'YCPL stage5 AST IR' "$strict_stage5_ir_dir/merged.ll"
  grep -q '@ycpl_stage5_ast_expr_nodes' "$strict_stage5_ir_dir/merged.ll"
  "$LLC_BIN" -filetype=obj "$strict_stage5_ir_dir/merged.ll" -o "$strict_stage5_ir_dir/merged.o"
  strict_stage5_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage5-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage4_native_dir/merged" build compiler/ycpl -o "$strict_stage5_native_dir" >/tmp/ycpl-strict-stage5-native.out
  if [ ! -x "$strict_stage5_native_dir/merged" ]; then
    printf 'Expected strict stage4 compiler to emit native %s/merged\n' "$strict_stage5_native_dir" >&2
    cat /tmp/ycpl-strict-stage5-native.out >&2
    exit 1
  fi
  "$strict_stage5_native_dir/merged" >/tmp/ycpl-strict-stage5-native-run.out
  grep -q 'YCPL stage5 AST IR' /tmp/ycpl-strict-stage5-native-run.out
  strict_stage3_tiny_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-tiny-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build "$renamed_tiny" -o "$strict_stage3_tiny_native_dir" >/tmp/ycpl-strict-stage3-tiny-native.out
  set +e
  "$strict_stage3_tiny_native_dir/merged" >/dev/null 2>&1
  strict_stage3_tiny_status=$?
  set -e
  if [ "$strict_stage3_tiny_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler tiny native to exit 13, got %d\n' "$strict_stage3_tiny_status" >&2
    exit 1
  fi
  strict_stage3_call_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-call-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/56_self_codegen_call_assignment.yc -o "$strict_stage3_call_native_dir" >/tmp/ycpl-strict-stage3-call-native.out
  set +e
  "$strict_stage3_call_native_dir/merged" >/dev/null 2>&1
  strict_stage3_call_status=$?
  set -e
  if [ "$strict_stage3_call_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler call native to exit 13, got %d\n' "$strict_stage3_call_status" >&2
    exit 1
  fi
  strict_stage3_control_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-control-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/57_self_codegen_control_flow.yc -o "$strict_stage3_control_native_dir" >/tmp/ycpl-strict-stage3-control-native.out
  set +e
  "$strict_stage3_control_native_dir/merged" >/dev/null 2>&1
  strict_stage3_control_status=$?
  set -e
  if [ "$strict_stage3_control_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler control native to exit 13, got %d\n' "$strict_stage3_control_status" >&2
    exit 1
  fi
  strict_stage3_else_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-else-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/58_self_codegen_else_helper.yc -o "$strict_stage3_else_native_dir" >/tmp/ycpl-strict-stage3-else-native.out
  set +e
  "$strict_stage3_else_native_dir/merged" >/dev/null 2>&1
  strict_stage3_else_status=$?
  set -e
  if [ "$strict_stage3_else_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler else/helper native to exit 13, got %d\n' "$strict_stage3_else_status" >&2
    exit 1
  fi
  strict_stage3_param_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-param-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/59_self_codegen_param_call.yc -o "$strict_stage3_param_native_dir" >/tmp/ycpl-strict-stage3-param-native.out
  set +e
  "$strict_stage3_param_native_dir/merged" >/dev/null 2>&1
  strict_stage3_param_status=$?
  set -e
  if [ "$strict_stage3_param_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler param-call native to exit 13, got %d\n' "$strict_stage3_param_status" >&2
    exit 1
  fi
  strict_stage3_chain_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-chain-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/60_self_codegen_helper_chain.yc -o "$strict_stage3_chain_native_dir" >/tmp/ycpl-strict-stage3-chain-native.out
  set +e
  "$strict_stage3_chain_native_dir/merged" >/dev/null 2>&1
  strict_stage3_chain_status=$?
  set -e
  if [ "$strict_stage3_chain_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler helper-chain native to exit 13, got %d\n' "$strict_stage3_chain_status" >&2
    exit 1
  fi
  strict_stage3_twoarg_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-twoarg-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/61_self_codegen_two_arg_call.yc -o "$strict_stage3_twoarg_native_dir" >/tmp/ycpl-strict-stage3-twoarg-native.out
  set +e
  "$strict_stage3_twoarg_native_dir/merged" >/dev/null 2>&1
  strict_stage3_twoarg_status=$?
  set -e
  if [ "$strict_stage3_twoarg_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler two-arg native to exit 13, got %d\n' "$strict_stage3_twoarg_status" >&2
    exit 1
  fi
  strict_stage3_forward_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-forward-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/62_self_codegen_forward_call.yc -o "$strict_stage3_forward_native_dir" >/tmp/ycpl-strict-stage3-forward-native.out
  set +e
  "$strict_stage3_forward_native_dir/merged" >/dev/null 2>&1
  strict_stage3_forward_status=$?
  set -e
  if [ "$strict_stage3_forward_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler forward-call native to exit 13, got %d\n' "$strict_stage3_forward_status" >&2
    exit 1
  fi

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
grep -q 'files=22' /tmp/ycpl-stage2-parse.out
grep -q 'files=22' /tmp/ycpl-stage2-check.out
grep -q 'fn_digest=' /tmp/ycpl-stage2-parse.out
grep -q 'body_digest=' /tmp/ycpl-stage2-parse.out
grep -q 'body_nodes=' /tmp/ycpl-stage2-parse.out
grep -q 'body_slots=' /tmp/ycpl-stage2-parse.out
grep -q 'transition_digest=' /tmp/ycpl-stage2-parse.out
grep -q 'return_exprs=' /tmp/ycpl-stage2-parse.out
grep -q 'typed_nodes=' /tmp/ycpl-stage2-parse.out
grep -q 'sig_nodes=' /tmp/ycpl-stage2-parse.out
grep -q 'expr_table: nodes=' /tmp/ycpl-stage2-parse.out
grep -q 'slots=' /tmp/ycpl-stage2-parse.out
grep -q 'typed_digest=' /tmp/ycpl-stage2-parse.out
grep -q 'main=1' /tmp/ycpl-stage2-check.out
grep -q 'body_digest=' /tmp/ycpl-stage2-check.out
grep -q 'ret_digest=' /tmp/ycpl-stage2-check.out
grep -q 'transition_digest=' /tmp/ycpl-stage2-check.out
grep -q 'local_assign_edges=' /tmp/ycpl-stage2-check.out
grep -q 'if_nodes=' /tmp/ycpl-stage2-check.out
grep -q 'for_nodes=' /tmp/ycpl-stage2-check.out
grep -q 'typed_nodes=' /tmp/ycpl-stage2-check.out
grep -q 'sig_nodes=' /tmp/ycpl-stage2-check.out
grep -q 'expr_table: nodes=' /tmp/ycpl-stage2-check.out
grep -q 'slots=' /tmp/ycpl-stage2-check.out
grep -q 'body_slots=' /tmp/ycpl-stage2-check.out
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
