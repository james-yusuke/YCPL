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

"$YCC_YCPL" parse compiler/ycpl >/tmp/ycpl-stage-parse.out
"$YCC_YCPL" check compiler/ycpl >/tmp/ycpl-stage-check.out
"$YCC_YCPL" parse examples/101_enum_switch_type_alias.yc >/tmp/ycpl-stage-enum-switch-type-parse.out
grep -q 'parse ok:' /tmp/ycpl-stage-enum-switch-type-parse.out
grep -q 'decls=4' /tmp/ycpl-stage-enum-switch-type-parse.out
grep -q 'funcs=2' /tmp/ycpl-stage-enum-switch-type-parse.out
grep -q 'nodes=' /tmp/ycpl-stage-enum-switch-type-parse.out
eightarg_stage_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-stage-eightarg-check.XXXXXX")"
cat >"$eightarg_stage_dir/removed_mut.yc" <<'YCPL'
fn main() i32 {
    mut value := 1
    return value
}
YCPL
set +e
"$YCC_YCPL" parse "$eightarg_stage_dir/removed_mut.yc" >/tmp/ycpl-stage-removed-mut.out 2>&1
removed_mut_rc=$?
set -e
if [ "$removed_mut_rc" -eq 0 ]; then
  printf 'Expected removed mut keyword to fail parsing\n' >&2
  cat /tmp/ycpl-stage-removed-mut.out >&2
  exit 1
fi
grep -q 'removed keyword is not supported' /tmp/ycpl-stage-removed-mut.out
cat >"$eightarg_stage_dir/eightarg.yc" <<'YCPL'
extern fn sum8(a i32, b i32, c i32, d i32, e i32, f i32, g i32, h i32) i32 as "sum8"

fn main() i32 {
    return sum8(1, 2, 3, 1, 2, 1, 2, 1)
}
YCPL
"$YCC_YCPL" check "$eightarg_stage_dir/eightarg.yc" >/tmp/ycpl-stage-eightarg-check.out
grep -q 'value=13' /tmp/ycpl-stage-eightarg-check.out
cat >"$eightarg_stage_dir/helper8.yc" <<'YCPL'
fn sum8(a i32, b i32, c i32, d i32, e i32, f i32, g i32, h i32) i32 {
    return a + b + c + d + e + f + g + h
}

fn main() i32 {
    return sum8(1, 2, 3, 1, 2, 1, 2, 1)
}
YCPL
"$YCC_YCPL" check "$eightarg_stage_dir/helper8.yc" >/tmp/ycpl-stage-helper8-check.out
grep -q 'value=13' /tmp/ycpl-stage-helper8-check.out
cat >"$eightarg_stage_dir/manyhelpers.yc" <<'YCPL'
fn h0() i32 { return 0 }
fn h1() i32 { return 1 }
fn h2() i32 { return 2 }
fn h3() i32 { return 3 }
fn h4() i32 { return 4 }
fn h5() i32 { return 5 }
fn h6() i32 { return 6 }
fn h7() i32 { return 7 }
fn h8() i32 { return 13 }

fn main() i32 {
    return h8()
}
YCPL
"$YCC_YCPL" check "$eightarg_stage_dir/manyhelpers.yc" >/tmp/ycpl-stage-manyhelpers-check.out
grep -q 'value=13' /tmp/ycpl-stage-manyhelpers-check.out
cat >"$eightarg_stage_dir/manylocals.yc" <<'YCPL'
fn main() i32 {
    a0 := 0
    a1 := 1
    a2 := 2
    a3 := 3
    a4 := 4
    a5 := 5
    a6 := 6
    a7 := 7
    items := [4, 2, 7]
    items[1] = items[0] + items[2]
    return items[1] + 2
}
YCPL
"$YCC_YCPL" check "$eightarg_stage_dir/manylocals.yc" >/tmp/ycpl-stage-manylocals-check.out
grep -q 'value=13' /tmp/ycpl-stage-manylocals-check.out
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

fn traversal_switch_surface(value i32) i32 {
    switch value {
        case 0 {
            return 1
        }
        default {
            return 2
        }
    }
    return 3
}
YCPL
cat >"$traversal_dir/ycpl/src/aaa_switch.yc" <<'YCPL'
module compiler.ycpl.generated.switchsurface

