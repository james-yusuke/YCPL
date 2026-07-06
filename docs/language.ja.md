# YCPL 言語構文

[English](language.en.md) | [Docs index](README.ja.md)

```text
.yc ファイル
├─ 任意の module/package 宣言
├─ imports
├─ functions, structs, externs, intrinsics
└─ fn main() entry
```

## ソースファイル

| ルール | 現在の対応 |
|---|---|
| 拡張子 | `.yc` |
| 文の区切り | 改行 |
| コメント | `// line`、ネスト可能な `/* block */` |
| トップレベル実行文 | codegen で拒否 |

```text
fn main() { ... }       -> 実行コードを置ける
トップレベル文          -> codegen が拒否
```

## 識別子とキーワード

識別子は英字または `_` で始まり、英字、数字、`_` を続けられます。

```text
module package import pub extern intrinsic fn struct const
if else for in return break continue as
true false none byte
```

`enum`、`match`、`switch`、`or`、`type` などの予約語は、まだ対応済みの構文ではありません。
詳細は [実装状況](status.ja.md#予約済みだが未実装) にまとめています。

## モジュールと import

```text
module math.basic
    |
    v
pub fn square
    |
    v
import "math/basic" as math
    |
    v
math.square(5)
```

```YCPL
module math.basic

pub fn square(x i32) i32 {
    return x * x
}
```

```YCPL
import "math/basic" as math

fn main() {
    result := math.square(5)
}
```

import した関数は alias 経由で呼びます。同じモジュール内の関数は直接呼べます。
`pub fn` と `pub struct` は外部モジュールから見えます。

## 関数

```text
fn name(param Type, other Type) ReturnType {
    statements
}
```

```YCPL
pub fn add(a i32, b i32) i32 {
    return a + b
}

extern fn c_strlen(s string) i64 as "strlen"
```

`intrinsic fn` は bundled `std` モジュール内だけで受け付けます。

## 型

```text
Types
├─ primitive: i32 i64 bool char byte string float double void size_t
├─ pointer:   *T
├─ slice:     []T
└─ nested:    [][]T
```

runtime slice は `{ data, len, cap, elem_size }` です。`std/array` で作った
slice は手動で管理します。

## 変数とリテラル

```text
name := value          推論された mutable binding
name: Type := value    明示型の mutable binding
const name := value    immutable binding
name = value           既存 binding への代入
```

```YCPL
count := 10
name: string := "YCPL"
const label: string := "stable"
```

整数、浮動小数、char、string、raw string、bool、`none`、array、byte array を
リテラルとして扱えます。

## 演算子と制御構文

```text
高い優先順位
  call, index, member, ++, --
  !, -, +, ++, --, *, &
  *, /, %, +, -, shifts, comparisons, ==, !=
  &&, ||
低い優先順位
```

```YCPL
if score >= 80 {
    println("pass")
} else {
    println("retry")
}

for i := 0; i < 10; i++ {
    println(i)
}

for value in xs {
    println(value)
}
```
