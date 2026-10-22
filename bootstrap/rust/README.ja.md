# Rust 版 bootstrap

[English](README.md)

独立した YCPL seed コンパイラです。Rust が字句解析・構文解析・名前解決・
型チェック・ownership・LLVM 命令の選択を担当します。C++ ラッパーは LLVM
ヘッダーを include し、`cxx` を通して検証付きの操作を提供します。
生成したプログラムは既存の C managed runtime と STL を共有します。

## ビルド・実行

Rust **1.97.1**／edition 2024、LLVM **22**、C++20 コンパイラ、`llc`、`clang` が
必要です。`cxx`・`cxx-build`・Bazel の `cxxbridge-cmd` は **1.0.205**、
`rules_rust` は **0.74.0** に固定しています。Cargo と Bazel はアプリケーションの
manifest・lockfile を共有し、Bazel はブリッジと C++ ソースを直接ビルドします。

リポジトリのルートで実行してください。

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
cargo build --manifest-path bootstrap/rust/Cargo.toml --release --locked
bootstrap/rust/target/release/ycc-bootstrap-rust run examples/basics/hello.yc -o build/rust-hello

bazel build //:ycc-bootstrap-rust
bazel-bin/bootstrap/rust/ycc-bootstrap-rust build examples/basics/hello.yc -o build/rust-hello
build/rust-hello/merged
```

`build`・`build-ir`（`ll` alias）・`run`・`debug`・`lex`・`parse`・`check`・
`resolve`・`help` を提供します。`-o DIRECTORY`・`--keep-obj`・`--link-llvm`・
`--` 以降の実行引数に対応します。入力は `.yc` ファイル、ディレクトリ、
`YCPL.json` project です。出力先は `-o`、project の `output`、`build` の順です。
検証済み IR は `merged.ll`、実行ファイルは `merged`、単一ファイルでは共通
テスト互換の `<stem>.ll` も保存します。

`LLVM_CONFIG`・`LLVM_BINDIR`・`LLVM_DIR`・`LLC`・`CLANG`・`LINKFLAGS`・
`YCPL_STL_ROOT`・`YCPL_RUNTIME_SRC`・`YCPL_RUNTIME_LIB` を利用できます。
外部コマンドは引数配列で実行し、空白を含むパスにも対応します。
`LINKFLAGS` は引用符を解析しますが、シェル実行はしません。

## 最終動作確認・再検証

```sh
bootstrap/rust/verify.sh cargo
bootstrap/rust/verify.sh bazel
```

Cargo 経路は rustfmt・clang-format・Clippy、追加の Rust/native・CLI テスト、
既存 conformance 全件を確認します。続いて Rust seed → YCPL stage1 → stage2 →
stage3 を生成し、stage2・stage3 の両方で conformance を実行します。
固定点比較は既存 oracle と同じく LLVM 22 で assemble/disassemble した IR の
ModuleID・source filename だけを揃え、残りを完全一致比較します。

Bazel の公開ターゲットと個別テストは次のとおりです。

```sh
bazel build //:ycc-stage1-from-rust //:ycc-stage2-from-rust //:ycc-stage3-from-rust
bazel test //bootstrap/rust:unit_tests //bootstrap/rust:cli_test \
  //:rust_conformance_test //:rust_self_host_test
```

共通 harness が一時ファイル名を共有するため、conformance・固定点の Bazel
テストは `exclusive` にしています。Cargo と Bazel の検証も順番に実行してください。
従来の C++ seed と標準 `//:ycc` の生成経路は引き続き利用できます。
CI は macOS・Ubuntu 24.04 の両方で Cargo／Bazel を検証します。

ソースは frontend、project loader、型解決、式・制御フロー・コレクション・
ownership の lowering、LLVM ブリッジに分割しています。AST は動的 arena と ID、
LLVM ハンドルは session ID・種類・index で管理し、別 module・破棄済み session・
種類の異なるハンドルを `Result` のエラーとして扱います。
成果物・生成された FFI ファイルはコミット対象外です。
