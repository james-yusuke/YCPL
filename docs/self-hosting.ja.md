# セルフホストの検証

[English](self-hosting.en.md) | [Docs index](README.ja.md)

YCPLの標準コンパイラ`ycc`はYCPLで実装されています。C++版
`ycc-bootstrap`は初回seedとreference専用です。

## 生成チェーン

```text
ycc-bootstrap (C++)
    -> ycc-stage1 (YCPL)
    -> ycc-stage2 (YCPL)
    -> ycc-stage3 (YCPL)
    -> ycc
       └─ ycc-ycpl
```

stage1だけをC++版で生成します。stage2はstage1、stage3はstage2で生成されます。
標準`ycc`はstage3の成果物です。

## 推奨確認コマンド

LLVM 22を設定してから、Bazelに全stageを生成させます。

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"

bazel build \
  //:ycc-bootstrap \
  //:ycc-stage1 \
  //:ycc-stage2 \
  //:ycc-stage3 \
  //:ycc \
  //:ycc-ycpl

bazel test //:self_host_stage_test //:ycc_ycpl_test
bazel test //...
```

fixed-point testは次を確認します。

1. stage2とstage3でcompiler自身のLLVM IRを生成する。
2. LLVM 22の`llvm-as`と`llvm-dis`でcanonicalizeする。
3. ModuleIDとsource filenameだけを安定化して完全一致を比較する。
4. stage2とstage3の両方でhelloをbuild/runする。
5. 両compilerへ同じ拡張可能なconformance suiteを適用する。
6. promoted `ycc`にbootstrap/fallback経路の文字列が残っていないことを確認する。

## C++ bootstrapだけをbuildする

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
bazel build //:ycc-bootstrap
```

成果物は`bazel-bin/ycc-bootstrap`です。bootstrapからcompiler projectを手動生成する
場合は、`compiler/ycpl`をcurrent directoryにして実行します。

```sh
mkdir -p /tmp/ycpl-stage1

(
  cd compiler/ycpl
  ../../bazel-bin/ycc-bootstrap build -o /tmp/ycpl-stage1
)

/tmp/ycpl-stage1/ycc check compiler/ycpl
```

`ycc-bootstrap build compiler/ycpl ...`をrepository rootから直接実行する方法は、
bootstrap driverのproject current-directory規約と一致しないため使いません。

## YCPL compilerでYCPL programをbuildする

```sh
YCPL_STL_ROOT="$PWD/stl" \
YCPL_RUNTIME_SRC="$PWD/bootstrap/cpp/runtime/yc_runtime.c" \
/tmp/ycpl-stage1/ycc \
  build examples/basics/hello.yc -o /tmp/ycpl-hello

/tmp/ycpl-hello/merged
```

期待出力は`Hello World`です。通常は環境変数を手動指定せず、
`bazel-bin/ycc`またはBazel runfiles経由で実行できます。

```sh
bazel run //:ycc -- run examples/basics/hello.yc
```

## 個別のconformance確認

```sh
tests/run_conformance.sh ./bazel-bin/ycc
```

このharnessは任意のcompiler executableへ適用できます。positive、negative、
runtime、project/module、stdlib、`c/*` FFIを同じoracleで検査します。
