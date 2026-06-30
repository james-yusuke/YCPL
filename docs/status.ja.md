# 実装状況

[English](status.en.md) | [Docs index](README.ja.md)

```mermaid
flowchart LR
    Feature["Feature"] --> Stable["examples で安定扱い"]
    Feature --> Experimental["実験中"]
    Feature --> Reserved["予約済み、未実装"]
```

## examples で安定扱い

```mermaid
mindmap
  root((stable))
    source
      yc extension
      YCPL.json
    modules
      module/package
      import as alias
      pub visibility
    functions
      fn
      extern fn
      main
    data
      structs
      pointers
      slices
      none
    flow
      if/else
      for
      for-in
      break/continue
    std
      fmt
      array
      mem
      str
      math
      io/fs/text/json/map
    tooling
      examples
      YCPL LSP v0.4
```

## 実験中

```mermaid
flowchart TD
    Exp["Experimental"] --> Intrinsic["bundled std の intrinsic fn"]
    Exp --> Sprintf["sprintf"]
    Exp --> Cast["cast"]
    Exp --> New["new([]T)"]
    Exp --> Variadic["user-defined variadic functions"]
    Exp --> PointerHeavy["pointer-heavy expressions"]
    Exp --> InlineStructs["nested/inline structs"]
    Exp --> SliceReturns["runtime slice returns"]
    Exp --> BroadFFI["broad C/Unix FFI"]
```

## 予約済みだが未実装

```text
enum interface match is go defer select switch or type importas
```

```mermaid
flowchart LR
    Reserved["reserved token"] --> Reason["将来構文との衝突を防ぐ"]
    Reserved --> NoParser["parser/codegen support は未実装"]
```

`none` は optional type ではなく null literal です。import した関数の直接呼びは
拒否されます。LSP navigation は現在、full project index ではなく開いている
document を走査します。
