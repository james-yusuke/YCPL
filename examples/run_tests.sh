#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
YCC="${YCC:-$ROOT_DIR/build/ycc}"
LINKFLAGS="${LINKFLAGS:--no-pie}"

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

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
TOTAL=0

if [ ! -f "$YCC" ]; then
    printf "${RED}Error: Compiler not found at $YCC${NC}\n"
    echo "Please build the project first: cd build && make"
    exit 1
fi

fizzbuzz_expected() {
    local i
    for i in $(seq 1 100); do
        if [ $((i % 15)) -eq 0 ]; then
            printf "%d FizzBuzz" "$i"
        elif [ $((i % 3)) -eq 0 ]; then
            printf "%d Fizz" "$i"
        elif [ $((i % 5)) -eq 0 ]; then
            printf "%d Buzz" "$i"
        else
            printf "%d" "$i"
        fi

        if [ "$i" -lt 100 ]; then
            printf "\n"
        fi
    done
}

expect_exact() {
    local actual="$1"
    local expected="$2"

    [ "$actual" = "$expected" ]
}

compile_run_and_verify() {
    local yc_file="$1"
    local expected_output="$2"
    shift 2
    local ir_patterns=("$@")
    local basename=$(basename "$yc_file" .yc)
    local out_dir="/tmp/YCPL_test_${basename}"
    local ll_file="$out_dir/${basename}.ll"
    local obj_file="$out_dir/${basename}.o"
    local exe_file="$out_dir/${basename}_exe"

    rm -rf "$out_dir"
    mkdir -p "$out_dir"

    ((TOTAL++))
    printf "  ${BLUE}$basename${NC}... "

    $YCC build-ir "$yc_file" -o "$out_dir" > "$out_dir/compile.log" 2>&1

    if grep -q "codegen error\|codegen failed" "$out_dir/compile.log"; then
        printf "${RED}FAIL${NC} (codegen error)\n"
        cat "$out_dir/compile.log"
        ((FAIL++))
        return 1
    fi

    local pattern
    for pattern in "${ir_patterns[@]}"; do
        if ! grep -q "$pattern" "$ll_file"; then
            printf "${RED}FAIL${NC} (missing IR pattern)\n"
            echo "  Expected IR pattern: $pattern"
            ((FAIL++))
            return 1
        fi
    done

    if [ ! -f "$ll_file" ]; then
        printf "${RED}FAIL${NC} (no IR generated)\n"
        ((FAIL++))
        return 1
    fi

    "$LLC" -filetype=obj "$ll_file" -o "$obj_file" 2>"$out_dir/llc.log"
    if [ $? -ne 0 ]; then
        printf "${RED}FAIL${NC} (llc error)\n"
        cat "$out_dir/llc.log"
        ((FAIL++))
        return 1
    fi

    "$CLANG" $LINKFLAGS "$obj_file" -o "$exe_file" -lm 2>"$out_dir/link.log"
    if [ $? -ne 0 ]; then
        printf "${RED}FAIL${NC} (link error)\n"
        cat "$out_dir/link.log"
        ((FAIL++))
        return 1
    fi

    local actual_output
    if command -v timeout &> /dev/null; then
        actual_output=$(timeout 5 "$exe_file" 2>&1)
    elif command -v gtimeout &> /dev/null; then
        actual_output=$(gtimeout 5 "$exe_file" 2>&1)
    else
        actual_output=$("$exe_file" 2>&1)
    fi
    local exit_code=$?

    if [ $exit_code -eq 124 ] || [ $exit_code -eq 137 ]; then
        printf "${RED}FAIL${NC} (timeout)\n"
        ((FAIL++))
        return 1
    fi

    if [ -n "$expected_output" ]; then
        if expect_exact "$actual_output" "$expected_output"; then
            printf "${GREEN}PASS${NC}\n"
            ((PASS++))
            return 0
        else
            printf "${RED}FAIL${NC} (output mismatch)\n"
            printf "  Expected:\n%s\n" "$expected_output"
            printf "  Got:\n%s\n" "$actual_output"
            ((FAIL++))
            return 1
        fi
    else
        printf "${GREEN}PASS${NC}\n"
        ((PASS++))
        return 0
    fi
}

