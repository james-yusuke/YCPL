# YCPL 標準ライブラリ

[English](stdlib.en.md) | [Docs index](README.ja.md)

標準ライブラリは `stl/std` 配下の YCPL ソースです。一部の低レベル API は
`intrinsic fn` として宣言され、compiler/runtime bridge で実装されます。

```text
stl/std/<module>/index.yc
├─ YCPL source wrappers   -> 通常の module codegen
├─ intrinsic declarations -> compiler/runtime bridge
└─ unsafe/mem             -> FFI 境界用 raw C allocation
```

## モジュール地図

```text
std/
├─ fmt    print, println, printf
├─ array  make, push, get, set, free 互換
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

## フォルダ構成

`stl/std/<module>/index.yc` が標準ライブラリの本線です。Go の `src/fmt`
のような形で、`std/base32`、`std/base64`、`std/bytes`、`std/hex`、
`std/hash` などを `import "std/base32" as base32` の形で使えます。
raw C allocation は `std/unsafe/mem` だけに置き、通常の container/buffer は
YCPL runtime allocator を使います。

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

## よく使う流れ

```text
fmt.println(value) -> stdout

array.make([]T)
    -> { data, len, cap, elem_size }
    -> array.push / array.get / array.set
    -> YCPL runtime 管理

text.concat / text.join / text.repeat
    -> managed StringBuilder を隠した high-level string construction

json.parse(text)
    -> JsonValue { root, source, range, owns }
    -> json.get / json.at views
    -> managed allocation foundation

bytes.from_string(text)
    -> Bytes { root, data, len, cap, owns }
    -> bytes.to_string / bytes.byte_to_string
    -> hex.encode / base64.encode / hash.crc32
    -> YCPL runtime 管理

map.make_i32(cap) / map.make_string(cap)
    -> Map<string, i32> / Map<string, string> runtime handle
    -> map.set_i32 / map.get_i32_or / map.delete_i32
    -> map.set_string / map.get_string / map.delete_string
    -> YCPL runtime 管理
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

## メモリ所有

```text
array.make / json.parse / bytes.from_string / map.make_*
    -> static link される YCPL runtime 経由で確保
    -> 所有している function frame の終了時に解放
    -> return される managed root は caller frame へ移動
    -> array header は backing data を、map handle は key/value arrays を解放

json.get / json.at
    -> non-owning views

std/unsafe/mem
    -> FFI 境界だけで使う raw C malloc/calloc/realloc/free
```

`ycc build` は `bootstrap/cpp/runtime/yc_runtime.c` を各 native binary に
static link します。runtime は `yc_runtime_init`、`yc_runtime_shutdown`、
`yc_frame_push`、`yc_frame_pop`、`yc_alloc`、`yc_calloc`、`yc_realloc`、
`yc_release`、`yc_move_to_parent`、`yc_move_to_ancestor` を提供します。この milestone では
background tracing GC は入れず、frame ownership による deterministic cleanup
を行います。managed value が escape する場合は、その ownership root と到達可能な
child だけを caller frame へ移し、無関係な local allocation は callee frame に残します。
array、map、Bytes、StringBuilder、JsonValue の root と backing allocation は同じ
ownership graph で管理されます。

pointer returnとaggregate returnは、callee frameをpopする前に到達可能なmanaged
valueをcallerへescapeさせます。scope assignmentとbreak/continue/return pathでは、
対応する決定的なframe unwindを生成します。

`extern fn` は YCPL 名を C/LLVM symbol に対応させます。`intrinsic fn` は bundled
`std` 専用で、user module では拒否されます。

`std/os`はcompiler toolingに必要な最小限のprocess hookです。明示的な
LLVM/runtime pathとnative build/run process executionを提供します。
self-hosted driverにbootstrap compiler fallbackはありません。

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
