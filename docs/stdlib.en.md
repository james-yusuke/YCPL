# YCPL Standard Library

[Japanese](stdlib.ja.md) | [Docs index](README.en.md)

The standard library is stored as YCPL source under `stl/std`. Some low-level
APIs are declared as `intrinsic fn` and implemented by compiler/runtime bridge
code.

```mermaid
flowchart TD
    STL["stl/std/*.yc"] --> Source["YCPL source wrappers"]
    STL --> Intrinsic["intrinsic declarations"]
    Source --> LLVM["normal module codegen"]
    Intrinsic --> Bridge["compiler/runtime bridge"]
```

## Module Map

```mermaid
mindmap
  root((std))
    fmt
      print
      println
      printf
    array
      new
      append
      get/set
      free
    mem
      alloc
      copy
      sizeof
    str
      len
      eq
      cmp
    math
      abs
      sqrt
      pow
    io
      read/write
      LSP frames
    fs
      exists
      read_file
    text
      find
      offsets
    json
      parse
      get
      stringify
    map
      caller-owned arrays
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

## Common Flows

```mermaid
flowchart LR
    Print["fmt.println(value)"] --> Out["stdout"]
    ArrayNew["array.new([]T, cap)"] --> Slice["{data,len,cap,elem_size}"]
    Slice --> Append["array.append"]
    Slice --> Free["array.free"]
    JsonParse["json.parse(text)"] --> View["JsonValue views"]
    View --> JsonFree["json.free(root)"]
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

```mermaid
flowchart TD
    Alloc["array.new / mem.alloc / json.parse"] --> Own["caller owns root value"]
    Own --> Use["use API"]
    Use --> Release["array.free / mem.free / json.free"]
    View["json.get / json.at"] --> Borrow["non-owning view"]
```

`extern fn` maps YCPL names to C/LLVM symbols. `intrinsic fn` is reserved for
bundled `std` modules and is rejected in user modules.