compile_run_with_input_and_verify() {
    local yc_file="$1"
    local input_text="$2"
    local expected_output="$3"
    local basename=$(basename "$yc_file" .yc)
    local out_dir="/tmp/YCPL_test_${basename}"
    local ll_file="$out_dir/${basename}.ll"
    local obj_file="$out_dir/${basename}.o"
    local exe_file="$out_dir/${basename}_exe"

    rm -rf "$out_dir"
    mkdir -p "$out_dir"

    ((TOTAL++))
    printf "  ${BLUE}$basename${NC}... "

    $YCC build-ir "$yc_file" -o "$out_dir" > "$out_dir/compile.log" 2>&1
    if [ $? -ne 0 ] || [ ! -f "$ll_file" ]; then
        printf "${RED}FAIL${NC} (compile failed)\n"
        cat "$out_dir/compile.log"
        ((FAIL++))
        return 1
    fi

    "$LLC" -filetype=obj "$ll_file" -o "$obj_file" 2>"$out_dir/llc.log"
    if [ $? -ne 0 ]; then
        printf "${RED}FAIL${NC} (llc error)\n"
        cat "$out_dir/llc.log"
        ((FAIL++))
        return 1
    fi

    "$CLANG" $LINKFLAGS "$obj_file" -o "$exe_file" -lm 2>"$out_dir/link.log"
    if [ $? -ne 0 ]; then
        printf "${RED}FAIL${NC} (link error)\n"
        cat "$out_dir/link.log"
        ((FAIL++))
        return 1
    fi

    local actual_output
    actual_output=$(printf "%s" "$input_text" | "$exe_file" 2>&1)

    if expect_exact "$actual_output" "$expected_output"; then
        printf "${GREEN}PASS${NC}\n"
        ((PASS++))
        return 0
    fi

    printf "${RED}FAIL${NC} (output mismatch)\n"
    printf "  Expected:\n%s\n" "$expected_output"
    printf "  Got:\n%s\n" "$actual_output"
    ((FAIL++))
    return 1
}

test_project() {
    local project_dir="$1"
    local expected_output="$2"
    local project_name=$(basename "$project_dir")
    local out_dir="/tmp/YCPL_test_proj_${project_name}"
    local work_project="$out_dir/project"

    rm -rf "$out_dir"
    mkdir -p "$out_dir"

    ((TOTAL++))
    printf "  ${BLUE}$project_name (project)${NC}... "

    cp -R "$project_dir" "$work_project"
    rm -rf "$work_project/build"

    (cd "$work_project" && $YCC build-ir) > "$out_dir/compile.log" 2>&1

    if grep -q "codegen error\|codegen failed\|error\|failed" "$out_dir/compile.log"; then
        printf "${RED}FAIL${NC} (build error)\n"
        cat "$out_dir/compile.log"
        ((FAIL++))
        return 1
    fi

    local ll_file=$(find "$work_project/build" -name "*.ll" 2>/dev/null | head -1)
    if [ -z "$ll_file" ]; then
        printf "${RED}FAIL${NC} (no IR generated)\n"
        ((FAIL++))
        return 1
    fi

    local obj_file="$out_dir/program.o"
    local exe_file="$out_dir/program"

    "$LLC" -filetype=obj "$ll_file" -o "$obj_file" 2>"$out_dir/llc.log"
    if [ $? -ne 0 ]; then
        printf "${RED}FAIL${NC} (llc error)\n"
        cat "$out_dir/llc.log"
        ((FAIL++))
        return 1
    fi

    "$CLANG" $LINKFLAGS "$obj_file" -o "$exe_file" -lm 2>"$out_dir/link.log"
    if [ $? -ne 0 ]; then
        printf "${RED}FAIL${NC} (link error)\n"
        cat "$out_dir/link.log"
        ((FAIL++))
        return 1
    fi

    local actual_output
    if command -v timeout &> /dev/null; then
        actual_output=$(timeout 5 "$exe_file" 2>&1)
    elif command -v gtimeout &> /dev/null; then
        actual_output=$(gtimeout 5 "$exe_file" 2>&1)
    else
        actual_output=$("$exe_file" 2>&1)
    fi
    local exit_code=$?

    if [ $exit_code -eq 124 ] || [ $exit_code -eq 137 ]; then
        printf "${RED}FAIL${NC} (timeout)\n"
        ((FAIL++))
        return 1
    fi

    if [ -n "$expected_output" ]; then
        if expect_exact "$actual_output" "$expected_output"; then
            printf "${GREEN}PASS${NC}\n"
            ((PASS++))
            return 0
        else
            printf "${RED}FAIL${NC} (output mismatch)\n"
            printf "  Expected:\n%s\n" "$expected_output"
            printf "  Got:\n%s\n" "$actual_output"
            ((FAIL++))
            return 1
        fi
    else
        printf "${GREEN}PASS${NC}\n"
        ((PASS++))
        return 0
    fi
}

