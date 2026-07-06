# YCPL Examples

This directory contains example programs written in YCPL.

## Single-File Examples

| File | Description |
|------|-------------|
| `01_hello.yc` | Basic "Hello World" program |
| `02_for_c_style.yc` | C-style for loop example |
| `03_fizzbuzz.yc` | Classic FizzBuzz problem |
| `06_variables_and_types.yc` | Inference, explicit types, booleans, chars, and doubles |
| `07_loops_and_control.yc` | `for in`, `break`, and `continue` |
| `08_arrays.yc` | Array literals, indexing, and `len` |
| `09_structs.yc` | Struct declaration, literal initialization, and field access |
| `10_strings.yc` | Strings, string length, and string iteration |
| `11_std_fmt_str_math.yc` | `std/fmt`, `std/str`, and `std/math` |
| `12_mutable_array.yc` | `std/array` new/append/get/set/free |
| `13_manual_memory.yc` | `std/mem` alloc/copy/set/free/sizeof |
| `15_implicit_alias.yc` | Import without `as`, using implicit last-segment alias |
| `19_compound_assignment.yc` | Compound assignment for variables, array index, and struct field |
| `20_const_mut_none.yc` | `const`, mutable locals, and `none` null literal |
| `21_array_for_in.yc` | Array value iteration with `for value in xs` |
| `22_complex_arrays.yc` | Nested arrays, struct arrays, grow, get/set, and manual free |
| `23_array_stress.yc` | 1000 appends with grow and iteration sum |
| `30_std_source_usage.yc` | YCPL source std modules, extern wrappers, intrinsic bridge, and IR checks |
| `34_std_lsp_foundation.yc` | `std/fs`, `std/text`, `std/json`, and `std/map` LSP foundation APIs |
| `35_std_io_echo.yc` | `std/io` fd read/write using stdin input |
| `100_retired_keywords_as_identifiers.yc` | Retired keywords accepted as ordinary identifiers |
| `36_std_json_ast.yc` | `std/json` tagged value parse/get/at/stringify/free |
| `40_short_circuit_and_string_field.yc` | Short-circuit logic and struct string field indexing |

## Project Examples

| Directory | Description |
|------|-------------|
| `04_module_project/` | Single module import example |
| `05_multi_module/` | Multi-module project with nested packages |
| `14_v1_foundation_project/` | Module alias + std array + loop + struct |
| `16_duplicate_symbols_project/` | Duplicate public symbol names resolved through aliases |

## Negative Tests

| Directory | Description |
|------|-------------|
| `17_private_access_failure/` | Private imported symbol access must fail |
| `18_missing_import_failure/` | Missing import path must fail |
| `24_const_reassign_failure.yc` | `const` reassignment must fail |
| `25_none_int_failure.yc` | `none` into integer must fail |
| `26_invalid_array_type_failure.yc` | Invalid `array.new` type argument must fail |
| `27_array_get_oob_abort.yc` | `array.get` out-of-bounds must abort |
| `28_array_set_oob_abort.yc` | `array.set` out-of-bounds must abort |
| `29_index_oob_abort.yc` | Index access out-of-bounds must abort |
| `31_extern_body_failure.yc` | `extern fn` with a body must fail |
| `32_intrinsic_outside_std_failure.yc` | `intrinsic fn` outside bundled std must fail |
| `33_missing_std_symbol_failure.yc` | Missing public std symbol must fail |
| `37_return_without_value_failure.yc` | Non-void function bare `return` must fail |
| `38_void_return_value_failure.yc` | Void function `return value` must fail |
| `39_missing_return_failure.yc` | Non-void function missing explicit return must fail |
| `41_unclosed_string_failure.yc` | Unterminated string literal must fail |
| `42_unclosed_comment_failure.yc` | Unclosed block comment must fail |
| `43_invalid_char_failure.yc` | Invalid char literal must fail |
| `44_unexpected_eof_failure.yc` | Unexpected EOF in nested block must fail |
| `45_bad_import_failure.yc` | Incomplete import alias must fail |
| `46_bad_type_failure.yc` | Unknown type annotation must fail |
| `47_malformed_call_failure.yc` | Malformed call syntax must fail |
| `48_bad_module_failure.yc` | Malformed module declaration must fail |
| `49_malformed_extern_failure.yc` | Malformed extern declaration must fail |
| `50_malformed_intrinsic_failure.yc` | Malformed intrinsic declaration must fail |
| `51_malformed_struct_literal_failure.yc` | Malformed struct literal must fail |
| `52_misplaced_else_failure.yc` | Misplaced `else` must fail |

### Project Structure

Each project has an `YCPL.json` configuration file:

```
project/
├── YCPL.json          # Project configuration
└── src/
    ├── main.yc        # Entry point
    └── math.yc        # Module with pub functions
```

### YCPL.json Format

```json
{
    "name": "myproject",
    "version": "0.1.0",
    "entry": "src/main.yc",
    "src": ["src/"],
    "output": "build/"
}
```

### Module Syntax

```YCPL
// Declaration (exported with pub)
module math

pub fn add(a i32, b i32) i32 {
    return a + b
}

fn internal_helper() {  // Not exported (private)
    // ...
}

// Import and usage
import "std/fmt" as fmt
import "math" as math

fn main() {
    result := math.add(1, 2)
    fmt.println(result)
}
```

### Visibility Rules

- Functions with `pub` keyword are exported and accessible from other modules
- Functions without `pub` are private (static linkage in LLVM IR)
- Use `pub fn` for public API functions
- Imported functions must be called as `alias.symbol(...)`
- Standard library modules are bundled YCPL source files in `../stl/std`
- See `../docs/` for the supported language syntax and current limitations

## Running Tests

```bash
./run_tests.sh
```

The runner checks exact stdout for positive tests, verifies expected compile or
runtime failures for negative tests, and builds project examples from temporary
copies so source directories are not polluted with build artifacts.

For project-based examples:

```bash
cd examples/04_module_project
../../bazel-bin/ycc build
../../bazel-bin/ycc build-ir
```

Requirements:
- YCPL compiler built (`bazel build //:ycc` or `cmake --build build`)
- LLVM tools (`llc`, or set `LLC=/path/to/llc`; `build-ir` does not need `llc`)
- Clang (`clang`, or set `CLANG=/path/to/clang`; `ycc build` uses `-lm` when linking
  examples because `std/math` uses C math)

When using Bazel-provided tools, run through `bazel test //:examples_test` so
the wrapper points the test runner at Bazel's `ycc`, `llc`, and `clang`.

The YCPL LSP has its own fixture runner:

```bash
../tools/lsp/run_tests.sh
```

## Adding New Examples

1. Single file: Add `.yc` file and update `run_tests.sh`
2. Project: Create directory with `YCPL.json` and `src/` folder
