# YCPL Standard Library

[Japanese](stdlib.ja.md) | [Docs index](README.en.md)

The standard library is stored as YCPL source under `stl/std`. Some low-level
APIs are declared as `intrinsic fn` and implemented by compiler/runtime bridge
code.

```text
stl/std/<module>/index.yc
├─ YCPL source wrappers   -> normal module codegen
├─ intrinsic declarations -> compiler/runtime bridge
└─ unsafe/mem             -> raw C allocation for FFI boundaries
```

## Module Map

```text
std/
├─ fmt    print, println, printf
├─ array  make, push, get, set, free compatibility
├─ mem    managed alloc/copy/sizeof
├─ str    len, eq, cmp
├─ math   abs, sqrt, pow
├─ io     read/write, LSP frames
├─ fs     exists, read_file, write_file
├─ os     getenv, system
├─ text   find, offsets
├─ json   parse, get, stringify
├─ map    runtime-backed arrays and Map<string, T> interop helpers
├─ bytes  owned/wrapped binary buffers
├─ hex    bytes <-> hexadecimal text
├─ base64 bytes <-> base64 text
├─ hash   FNV-1a32, CRC32
├─ llvm   LLVM C API bridge
└─ unsafe/mem raw C malloc/calloc/realloc/free for FFI-only use
```

## Folder Layout

`stl/std/<module>/index.yc` is the primary standard-library layout, similar to
Go's `src/fmt` shape. Modules such as `std/base32`, `std/base64`, `std/bytes`,
`std/hex`, and `std/hash` can be imported with paths like
`import "std/base32" as base32`. Raw C allocation lives only in
`std/unsafe/mem`; normal containers and buffers use the YCPL runtime allocator.

```YCPL
b: owned Bytes := bytes.from_string("YCPL")

encoded := base32.encode(b)
decoded := base32.decode(encoded)

fmt.println(b.eq(decoded))
```

| Module | Source |
|---|---|
| `std/map` | `stl/std/map/index.yc` |
| `std/unsafe/mem` | `stl/std/unsafe/mem/index.yc` |
| `std/fmt` | `stl/std/fmt/index.yc` |
| `std/array` | `stl/std/array/index.yc` |
| `std/mem` | `stl/std/mem/index.yc` |
| `std/str` | `stl/std/str/index.yc` |
| `std/math` | `stl/std/math/index.yc` |
| `std/io` | `stl/std/io/index.yc` |
| `std/fs` | `stl/std/fs/index.yc` |
| `std/os` | `stl/std/os/index.yc` |
| `std/text` | `stl/std/text/index.yc` |
| `std/json` | `stl/std/json/index.yc` |
| `std/bytes` | `stl/std/bytes/index.yc` |
| `std/hex` | `stl/std/hex/index.yc` |
| `std/base32` | `stl/std/base32/index.yc` |
| `std/base64` | `stl/std/base64/index.yc` |
| `std/hash` | `stl/std/hash/index.yc` |
| `std/llvm` | `stl/std/llvm/index.yc` |

## Common Flows

```text
fmt.println(value) -> stdout

array.make([]T)
    -> { data, len, cap, elem_size }
    -> array.push / array.get / array.set
    -> managed by the YCPL runtime

text.concat / text.join / text.repeat
    -> high-level string construction over managed StringBuilder internals

json.parse(text)
    -> JsonValue { root, source, range, owns }
    -> json.get / json.at views
    -> managed allocation foundation

bytes.from_string(text)
    -> Bytes { root, data, len, cap, owns }
    -> bytes.to_string / bytes.byte_to_string
    -> hex.encode / base64.encode / hash.crc32
    -> managed by the YCPL runtime

map.make_i32(cap) / map.make_string(cap)
    -> Map<string, i32> / Map<string, string> runtime handle
    -> map.set_i32 / map.get_i32_or / map.delete_i32
    -> map.set_string / map.get_string / map.delete_string
    -> managed by the YCPL runtime
```

```YCPL
import "std/fmt" as fmt
import "std/array" as array
import "std/map" as map
import "std/text" as text

fn main() {
    xs := array.make([]i32)
    xs = array.push(xs, 10)
    fmt.println(array.get(xs, 0))

    message := text.join("YCPL", " ", "runtime")
    fmt.println(message)

    counts := map.make_i32(4)
    map.set_i32(counts, "parser", 12)
    fmt.println(map.get_i32_or(counts, "parser", 0))
}
```

## Memory Ownership

```text
array.make / json.parse / bytes.from_string / map.make_*
    -> allocated through the statically linked YCPL runtime
    -> released when the owning function frame exits
    -> returned managed roots are moved to the caller frame
    -> array headers release their backing data, and map handles release their key/value arrays

json.get / json.at
    -> non-owning views

std/unsafe/mem
    -> raw C malloc/calloc/realloc/free for FFI boundaries only
```

`ycc build` links `bootstrap/cpp/runtime/yc_runtime.c` into every native binary.
The runtime currently provides `yc_runtime_init`, `yc_runtime_shutdown`,
`yc_frame_push`, `yc_frame_pop`, `yc_alloc`, `yc_calloc`, `yc_realloc`,
`yc_release`, `yc_move_to_parent`, and `yc_move_to_ancestor`. Background tracing GC is intentionally
not part of this milestone; the design is deterministic frame ownership with
manual-free compatibility during migration. When a managed value escapes, the
runtime moves only its ownership root and reachable children to the caller
frame. Unrelated local allocations remain in the callee frame. Array, map,
Bytes, StringBuilder, and JsonValue roots keep their backing allocations in the
same ownership graph.

Pointer returns use selective graph escape. Aggregate returns also retain a
temporary whole-frame compatibility fallback until every compiler-internal
aggregate registers all of its related buffers as runtime children.

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
