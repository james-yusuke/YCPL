# 実装状況

[English](status.en.md) | [Docs index](README.ja.md)

```text
Feature status
├─ examples で安定扱い
├─ 実験中
└─ 予約済み、未実装
```

## examples で安定扱い

```text
stable
├─ source: yc extension, YCPL.json
├─ modules: module/package, import as alias, pub visibility
├─ functions: fn, extern fn, main
├─ data: structs, pointers, slices, none
├─ flow: if/else, for, for-in, break/continue
├─ std: fmt, array, mem, str, math, io, fs, text, json, map
└─ tooling: examples, YCPL LSP v0.4
```

## 実験中

```text
experimental
├─ bundled std の intrinsic fn
├─ sprintf
├─ cast
├─ new([]T)
├─ user-defined variadic functions
├─ pointer-heavy expressions
├─ nested/inline structs
├─ runtime slice returns
└─ broad C/Unix FFI
```

## 予約済みだが未実装

```text
enum interface match is go defer select switch or type importas
```

```text
reserved token
├─ 将来構文との衝突を防ぐ
└─ parser/codegen support は未実装
```

`none` は optional type ではなく null literal です。import した関数の直接呼びは
拒否されます。LSP navigation は現在、full project index ではなく開いている
document を走査します。