fn traversal_switch_surface(value i32) i32 {
    switch value {
        case 0 {
            return 1
        }
        default {
            return 2
        }
    }
    return 3
}
YCPL
"$YCC_YCPL" parse "$traversal_dir/ycpl" >/tmp/ycpl-stage-traversal-parse.out
require_project_file_count /tmp/ycpl-stage-traversal-parse.out 24 "recursive traversal in $traversal_dir/ycpl"
traversal_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-stage-traversal-ir.XXXXXX")"
YCPL_NO_BOOTSTRAP=1 "$YCC_YCPL" build-ir "$traversal_dir/ycpl" -o "$traversal_ir_dir" >/tmp/ycpl-stage-traversal-ir.out
grep -q 'node_lower_else_body' "$traversal_ir_dir/project_body.ll"
grep -q 'node_lower_break_slot' "$traversal_ir_dir/project_body.ll"
grep -q 'node_lower_continue_slot' "$traversal_ir_dir/project_body.ll"
grep -q 'node_lower_for_in_check' "$traversal_ir_dir/project_body.ll"
grep -q 'node_lower_switch_case' "$traversal_ir_dir/project_body.ll"
grep -q 'switch i32' "$traversal_ir_dir/project_body.ll"
require_project_file_count /tmp/ycpl-stage-parse.out 23 "stage parse"
require_project_file_count /tmp/ycpl-stage-check.out 23 "stage check"
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
grep -q '@ycpl_ast_signature_typed_return_functions' "$strict_ir_dir/merged.ll"
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
grep -q 'load i32, ptr @ycpl_ast_signature_typed_return_functions' "$strict_ir_dir/merged.ll"
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
grep -q 'function_body_source_traversal_gate' "$strict_ir_dir/merged.ll"
grep -q 'function_body_second_half' "$strict_ir_dir/merged.ll"
grep -q 'function_body_tail' "$strict_ir_dir/merged.ll"
grep -q 'function_body_range6_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_range_tail' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ranges_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_slot_and_range_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_score' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_body_identifier_payloads' "$strict_ir_dir/merged.ll"
grep -q 'function_body_literal_payloads' "$strict_ir_dir/merged.ll"
grep -q 'function_body_type_payloads' "$strict_ir_dir/merged.ll"
grep -q 'function_body_control_payloads' "$strict_ir_dir/merged.ll"
grep -q 'function_body_local_symbol_refs' "$strict_ir_dir/merged.ll"
grep -q 'function_body_assignment_target_refs' "$strict_ir_dir/merged.ll"
grep -q 'function_body_call_target_refs' "$strict_ir_dir/merged.ll"
grep -q 'function_body_return_symbol_refs' "$strict_ir_dir/merged.ll"
grep -q 'function_body_semantic_surface' "$strict_ir_dir/merged.ll"
grep -q 'function_body_semantic_node_sum' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_lowered_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_value_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_type_state' "$strict_ir_dir/merged.ll"
grep -q 'loaded_function_expr_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_table_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_literal_value_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_string_literal_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_bool_literal_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_none_literal_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_numeric_literal_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_identifier_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_identifier_resolved_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_call_value_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_call_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_call_resolved_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_project_call_resolved_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_typed_identifier_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_typed_call_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_project_typed_call_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_typed_symbol_surface' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_project_type_surface' "$strict_ir_dir/merged.ll"
grep -q 'function_expression_typed_shape_score' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_field0_gep' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_field_index_gep' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_field_index_value' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_resolved_field_index_value' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_actual_struct_gep' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_actual_field_loaded' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_actual_field_value' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_name_hash_value' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_name_indexed_value' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_field2_gep' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_index_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_index_slice_len_gep' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_index_bounds_check' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_index_gep' "$strict_ir_dir/merged.ll"
grep -q 'expr_lower_index_slice_len_gep' "$strict_ir_dir/merged.ll"
grep -q 'expr_lower_index_bounds_check' "$strict_ir_dir/merged.ll"
grep -q 'expr_lower_index_in_bounds' "$strict_ir_dir/merged.ll"
grep -q 'expr_lower_index_oob' "$strict_ir_dir/merged.ll"
grep -q 'expr_lower_index_gep' "$strict_ir_dir/merged.ll"
grep -q 'expr_lower_index_len_checked_value' "$strict_ir_dir/merged.ll"
grep -q 'alloca \[4 x i32\]' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_binary_value_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_binary_value_cmp' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_binary_bool_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_binary_numeric_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_unary_numeric_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_lowered_value_state' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_lowered_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_expr_value_environment' "$strict_ir_dir/merged.ll"
grep -q 'function_body_expr_typed_environment' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_value_for_statement' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_type_for_statement' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_typed_value_for_statement' "$strict_ir_dir/merged.ll"
grep -q 'function_body_assignment_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_return_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_value_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_statement_expr_type' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_expr_value_flow' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_expr_typed_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_ast_value_slot' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_ast_value_seed' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_ast_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_direct_local_loaded' "$strict_ir_dir/merged.ll"
grep -q 'function_body_direct_assignment_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_direct_assignment_loaded' "$strict_ir_dir/merged.ll"
grep -q 'function_body_direct_call_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_direct_call_loaded' "$strict_ir_dir/merged.ll"
grep -q 'function_body_direct_return_loaded' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_ast_lowered_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_local_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_assignment_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_call_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_return_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_i32_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_bool_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_string_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_pointer_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_none_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_unknown_statement_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_resolved_local_numeric_type_flow' "$strict_ir_dir/merged.ll"
grep -q 'function_body_resolved_assignment_numeric_type_flow' "$strict_ir_dir/merged.ll"
grep -q 'function_body_resolved_call_numeric_type_flow' "$strict_ir_dir/merged.ll"
grep -q 'function_body_resolved_return_numeric_type_flow' "$strict_ir_dir/merged.ll"
grep -q 'function_body_resolved_statement_role_type_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_real_resolved_type_lowered_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_expr_typed_environment' "$strict_ir_dir/merged.ll"
grep -q 'function_body_expr_typed_with_statement_environment' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_expr_owner_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_expr_owner_value_flow' "$strict_ir_dir/merged.ll"
grep -q 'function_body_lowered_statement_expr_owner_state' "$strict_ir_dir/merged.ll"
grep -q 'function_statement_expr_owner_limit' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_expr_owner_lowered_count' "$strict_ir_dir/merged.ll"
grep -q 'function_body_lowered_statement_expr_owner_count' "$strict_ir_dir/merged.ll"
grep -q 'function_body_statement_expr_owner_lowered_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_sequence_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_kind_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_expr_count_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_semantic_sequence_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_local_sequence_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_assignment_sequence_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_call_sequence_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_return_sequence_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_control_sequence_state' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_semantic_sequence_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_ast_node_sequence_lowered' "$strict_ir_dir/merged.ll"
grep -q 'function_body_expr_owner_environment' "$strict_ir_dir/merged.ll"
grep -q 'node_statement_expr_owner_score' "$strict_ir_dir/merged.ll"
grep -q 'function_statement_expr_ownership_score' "$strict_ir_dir/merged.ll"
grep -q 'function_body_owned_expr_sum' "$strict_ir_dir/merged.ll"
grep -q 'function_tail_expr_value' "$strict_ir_dir/merged.ll"
grep -q 'function_body_tail_expr_value_flow' "$strict_ir_dir/merged.ll"
grep -Eq 'store i32 ([6-9][0-9][0-9]|[1-9][0-9][0-9][0-9]), ptr %function_expr_lowered_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expression_slot_score' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_identifier_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_literal_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_string_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_bool_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_none_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_member_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_index_nodes' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_literal_type_surface' "$strict_ir_dir/merged.ll"
grep -q 'function_expr_call_access_sum' "$strict_ir_dir/merged.ll"
grep -q 'function_expression_shape_score' "$strict_ir_dir/merged.ll"
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
grep -q 'define i32 @ycpl_node_switch_probe' "$strict_ir_dir/local_return.ll"
grep -q 'switch i32' "$strict_ir_dir/local_return.ll"
grep -q 'call i32 @ycpl_node_switch_probe' "$strict_ir_dir/local_return.ll"
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
grep -q 'function_body_source_traversal_gate' "$strict_ir_dir/project_body.ll"
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
grep -q 'function_body_identifier_payloads' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_literal_payloads' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_type_payloads' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_control_payloads' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_local_symbol_refs' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_assignment_target_refs' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_call_target_refs' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_return_symbol_refs' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_semantic_surface' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_semantic_node_sum' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_lowered_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'loaded_function_expr_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_table_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_literal_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_string_literal_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_bool_literal_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_none_literal_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_numeric_literal_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_identifier_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_identifier_resolved_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_call_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_call_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_call_resolved_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_project_call_resolved_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_typed_identifier_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_typed_call_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_project_typed_call_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_typed_symbol_surface' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_project_type_surface' "$strict_ir_dir/project_body.ll"
grep -q 'function_expression_typed_shape_score' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_field0_gep' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_field_index_gep' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_field_index_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_resolved_field_index_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_actual_struct_gep' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_actual_field_loaded' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_actual_field_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_name_hash_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_name_indexed_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_field2_gep' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_index_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_index_slice_len_gep' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_index_bounds_check' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_index_gep' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_index_slice_len_gep' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_index_bounds_check' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_index_in_bounds' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_index_oob' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_index_gep' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_index_len_checked_value' "$strict_ir_dir/project_body.ll"
grep -q 'alloca \[4 x i32\]' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_binary_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_binary_value_cmp' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_binary_bool_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_binary_numeric_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_unary_numeric_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_lowered_value_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_lowered_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_expr_value_environment' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_expr_typed_environment' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_value_for_statement' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_type_for_statement' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_typed_value_for_statement' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_assignment_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_return_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_value_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_statement_expr_type' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_expr_value_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_expr_typed_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_ast_value_slot' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_ast_value_seed' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_ast_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_direct_local_loaded' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_direct_assignment_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_direct_assignment_loaded' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_direct_call_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_direct_call_loaded' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_direct_return_loaded' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_ast_lowered_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_local_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_assignment_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_call_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_return_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_i32_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_bool_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_string_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_pointer_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_none_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_unknown_statement_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_resolved_local_numeric_type_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_resolved_local_reference_type_flow_slot' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_resolved_assignment_numeric_type_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_resolved_assignment_reference_type_flow_slot' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_resolved_call_numeric_type_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_resolved_call_reference_type_flow_slot' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_resolved_return_numeric_type_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_resolved_return_reference_type_flow_slot' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_resolved_statement_role_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_resolved_statement_type_flow_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_resolved_type_lowered_state' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_call_resolved_arity_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_call_resolved_arity_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_call_resolved_arity_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_project_call_signature_type_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_expr_typed_environment' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_expr_typed_with_statement_environment' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_expr_owner_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_expr_owner_value_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_lowered_statement_expr_owner_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_statement_expr_owner_limit' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_expr_owner_lowered_count' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_lowered_statement_expr_owner_count' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_statement_expr_owner_lowered_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_sequence_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_kind_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_expr_count_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_semantic_sequence_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_local_sequence_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_assignment_sequence_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_call_sequence_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_return_sequence_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_control_sequence_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_semantic_sequence_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_ast_node_sequence_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_expr_owner_environment' "$strict_ir_dir/project_body.ll"
grep -q 'node_statement_expr_owner_score' "$strict_ir_dir/project_body.ll"
grep -q 'function_statement_expr_ownership_score' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_owned_expr_sum' "$strict_ir_dir/project_body.ll"
grep -q 'function_tail_expr_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_tail_expr_type' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_tail_expr_value_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_tail_expr_typed_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_statement_ast_value_slot' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_statement_expr_typed_value' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_ast_node_sequence_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_ast_node_semantic_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_statement_expr_owner_lowered' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_tail_expr_value_flow' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_lowered_node_count' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_lowered_expr_count' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_unlowered_node_count' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_unlowered_expr_count' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_lowered_coverage' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_unlowered_total' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_lowered_covered_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_unlowered_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_lowered_state' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_lowered_total_with_real_ast' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_node_lowering_limit' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_expr_lowering_limit' "$strict_ir_dir/project_body.ll"
grep -q 'function_body_real_statement_expr_lowering_limit' "$strict_ir_dir/project_body.ll"
grep -q 'store i32 128, ptr %function_body_real_node_lowering_limit' "$strict_ir_dir/project_body.ll"
grep -q 'store i32 256, ptr %function_body_real_expr_lowering_limit' "$strict_ir_dir/project_body.ll"
grep -q 'store i32 128, ptr %function_body_real_statement_expr_lowering_limit' "$strict_ir_dir/project_body.ll"
grep -q 'store i32 128, ptr %function_body_real_lowered_node_count' "$strict_ir_dir/project_body.ll"
grep -q 'store i32 256, ptr %function_body_real_lowered_expr_count' "$strict_ir_dir/project_body.ll"
if grep -Eq 'store i32 (12[9]|1[3-9][0-9]|[2-9][0-9][0-9]|[1-9][0-9][0-9][0-9]+), ptr %function_body_real_lowered_node_count' "$strict_ir_dir/project_body.ll"; then
  printf 'function_body_real_lowered_node_count exceeded the configured real node lowering cap\n' >&2
  exit 1
