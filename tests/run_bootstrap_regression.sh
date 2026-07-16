#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
YCC="${YCC:-$ROOT_DIR/build/ycc}"
LINKFLAGS="${LINKFLAGS:--no-pie}"
export YCPL_STL_ROOT="${YCPL_STL_ROOT:-$ROOT_DIR/stl}"

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
RUNTIME_SRC="${YCPL_RUNTIME_SRC:-$ROOT_DIR/bootstrap/cpp/runtime/yc_runtime.c}"

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

runtime_object_for() {
    local out_dir="$1"
    local runtime_obj="$out_dir/yc_runtime.o"

    if [ ! -f "$RUNTIME_SRC" ]; then
        return 2
    fi

    "$CLANG" -std=c11 -c "$RUNTIME_SRC" -o "$runtime_obj" 2>"$out_dir/runtime.log"
    if [ $? -ne 0 ]; then
        return 1
    fi

    printf "%s\n" "$runtime_obj"
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

    local runtime_obj
    runtime_obj=$(runtime_object_for "$out_dir")
    local runtime_status=$?
    if [ $runtime_status -ne 0 ]; then
        printf "${RED}FAIL${NC} (runtime object error)\n"
        if [ $runtime_status -eq 2 ]; then
            echo "  Missing runtime source: $RUNTIME_SRC"
        else
            cat "$out_dir/runtime.log"
        fi
        ((FAIL++))
        return 1
    fi

    "$CLANG" $LINKFLAGS "$obj_file" "$runtime_obj" -o "$exe_file" -lm 2>"$out_dir/link.log"
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

    local runtime_obj
    runtime_obj=$(runtime_object_for "$out_dir")
    local runtime_status=$?
    if [ $runtime_status -ne 0 ]; then
        printf "${RED}FAIL${NC} (runtime object error)\n"
        if [ $runtime_status -eq 2 ]; then
            echo "  Missing runtime source: $RUNTIME_SRC"
        else
            cat "$out_dir/runtime.log"
        fi
        ((FAIL++))
        return 1
    fi

    "$CLANG" $LINKFLAGS "$obj_file" "$runtime_obj" -o "$exe_file" -lm 2>"$out_dir/link.log"
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

    local runtime_obj
    runtime_obj=$(runtime_object_for "$out_dir")
    local runtime_status=$?
    if [ $runtime_status -ne 0 ]; then
        printf "${RED}FAIL${NC} (runtime object error)\n"
        if [ $runtime_status -eq 2 ]; then
            echo "  Missing runtime source: $RUNTIME_SRC"
        else
            cat "$out_dir/runtime.log"
        fi
        ((FAIL++))
        return 1
    fi

    "$CLANG" $LINKFLAGS "$obj_file" "$runtime_obj" -o "$exe_file" -lm 2>"$out_dir/link.log"
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

    local runtime_obj
    runtime_obj=$(runtime_object_for "$out_dir")
    local runtime_status=$?
    if [ $runtime_status -ne 0 ]; then
        printf "${RED}FAIL${NC} (runtime object error)\n"
        if [ $runtime_status -eq 2 ]; then
            echo "  Missing runtime source: $RUNTIME_SRC"
        else
            cat "$out_dir/runtime.log"
        fi
        ((FAIL++))
        return 1
    fi

    "$CLANG" $LINKFLAGS "$obj_file" "$runtime_obj" -o "$exe_file" -lm 2>"$out_dir/link.log"
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
compile_run_and_verify "$ROOT_DIR/examples/basics/hello.yc" "Hello World"
compile_run_and_verify "$ROOT_DIR/examples/basics/for_loop.yc" $'0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10'
compile_run_and_verify "$ROOT_DIR/examples/basics/fizzbuzz.yc" "$(fizzbuzz_expected)"
compile_run_and_verify "$ROOT_DIR/examples/basics/variables_and_types.yc" $'3\n12\nenabled\n69\n2.500000'
compile_run_and_verify "$ROOT_DIR/examples/basics/control_flow.yc" "7"
compile_run_and_verify "$ROOT_DIR/examples/basics/arrays.yc" $'3\n1\n3'
compile_run_and_verify "$ROOT_DIR/examples/basics/structs.yc" "7"
compile_run_and_verify "$ROOT_DIR/examples/basics/strings.yc" $'YCPL\n4\n65\n66\n67'
compile_run_and_verify "$ROOT_DIR/examples/basics/import_alias.yc" "implicit alias"
compile_run_and_verify "$ROOT_DIR/examples/basics/compound_assignment.yc" "31"
compile_run_and_verify "$ROOT_DIR/examples/basics/const_and_none.yc" $'ok\nset'
compile_run_and_verify "$ROOT_DIR/examples/basics/array_iteration.yc" "15"
compile_run_and_verify "$ROOT_DIR/examples/basics/short_circuit.yc" $'safe\n67'
compile_run_and_verify "$ROOT_DIR/examples/basics/enum_switch_alias.yc" $'10\n20\n30' "switch i32"
compile_run_and_verify "$ROOT_DIR/examples/basics/defer_scope.yc" $'body\nouter\nloop\nloop\nearly\nfunction'
compile_run_and_verify "$ROOT_DIR/examples/stdlib/fmt_str_math.yc" $'std ready\nlen5\n1\n7\n3.000000'
compile_run_with_input_and_verify "$ROOT_DIR/examples/stdlib/io_echo.yc" "lsp-io" "lsp-io"
compile_run_and_verify "$ROOT_DIR/examples/stdlib/json.yc" $'1\n42\n1\nYCPL\n2\nyes\n10\n{"x":3,"y":4}'
compile_run_and_verify "$ROOT_DIR/examples/stdlib/bytes_hex_hash.yc" $'4\n89\nYCPL\nY\n120\n1\n5943504c\n1\n1041946889\n541916226'
compile_run_and_verify "$ROOT_DIR/examples/stdlib/base64.yc" $'\nZg==\n1\nZm8=\n1\nZm9v\n1\nZm9vYg==\n1'
compile_run_and_verify "$ROOT_DIR/examples/stdlib/encoding.yc" $'LFBVATA=\n1\nWUNQTA==\n1\n5943504C\n1\n52232505' "@std__base32__encode" "@std__base64__encode_url" "@std__bytes__eq"
compile_run_and_verify "$ROOT_DIR/examples/stdlib/managed_runtime.yc" $'9\nYCPL\n7\n21\n"YCPL"' "@yc_runtime_init" "@yc_alloc" "@yc_runtime_shutdown"
compile_run_and_verify "$ROOT_DIR/examples/stdlib/managed_collections.yc" $'3\n16\nYCPL gogo\n3\n8\n1\n0' "%YCPLArrayHeader" "@yc_attach_child" "@yc_replace_child" "@yc_move_to_ancestor" "@std__text__concat" "@std__map__make_i32"
compile_run_and_verify "$ROOT_DIR/examples/stdlib/foundation.yc" $'managed | portable | self-hosted\n10\n30\n1\nYCPL\n/tmp/project\n5'

echo ""
echo "--- Compatibility and Compiler Fixtures ---"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compat/12_mutable_array.yc" $'2\n2\n10\n30'
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compat/13_manual_memory.yc" $'4\n16843009'
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compat/22_complex_arrays.yc" "36"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compat/23_array_stress.yc" $'1000\n499500'
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compat/30_std_source_usage.yc" $'6\n1\n9\n8.000000\n0.000000\n1.000000\n0\n4\n24' "@std__str__eq" "@std__math__abs"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compat/106_std_selfhost_primitives.yc" $'tok:ens\n27\n1\n2' "@std__text__append" "@std__map__put_i32" "%YCPLArrayHeader"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compat/109_map_runtime_api.yc" $'12\n1\n-1\nYCPL' "@std__map__new_i32" "@std__map__put_i32_value" "@std__map__free_i32"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compiler/34_std_lsp_foundation.yc" $'42\n1\n4\ninitialize\n6\n1\n1\n1\n1\nfn main() {}'
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compiler/100_retired_keywords_as_identifiers.yc" "42"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compiler/108_map_type_syntax.yc" "13" "@std__map__put_i32" "%SymbolTable"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compiler/109_vec_builtin.yc" $'0\n1\n2\n3\n16\n60\n30\n9\n0\n7\n2\n8' "%YCPLArrayHeader" "@yc_attach_child" "@yc_replace_child"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compiler/110_dynamic_limits.yc" $'160\n48\n64' "f64\"" "dynamic_limits__many"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compiler/115_std_foundation_expanded.yc" $'1\nYCPL\na-x-x\n3\none|two|three\nycpl\nYCPL\n1\n3\n3\n1\n128512\n1\n-2147483648\n1\n9223372036854775807\n1\n-1250.000000\n-42\n12.5\n0\n0\n1\n6\n1\nYCPL!!\n1\n1\n!!LPCY\n/tmp/b/file.yc\n/tmp/b\nfile.yc\n/tmp\n.yc\nfile\n1\n1\n4\n4\n3\n1\n1\n2\n3\n0\n3\n8\n4.000000\n3.000000\n4.000000\n4.000000\n3.000000\n1\n1\n1\nYCPL\n125.000000\n4\n2\n"a\\nb"\n0\n0\n1\n0\n1\n0\n1\n0\n1\n1\n1\n1\n4'
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compiler/118_std_text_expanded.yc" $'3\na|b|c\nYCPL\na+b'
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compiler/119_std_path_expanded.yc" $'/tmp/b\n../../a\n/tmp/b'
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compiler/120_std_utf8_expanded.yc" $'1\n3\n3\n😀'
compile_run_and_verify "$ROOT_DIR/tests/fixtures/compiler/struct_array_index.yc" "7" "load_struct_value_dyn"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/runtime/107_slice_pointer_extern_abi.yc" $'strap\nstr\n1\n5' "@std__text__slice" "@std__mem__copy" "@memcmp"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/runtime/111_managed_frame_cleanup.yc" $'12\n0\n6\n1' "@yc_runtime_live_allocations" "@yc_frame_pop" "@yc_move_to_ancestor"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/runtime/112_managed_child_destructors.yc" $'2\n2' "@yc_attach_child" "@yc_replace_child" "@yc_release"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/runtime/113_managed_value_roots.yc" $'2\n2\n2' "@yc_attach_child" "@yc_replace_child" "@yc_release"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/runtime/114_vec_managed_ownership.yc" $'2\n2\n2\n2' "@yc_attach_child" "@yc_release" "vec.clear" "vec.replace"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/runtime/116_std_system_expanded.yc" $'1\n1\n1\n1\n1\nYCPL\n1\n1\n4\n1\n1\n1\n1\n1\n1\n1\n1\n1\nA-B\n1\n1\n1'
compile_run_and_verify "$ROOT_DIR/tests/fixtures/runtime/117_std_fs_bytes_expanded.yc" $'1\n1\nbytes\n1'
compile_run_and_verify "$ROOT_DIR/tests/fixtures/runtime/scope_escape_cleanup.yc" $'scope escape\n0\n0' "@yc_move_to_ancestor" "@yc_frame_push" "@yc_frame_pop"
compile_run_and_verify "$ROOT_DIR/tests/fixtures/runtime/process_argv.yc" "0" "@yc_process_run_packed"

echo ""
echo "--- Project Tests ---"
test_project "$ROOT_DIR/examples/projects/module_project" $'30\n30\n20\n10'
test_project "$ROOT_DIR/examples/projects/multi_module" $'Hello, YCPL!\n25\n125'
test_project "$ROOT_DIR/tests/fixtures/compat/14_v1_foundation_project" "10"
test_project "$ROOT_DIR/tests/fixtures/projects/16_duplicate_symbols_project" "3"

echo ""
echo "--- Negative Module Tests ---"
test_project_expect_failure "$ROOT_DIR/tests/fixtures/negative/17_private_access_failure" "no public function"
test_project_expect_failure "$ROOT_DIR/tests/fixtures/negative/18_missing_import_failure" "Cannot resolve import"

echo ""
echo "--- Negative Core v1.1 Tests ---"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/24_const_reassign_failure.yc" "cannot assign to const"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/25_none_int_failure.yc" "none can only initialize"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/26_invalid_array_type_failure.yc" "array.new first argument"
compile_run_expect_failure "$ROOT_DIR/tests/fixtures/negative/27_array_get_oob_abort.yc"
compile_run_expect_failure "$ROOT_DIR/tests/fixtures/negative/28_array_set_oob_abort.yc"
compile_run_expect_failure "$ROOT_DIR/tests/fixtures/negative/29_index_oob_abort.yc"

echo ""
echo "--- Negative Core v1.2 Tests ---"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/31_extern_body_failure.yc" "extern function cannot have a body"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/32_intrinsic_outside_std_failure.yc" "intrinsic functions are only allowed in std modules"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/33_missing_std_symbol_failure.yc" "no public function"

echo ""
echo "--- Negative Core v1.3 Return Tests ---"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/37_return_without_value_failure.yc" "non-void function requires a return value"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/38_void_return_value_failure.yc" "void function cannot return a value"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/39_missing_return_failure.yc" "non-void function is missing an explicit return"

echo ""
echo "--- Negative Parser/Lexer Tests ---"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/41_unclosed_string_failure.yc" "unterminated string literal"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/42_unclosed_comment_failure.yc" "unclosed block comment"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/43_invalid_char_failure.yc" "unterminated/invalid char literal"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/44_unexpected_eof_failure.yc" "expected '}' to end block"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/45_bad_import_failure.yc" "expected alias after 'as'"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/46_bad_type_failure.yc" "unknown type: MissingType"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/47_malformed_call_failure.yc" "expected ')' in call"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/48_bad_module_failure.yc" "expected module/package name"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/49_malformed_extern_failure.yc" "expected function or method name"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/50_malformed_intrinsic_failure.yc" "expected function or method name"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/51_malformed_struct_literal_failure.yc" "expected '}' to close struct literal"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/52_misplaced_else_failure.yc" "unexpected token in expression"

echo ""
echo "--- Negative Vec Tests ---"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/53_vec_capacity_type_failure.yc" "Vec capacity must be an integer"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/54_vec_push_type_failure.yc" "Vec.push value type does not match element type"
compile_expect_failure "$ROOT_DIR/tests/fixtures/negative/55_vec_raw_pointer_failure.yc" "Vec value cannot initialize a different declared type"
compile_run_expect_failure "$ROOT_DIR/tests/fixtures/negative/56_vec_index_oob_abort.yc"

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
