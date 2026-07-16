# YCPL 言語構文

[English](language.en.md) | [Docs index](README.ja.md)

```text
.yc ファイル
├─ 任意の module/package 宣言
├─ imports
├─ functions, structs, enums, type aliases, externs, intrinsics
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
module package import pub extern intrinsic fn struct enum type const owned
if else for in switch case default return break continue defer scope as
true false none byte
```

`case` と `default` は `switch` 本体のラベルとして使います。

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
├─ map slice: []Map<string, T>
├─ owned:     owned T
├─ map:       Map<string, T>
├─ alias:     type Score = i32
├─ enum:      enum Color { Red, Green }
└─ nested:    [][]T
```

runtime slice は `{ data, len, cap, elem_size }` です。`std/array`、
`std/mem`、`std/bytes`、`std/json`、`std/map` で作った値は static link される
YCPL runtime 経由で確保します。古い free helper は deterministic frame cleanup
後に残る precise destructor 完成までの互換 release として残します。
`owned T`は所有値の意図を示す型修飾子として受け付け、現時点ではABI上は`T`と
同じです。
`Map<string, T>`はmap handle型として受け付けます。現在のABIでは
opaque pointerにlowerされ、実ストレージは`std/map`のruntime-backed
key/value arrays APIを使います。

```YCPL
enum Color {
    Red = 2,
    Green,
    Blue = 8,
}

type Score = i32
type Symbols = Map<string, i32>
```

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

switch color {
    case Color.Red {
        println("red")
    }
    case Green {
        println("green")
    }
    default {
        println("other")
    }
}
```

`switch`は`switch expression { case expression { ... } default { ... } }`の形です。
selectorとcase expressionはresolver/type checkerで解決され、LLVM backendへ
lowerされます。

## defer、scope、UFCS

標準の`ycc`は`defer`文をサポートします。`defer expr`または
`defer { ... }`は現在のscopeまたは関数を抜ける際にLIFO順で実行されます。

```YCPL
defer fmt.println("leaving scope")
```

`scope name { ... }` は名前付きの lexical scope です。局所的な作業領域を明示したい
時に使えます。

import 済み module に同名の public function が 1 つだけある場合、`value.method(x)` は
`module.method(value, x)` として扱われます。managed value は runtime frame が所有するため、
解放処理を `defer` する必要はありません。