fi
if grep -Eq 'store i32 (25[7-9]|2[6-9][0-9]|[3-9][0-9][0-9]|[1-9][0-9][0-9][0-9]+), ptr %function_body_real_lowered_expr_count' "$strict_ir_dir/project_body.ll"; then
  printf 'function_body_real_lowered_expr_count exceeded the configured real expression lowering cap\n' >&2
  exit 1
fi
grep -Eq 'store i32 ([1-9][0-9]*), ptr %function_body_real_unlowered_node_count' "$strict_ir_dir/project_body.ll"
grep -Eq 'store i32 ([1-9][0-9]*), ptr %function_body_real_unlowered_expr_count' "$strict_ir_dir/project_body.ll"
grep -q 'store i32 128, ptr %function_statement_expr_owner_limit' "$strict_ir_dir/project_body.ll"
grep -Eq 'store i32 ([6-9][0-9][0-9]|[1-9][0-9][0-9][0-9]), ptr %function_expr_lowered_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expression_slot_score' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_identifier_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_literal_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_string_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_bool_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_none_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_member_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_index_nodes' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_literal_type_surface' "$strict_ir_dir/project_body.ll"
grep -q 'function_expr_call_access_sum' "$strict_ir_dir/project_body.ll"
grep -q 'function_expression_shape_score' "$strict_ir_dir/project_body.ll"
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
grep -q 'expr_lower_member_field0_gep' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_member_field_index_gep' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_member_field_index_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_member_resolved_field_index_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_member_actual_struct_gep' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_member_actual_field_loaded' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_member_actual_field_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_member_name_hash_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_member_name_indexed_value' "$strict_ir_dir/project_body.ll"
grep -q 'expr_lower_member_field2_gep' "$strict_ir_dir/project_body.ll"
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
require_project_file_count /tmp/ycpl-strict-native-parse.out 23 "strict native parse"
require_project_file_count /tmp/ycpl-strict-native-check.out 23 "strict native check"
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
grep -q 'LLVM_CONFIG' "$strict_stage3_ir_dir/merged.ll"
grep -q 'PATH=/opt/homebrew/opt/llvm/bin' "$strict_stage3_ir_dir/merged.ll"
grep -q '/usr/lib/llvm-22/bin' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinystd2encoding.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinystdbase64.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinystdbytes.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyllvmcall2icmp.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyllvmbuildermemory.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyllvmfunctiontype.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyvoidextern.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyllvmcapi.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyexternmalloc.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyexternstring.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinymainargs.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinystring.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyarray.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyenumswitch.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinyboolhelper.ir' "$strict_stage3_ir_dir/merged.ll"
grep -q '@.stage3.tinybool.ir' "$strict_stage3_ir_dir/merged.ll"
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

strict_dynamic_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-dynamic-return-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/73_self_codegen_dynamic_return.yc -o "$strict_dynamic_return_ir_dir" >/tmp/ycpl-strict-dynamic-return-ir.out
grep -q 'YCPL dynamic constant return IR' "$strict_dynamic_return_ir_dir/merged.ll"
grep -q 'ret i32 17' "$strict_dynamic_return_ir_dir/merged.ll"

strict_dynamic_local_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-dynamic-local-return-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/74_self_codegen_dynamic_local_return.yc -o "$strict_dynamic_local_return_ir_dir" >/tmp/ycpl-strict-dynamic-local-return-ir.out
grep -q 'YCPL dynamic local return IR' "$strict_dynamic_local_return_ir_dir/merged.ll"
grep -q 'store i32 23' "$strict_dynamic_local_return_ir_dir/merged.ll"
grep -q 'ret i32 %loadtmp' "$strict_dynamic_local_return_ir_dir/merged.ll"

strict_dynamic_assignment_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-dynamic-assignment-return-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/75_self_codegen_dynamic_assignment_return.yc -o "$strict_dynamic_assignment_return_ir_dir" >/tmp/ycpl-strict-dynamic-assignment-return-ir.out
grep -q 'YCPL dynamic assignment return IR' "$strict_dynamic_assignment_return_ir_dir/merged.ll"
grep -q 'store i32 4' "$strict_dynamic_assignment_return_ir_dir/merged.ll"
grep -q 'store i32 31' "$strict_dynamic_assignment_return_ir_dir/merged.ll"
grep -q 'ret i32 %loadtmp' "$strict_dynamic_assignment_return_ir_dir/merged.ll"

strict_dynamic_binary_add_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-dynamic-binary-add-return-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/79_self_codegen_dynamic_binary_add_return.yc -o "$strict_dynamic_binary_add_return_ir_dir" >/tmp/ycpl-strict-dynamic-binary-add-return-ir.out
grep -q 'YCPL dynamic binary add return IR' "$strict_dynamic_binary_add_return_ir_dir/merged.ll"
grep -q 'store i32 8' "$strict_dynamic_binary_add_return_ir_dir/merged.ll"
grep -q 'store i32 21' "$strict_dynamic_binary_add_return_ir_dir/merged.ll"
grep -q 'add i32 %leftload, %rightload' "$strict_dynamic_binary_add_return_ir_dir/merged.ll"
grep -q 'ret i32 %addtmp' "$strict_dynamic_binary_add_return_ir_dir/merged.ll"

strict_dynamic_compare_if_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-dynamic-compare-if-return-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/80_self_codegen_dynamic_compare_if_return.yc -o "$strict_dynamic_compare_if_return_ir_dir" >/tmp/ycpl-strict-dynamic-compare-if-return-ir.out
grep -q 'YCPL dynamic compare-if return IR' "$strict_dynamic_compare_if_return_ir_dir/merged.ll"
grep -q 'store i32 3' "$strict_dynamic_compare_if_return_ir_dir/merged.ll"
grep -q 'store i32 9' "$strict_dynamic_compare_if_return_ir_dir/merged.ll"
grep -q 'icmp slt i32 %leftload, %rightload' "$strict_dynamic_compare_if_return_ir_dir/merged.ll"
grep -q 'br i1 %cmptmp' "$strict_dynamic_compare_if_return_ir_dir/merged.ll"
grep -q 'ret i32 44' "$strict_dynamic_compare_if_return_ir_dir/merged.ll"
grep -q 'ret i32 12' "$strict_dynamic_compare_if_return_ir_dir/merged.ll"

strict_dynamic_zero_call_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-dynamic-zero-call-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/76_self_codegen_dynamic_zero_arg_call.yc -o "$strict_dynamic_zero_call_ir_dir" >/tmp/ycpl-strict-dynamic-zero-call-ir.out
grep -q 'YCPL dynamic zero-arg call IR' "$strict_dynamic_zero_call_ir_dir/merged.ll"
grep -q 'define i32 @dyn_seed' "$strict_dynamic_zero_call_ir_dir/merged.ll"
grep -q 'ret i32 29' "$strict_dynamic_zero_call_ir_dir/merged.ll"
grep -q 'call i32 @dyn_seed' "$strict_dynamic_zero_call_ir_dir/merged.ll"

strict_dynamic_if_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-dynamic-if-return-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/77_self_codegen_dynamic_if_return.yc -o "$strict_dynamic_if_return_ir_dir" >/tmp/ycpl-strict-dynamic-if-return-ir.out
grep -q 'YCPL dynamic if-return IR' "$strict_dynamic_if_return_ir_dir/merged.ll"
grep -q 'icmp eq i32' "$strict_dynamic_if_return_ir_dir/merged.ll"
grep -q 'br i1' "$strict_dynamic_if_return_ir_dir/merged.ll"
grep -q 'ret i32 34' "$strict_dynamic_if_return_ir_dir/merged.ll"
grep -q 'ret i32 55' "$strict_dynamic_if_return_ir_dir/merged.ll"

strict_dynamic_for_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-dynamic-for-return-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/78_self_codegen_dynamic_for_return.yc -o "$strict_dynamic_for_return_ir_dir" >/tmp/ycpl-strict-dynamic-for-return-ir.out
grep -q 'YCPL dynamic for-return IR' "$strict_dynamic_for_return_ir_dir/merged.ll"
grep -q 'loop_check' "$strict_dynamic_for_return_ir_dir/merged.ll"
grep -q 'loop_update' "$strict_dynamic_for_return_ir_dir/merged.ll"
grep -q 'icmp slt i32' "$strict_dynamic_for_return_ir_dir/merged.ll"
grep -q 'add i32 %sumload, 3' "$strict_dynamic_for_return_ir_dir/merged.ll"
grep -q 'ret i32 %result' "$strict_dynamic_for_return_ir_dir/merged.ll"

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

