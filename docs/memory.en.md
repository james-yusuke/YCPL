# Vec and Memory Ownership

[Japanese](memory.ja.md) | [Docs index](README.en.md)

Ordinary YCPL code uses `Vec<T>` for growable arrays and `[]T` for non-growing
views. `malloc`, `calloc`, `realloc`, and `free` are not the normal container
API; they are implementation details of the runtime or explicit C/unsafe
boundaries.

## Vec and Slices

| Type | Meaning | Growth | Ownership |
|---|---|---|---|
| `Vec<T>` | Managed dynamic-array handle | `push` and `reserve` | Header owns backing storage |
| `[]T` | View over an element range | No | Usually references another value |
| `*T` | Raw pointer | No container operations | Carries no automatic safety |

```YCPL
values := Vec<i32>{capacity: 8}
values.push(10)
values.push(20)

alias := values
alias[0] = 11

view := values.as_slice()
println(view[0]) // 11
```

Copying a Vec shares the same managed handle; it is not a deep value copy.
`as_slice()` also avoids copying and returns a view over the same backing
storage.

## Public Operations

```YCPL
index := values.push(value)
length := values.len()
capacity := values.capacity()

values.reserve(1024)
values.clear()

value := values[index]
values[index] = value
view := values.as_slice()
```

- `push` returns the pre-insertion index as `i32`.
- `reserve` may increase capacity without changing length.
- `clear` releases managed elements and resets length to zero.
- Indexed reads and writes are bounds checked.
- Push, overwrite, and clear attach, replace, or release ownership edges for managed elements.
- Nested Vec values are managed elements as well.

Negative capacity, capacity arithmetic overflow, and out-of-range indexes abort
after a diagnostic. The public API exposes no `free`, raw backing pointer, or
implicit `Vec<T> -> *T` conversion.

## Runtime Ownership

Native binaries statically link `bootstrap/cpp/runtime/yc_runtime.c`. The
runtime tracks managed allocations in function and scope frames and releases
them deterministically when control leaves the scope.

```text
function entry
    -> push frame
    -> register Vec header and backing storage
    -> attach managed children to the ownership graph
return / scope exit
    -> move escaping roots to the caller
    -> unwind remaining values in LIFO order
    -> pop frame
```

Returning a Vec moves its container root, reachable backing storage, and
managed children to the caller frame. Unrelated local allocations remain in
the callee frame.

## C and Unsafe Boundaries

- `stl/c/*`: raw C, POSIX, and LLVM ABI declarations.
- `stl/std/*`: language-level standard APIs.
- `std/unsafe/mem`: compatibility wrapper for explicit raw allocation.
- `compiler/ycpl`: directly imports no `std/mem` and uses `Vec<T>` for variable-length data.
- `c/llvm`: only dedicated LLVM reference bridges access Vec backing data.

YCPL programs do not need raw allocators unless an FFI requires them. Prefer
`Vec<T>` for general data structures, `std/text` for string construction, and
`std/bytes` for binary buffers.
