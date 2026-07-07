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
├─ fs     exists, read_file, write_file
├─ os     getenv, system
├─ text   find, offsets
├─ json   parse, get, stringify
├─ map    caller-owned arrays
├─ bytes  owned/wrapped binary buffers
├─ hex    bytes <-> hexadecimal text
├─ base64 bytes <-> base64 text
├─ hash   FNV-1a32, CRC32
└─ llvm   LLVM C API bridge
```

## std2 Experimental Library

`stl/std2/<module>/index.yc` contains a folder-based standard-library candidate,
similar to Go's `src/fmt` layout. It is separate from the existing `stl/std`.
Modules such as `std2/base32`, `std2/base64`, `std2/bytes`, `std2/hex`, and
`std2/hash` can be imported with paths like `import "std2/base32" as base32`.

```YCPL
b: owned Bytes := bytes.from_string("YCPL")
defer b.free()

encoded := base32.encode(b)
decoded := base32.decode(encoded)
defer decoded.free()

fmt.println(b.eq(decoded))
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
| `std/os` | `stl/std/os.yc` |
| `std/text` | `stl/std/text.yc` |
| `std/json` | `stl/std/json.yc` |
| `std/map` | `stl/std/map.yc` |
| `std/bytes` | `stl/std/bytes.yc` |
| `std/hex` | `stl/std/hex.yc` |
| `std/base64` | `stl/std/base64.yc` |
| `std/hash` | `stl/std/hash.yc` |
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

bytes.from_string(text)
    -> Bytes { data, len, cap, owns }
    -> bytes.to_string / bytes.byte_to_string
    -> hex.encode / base64.encode / hash.crc32
    -> bytes.free
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

`std/os` exposes the narrow process hooks currently needed by compiler tooling:
`getenv` for explicit tool paths such as `YCPL_BOOTSTRAP_YCC`, and `system` for
the transitional `ycc-ycpl build` stage driver.

`std/bytes`, `std/hex`, `std/base64`, and `std/hash` are foundation modules for
file formats such as zip and for educational cryptography experiments. The
FNV-1a32 and CRC32 functions in `std/hash` are for checks and identifiers, not
cryptographic security.

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
