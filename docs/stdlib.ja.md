# YCPL 標準ライブラリ

[English](stdlib.en.md) | [Docs index](README.ja.md)

標準ライブラリは `stl/std` 配下の YCPL ソースです。一部の低レベル API は
`intrinsic fn` として宣言され、compiler/runtime bridge で実装されます。

```mermaid
flowchart TD
    STL["stl/std/*.yc"] --> Source["YCPL source wrappers"]
    STL --> Intrinsic["intrinsic declarations"]
    Source --> LLVM["通常の module codegen"]
    Intrinsic --> Bridge["compiler/runtime bridge"]
```

## モジュール地図

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

## よく使う流れ

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

## メモリ所有

```mermaid
flowchart TD
    Alloc["array.new / mem.alloc / json.parse"] --> Own["caller owns root value"]
    Own --> Use["use API"]
    Use --> Release["array.free / mem.free / json.free"]
    View["json.get / json.at"] --> Borrow["non-owning view"]
```

`extern fn` は YCPL 名を C/LLVM symbol に対応させます。`intrinsic fn` は bundled
`std` 専用で、user module では拒否されます。