test_project_expect_failure() {
    local project_dir="$1"
    local expected_error="$2"
    local project_name=$(basename "$project_dir")
    local out_dir="/tmp/YCPL_test_negative_${project_name}"
    local work_project="$out_dir/project"

    rm -rf "$out_dir"
    mkdir -p "$out_dir"

    ((TOTAL++))
    printf "  ${BLUE}$project_name (expected failure)${NC}... "

    cp -R "$project_dir" "$work_project"
    rm -rf "$work_project/build"

    (cd "$work_project" && $YCC build-ir) > "$out_dir/compile.log" 2>&1
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        printf "${RED}FAIL${NC} (unexpected success)\n"
        cat "$out_dir/compile.log"
        ((FAIL++))
        return 1
    fi

    if grep -q "$expected_error" "$out_dir/compile.log"; then
        printf "${GREEN}PASS${NC}\n"
        ((PASS++))
        return 0
    fi

    printf "${RED}FAIL${NC} (missing expected diagnostic)\n"
    echo "  Expected diagnostic: $expected_error"
    cat "$out_dir/compile.log"
    ((FAIL++))
    return 1
}

compile_expect_failure() {
    local yc_file="$1"
    local expected_error="$2"
    local basename=$(basename "$yc_file" .yc)
    local out_dir="/tmp/YCPL_test_compile_negative_${basename}"

    rm -rf "$out_dir"
    mkdir -p "$out_dir"

    ((TOTAL++))
    printf "  ${BLUE}$basename (expected compile failure)${NC}... "

    $YCC build-ir "$yc_file" -o "$out_dir" > "$out_dir/compile.log" 2>&1
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        printf "${RED}FAIL${NC} (unexpected success)\n"
        cat "$out_dir/compile.log"
        ((FAIL++))
        return 1
    fi

    if grep -q "$expected_error" "$out_dir/compile.log"; then
        printf "${GREEN}PASS${NC}\n"
        ((PASS++))
        return 0
    fi

    printf "${RED}FAIL${NC} (missing expected diagnostic)\n"
    echo "  Expected diagnostic: $expected_error"
    cat "$out_dir/compile.log"
    ((FAIL++))
    return 1
}