strict_bool_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-bool-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/63_self_codegen_bool_condition.yc -o "$strict_bool_ir_dir" >/tmp/ycpl-strict-bool-ir.out
grep -q 'alloca i1' "$strict_bool_ir_dir/merged.ll"
grep -q 'xor i1' "$strict_bool_ir_dir/merged.ll"
grep -q 'ret i32 %result' "$strict_bool_ir_dir/merged.ll"

strict_bool_helper_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-bool-helper-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/64_self_codegen_bool_helper.yc -o "$strict_bool_helper_ir_dir" >/tmp/ycpl-strict-bool-helper-ir.out
grep -q 'define i1 @ready' "$strict_bool_helper_ir_dir/merged.ll"
grep -q 'call i1 @ready' "$strict_bool_helper_ir_dir/merged.ll"
grep -q 'ret i32 %result' "$strict_bool_helper_ir_dir/merged.ll"

strict_string_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-string-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/65_self_codegen_string_local.yc -o "$strict_string_ir_dir" >/tmp/ycpl-strict-string-ir.out
grep -q 'define ptr @label' "$strict_string_ir_dir/merged.ll"
grep -q '@.tiny.string.compiler' "$strict_string_ir_dir/merged.ll"
grep -q 'store ptr %otherload' "$strict_string_ir_dir/merged.ll"

strict_array_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-array-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/81_self_codegen_array_index.yc -o "$strict_array_ir_dir" >/tmp/ycpl-strict-array-ir.out
grep -q 'YCPL tiny array index stage IR' "$strict_array_ir_dir/merged.ll"
grep -q 'alloca \[3 x i32\]' "$strict_array_ir_dir/merged.ll"
grep -q 'getelementptr \[3 x i32\]' "$strict_array_ir_dir/merged.ll"
grep -q 'ret i32 %result' "$strict_array_ir_dir/merged.ll"

enum_alias_switch_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-enum-alias-switch.XXXXXX")"
enum_alias_switch_file="$enum_alias_switch_dir/enum_alias_switch.yc"
cat > "$enum_alias_switch_file" <<'YCPL'
enum Color {
    Red = 2,
    Green,
    Blue = 8,
}

type Score = i32

fn main() i32 {
    choice: Score = Green
    switch choice {
        case Color.Red {
            return 7
        }
        case Green {
            return 13
        }
        default {
            return 99
        }
    }
    return 0
}
YCPL
strict_enum_alias_switch_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-enum-alias-switch-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir "$enum_alias_switch_file" -o "$strict_enum_alias_switch_ir_dir" >/tmp/ycpl-strict-enum-alias-switch-ir.out
grep -q 'YCPL tiny enum alias switch stage IR' "$strict_enum_alias_switch_ir_dir/merged.ll"
grep -q 'switch i32' "$strict_enum_alias_switch_ir_dir/merged.ll"
grep -q 'ret i32 13' "$strict_enum_alias_switch_ir_dir/merged.ll"

strict_extern_string_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-extern-string-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/66_self_codegen_extern_string_call.yc -o "$strict_extern_string_ir_dir" >/tmp/ycpl-strict-extern-string-ir.out
grep -q 'declare i32 @strcmp' "$strict_extern_string_ir_dir/merged.ll"
grep -q 'call i32 @strcmp' "$strict_extern_string_ir_dir/merged.ll"
grep -q 'ret i32 13' "$strict_extern_string_ir_dir/merged.ll"

strict_extern_malloc_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-extern-malloc-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/67_self_codegen_extern_malloc_ptr.yc -o "$strict_extern_malloc_ir_dir" >/tmp/ycpl-strict-extern-malloc-ir.out
grep -q 'declare ptr @malloc' "$strict_extern_malloc_ir_dir/merged.ll"
grep -q 'call ptr @malloc' "$strict_extern_malloc_ir_dir/merged.ll"
grep -q 'ret i32 13' "$strict_extern_malloc_ir_dir/merged.ll"

strict_llvm_c_api_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-llvm-c-api-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/68_self_codegen_llvm_c_api_call.yc -o "$strict_llvm_c_api_ir_dir" >/tmp/ycpl-strict-llvm-c-api-ir.out
grep -q 'declare ptr @LLVMContextCreate' "$strict_llvm_c_api_ir_dir/merged.ll"
grep -q 'call ptr @LLVMModuleCreateWithNameInContext' "$strict_llvm_c_api_ir_dir/merged.ll"

strict_void_extern_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-void-extern-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/69_self_codegen_void_extern_call.yc -o "$strict_void_extern_ir_dir" >/tmp/ycpl-strict-void-extern-ir.out
grep -q 'declare void @LLVMContextDispose' "$strict_void_extern_ir_dir/merged.ll"
grep -q 'define void @cleanup' "$strict_void_extern_ir_dir/merged.ll"

strict_llvm_function_type_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-llvm-function-type-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/70_self_codegen_llvm_function_type_call.yc -o "$strict_llvm_function_type_ir_dir" >/tmp/ycpl-strict-llvm-function-type-ir.out
grep -q 'declare ptr @LLVMFunctionType' "$strict_llvm_function_type_ir_dir/merged.ll"
grep -q 'call ptr @LLVMFunctionType' "$strict_llvm_function_type_ir_dir/merged.ll"

strict_llvm_builder_memory_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-llvm-builder-memory-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/71_self_codegen_llvm_builder_memory_call.yc -o "$strict_llvm_builder_memory_ir_dir" >/tmp/ycpl-strict-llvm-builder-memory-ir.out
grep -q 'declare ptr @LLVMBuildAlloca' "$strict_llvm_builder_memory_ir_dir/merged.ll"
grep -q 'call ptr @LLVMBuildLoad2' "$strict_llvm_builder_memory_ir_dir/merged.ll"

