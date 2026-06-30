# YCPL 言語構文

[English](language.en.md) | [Docs index](README.ja.md)

```mermaid
flowchart TD
    File[".yc ファイル"] --> OptionalModule["任意の module/package"]
    OptionalModule --> Imports["imports"]
    Imports --> Decls["functions, structs, externs, intrinsics"]
    Decls --> Main["fn main() entry"]
```

## ソースファイル

| ルール | 現在の対応 |
|---|---|
| 拡張子 | `.yc` |
| 文の区切り | 改行 |
| コメント | `// line`、ネスト可能な `/* block */` |
| トップレベル実行文 | codegen で拒否 |

```mermaid
flowchart LR
    Good["fn main() { ... }"] --> OK["実行コードを置ける"]
    Bad["トップレベル文"] --> Reject["codegen が拒否"]
```

## 識別子とキーワード

識別子は英字または `_` で始まり、英字、数字、`_` を続けられます。

```text
module package import pub extern intrinsic fn struct enum interface const mut
if else match for in return break continue as is go defer select switch
true false none or type importas byte
```

## モジュールと import

```mermaid
flowchart LR
    Import["import \"math/basic\" as math"] --> Alias["math"]
    Alias --> Call["math.square(5)"]
    Module["module math.basic"] --> Export["pub fn square"]
    Export --> Call
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

```mermaid
flowchart LR
    Name["fn name"] --> Params["(param Type)"]
    Params --> Return["ReturnType または void"]
    Return --> Body["{ statements }"]
```

```YCPL
pub fn add(a i32, b i32) i32 {
    return a + b
}

extern fn c_strlen(s string) i64 as "strlen"
```

`intrinsic fn` は bundled `std` モジュール内だけで受け付けます。

## 型

```mermaid
flowchart TD
    Types["Types"] --> Primitive["i32 i64 bool char byte string float double void size_t"]
    Types --> Pointer["*T"]
    Types --> Slice["[]T"]
    Slice --> Nested["[][]T"]
    String["string"] --> CString["C string pointer"]
```

runtime slice は `{ data, len, cap, elem_size }` です。`std/array` で作った
slice は手動で管理します。

## 変数とリテラル

```mermaid
flowchart LR
    Infer["name := value"] --> Mutable["デフォルト mutable"]
    Explicit["name: Type := value"] --> Mutable
    Const["const name := value"] --> Immutable["binding immutable"]
    Assign["name = value"] --> Existing["既存変数"]
```

```YCPL
count := 10
name: string := "YCPL"
const label: string := "stable"
```

整数、浮動小数、char、string、raw string、bool、`none`、array、byte array を
リテラルとして扱えます。

## 演算子と制御構文

```mermaid
flowchart TD
    Expr["Expression"] --> Postfix["call, index, member, ++, --"]
    Expr --> Unary["!, -, +, ++, --, *, &"]
    Expr --> Binary["*, /, %, +, -, shifts, comparisons, ==, !="]
    Expr --> Logical["&&, ||"]
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