compile_run_expect_failure() {
    local yc_file="$1"
    local basename=$(basename "$yc_file" .yc)
    local out_dir="/tmp/YCPL_test_runtime_negative_${basename}"
    local ll_file="$out_dir/${basename}.ll"
    local obj_file="$out_dir/${basename}.o"
    local exe_file="$out_dir/${basename}_exe"

    rm -rf "$out_dir"
    mkdir -p "$out_dir"

    ((TOTAL++))
    printf "  ${BLUE}$basename (expected runtime failure)${NC}... "

    $YCC build-ir "$yc_file" -o "$out_dir" > "$out_dir/compile.log" 2>&1
    if [ $? -ne 0 ] || [ ! -f "$ll_file" ]; then
        printf "${RED}FAIL${NC} (compile failed)\n"
        cat "$out_dir/compile.log"
        ((FAIL++))
        return 1
    fi

    "$LLC" -filetype=obj "$ll_file" -o "$obj_file" 2>"$out_dir/llc.log"
    if [ $? -ne 0 ]; then
        printf "${RED}FAIL${NC} (llc error)\n"
        cat "$out_dir/llc.log"
        ((FAIL++))
        return 1
    fi

    "$CLANG" $LINKFLAGS "$obj_file" -o "$exe_file" -lm 2>"$out_dir/link.log"
    if [ $? -ne 0 ]; then
        printf "${RED}FAIL${NC} (link error)\n"
        cat "$out_dir/link.log"
        ((FAIL++))
        return 1
    fi

    if command -v timeout &> /dev/null; then
        timeout 5 bash -c '"$1" > "$2" 2>&1' _ "$exe_file" "$out_dir/run.log" > /dev/null 2>&1
    elif command -v gtimeout &> /dev/null; then
        gtimeout 5 bash -c '"$1" > "$2" 2>&1' _ "$exe_file" "$out_dir/run.log" > /dev/null 2>&1
    else
        bash -c '"$1" > "$2" 2>&1' _ "$exe_file" "$out_dir/run.log" > /dev/null 2>&1
    fi
    local exit_code=$?

    if [ $exit_code -ne 0 ] && [ $exit_code -ne 124 ] && [ $exit_code -ne 137 ]; then
        printf "${GREEN}PASS${NC}\n"
        ((PASS++))
        return 0
    fi

    printf "${RED}FAIL${NC} (unexpected runtime success or timeout)\n"
    cat "$out_dir/run.log"
    ((FAIL++))
    return 1
}

echo "========================================"
echo "  YCPL Test Suite"
echo "========================================"
echo ""

echo "--- Single File Tests ---"
compile_run_and_verify "$SCRIPT_DIR/01_hello.yc" "Hello World"
compile_run_and_verify "$SCRIPT_DIR/02_for_c_style.yc" $'0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10'
compile_run_and_verify "$SCRIPT_DIR/03_fizzbuzz.yc" "$(fizzbuzz_expected)"
compile_run_and_verify "$SCRIPT_DIR/06_variables_and_types.yc" $'3\n12\nenabled\n69\n2.500000'
compile_run_and_verify "$SCRIPT_DIR/07_loops_and_control.yc" "7"
compile_run_and_verify "$SCRIPT_DIR/08_arrays.yc" $'3\n1\n3'
compile_run_and_verify "$SCRIPT_DIR/09_structs.yc" "7"
compile_run_and_verify "$SCRIPT_DIR/10_strings.yc" $'YCPL\n4\n65\n66\n67'
compile_run_and_verify "$SCRIPT_DIR/11_std_fmt_str_math.yc" $'std ready\nlen5\n1\n7\n3.000000'
compile_run_and_verify "$SCRIPT_DIR/12_mutable_array.yc" $'2\n2\n10\n30'
compile_run_and_verify "$SCRIPT_DIR/13_manual_memory.yc" $'4\n16843009'
compile_run_and_verify "$SCRIPT_DIR/15_implicit_alias.yc" "implicit alias"
compile_run_and_verify "$SCRIPT_DIR/19_compound_assignment.yc" "31"
compile_run_and_verify "$SCRIPT_DIR/20_const_mut_none.yc" $'ok\nset'
compile_run_and_verify "$SCRIPT_DIR/21_array_for_in.yc" "15"
compile_run_and_verify "$SCRIPT_DIR/22_complex_arrays.yc" "36"
compile_run_and_verify "$SCRIPT_DIR/23_array_stress.yc" $'1000\n499500'
compile_run_and_verify "$SCRIPT_DIR/30_std_source_usage.yc" $'6\n1\n9\n8.000000\n0.000000\n1.000000\n0\n4\n24' "@std__str__eq" "@std__math__abs"
compile_run_and_verify "$SCRIPT_DIR/34_std_lsp_foundation.yc" $'42\n1\n4\ninitialize\n6\n1\n1\n1\n1\nfn main() {}'
compile_run_with_input_and_verify "$SCRIPT_DIR/35_std_io_echo.yc" "lsp-io" "lsp-io"
compile_run_and_verify "$SCRIPT_DIR/36_std_json_ast.yc" $'1\n42\n1\nYCPL\n2\nyes\n10\n{"x":3,"y":4}'
compile_run_and_verify "$SCRIPT_DIR/40_short_circuit_and_string_field.yc" $'safe\n67'
compile_run_and_verify "$SCRIPT_DIR/100_retired_keywords_as_identifiers.yc" "21"

