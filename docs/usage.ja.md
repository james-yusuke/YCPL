# YCPLの使い道とローカル検証

[English](usage.en.md) | [ドキュメント一覧](README.ja.md)

YCPLは、LLVM 22によるネイティブコード生成、managed runtime、標準ライブラリ、
セルフホストコンパイラ、LSPを一緒に試せる実験的な言語です。
最初の用途には、ローカルで使う小さなCLIやデータ変換ツールが適しています。

| 用途 | 使える実装 | 試す入口 |
|---|---|---|
| JSON設定の検査・集計 | `std/json`、`std/fs`、`std/text`、`Vec<T>` | `examples/stdlib/foundation.yc`、`json.yc` |
| テキスト・バイト列の変換 | UTF-8、hex、base32/base64、bytes | `examples/stdlib/encoding.yc`、`bytes_hex_hash.yc` |
| 複数ファイルのCLI | `YCPL.json`、module/import、引数付きprocess API | `examples/projects/module_project/`、`stl/std/os/index.yc` |
| コンパイラ・言語ツールの学習 | AST、型解決、LLVM lowering、固定点比較、LSP | `compiler/ycpl/`、`tools/lsp/` |

ネットワークサービスや本番運用を始める前に、必要なAPIと失敗時の動作を個別に
確認してください。現在はearly alphaで、互換性とメモリ安全性の保証は発展途上です。
`c/*`とraw pointerを使う部分にはCと同様の注意が必要です。

## 一括検証

LLVM 22、CMake、C/C++コンパイラ、Node.js、npm、Python 3が必要です。
初回のみ、エディタの依存をlockfileからインストールします。

```sh
npm ci --prefix editors/vscode/language-server
npm ci --prefix editors/vscode/extension
scripts/verify-local.sh
```

このスクリプトはCMakeでC++ seedをビルドし、ランタイムをAddressSanitizerと
UndefinedBehaviorSanitizerで検査します。続いてseedのconformance、stage1〜3の生成、
stage2/stage3のLLVM IR完全一致と両段階のconformance、LSPのテスト、VSIXの生成・検査、
最後にHello Worldの実行を確認します。Bazelの固定点テストと同じoracleを使用します。

デスクトップ環境で、生成したVSIXをVS Codeに読み込むテストも実行できます。
バージョンの解決やテスト用VS Codeのダウンロードにはネットワークが必要です。

```sh
YCPL_VERIFY_VSCODE_GUI=1 scripts/verify-local.sh
```

依存の既知脆弱性を再監査する場合は、ネットワーク接続のある環境で実行します。

```sh
npm audit --prefix editors/vscode/language-server
npm audit --prefix editors/vscode/extension
```

LinuxでのCIと同じlinker/POSIX設定は`.github/workflows/ci.yml`を参照してください。
`LLVM_CONFIG`、`CLANG`、`LLC`、`LINKFLAGS`の明示指定を引き継ぎます。

## 検証したコンパイラを使う

スクリプト完了後、セルフホスト版は`build/local-verification/stage3/merged`にあります。

```sh
build/local-verification/stage3/merged run examples/stdlib/foundation.yc -o build/demo-foundation
build/local-verification/stage3/merged run examples/stdlib/encoding.yc -o build/demo-encoding
build/local-verification/stage3/merged run examples/projects/module_project -o build/demo-modules
```

`scope name { ... }`は削除しました。通常の`{ ... }`ブロックへ置き換えてください。
`defer`とmanaged valueのブロック終了時の解放は利用できます。
具体例は`examples/basics/defer_blocks.yc`です。`scope`は変数名として使用できます。
