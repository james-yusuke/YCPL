# YCPL Standard Library

The v1.3 standard library is imported through alias-qualified modules and is
stored as bundled YCPL source under `stl/std`. Pure functions are written in
YCPL. Low-level operations that need compiler/runtime knowledge are declared in
those source modules as `intrinsic fn`.

Current source modules:

```text
stl/std/fmt.ec
stl/std/array.ec
stl/std/mem.ec
stl/std/str.ec
stl/std/math.ec
stl/std/io.ec
stl/std/fs.ec
stl/std/text.ec
stl/std/json.ec
stl/std/map.ec
```

## fmt

```YCPL
import "std/fmt" as fmt

fmt.print("value")
fmt.println("value")
fmt.printf("%d\n", 42)
```

- `fmt.print` prints values without a trailing newline.
- `fmt.println` prints values with a trailing newline.
- `fmt.printf` forwards to C `printf`.
- These functions are intrinsic declarations in `stl/std/fmt.ec` because
  formatted printing depends on compiler-side value classification.

## array

```YCPL
import "std/array" as array

xs := array.new([]i32, 1)
xs = array.append(xs, 10)
xs = array.append(xs, 20)
array.set(xs, 1, 30)

len := array.len(xs)
cap := array.cap(xs)
value := array.get(xs, 1)

array.free(xs)
```

Rules:

- The runtime layout is `{ data, len, cap, elem_size }`.
- `array.new([]T, cap)` creates a mutable runtime slice with length `0`.
- `array.append(xs, value)` returns the updated slice. Reassign it to the
  original variable.
- `array.get` and `array.set` abort on out-of-bounds access.
- Every `array.new` result must be released with `array.free`.
- Nested arrays are written as `[][]T`. Free every inner array before freeing
  the outer array.
- `for value in xs` iterates array values.
- `std/array` is an YCPL source module whose public APIs are intrinsic
  declarations backed by the compiler/runtime array layout.
- Using a slice after `array.free` is undefined behavior in v1.2.

## mem

```YCPL
import "std/mem" as mem

size := mem.sizeof(i32)
ptr := mem.alloc(size)
ptr = mem.realloc(ptr, size * 2)
mem.set(ptr, 0, size * 2)
mem.free(ptr)
```

APIs:

```text
mem.alloc(size)
mem.calloc(count, size)
mem.realloc(ptr, size)
mem.free(ptr)
mem.copy(dst, src, size)
mem.set(dst, value, size)
mem.sizeof(Type)
```

Size arguments use `i64` internally. Memory returned by `alloc`, `calloc`, or
`realloc` must be released with `mem.free`. `alloc`, `calloc`, `realloc`,
`free`, `copy`, and `set` are YCPL wrappers around `extern fn` declarations;
`sizeof(Type)` remains an intrinsic because it depends on compiler type layout.

## str

```YCPL
import "std/str" as str

len := str.len("hello")
same := str.eq("a", "a")
order := str.cmp("a", "b")
dst := str.copy(buffer, "text")
```

Strings are C strings (`*i8`). `str.len`, `str.cmp`, and `str.copy` are YCPL
wrappers around C string functions. `str.eq` is implemented in YCPL and returns
`1` for equal strings and `0` otherwise.

## math

```YCPL
import "std/math" as math

absolute := math.abs(-7)
root := math.sqrt(9.0)
power := math.pow(2.0, 3.0)
s := math.sin(0.0)
c := math.cos(0.0)
```

`math.abs` is implemented in YCPL for `i32`. `math.pow`, `math.sin`,
`math.cos`, and `math.sqrt` are YCPL wrappers around C math functions. When
linking generated object files manually, pass `-lm` to `clang`.

## io

```YCPL
import "std/io" as io

buf: string := io.read_stdin_all(4096)
io.write_str(1, buf)
io.send_lsp_body("{\"jsonrpc\":\"2.0\"}")
```

`std/io` wraps fd-based `read` and `write` and provides helpers for raw stdout
and LSP `Content-Length` body framing.

## fs

```YCPL
import "std/fs" as fs

if fs.exists("examples/01_hello.ec") {
    text := fs.read_file("examples/01_hello.ec")
}
```

`std/fs` currently provides small fixed-buffer helpers for LSP/editor tooling.

## text

```YCPL
import "std/text" as text

idx := text.find("hello YCPL", "YCPL")
ok := text.starts_with("Content-Length", "Content")
line := text.line_of_offset("a\nb", 2)
```

`std/text` provides LSP-oriented string search, line/column conversion, and
simple buffer helpers. UTF-16 conversion is ASCII-compatible in v1.3.

## json

```YCPL
import "std/json" as json

value := json.parse("{\"id\":42,\"ok\":true,\"name\":\"YCPL\"}")
id := json.get_i32(value, "id")
name := json.get_string(value, "name")
json.free(value)
```

`std/json` provides a tagged `JsonValue` view API plus JSON-RPC helpers used by
the YCPL LSP. The main APIs are:

```text
json.parse(text)
json.stringify(value)
json.kind(value)
json.get(value, key)
json.get_string(value, key)
json.get_i32(value, key)
json.get_bool(value, key)
json.at(value, index)
json.len(value)
json.free(value)
```

`json.parse` owns a copy of the source text. Release that root value with
`json.free`. Values returned by `get` and `at` are non-owning views into the
same source. Strings returned by `get_string` are allocated and should be
released with `mem.free`.

The LSP helper layer remains available:

```text
json.field_string(message, "\"name\"")
json.field_i32(message, "\"id\"")
json.id_i32(message)
json.method_name_is(message, "initialize")
json.content_length_at(message, offset)
```

Returned strings from `field_string` are also allocated and should be released
with `mem.free` when they are not stored elsewhere.

## map

```YCPL
import "std/array" as array
import "std/map" as map

keys := array.new([]string, 2)
values := array.new([]string, 2)
keys = array.append(keys, none)
values = array.append(values, none)
map.put(keys, values, "uri", "file:///main.ec")
text := map.get(keys, values, "uri")
map.free(keys, values)
```

`std/map` is a caller-owned linear map built from parallel arrays. It provides
`find`, `has`, `get`, `put`, `remove`, `get_i32`, and `put_i32`. For fixed-size
stores, pre-fill `keys` and `values` with `none` slots and update them with
`map.put`. YCPL functions returning runtime slices are intentionally avoided in
v1.3.

## extern and intrinsic in std

`extern fn` declarations are bodyless and may map an YCPL name to a C/LLVM
symbol:

```YCPL
extern fn c_strlen(s string) i64 as "strlen"
```

`intrinsic fn` declarations are bodyless standard-library bridge declarations:

```YCPL
pub intrinsic fn sizeof(typ Type) i64
```

`intrinsic fn` is rejected outside bundled `std` modules. It is not a general
user extension mechanism.
