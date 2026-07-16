# YCPL Standard Library

[Japanese](stdlib.ja.md) | [Docs index](README.en.md)

The standard library is stored as YCPL source under `stl/std`. New public C,
POSIX, and LLVM declarations are collected under `stl/c`. Some low-level APIs
are declared as `intrinsic fn` and implemented by compiler/runtime bridge code.

```text
stl/std/<module>/index.yc
├─ YCPL source wrappers   -> normal module codegen
├─ intrinsic declarations -> compiler/runtime bridge
└─ unsafe/mem             -> explicit unsafe compatibility wrapper

stl/c/<module>/index.yc
└─ extern declarations    -> raw C, POSIX, and LLVM ABI boundary
```

## Module Map

```text
std/
├─ Vec<T> compiler-built-in managed dynamic array
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
├─ llvm   LLVM compatibility wrapper
└─ unsafe/mem explicit unsafe malloc/calloc/realloc/free wrapper

c/
├─ stdlib malloc, calloc, realloc, free, getenv, system
├─ string memcpy, memset, strlen, and related functions
├─ stdio / unistd / fcntl / sys.stat
├─ math
├─ llvm   LLVM 22 C API and Vec argument bridges
└─ yc_runtime runtime/source-traversal bridge
```

## Folder Layout

`stl/std/<module>/index.yc` is the primary standard-library layout, similar to
Go's `src/fmt` shape. Modules such as `std/base32`, `std/base64`, `std/bytes`,
`std/hex`, and `std/hash` can be imported with paths like
`import "std/base32" as base32`. The canonical location for raw C symbol
declarations is `stl/c`; `std/unsafe/mem` is an explicitly unsafe compatibility
wrapper. Normal containers and buffers should use `Vec<T>` or runtime-managed
standard types. The self-hosted compiler directly imports no `std/mem`.

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

Vec<T>{} / Vec<T>{capacity: n}
    -> compiler-built-in managed header
    -> push / len / capacity / reserve / clear / index / as_slice
    -> reference semantics with no manual free

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
import "std/map" as map
import "std/text" as text

fn main() {
    xs := Vec<i32>{capacity: 4}
    xs.push(10)
    fmt.println(xs[0])

    message := text.join("YCPL", " ", "runtime")
    fmt.println(message)

    counts := map.make_i32(4)
    map.set_i32(counts, "parser", 12)
    fmt.println(map.get_i32_or(counts, "parser", 0))
}
```

## Memory Ownership

```text
Vec<T>{} / array.make / json.parse / bytes.from_string / map.make_*
    -> allocated through the statically linked YCPL runtime
    -> released when the owning function frame exits
    -> returned managed roots are moved to the caller frame
    -> array headers release their backing data, and map handles release their key/value arrays

json.get / json.at
    -> non-owning views

std/unsafe/mem
    -> explicit unsafe wrapper, not for ordinary YCPL code

c/*
    -> raw C/LLVM ABI declarations without safe ownership semantics
```

`ycc build` links `bootstrap/cpp/runtime/yc_runtime.c` into every native binary.
The runtime currently provides `yc_runtime_init`, `yc_runtime_shutdown`,
`yc_frame_push`, `yc_frame_pop`, `yc_alloc`, `yc_calloc`, `yc_realloc`,
`yc_release`, `yc_move_to_parent`, and `yc_move_to_ancestor`. Background tracing GC is intentionally
not part of this milestone; the design is deterministic frame ownership with
manual-free compatibility during migration. When a managed value escapes, the
runtime moves only its ownership root and reachable children to the caller
frame. Unrelated local allocations remain in the callee frame. Vec, array, map,
Bytes, StringBuilder, and JsonValue roots keep their backing allocations in the
same ownership graph.

Pointer and aggregate returns escape their reachable managed values to the
caller before the callee frame is popped. Scope assignments and
break/continue/return paths emit the corresponding deterministic frame unwind.

`extern fn` maps YCPL names to C/LLVM symbols. `intrinsic fn` is reserved for
bundled `std` modules and is rejected in user modules.

`std/os` exposes the narrow process hooks needed by compiler tooling, including
explicit LLVM/runtime paths and native build/run process execution. The
self-hosted driver has no bootstrap compiler fallback.

`std/bytes`, `std/hex`, `std/base64`, and `std/hash` are foundation modules for
file formats such as zip and for educational cryptography experiments. The
FNV-1a32 and CRC32 functions in `std/hash` are for checks and identifiers, not
cryptographic security.

## LLVM C API

```YCPL
import "c/llvm" as llvm

fn main() {
    ctx := llvm.context_create()
    mod := llvm.module_create("demo", ctx)
    ir := llvm.module_to_string(mod)
    llvm.dispose_message(ir)
    llvm.module_dispose(mod)
    llvm.context_dispose(ctx)
}
```

`std/llvm` remains for compatibility with existing code, but new low-level
bindings belong in `c/llvm`. The `c/llvm` module provides dedicated bridges for
passing LLVM reference sequences from `Vec<i64>` without exposing a general
Vec-to-pointer conversion to YCPL programs.

`ycc build` auto-links LLVM when the generated IR references `LLVM...` C API
symbols. Use `LLVM_CONFIG=/path/to/llvm-config` to select the LLVM prefix
without installing symlinks into `/usr`.
