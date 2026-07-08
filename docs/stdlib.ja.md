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
├─ array  new, append, get, set, free 互換
├─ mem    managed alloc, copy, sizeof
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
└─ unsafe/mem FFI 専用 raw C malloc/calloc/realloc/free
```

## std2 実験ライブラリ

`stl/std2/<module>/index.yc` には、Go の `src/fmt` のようなフォルダ版 standard
library 候補を置いています。既存の `stl/std` とは分離されています。
`std2/base32`、`std2/base64`、`std2/bytes`、`std2/hex`、`std2/hash` などを
`import "std2/base32" as base32` の形で使えます。
`std2/map` は `std/map` のフォルダ版 counterpart で、今後の
`Map<string, T>` runtime helper を追加する場所です。

```YCPL
b: owned Bytes := bytes.from_string("YCPL")

encoded := base32.encode(b)
decoded := base32.decode(encoded)

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
| `std/unsafe/mem` | `stl/std/unsafe/mem.yc` |
| `std2/map` | `stl/std2/map/index.yc` |
| `std2/unsafe/mem` | `stl/std2/unsafe/mem/index.yc` |
| `std/bytes` | `stl/std/bytes.yc` |
| `std/hex` | `stl/std/hex.yc` |
| `std/base64` | `stl/std/base64.yc` |
| `std/hash` | `stl/std/hash.yc` |
| `std/llvm` | `stl/std/llvm.yc` |

## よく使う流れ

```text
fmt.println(value) -> stdout

array.new([]T, cap)
    -> { data, len, cap, elem_size }
    -> array.append / array.get / array.set
    -> YCPL runtime 管理。array.free は互換 release として残す

json.parse(text)
    -> JsonValue root
    -> json.get / json.at views
    -> managed allocation foundation。json.free は互換として残す

bytes.from_string(text)
    -> Bytes { data, len, cap, owns }
    -> bytes.to_string / bytes.byte_to_string
    -> hex.encode / base64.encode / hash.crc32
    -> YCPL runtime 管理。bytes.free は互換として残す

map.new_i32(cap) / map.new_string(cap)
    -> Map<string, i32> / Map<string, string> runtime handle
    -> map.put_i32_value / map.get_i32_value / map.remove_i32_value
    -> map.put_string_value / map.get_string_value / map.remove_string_value
    -> YCPL runtime 管理。map.free_i32 / map.free_string は互換として残す
```

```YCPL
import "std/fmt" as fmt
import "std/array" as array
import "std2/map" as map

fn main() {
    xs := array.new([]i32, 1)
    xs = array.append(xs, 10)
    fmt.println(array.get(xs, 0))

    counts := map.new_i32(4)
    map.put_i32_value(counts, "parser", 12)
    fmt.println(map.get_i32_value(counts, "parser", 0))
}
```

## メモリ所有

```text
array.new / mem.alloc / json.parse / bytes.from_string / map.new_*
    -> static link される YCPL runtime 経由で確保
    -> 所有している function frame の終了時に解放
    -> return される managed root は caller frame へ移動
    -> array header は backing data を、map handle は key/value arrays を解放

json.get / json.at
    -> non-owning views

array.free / mem.free / bytes.free / json.free / map.free_*
    -> 旧コード移行用の yc_release compatibility wrapper

std/unsafe/mem と std2/unsafe/mem
    -> FFI 境界だけで使う raw C malloc/calloc/realloc/free
```

`ycc build` は `bootstrap/cpp/runtime/yc_runtime.c` を各 native binary に
static link します。runtime は `yc_runtime_init`、`yc_runtime_shutdown`、
`yc_frame_push`、`yc_frame_pop`、`yc_alloc`、`yc_calloc`、`yc_realloc`、
`yc_release`、`yc_move_to_parent` を提供します。この milestone では
background tracing GC は入れず、frame ownership による deterministic cleanup
へ寄せつつ、移行期間の manual-free 互換を残しています。managed root を返す場合は、
slice/map などの backing storage が caller で生きるよう、その frame の allocation を
保守的に caller frame へ移動します。
array と map の root は child allocation を登録するため、root を release すると
backing data / key-value arrays も release されます。

`extern fn` は YCPL 名を C/LLVM symbol に対応させます。`intrinsic fn` は bundled
`std` 専用で、user module では拒否されます。

`std/os` は compiler tooling に必要な最小限の process hook です。
`YCPL_BOOTSTRAP_YCC` のような明示的な tool path を読む `getenv` と、移行中の
`ycc-ycpl build` stage driver が使う `system` を提供します。

`std/bytes`、`std/hex`、`std/base64`、`std/hash` は zip などのファイル形式や
学習用暗号処理に向けた基盤です。`std/hash` の FNV-1a32 と CRC32 は検査・識別用で、
セキュリティ用途の暗号ハッシュではありません。

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
