# YCPL Examples

This directory contains example programs written in YCPL.

## Single-File Examples

| File | Description |
|------|-------------|
| `01_hello.ec` | Basic "Hello World" program |
| `02_for_c_style.ec` | C-style for loop example |
| `03_fizzbuzz.ec` | Classic FizzBuzz problem |
| `06_variables_and_types.ec` | Inference, explicit types, booleans, chars, and doubles |
| `07_loops_and_control.ec` | `for in`, `break`, and `continue` |
| `08_arrays.ec` | Array literals, indexing, and `len` |
| `09_structs.ec` | Struct declaration, literal initialization, and field access |
| `10_strings.ec` | Strings, string length, and string iteration |
| `11_std_fmt_str_math.ec` | `std/fmt`, `std/str`, and `std/math` |
| `12_mutable_array.ec` | `std/array` new/append/get/set/free |
| `13_manual_memory.ec` | `std/mem` alloc/copy/set/free/sizeof |
| `15_implicit_alias.ec` | Import without `as`, using implicit last-segment alias |
| `19_compound_assignment.ec` | Compound assignment for variables, array index, and struct field |
| `20_const_mut_none.ec` | `const`, `mut`, and `none` null literal |
| `21_array_for_in.ec` | Array value iteration with `for value in xs` |
| `22_complex_arrays.ec` | Nested arrays, struct arrays, grow, get/set, and manual free |
| `23_array_stress.ec` | 1000 appends with grow and iteration sum |
| `30_std_source_usage.ec` | YCPL source std modules, extern wrappers, intrinsic bridge, and IR checks |
| `34_std_lsp_foundation.ec` | `std/fs`, `std/text`, `std/json`, and `std/map` LSP foundation APIs |
| `35_std_io_echo.ec` | `std/io` fd read/write using stdin input |
| `36_std_json_ast.ec` | `std/json` tagged value parse/get/at/stringify/free |
| `40_short_circuit_and_string_field.ec` | Short-circuit logic and struct string field indexing |

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
| `24_const_reassign_failure.ec` | `const` reassignment must fail |
| `25_none_int_failure.ec` | `none` into integer must fail |
| `26_invalid_array_type_failure.ec` | Invalid `array.new` type argument must fail |
| `27_array_get_oob_abort.ec` | `array.get` out-of-bounds must abort |
| `28_array_set_oob_abort.ec` | `array.set` out-of-bounds must abort |
| `29_index_oob_abort.ec` | Index access out-of-bounds must abort |
| `31_extern_body_failure.ec` | `extern fn` with a body must fail |
| `32_intrinsic_outside_std_failure.ec` | `intrinsic fn` outside bundled std must fail |
| `33_missing_std_symbol_failure.ec` | Missing public std symbol must fail |
| `37_return_without_value_failure.ec` | Non-void function bare `return` must fail |
| `38_void_return_value_failure.ec` | Void function `return value` must fail |
| `39_missing_return_failure.ec` | Non-void function missing explicit return must fail |
| `41_unclosed_string_failure.ec` | Unterminated string literal must fail |
| `42_unclosed_comment_failure.ec` | Unclosed block comment must fail |
| `43_invalid_char_failure.ec` | Invalid char literal must fail |
| `44_unexpected_eof_failure.ec` | Unexpected EOF in nested block must fail |
| `45_bad_import_failure.ec` | Incomplete import alias must fail |
| `46_bad_type_failure.ec` | Unknown type annotation must fail |
| `47_malformed_call_failure.ec` | Malformed call syntax must fail |
| `48_bad_module_failure.ec` | Malformed module declaration must fail |
| `49_malformed_extern_failure.ec` | Malformed extern declaration must fail |
| `50_malformed_intrinsic_failure.ec` | Malformed intrinsic declaration must fail |
| `51_malformed_struct_literal_failure.ec` | Malformed struct literal must fail |
| `52_misplaced_else_failure.ec` | Misplaced `else` must fail |

### Project Structure

Each project has an `YCPL.json` configuration file:

```
project/
├── YCPL.json          # Project configuration
└── src/
    ├── main.ec        # Entry point
    └── math.ec        # Module with pub functions
```

### YCPL.json Format

```json
{
    "name": "myproject",
    "version": "0.1.0",
    "entry": "src/main.ec",
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
../../build/ecc build
```

Requirements:
- YCPL compiler built (`cd build && make`)
- LLVM tools (`llc`)
- Clang (`-lm` is used when linking examples because `std/math` uses C math)

The YCPL LSP has its own fixture runner:

```bash
../tools/lsp/run_tests.sh
```

## Adding New Examples

1. Single file: Add `.ec` file and update `run_tests.sh`
2. Project: Create directory with `YCPL.json` and `src/` folder
