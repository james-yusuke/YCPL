# YCPL Standard Library

[Japanese](stdlib.ja.md) | [Docs index](README.en.md)

The standard library is stored as YCPL source under `stl/std`. Some low-level
APIs are declared as `intrinsic fn` and implemented by compiler/runtime bridge
code.

```text
stl/std/*.yc
├─ YCPL source wrappers  -> normal module codegen
└─ intrinsic declarations -> compiler/runtime bridge
```

## Module Map

```text
std/
├─ fmt    print, println, printf
├─ array  new, append, get, set, free
├─ mem    alloc, copy, sizeof
├─ str    len, eq, cmp
├─ math   abs, sqrt, pow
├─ io     read/write, LSP frames
├─ fs     exists, read_file
├─ text   find, offsets
├─ json   parse, get, stringify
├─ map    caller-owned arrays
└─ llvm   LLVM C API bridge
```

| Module | Source |
|---|---|
| `std/fmt` | `stl/std/fmt.yc` |
| `std/array` | `stl/std/array.yc` |
| `std/mem` | `stl/std/mem.yc` |
| `std/str` | `stl/std/str.yc` |
| `std/math` | `stl/std/math.yc` |
| `std/io` | `stl/std/io.yc` |
| `std/fs` | `stl/std/fs.yc` |
| `std/text` | `stl/std/text.yc` |
| `std/json` | `stl/std/json.yc` |
| `std/map` | `stl/std/map.yc` |
| `std/llvm` | `stl/std/llvm.yc` |

## Common Flows

```text
fmt.println(value) -> stdout

array.new([]T, cap)
    -> { data, len, cap, elem_size }
    -> array.append / array.get / array.set
    -> array.free

json.parse(text)
    -> JsonValue root
    -> json.get / json.at views
    -> json.free(root)
```

```YCPL
import "std/fmt" as fmt
import "std/array" as array

fn main() {
    xs := array.new([]i32, 1)
    xs = array.append(xs, 10)
    fmt.println(array.get(xs, 0))
    array.free(xs)
}
```

## Memory Ownership

```text
array.new / mem.alloc / json.parse
    -> caller owns root value
    -> release with array.free / mem.free / json.free

json.get / json.at
    -> non-owning views
```

`extern fn` maps YCPL names to C/LLVM symbols. `intrinsic fn` is reserved for
bundled `std` modules and is rejected in user modules.

## LLVM C API

```YCPL
import "std/llvm" as llvm

fn main() {
    ctx := llvm.context_create()
    mod := llvm.module_create_with_name_in_context("demo", ctx)
    ir := llvm.print_module_to_string(mod)
    llvm.dispose_message(ir)
    llvm.dispose_module(mod)
    llvm.context_dispose(ctx)
}
```

`ycc build` auto-links LLVM when the generated IR references `LLVM...` C API
symbols. Use `LLVM_CONFIG=/path/to/llvm-config` to select the LLVM prefix
without installing symlinks into `/usr`.
