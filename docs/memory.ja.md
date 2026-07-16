# Vecとメモリ所有

[English](memory.en.md) | [Docs index](README.ja.md)

YCPLの通常コードでは、可変長配列に`Vec<T>`、非拡張の参照範囲に`[]T`を使います。
`malloc`、`calloc`、`realloc`、`free`は言語の通常コンテナAPIではなく、
runtimeまたは明示的なC/unsafe境界の実装詳細です。

## Vecとslice

| 型 | 意味 | 拡張 | 所有 |
|---|---|---|---|
| `Vec<T>` | managed dynamic array handle | `push`、`reserve`可 | headerがbacking storageを所有 |
| `[]T` | 要素範囲のview | 不可 | 通常は元の値を参照 |
| `*T` | raw pointer | コンテナ操作なし | 自動的な安全性を付与しない |

```YCPL
values := Vec<i32>{capacity: 8}
values.push(10)
values.push(20)

alias := values
alias[0] = 11

view := values.as_slice()
println(view[0]) // 11
```

Vecのコピーは同じmanaged handleを共有します。value copyによるdeep copyでは
ありません。`as_slice()`も要素を複製せず、同じbacking storageへのviewを返します。

## 公開操作

```YCPL
index := values.push(value)
length := values.len()
capacity := values.capacity()

values.reserve(1024)
values.clear()

value := values[index]
values[index] = value
view := values.as_slice()
```

- `push`は挿入前のindexを`i32`で返します。
- `reserve`はlengthを変えず、必要なら容量だけを増やします。
- `clear`はmanaged要素をreleaseしてlengthを0にします。
- index read/writeはbounds checkされます。
- managed要素のpush、上書き、clearではownership graphをattach/replace/releaseします。
- nested Vecもmanaged要素として扱います。

負のcapacity、capacity計算overflow、範囲外indexは診断後にabortします。
公開APIには`free`、raw backing pointer、暗黙の`Vec<T> -> *T`変換はありません。

## Runtime ownership

native binaryには`bootstrap/cpp/runtime/yc_runtime.c`がstatic linkされます。
runtimeはfunction/scopeごとのframeでmanaged allocationを追跡し、scopeを抜ける時に
決定的にreleaseします。

```text
function entry
    -> frame push
    -> Vec headerとbacking storageを登録
    -> child managed valueをownership graphへattach
return / scope exit
    -> escapeするrootをcallerへ移動
    -> 残りをLIFO unwind
    -> frame pop
```

Vecをreturnした場合、container rootと到達可能なbacking storage・managed childが
caller frameへ移動します。無関係なlocal allocationはcallee frameに残ります。

## Cとunsafeの境界

- `stl/c/*`: C、POSIX、LLVMのraw ABI宣言。
- `stl/std/*`: 言語レベルの標準API。
- `std/unsafe/mem`: raw allocationを明示的に使う互換wrapper。
- `compiler/ycpl`: `std/mem`を直接importせず、可変長データに`Vec<T>`を使う。
- `c/llvm`: LLVMへ連続参照列を渡す専用bridgeだけがVecの内部dataへ触れる。

FFIが要求する場合を除き、YCPLプログラムからraw allocatorを呼ぶ必要はありません。
一般のデータ構造には`Vec<T>`、文字列構築には`std/text`、binary bufferには
`std/bytes`を使います。
