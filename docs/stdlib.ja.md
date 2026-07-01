# YCPL 標準ライブラリ

[English](stdlib.en.md) | [Docs index](README.ja.md)

標準ライブラリは `stl/std` 配下の YCPL ソースです。一部の低レベル API は
`intrinsic fn` として宣言され、compiler/runtime bridge で実装されます。

```text
stl/std/*.yc
├─ YCPL source wrappers   -> 通常の module codegen
└─ intrinsic declarations -> compiler/runtime bridge
```

## モジュール地図

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

## よく使う流れ

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

## メモリ所有

```text
array.new / mem.alloc / json.parse
    -> caller owns root value
    -> array.free / mem.free / json.free で解放

json.get / json.at
    -> non-owning views
```

`extern fn` は YCPL 名を C/LLVM symbol に対応させます。`intrinsic fn` は bundled
`std` 専用で、user module では拒否されます。

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

生成 IR が `LLVM...` の C API symbol を参照する場合、`ycc build` は LLVM を自動 link
します。LLVM prefix を選ぶ場合は `/usr` に symlink を作らず
`LLVM_CONFIG=/path/to/llvm-config` を指定します。
