# VS Code での YCPL 開発

[English](../editors/vscode/extension/README.md)

0.4 では編集支援、ビルドタスク、Test Explorer、カバレッジ、ネイティブデバッグ、
プロファイルを利用できます。LLVM 22 とセルフホスト版 `ycc` が必要です。
`YCPL.compiler.path` に実行ファイルを指定し、別リポジトリから使う場合は
`YCPL.stlRoot`、`YCPL.runtimeSource` も設定してください。
**YCPL: Show Environment** で選択されたパスを確認できます。

## 編集とプロジェクト

既定は VSIX 同梱の TypeScript LSP です。`YCPL.server.mode` を `auto` にすると
設定・ワークスペース・PATH の順に native LSP を探し、初期化できなければ同梱版を
使います。`native` は YCPL 製 LSP を必須にします。高度な抽出・import のコード
アクションは TypeScript 版で利用してください。ステータスバーに動作中のサーバーを表示します。

| 分野 | 利用できる機能 |
|---|---|
| 入力 | 補完、stdlib の自動 import、引数ヘルプ、ホバー、スニペット、意味に応じた色分け |
| 移動 | 定義・宣言・型定義、参照、名前変更、シンボル検索、呼び出し階層、参照レンズ |
| 整形 | ファイル・選択範囲・保存時の整形。raw string、文字リテラル、ネストしたコメントを保持 |
| import | 追加、並べ替え、未使用 alias の削除、保存時の整理。付随コメント・副作用用 import を保持 |
| リファクタリング | 変数・関数への抽出、定数リテラルのインライン化、空の構造体の基本型フィールド補完 |
| 診断 | 編集中の構文診断、保存・Check 時の実コンパイラ診断、タスクの問題マッチャー |
| プロジェクト | 新規作成、ローカル playground、YCPL.json の補完・検証、複数ルート、ビルドタスク |
| テスト生成 | 公開関数用の TODO テスト生成、実装とテストファイルの切り替え |

抽出は制御フローの脱出やローカル変数の escape がある場合には提供しません。
関数抽出のキャプチャはポインターを使い、書き込みを元の変数に反映します。
名前変更は予約語・不正な識別子・衝突を拒否します。Go の interface 実装生成、
struct tag の書き換え、Go module の脆弱性データベースに対応する YCPL の言語・
パッケージ機構は現在ありません。

通常の出力は `.ycpl/build` です。`YCPL.outputDirectory` で変更できます。
親の `YCPL.json` があればプロジェクト単位で実行します。**Open Local Playground** は
`.ycpl/playground` に独立したソースを作るため、既存プロジェクト内でも試せます。
**Run** は生成バイナリをターミナルで直接起動し、対話入力に対応します。
`YCPL.run.arguments` の各要素はシェル展開せず、そのまま渡します。
コンパイラ・テスト・プロファイルの実行にはワークスペースの信頼が必要です。

## テストと計測

`*_test.yc` に次の公開関数を置くと Test Explorer に表示します。

```yc
import "./math.yc" as math

pub fn test_add() bool { return math.add(20, 22) == 42 }
pub fn benchmark_add() bool { return math.add(1, 2) == 3 }
pub fn fuzz_identity(seed i32) bool { return math.add(seed, 0) == seed }
```

Run・Debug・Coverage のプロファイル、ワークスペース・ファイル・カーソル位置の
テスト実行、Run Test レンズに対応します。true は成功、false は失敗、ビルド失敗は
エラー、キャンセルはスキップとして表示します。生成した TODO テストは false を返すので、
未実装のテストが成功したように見えることはありません。

ベンチマークの反復数は `YCPL.testing.benchmarkIterations` で設定します。
計測値にはプロセス起動時間も含まれます。`fuzz_*` は i32 の連続した seed を渡す
再現可能なプロパティテストです。`fuzzIterations` と `fuzzStartSeed` で範囲を指定し、
失敗時に表示した seed から再実行できます。coverage に応じた入力変異・最小化・
他の型の自動入力生成は行いません。

カバレッジは LLVM GCOV の計測コードから取得した実行行数を使い、import 先の
ワークスペース内ヘルパーも表示対象にします。LLVM 22 の `opt`、`clang`、
`llvm-cov` と clang の profile runtime が必要です。Ubuntu のセットアップスクリプトは
`libclang-rt-22-dev` も導入します。

## デバッグ

F5、**Debug Current File or Project**、**Debug Test at Cursor**、Test Explorer の
Debug は LLVM 22 以降の `lldb-dap` を使います。見つからなければ
`YCPL.debug.adapterPath` を指定してください。`ycc -g` が DWARF と最適化を抑えた
コードを生成し、ソースのブレークポイント、ステップ実行、スタック、引数・ローカル変数を
表示できます。構造体にはフィールド情報を付けます。再帰型や managed container の
表示は現状の内部ハンドルに基づき、Go 専用のコレクション表示とは異なります。
オブジェクトファイルはデバッグセッション終了まで保持します。

```json
{
  "type": "ycpl",
  "request": "launch",
  "name": "YCPL: Debug",
  "program": "${file}",
  "args": ["空白のある引数"],
  "console": "integratedTerminal"
}
```

既存バイナリ、pid による attach、LLDB の `coreFile` も指定できます。
Ubuntu は `lldb-22`、macOS は `brew install lldb` で別途導入してください。
`llvm@22` のコンパイラパッケージに adapter が同梱されているとは限りません。
Remote/Container ではワークスペース側の拡張ホストで実行します。
自動デプロイの設定は生成しません。

## プロファイル

- **Collect Execution Profile**: LLVM 計測による関数・ブロックの正確な実行回数を表示します。
- **Collect CPU Samples**: macOS は `sample` で `YCPL.profiling.duration` 秒を計測後、
  対象を終了します。Linux は `perf record` / `perf report` を利用します。
  カーネルが perf event の使用を許可している必要があります。
- **Collect Memory Profile**: macOS は `leaks --atExit`、Linux は Valgrind Massif と
  `ms_print` を利用します。事前にシステムツールを導入してください。

レポートと生データは `.ycpl/profiles` に保存します。キャンセルすると所有する
子プロセスも終了します。実行回数、CPU サンプル、メモリ計測は別のレポートです。

## 最終確認を再実行する

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
npm ci --prefix editors/vscode/language-server
npm ci --prefix editors/vscode/extension
npm run check --prefix editors/vscode/language-server
npm run check --prefix editors/vscode/extension
YCC="$PWD/bazel-bin/ycc" tests/test_development_workflows.sh
tools/lsp/run_tests.sh
npm run test:extension --prefix editors/vscode/extension
npm run test:extension:native --prefix editors/vscode/extension
npm run check-package --prefix editors/vscode/extension
```

`npm run format --prefix editors/vscode/extension` でコードを整形できます。
`check` は固定した Prettier 設定による整形チェックも含みます。
統合テストは VSIX を展開して起動し、実際の成功・失敗テスト、カバレッジ、
プロファイル、LLDB のソース停止と変数の値を検証します。
`YCPL_TEST_COMPILER` でセルフホスト版 ycc を、`VSCODE_EXECUTABLE_PATH` で
手元の VS Code 実行ファイルを指定できます。CI は macOS と Ubuntu で実行します。