strict_llvm_call2_icmp_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-llvm-call2-icmp-ir.XXXXXX")"
"$strict_native_dir/merged" build-ir examples/72_self_codegen_llvm_call2_icmp_call.yc -o "$strict_llvm_call2_icmp_ir_dir" >/tmp/ycpl-strict-llvm-call2-icmp-ir.out
grep -q 'declare ptr @LLVMBuildCall2(ptr, ptr, ptr, ptr, i32, ptr)' "$strict_llvm_call2_icmp_ir_dir/merged.ll"
grep -q 'call ptr @LLVMBuildICmp' "$strict_llvm_call2_icmp_ir_dir/merged.ll"

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
  require_project_file_count /tmp/ycpl-strict-stage3-native-parse.out 23 "strict stage3 native parse"
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
  grep -q 'define i32 @ycpl_stage4_project_body_lowering' "$strict_stage4_ir_dir/merged.ll"
  grep -q 'function_body_statement_resolved_type_slot' "$strict_stage4_ir_dir/merged.ll"
  grep -q 'function_body_resolved_statement_value' "$strict_stage4_ir_dir/merged.ll"
  grep -q 'function_body_resolved_local_loaded' "$strict_stage4_ir_dir/merged.ll"
  grep -q 'function_body_resolved_assignment_loaded' "$strict_stage4_ir_dir/merged.ll"
  grep -q 'function_body_resolved_call_loaded' "$strict_stage4_ir_dir/merged.ll"
  grep -q 'function_body_resolved_return_loaded' "$strict_stage4_ir_dir/merged.ll"
  grep -q 'function_body_resolved_statement_lowered_state' "$strict_stage4_ir_dir/merged.ll"
  "$LLC_BIN" -filetype=obj "$strict_stage4_ir_dir/merged.ll" -o "$strict_stage4_ir_dir/merged.o"
  strict_stage3_tiny_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-tiny-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir "$renamed_tiny" -o "$strict_stage3_tiny_ir_dir" >/tmp/ycpl-strict-stage3-tiny-ir.out
  grep -q 'ret i32 13' "$strict_stage3_tiny_ir_dir/merged.ll"
  strict_stage3_dynamic_local_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-dynamic-local-return-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/74_self_codegen_dynamic_local_return.yc -o "$strict_stage3_dynamic_local_return_ir_dir" >/tmp/ycpl-strict-stage3-dynamic-local-return-ir.out
  grep -q 'YCPL dynamic local return IR' "$strict_stage3_dynamic_local_return_ir_dir/merged.ll"
  grep -q 'store i32 23' "$strict_stage3_dynamic_local_return_ir_dir/merged.ll"
  grep -q 'ret i32 %loadtmp' "$strict_stage3_dynamic_local_return_ir_dir/merged.ll"
  strict_stage3_dynamic_assignment_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-dynamic-assignment-return-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/75_self_codegen_dynamic_assignment_return.yc -o "$strict_stage3_dynamic_assignment_return_ir_dir" >/tmp/ycpl-strict-stage3-dynamic-assignment-return-ir.out
  grep -q 'YCPL dynamic assignment return IR' "$strict_stage3_dynamic_assignment_return_ir_dir/merged.ll"
  grep -q 'store i32 4' "$strict_stage3_dynamic_assignment_return_ir_dir/merged.ll"
  grep -q 'store i32 31' "$strict_stage3_dynamic_assignment_return_ir_dir/merged.ll"
  grep -q 'ret i32 %loadtmp' "$strict_stage3_dynamic_assignment_return_ir_dir/merged.ll"
  strict_stage3_dynamic_binary_add_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-dynamic-binary-add-return-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/79_self_codegen_dynamic_binary_add_return.yc -o "$strict_stage3_dynamic_binary_add_return_ir_dir" >/tmp/ycpl-strict-stage3-dynamic-binary-add-return-ir.out
  grep -q 'YCPL dynamic binary add return IR' "$strict_stage3_dynamic_binary_add_return_ir_dir/merged.ll"
  grep -q 'store i32 8' "$strict_stage3_dynamic_binary_add_return_ir_dir/merged.ll"
  grep -q 'store i32 21' "$strict_stage3_dynamic_binary_add_return_ir_dir/merged.ll"
  grep -q 'add i32 %leftload, %rightload' "$strict_stage3_dynamic_binary_add_return_ir_dir/merged.ll"
  grep -q 'ret i32 %addtmp' "$strict_stage3_dynamic_binary_add_return_ir_dir/merged.ll"
  strict_stage3_dynamic_compare_if_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-dynamic-compare-if-return-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/80_self_codegen_dynamic_compare_if_return.yc -o "$strict_stage3_dynamic_compare_if_return_ir_dir" >/tmp/ycpl-strict-stage3-dynamic-compare-if-return-ir.out
  grep -q 'YCPL dynamic compare-if return IR' "$strict_stage3_dynamic_compare_if_return_ir_dir/merged.ll"
  grep -q 'store i32 3' "$strict_stage3_dynamic_compare_if_return_ir_dir/merged.ll"
  grep -q 'store i32 9' "$strict_stage3_dynamic_compare_if_return_ir_dir/merged.ll"
  grep -q 'icmp slt i32 %leftload, %rightload' "$strict_stage3_dynamic_compare_if_return_ir_dir/merged.ll"
  grep -q 'br i1 %cmptmp' "$strict_stage3_dynamic_compare_if_return_ir_dir/merged.ll"
  grep -q 'ret i32 44' "$strict_stage3_dynamic_compare_if_return_ir_dir/merged.ll"
  grep -q 'ret i32 12' "$strict_stage3_dynamic_compare_if_return_ir_dir/merged.ll"
  strict_stage3_dynamic_zero_call_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-dynamic-zero-call-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/76_self_codegen_dynamic_zero_arg_call.yc -o "$strict_stage3_dynamic_zero_call_ir_dir" >/tmp/ycpl-strict-stage3-dynamic-zero-call-ir.out
  grep -q 'YCPL dynamic zero-arg call IR' "$strict_stage3_dynamic_zero_call_ir_dir/merged.ll"
  grep -q 'define i32 @dyn_seed' "$strict_stage3_dynamic_zero_call_ir_dir/merged.ll"
  grep -q 'ret i32 29' "$strict_stage3_dynamic_zero_call_ir_dir/merged.ll"
  grep -q 'call i32 @dyn_seed' "$strict_stage3_dynamic_zero_call_ir_dir/merged.ll"
  strict_stage3_dynamic_if_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-dynamic-if-return-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/77_self_codegen_dynamic_if_return.yc -o "$strict_stage3_dynamic_if_return_ir_dir" >/tmp/ycpl-strict-stage3-dynamic-if-return-ir.out
  grep -q 'YCPL dynamic if-return IR' "$strict_stage3_dynamic_if_return_ir_dir/merged.ll"
  grep -q 'icmp eq i32' "$strict_stage3_dynamic_if_return_ir_dir/merged.ll"
  grep -q 'br i1' "$strict_stage3_dynamic_if_return_ir_dir/merged.ll"
  grep -q 'ret i32 34' "$strict_stage3_dynamic_if_return_ir_dir/merged.ll"
  grep -q 'ret i32 55' "$strict_stage3_dynamic_if_return_ir_dir/merged.ll"
  strict_stage3_dynamic_for_return_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-dynamic-for-return-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/78_self_codegen_dynamic_for_return.yc -o "$strict_stage3_dynamic_for_return_ir_dir" >/tmp/ycpl-strict-stage3-dynamic-for-return-ir.out
  grep -q 'YCPL dynamic for-return IR' "$strict_stage3_dynamic_for_return_ir_dir/merged.ll"
  grep -q 'loop_check' "$strict_stage3_dynamic_for_return_ir_dir/merged.ll"
  grep -q 'loop_update' "$strict_stage3_dynamic_for_return_ir_dir/merged.ll"
  grep -q 'icmp slt i32' "$strict_stage3_dynamic_for_return_ir_dir/merged.ll"
  grep -q 'add i32 %sumload, 3' "$strict_stage3_dynamic_for_return_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_dynamic_for_return_ir_dir/merged.ll"
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
  strict_stage3_bool_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-bool-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/63_self_codegen_bool_condition.yc -o "$strict_stage3_bool_ir_dir" >/tmp/ycpl-strict-stage3-bool-ir.out
  grep -q 'alloca i1' "$strict_stage3_bool_ir_dir/merged.ll"
  grep -q 'xor i1' "$strict_stage3_bool_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_bool_ir_dir/merged.ll"
  strict_stage3_bool_helper_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-bool-helper-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/64_self_codegen_bool_helper.yc -o "$strict_stage3_bool_helper_ir_dir" >/tmp/ycpl-strict-stage3-bool-helper-ir.out
  grep -q 'define i1 @ready' "$strict_stage3_bool_helper_ir_dir/merged.ll"
  grep -q 'call i1 @ready' "$strict_stage3_bool_helper_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_bool_helper_ir_dir/merged.ll"
  strict_stage3_string_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-string-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/65_self_codegen_string_local.yc -o "$strict_stage3_string_ir_dir" >/tmp/ycpl-strict-stage3-string-ir.out
  grep -q 'define ptr @label' "$strict_stage3_string_ir_dir/merged.ll"
  grep -q '@.tiny.string.compiler' "$strict_stage3_string_ir_dir/merged.ll"
  grep -q 'store ptr %otherload' "$strict_stage3_string_ir_dir/merged.ll"
  strict_stage3_main_args_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-main-args-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/99_self_codegen_main_args.yc -o "$strict_stage3_main_args_ir_dir" >/tmp/ycpl-strict-stage3-main-args-ir.out
  grep -q 'YCPL tiny main args stage IR' "$strict_stage3_main_args_ir_dir/merged.ll"
  grep -q 'define i32 @main(i32 %argc, ptr %argv)' "$strict_stage3_main_args_ir_dir/merged.ll"
  grep -q 'alloca i32' "$strict_stage3_main_args_ir_dir/merged.ll"
  grep -q 'alloca ptr' "$strict_stage3_main_args_ir_dir/merged.ll"
  grep -q 'store ptr %argv' "$strict_stage3_main_args_ir_dir/merged.ll"
  grep -q 'ret i32 13' "$strict_stage3_main_args_ir_dir/merged.ll"
  strict_stage3_std_bytes_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-std-bytes-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/102_std_bytes_hex_hash.yc -o "$strict_stage3_std_bytes_ir_dir" >/tmp/ycpl-strict-stage3-std-bytes-ir.out
  grep -q 'YCPL tiny std bytes/hex/hash stage IR' "$strict_stage3_std_bytes_ir_dir/merged.ll"
  grep -q '@.tiny.std.bytes.out' "$strict_stage3_std_bytes_ir_dir/merged.ll"
  grep -q 'declare i32 @printf' "$strict_stage3_std_bytes_ir_dir/merged.ll"
  grep -q '1041946889' "$strict_stage3_std_bytes_ir_dir/merged.ll"
  grep -q '541916226' "$strict_stage3_std_bytes_ir_dir/merged.ll"
  strict_stage3_std_base64_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-std-base64-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/103_std_base64.yc -o "$strict_stage3_std_base64_ir_dir" >/tmp/ycpl-strict-stage3-std-base64-ir.out
  grep -q 'YCPL tiny std base64 stage IR' "$strict_stage3_std_base64_ir_dir/merged.ll"
  grep -q '@.tiny.std.base64.out' "$strict_stage3_std_base64_ir_dir/merged.ll"
  grep -q 'declare i32 @printf' "$strict_stage3_std_base64_ir_dir/merged.ll"
  grep -q 'Zm9vYg==' "$strict_stage3_std_base64_ir_dir/merged.ll"
  strict_stage3_std2_encoding_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-std2-encoding-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/104_std2_encoding.yc -o "$strict_stage3_std2_encoding_ir_dir" >/tmp/ycpl-strict-stage3-std2-encoding-ir.out
  grep -q 'YCPL tiny std2 encoding stage IR' "$strict_stage3_std2_encoding_ir_dir/merged.ll"
  grep -q '@.tiny.std2.encoding.out' "$strict_stage3_std2_encoding_ir_dir/merged.ll"
  grep -q 'LFBVATA=' "$strict_stage3_std2_encoding_ir_dir/merged.ll"
  grep -q '52232505' "$strict_stage3_std2_encoding_ir_dir/merged.ll"
  strict_stage3_array_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-array-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/81_self_codegen_array_index.yc -o "$strict_stage3_array_ir_dir" >/tmp/ycpl-strict-stage3-array-ir.out
  grep -q 'YCPL tiny array index stage IR' "$strict_stage3_array_ir_dir/merged.ll"
  grep -q 'alloca \[3 x i32\]' "$strict_stage3_array_ir_dir/merged.ll"
  grep -q 'getelementptr \[3 x i32\]' "$strict_stage3_array_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_array_ir_dir/merged.ll"
  strict_stage3_array_assign_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-array-assign-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/82_self_codegen_array_assignment.yc -o "$strict_stage3_array_assign_ir_dir" >/tmp/ycpl-strict-stage3-array-assign-ir.out
  grep -q 'YCPL tiny array mutation stage IR' "$strict_stage3_array_assign_ir_dir/merged.ll"
  grep -q 'getelementptr \[3 x i32\]' "$strict_stage3_array_assign_ir_dir/merged.ll"
  grep -q 'store i32 %sum' "$strict_stage3_array_assign_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_array_assign_ir_dir/merged.ll"
  strict_stage3_array_dynamic_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-array-dynamic-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/83_self_codegen_array_dynamic_index.yc -o "$strict_stage3_array_dynamic_ir_dir" >/tmp/ycpl-strict-stage3-array-dynamic-ir.out
  grep -q 'YCPL tiny array mutation stage IR' "$strict_stage3_array_dynamic_ir_dir/merged.ll"
  grep -q 'i32 %dynamicindex' "$strict_stage3_array_dynamic_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_array_dynamic_ir_dir/merged.ll"
  strict_stage3_array_for_in_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-array-for-in-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/84_self_codegen_array_for_in.yc -o "$strict_stage3_array_for_in_ir_dir" >/tmp/ycpl-strict-stage3-array-for-in-ir.out
  grep -q 'YCPL tiny array for-in stage IR' "$strict_stage3_array_for_in_ir_dir/merged.ll"
  grep -q 'tiny_for_in_check' "$strict_stage3_array_for_in_ir_dir/merged.ll"
  grep -q 'tiny_for_in_continue' "$strict_stage3_array_for_in_ir_dir/merged.ll"
  grep -q 'tiny_for_in_break' "$strict_stage3_array_for_in_ir_dir/merged.ll"
  grep -q 'ret i32 13' "$strict_stage3_array_for_in_ir_dir/merged.ll"
  strict_stage3_numeric_for_in_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-numeric-for-in-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/89_self_codegen_numeric_for_in.yc -o "$strict_stage3_numeric_for_in_ir_dir" >/tmp/ycpl-strict-stage3-numeric-for-in-ir.out
  grep -q 'YCPL tiny numeric for-in stage IR' "$strict_stage3_numeric_for_in_ir_dir/merged.ll"
  grep -q 'tiny_numeric_for_check' "$strict_stage3_numeric_for_in_ir_dir/merged.ll"
  grep -q 'tiny_numeric_for_continue' "$strict_stage3_numeric_for_in_ir_dir/merged.ll"
  grep -q 'ret i32 13' "$strict_stage3_numeric_for_in_ir_dir/merged.ll"
  strict_stage3_c_for_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-c-for-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/91_self_codegen_c_for_return.yc -o "$strict_stage3_c_for_ir_dir" >/tmp/ycpl-strict-stage3-c-for-ir.out
  grep -q 'YCPL tiny C-style for stage IR' "$strict_stage3_c_for_ir_dir/merged.ll"
  grep -q 'tiny_c_for_check' "$strict_stage3_c_for_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_c_for_ir_dir/merged.ll"
  strict_stage3_struct2_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-struct2-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/92_self_codegen_struct_member.yc -o "$strict_stage3_struct2_ir_dir" >/tmp/ycpl-strict-stage3-struct2-ir.out
  grep -q 'YCPL tiny struct2 stage IR' "$strict_stage3_struct2_ir_dir/merged.ll"
  grep -q 'getelementptr { i32, i32 }' "$strict_stage3_struct2_ir_dir/merged.ll"
  grep -q 'call i32 @sum' "$strict_stage3_struct2_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_struct2_ir_dir/merged.ll"
  strict_stage3_struct3_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-struct3-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/96_self_codegen_struct3_member.yc -o "$strict_stage3_struct3_ir_dir" >/tmp/ycpl-strict-stage3-struct3-ir.out
  grep -q 'YCPL tiny struct3 stage IR' "$strict_stage3_struct3_ir_dir/merged.ll"
  grep -q 'getelementptr { i32, i32, i32 }' "$strict_stage3_struct3_ir_dir/merged.ll"
  grep -q 'call i32 @sum3' "$strict_stage3_struct3_ir_dir/merged.ll"
  grep -q 'ret i32 %result' "$strict_stage3_struct3_ir_dir/merged.ll"
  strict_stage3_enum_alias_switch_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-enum-alias-switch-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir "$enum_alias_switch_file" -o "$strict_stage3_enum_alias_switch_ir_dir" >/tmp/ycpl-strict-stage3-enum-alias-switch-ir.out
  grep -q 'YCPL tiny enum alias switch stage IR' "$strict_stage3_enum_alias_switch_ir_dir/merged.ll"
  grep -q 'switch i32' "$strict_stage3_enum_alias_switch_ir_dir/merged.ll"
  grep -q 'ret i32 13' "$strict_stage3_enum_alias_switch_ir_dir/merged.ll"
  strict_stage3_extern_string_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-extern-string-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/66_self_codegen_extern_string_call.yc -o "$strict_stage3_extern_string_ir_dir" >/tmp/ycpl-strict-stage3-extern-string-ir.out
  grep -q 'declare i32 @strcmp' "$strict_stage3_extern_string_ir_dir/merged.ll"
  grep -q 'call i32 @strcmp' "$strict_stage3_extern_string_ir_dir/merged.ll"
  grep -q 'ret i32 13' "$strict_stage3_extern_string_ir_dir/merged.ll"
  strict_stage3_extern_malloc_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-extern-malloc-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/67_self_codegen_extern_malloc_ptr.yc -o "$strict_stage3_extern_malloc_ir_dir" >/tmp/ycpl-strict-stage3-extern-malloc-ir.out
  grep -q 'declare ptr @malloc' "$strict_stage3_extern_malloc_ir_dir/merged.ll"
  grep -q 'call ptr @malloc' "$strict_stage3_extern_malloc_ir_dir/merged.ll"
  grep -q 'ret i32 13' "$strict_stage3_extern_malloc_ir_dir/merged.ll"
  strict_stage3_llvm_c_api_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-llvm-c-api-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/68_self_codegen_llvm_c_api_call.yc -o "$strict_stage3_llvm_c_api_ir_dir" >/tmp/ycpl-strict-stage3-llvm-c-api-ir.out
  grep -q 'declare ptr @LLVMContextCreate' "$strict_stage3_llvm_c_api_ir_dir/merged.ll"
  grep -q 'call ptr @LLVMModuleCreateWithNameInContext' "$strict_stage3_llvm_c_api_ir_dir/merged.ll"
  strict_stage3_void_extern_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-void-extern-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/69_self_codegen_void_extern_call.yc -o "$strict_stage3_void_extern_ir_dir" >/tmp/ycpl-strict-stage3-void-extern-ir.out
  grep -q 'declare void @LLVMContextDispose' "$strict_stage3_void_extern_ir_dir/merged.ll"
  grep -q 'define void @cleanup' "$strict_stage3_void_extern_ir_dir/merged.ll"
  strict_stage3_llvm_function_type_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-llvm-function-type-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/70_self_codegen_llvm_function_type_call.yc -o "$strict_stage3_llvm_function_type_ir_dir" >/tmp/ycpl-strict-stage3-llvm-function-type-ir.out
  grep -q 'declare ptr @LLVMFunctionType' "$strict_stage3_llvm_function_type_ir_dir/merged.ll"
  grep -q 'call ptr @LLVMFunctionType' "$strict_stage3_llvm_function_type_ir_dir/merged.ll"
  strict_stage3_llvm_builder_memory_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-llvm-builder-memory-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/71_self_codegen_llvm_builder_memory_call.yc -o "$strict_stage3_llvm_builder_memory_ir_dir" >/tmp/ycpl-strict-stage3-llvm-builder-memory-ir.out
  grep -q 'declare ptr @LLVMBuildAlloca' "$strict_stage3_llvm_builder_memory_ir_dir/merged.ll"
  grep -q 'call ptr @LLVMBuildLoad2' "$strict_stage3_llvm_builder_memory_ir_dir/merged.ll"
  strict_stage3_llvm_call2_icmp_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-llvm-call2-icmp-ir.XXXXXX")"
  "$strict_stage3_native_dir/merged" build-ir examples/72_self_codegen_llvm_call2_icmp_call.yc -o "$strict_stage3_llvm_call2_icmp_ir_dir" >/tmp/ycpl-strict-stage3-llvm-call2-icmp-ir.out
  grep -q 'declare ptr @LLVMBuildCall2(ptr, ptr, ptr, ptr, i32, ptr)' "$strict_stage3_llvm_call2_icmp_ir_dir/merged.ll"
  grep -q 'call ptr @LLVMBuildICmp' "$strict_stage3_llvm_call2_icmp_ir_dir/merged.ll"
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
  require_project_file_count /tmp/ycpl-strict-stage4-native-parse.out 23 "strict stage4 native parse"
  grep -q 'typed_nodes=' /tmp/ycpl-strict-stage4-native-parse.out
  grep -q 'expr_nodes=' /tmp/ycpl-strict-stage4-native-parse.out
  grep -q 'main=1' /tmp/ycpl-strict-stage4-native-check.out
  strict_stage5_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage5-ir.XXXXXX")"
  "$strict_stage4_native_dir/merged" build-ir compiler/ycpl -o "$strict_stage5_ir_dir" >/tmp/ycpl-strict-stage5-ir.out
  grep -q 'YCPL stage5 AST IR' "$strict_stage5_ir_dir/merged.ll"
  grep -q '@.stage5.stage6.ir' "$strict_stage5_ir_dir/merged.ll"
  grep -q '@ycpl_stage5_ast_expr_nodes' "$strict_stage5_ir_dir/merged.ll"
  grep -q 'define i32 @ycpl_stage5_project_body_lowering' "$strict_stage5_ir_dir/merged.ll"
  grep -q 'function_body_statement_resolved_type_slot' "$strict_stage5_ir_dir/merged.ll"
  grep -q 'function_body_resolved_statement_value' "$strict_stage5_ir_dir/merged.ll"
  grep -q 'function_body_resolved_local_loaded' "$strict_stage5_ir_dir/merged.ll"
  grep -q 'function_body_resolved_assignment_loaded' "$strict_stage5_ir_dir/merged.ll"
  grep -q 'function_body_resolved_call_loaded' "$strict_stage5_ir_dir/merged.ll"
  grep -q 'function_body_resolved_return_loaded' "$strict_stage5_ir_dir/merged.ll"
  grep -q 'function_body_resolved_statement_lowered_state' "$strict_stage5_ir_dir/merged.ll"
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
  "$strict_stage5_native_dir/merged" parse compiler/ycpl >/tmp/ycpl-strict-stage5-native-parse.out
  "$strict_stage5_native_dir/merged" check compiler/ycpl >/tmp/ycpl-strict-stage5-native-check.out
  grep -q 'typed_nodes=' /tmp/ycpl-strict-stage5-native-parse.out
  grep -q 'expr_nodes=' /tmp/ycpl-strict-stage5-native-parse.out
  grep -q 'main=1' /tmp/ycpl-strict-stage5-native-check.out
  strict_stage6_ir_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage6-ir.XXXXXX")"
  "$strict_stage5_native_dir/merged" build-ir compiler/ycpl -o "$strict_stage6_ir_dir" >/tmp/ycpl-strict-stage6-ir.out
  grep -q 'YCPL stage6 AST IR' "$strict_stage6_ir_dir/merged.ll"
  grep -q '@ycpl_stage6_ast_expr_nodes' "$strict_stage6_ir_dir/merged.ll"
  grep -q 'define i32 @ycpl_stage6_project_body_lowering' "$strict_stage6_ir_dir/merged.ll"
  grep -q 'function_body_resolved_statement_lowered_state' "$strict_stage6_ir_dir/merged.ll"
  "$LLC_BIN" -filetype=obj "$strict_stage6_ir_dir/merged.ll" -o "$strict_stage6_ir_dir/merged.o"
  strict_stage6_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage6-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage5_native_dir/merged" build compiler/ycpl -o "$strict_stage6_native_dir" >/tmp/ycpl-strict-stage6-native.out
  if [ ! -x "$strict_stage6_native_dir/merged" ]; then
    printf 'Expected strict stage5 compiler to emit native %s/merged\n' "$strict_stage6_native_dir" >&2
    cat /tmp/ycpl-strict-stage6-native.out >&2
    exit 1
  fi
  "$strict_stage6_native_dir/merged" >/tmp/ycpl-strict-stage6-native-run.out
  grep -q 'YCPL stage6 AST IR' /tmp/ycpl-strict-stage6-native-run.out
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
  strict_stage3_enum_alias_switch_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-enum-alias-switch-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build "$enum_alias_switch_file" -o "$strict_stage3_enum_alias_switch_native_dir" >/tmp/ycpl-strict-stage3-enum-alias-switch-native.out
  set +e
  "$strict_stage3_enum_alias_switch_native_dir/merged" >/dev/null 2>&1
  strict_stage3_enum_alias_switch_status=$?
  set -e
  if [ "$strict_stage3_enum_alias_switch_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler enum/alias/switch native to exit 13, got %d\n' "$strict_stage3_enum_alias_switch_status" >&2
    exit 1
  fi
  strict_stage3_array_assign_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-array-assign-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/82_self_codegen_array_assignment.yc -o "$strict_stage3_array_assign_native_dir" >/tmp/ycpl-strict-stage3-array-assign-native.out
  set +e
  "$strict_stage3_array_assign_native_dir/merged" >/dev/null 2>&1
  strict_stage3_array_assign_status=$?
  set -e
  if [ "$strict_stage3_array_assign_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler array assignment native to exit 13, got %d\n' "$strict_stage3_array_assign_status" >&2
    exit 1
  fi
  strict_stage3_array_dynamic_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-array-dynamic-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/83_self_codegen_array_dynamic_index.yc -o "$strict_stage3_array_dynamic_native_dir" >/tmp/ycpl-strict-stage3-array-dynamic-native.out
  set +e
  "$strict_stage3_array_dynamic_native_dir/merged" >/dev/null 2>&1
  strict_stage3_array_dynamic_status=$?
  set -e
  if [ "$strict_stage3_array_dynamic_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler array dynamic index native to exit 13, got %d\n' "$strict_stage3_array_dynamic_status" >&2
    exit 1
  fi
  strict_stage3_array_for_in_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-array-for-in-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/84_self_codegen_array_for_in.yc -o "$strict_stage3_array_for_in_native_dir" >/tmp/ycpl-strict-stage3-array-for-in-native.out
  set +e
  "$strict_stage3_array_for_in_native_dir/merged" >/dev/null 2>&1
  strict_stage3_array_for_in_status=$?
  set -e
  if [ "$strict_stage3_array_for_in_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler array for-in native to exit 13, got %d\n' "$strict_stage3_array_for_in_status" >&2
    exit 1
  fi
  strict_stage3_numeric_for_in_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-numeric-for-in-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/89_self_codegen_numeric_for_in.yc -o "$strict_stage3_numeric_for_in_native_dir" >/tmp/ycpl-strict-stage3-numeric-for-in-native.out
  set +e
  "$strict_stage3_numeric_for_in_native_dir/merged" >/dev/null 2>&1
  strict_stage3_numeric_for_in_status=$?
  set -e
  if [ "$strict_stage3_numeric_for_in_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler numeric for-in native to exit 13, got %d\n' "$strict_stage3_numeric_for_in_status" >&2
    exit 1
  fi
  strict_stage3_c_for_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-c-for-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/91_self_codegen_c_for_return.yc -o "$strict_stage3_c_for_native_dir" >/tmp/ycpl-strict-stage3-c-for-native.out
  set +e
  "$strict_stage3_c_for_native_dir/merged" >/dev/null 2>&1
  strict_stage3_c_for_status=$?
  set -e
  if [ "$strict_stage3_c_for_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler C-style for native to exit 13, got %d\n' "$strict_stage3_c_for_status" >&2
    exit 1
  fi
  strict_stage3_struct2_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-struct2-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/92_self_codegen_struct_member.yc -o "$strict_stage3_struct2_native_dir" >/tmp/ycpl-strict-stage3-struct2-native.out
  set +e
  "$strict_stage3_struct2_native_dir/merged" >/dev/null 2>&1
  strict_stage3_struct2_status=$?
  set -e
  if [ "$strict_stage3_struct2_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler struct2 native to exit 13, got %d\n' "$strict_stage3_struct2_status" >&2
    exit 1
  fi
  strict_stage3_struct2_assign_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-struct2-assign-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/93_self_codegen_struct_member_assignment.yc -o "$strict_stage3_struct2_assign_native_dir" >/tmp/ycpl-strict-stage3-struct2-assign-native.out
  set +e
  "$strict_stage3_struct2_assign_native_dir/merged" >/dev/null 2>&1
  strict_stage3_struct2_assign_status=$?
  set -e
  if [ "$strict_stage3_struct2_assign_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler struct2 assignment native to exit 13, got %d\n' "$strict_stage3_struct2_assign_status" >&2
    exit 1
  fi
  strict_stage3_struct2_param_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-struct2-param-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/94_self_codegen_struct_param_call.yc -o "$strict_stage3_struct2_param_native_dir" >/tmp/ycpl-strict-stage3-struct2-param-native.out
  set +e
  "$strict_stage3_struct2_param_native_dir/merged" >/dev/null 2>&1
  strict_stage3_struct2_param_status=$?
  set -e
  if [ "$strict_stage3_struct2_param_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler struct2 param native to exit 13, got %d\n' "$strict_stage3_struct2_param_status" >&2
    exit 1
  fi
  strict_stage3_struct2_return_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-struct2-return-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/95_self_codegen_struct_return.yc -o "$strict_stage3_struct2_return_native_dir" >/tmp/ycpl-strict-stage3-struct2-return-native.out
  set +e
  "$strict_stage3_struct2_return_native_dir/merged" >/dev/null 2>&1
  strict_stage3_struct2_return_status=$?
  set -e
  if [ "$strict_stage3_struct2_return_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler struct2 return native to exit 13, got %d\n' "$strict_stage3_struct2_return_status" >&2
    exit 1
  fi
  strict_stage3_struct3_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-struct3-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/96_self_codegen_struct3_member.yc -o "$strict_stage3_struct3_native_dir" >/tmp/ycpl-strict-stage3-struct3-native.out
  set +e
  "$strict_stage3_struct3_native_dir/merged" >/dev/null 2>&1
  strict_stage3_struct3_status=$?
  set -e
  if [ "$strict_stage3_struct3_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler struct3 native to exit 13, got %d\n' "$strict_stage3_struct3_status" >&2
    exit 1
  fi
  strict_stage3_struct3_param_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-struct3-param-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/97_self_codegen_struct3_param_call.yc -o "$strict_stage3_struct3_param_native_dir" >/tmp/ycpl-strict-stage3-struct3-param-native.out
  set +e
  "$strict_stage3_struct3_param_native_dir/merged" >/dev/null 2>&1
  strict_stage3_struct3_param_status=$?
  set -e
  if [ "$strict_stage3_struct3_param_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler struct3 param native to exit 13, got %d\n' "$strict_stage3_struct3_param_status" >&2
    exit 1
  fi
  strict_stage3_struct3_return_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-struct3-return-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/98_self_codegen_struct3_return.yc -o "$strict_stage3_struct3_return_native_dir" >/tmp/ycpl-strict-stage3-struct3-return-native.out
  set +e
  "$strict_stage3_struct3_return_native_dir/merged" >/dev/null 2>&1
  strict_stage3_struct3_return_status=$?
  set -e
  if [ "$strict_stage3_struct3_return_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler struct3 return native to exit 13, got %d\n' "$strict_stage3_struct3_return_status" >&2
    exit 1
  fi
  strict_stage3_main_args_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-main-args-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/99_self_codegen_main_args.yc -o "$strict_stage3_main_args_native_dir" >/tmp/ycpl-strict-stage3-main-args-native.out
  set +e
  "$strict_stage3_main_args_native_dir/merged" >/dev/null 2>&1
  strict_stage3_main_args_status=$?
  set -e
  if [ "$strict_stage3_main_args_status" -ne 13 ]; then
    printf 'Expected strict stage3 generated compiler main-args native to exit 13, got %d\n' "$strict_stage3_main_args_status" >&2
    exit 1
  fi
  strict_stage3_std_bytes_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-std-bytes-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/102_std_bytes_hex_hash.yc -o "$strict_stage3_std_bytes_native_dir" >/tmp/ycpl-strict-stage3-std-bytes-native.out
  strict_stage3_std_bytes_output="$("$strict_stage3_std_bytes_native_dir/merged")"
  strict_stage3_std_bytes_expected=$'4\n89\nYCPL\nY\n120\n1\n5943504c\n1\n1041946889\n541916226'
  if [ "$strict_stage3_std_bytes_output" != "$strict_stage3_std_bytes_expected" ]; then
    printf 'Expected strict stage3 generated compiler std bytes output mismatch\n' >&2
    printf 'Expected:\n%s\n' "$strict_stage3_std_bytes_expected" >&2
    printf 'Got:\n%s\n' "$strict_stage3_std_bytes_output" >&2
    exit 1
  fi
  strict_stage3_std_base64_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-std-base64-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/103_std_base64.yc -o "$strict_stage3_std_base64_native_dir" >/tmp/ycpl-strict-stage3-std-base64-native.out
  strict_stage3_std_base64_output="$("$strict_stage3_std_base64_native_dir/merged")"
  strict_stage3_std_base64_expected=$'\nZg==\n1\nZm8=\n1\nZm9v\n1\nZm9vYg==\n1'
  if [ "$strict_stage3_std_base64_output" != "$strict_stage3_std_base64_expected" ]; then
    printf 'Expected strict stage3 generated compiler std base64 output mismatch\n' >&2
    printf 'Expected:\n%s\n' "$strict_stage3_std_base64_expected" >&2
    printf 'Got:\n%s\n' "$strict_stage3_std_base64_output" >&2
    exit 1
  fi
  strict_stage3_std2_encoding_native_dir="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-strict-stage3-std2-encoding-native.XXXXXX")"
  LLVM_BINDIR="$(dirname "$LLC_BIN")" "$strict_stage3_native_dir/merged" build examples/104_std2_encoding.yc -o "$strict_stage3_std2_encoding_native_dir" >/tmp/ycpl-strict-stage3-std2-encoding-native.out
  strict_stage3_std2_encoding_output="$("$strict_stage3_std2_encoding_native_dir/merged")"
  strict_stage3_std2_encoding_expected=$'LFBVATA=\n1\nWUNQTA==\n1\n5943504C\n1\n52232505'
  if [ "$strict_stage3_std2_encoding_output" != "$strict_stage3_std2_encoding_expected" ]; then
    printf 'Expected strict stage3 generated compiler std2 encoding output mismatch\n' >&2
    printf 'Expected:\n%s\n' "$strict_stage3_std2_encoding_expected" >&2
    printf 'Got:\n%s\n' "$strict_stage3_std2_encoding_output" >&2
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
"$STAGE2" check "$eightarg_stage_dir/eightarg.yc" >/tmp/ycpl-stage2-eightarg-check.out
grep -q 'value=13' /tmp/ycpl-stage2-eightarg-check.out
"$STAGE2" check "$eightarg_stage_dir/helper8.yc" >/tmp/ycpl-stage2-helper8-check.out
grep -q 'value=13' /tmp/ycpl-stage2-helper8-check.out
"$STAGE2" check "$eightarg_stage_dir/manyhelpers.yc" >/tmp/ycpl-stage2-manyhelpers-check.out
grep -q 'value=13' /tmp/ycpl-stage2-manyhelpers-check.out
"$STAGE2" check "$eightarg_stage_dir/manylocals.yc" >/tmp/ycpl-stage2-manylocals-check.out
grep -q 'value=13' /tmp/ycpl-stage2-manylocals-check.out
require_project_file_count /tmp/ycpl-stage2-parse.out 23 "stage2 parse"
require_project_file_count /tmp/ycpl-stage2-check.out 23 "stage2 check"
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