echo ""
echo "--- Project Tests ---"
test_project "$SCRIPT_DIR/04_module_project" $'30\n30\n20\n10'
test_project "$SCRIPT_DIR/05_multi_module" $'Hello, YCPL!\n25\n125'
test_project "$SCRIPT_DIR/14_v1_foundation_project" "10"
test_project "$SCRIPT_DIR/16_duplicate_symbols_project" "3"

echo ""
echo "--- Negative Module Tests ---"
test_project_expect_failure "$SCRIPT_DIR/17_private_access_failure" "no public function"
test_project_expect_failure "$SCRIPT_DIR/18_missing_import_failure" "Cannot resolve import"

echo ""
echo "--- Negative Core v1.1 Tests ---"
compile_expect_failure "$SCRIPT_DIR/24_const_reassign_failure.yc" "cannot assign to const"
compile_expect_failure "$SCRIPT_DIR/25_none_int_failure.yc" "none can only initialize"
compile_expect_failure "$SCRIPT_DIR/26_invalid_array_type_failure.yc" "array.new first argument"
compile_run_expect_failure "$SCRIPT_DIR/27_array_get_oob_abort.yc"
compile_run_expect_failure "$SCRIPT_DIR/28_array_set_oob_abort.yc"
compile_run_expect_failure "$SCRIPT_DIR/29_index_oob_abort.yc"

echo ""
echo "--- Negative Core v1.2 Tests ---"
compile_expect_failure "$SCRIPT_DIR/31_extern_body_failure.yc" "extern function cannot have a body"
compile_expect_failure "$SCRIPT_DIR/32_intrinsic_outside_std_failure.yc" "intrinsic functions are only allowed in std modules"
compile_expect_failure "$SCRIPT_DIR/33_missing_std_symbol_failure.yc" "no public function"

echo ""
echo "--- Negative Core v1.3 Return Tests ---"
compile_expect_failure "$SCRIPT_DIR/37_return_without_value_failure.yc" "non-void function requires a return value"
compile_expect_failure "$SCRIPT_DIR/38_void_return_value_failure.yc" "void function cannot return a value"
compile_expect_failure "$SCRIPT_DIR/39_missing_return_failure.yc" "non-void function is missing an explicit return"

echo ""
echo "--- Negative Parser/Lexer Tests ---"
compile_expect_failure "$SCRIPT_DIR/41_unclosed_string_failure.yc" "unterminated string literal"
compile_expect_failure "$SCRIPT_DIR/42_unclosed_comment_failure.yc" "unclosed block comment"
compile_expect_failure "$SCRIPT_DIR/43_invalid_char_failure.yc" "unterminated/invalid char literal"
compile_expect_failure "$SCRIPT_DIR/44_unexpected_eof_failure.yc" "expected '}' to end block"
compile_expect_failure "$SCRIPT_DIR/45_bad_import_failure.yc" "expected alias after 'as'"
compile_expect_failure "$SCRIPT_DIR/46_bad_type_failure.yc" "unknown type: MissingType"
compile_expect_failure "$SCRIPT_DIR/47_malformed_call_failure.yc" "expected ')' in call"
compile_expect_failure "$SCRIPT_DIR/48_bad_module_failure.yc" "expected module/package name"
compile_expect_failure "$SCRIPT_DIR/49_malformed_extern_failure.yc" "expected function or method name"
compile_expect_failure "$SCRIPT_DIR/50_malformed_intrinsic_failure.yc" "expected function or method name"
compile_expect_failure "$SCRIPT_DIR/51_malformed_struct_literal_failure.yc" "expected '}' to close struct literal"
compile_expect_failure "$SCRIPT_DIR/52_misplaced_else_failure.yc" "unexpected token in expression"

echo ""
echo "========================================"
printf "  Results: ${GREEN}$PASS/$TOTAL passed${NC}\n"
if [ $FAIL -gt 0 ]; then
    printf "  ${RED}$FAIL failed${NC}\n"
fi
echo "========================================"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

exit 0
