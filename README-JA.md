# YCPL

[English](README.md) | [English docs](docs/README.en.md) | [日本語 docs](docs/README.ja.md)

YCPL は、システムプログラミング向けの実験的な言語です。C++ 製コンパイラ、
LLVM バックエンド、YCPL で書かれた標準ライブラリ、サンプル、LSP を含みます。
ソース拡張子は `.yc` です。

```text
.yc ソース
    |
    v
+--------+   +--------+   +-----+   +-----------------+   +----------+
| Lexer  |-->| Parser |-->| AST |-->| Module resolver |-->| Codegen  |
+--------+   +--------+   +-----+   +-----------------+   +----------+
                                                               |
                                                               v
                                                     LLVM IR (.ll)
                                                               |
                                                               v
                                                          llc + clang
                                                               |
                                                               v
                                                        native binary
```

```text
YCPL
├─ 言語
│  ├─ 静的型
│  ├─ スライス
│  ├─ 構造体
│  └─ モジュール
├─ コンパイラ
│  ├─ C++20
│  ├─ LLVM
│  └─ プロジェクトビルド
├─ 標準ライブラリ
│  ├─ std/fmt
│  ├─ std/array
│  ├─ std/mem
│  └─ std/json
└─ ツール
   ├─ VSCode
   ├─ ネイティブ LSP
   └─ 回帰サンプル
```

## 全体像

```text
Repository
├─ bootstrap/cpp/   C++ bootstrap compiler。src/cli と codegen subsystem を分離
├─ compiler/ycpl/   YCPL 製 compiler、lex/parse milestone
├─ stl/std/         YCPL 標準ライブラリ
├─ examples/        .yc サンプルと回帰テスト
├─ tools/lsp/       YCPL 製 LSP
├─ editors/vscode/  VS Code 拡張と TypeScript LSP package
└─ docs/            英語/日本語ドキュメント
```

| 項目 | 状態 |
|---|---|
| 安定性 | かなり初期の alpha、production 非推奨 |
| ソース拡張子 | `.yc` |
| ビルド出力 | `ycc build` は native binary、`ycc build-ir` は LLVM IR (`.ll`) |
| プロジェクト設定 | `YCPL.json` |
| コンパイラバイナリ | `ycc` bootstrap、`ycc-ycpl` self-hosting compiler 作業中 |

## ビルド

```text
開発者
   |
   | bazel build //:ycc //:ycc-ycpl
   v
Bazel ---- 設定 ----> llvm-config 経由の LLVM 22
   |
   +----> bazel-bin/ycc       C++ bootstrap compiler
   |
   +----> bazel-bin/ycc-ycpl  YCPL compiler scaffold
```

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
bazel build //:ycc //:ycc-ycpl
bazel test //...
```

`scripts/setup-llvm.sh` は `/usr` や `/usr/local` に LLVM の symlink を作りません。
代わりに `LLVM_CONFIG`、`LLVM_BINDIR`、`LLVM_DIR`、PATH prefix を出力します。
Ubuntu、Docker、macOS arm/Homebrew の LLVM を system tooling から分離して扱えます。
Bazel と CMake は `llvm-config` が返す LLVM library directory に link し、その
directory を build rpath に入れるため、LLVM shared library を `/usr` にコピーしたり
link したりする必要はありません。

この方針は Odin と同じ実用モデルです。明示的な `LLVM_CONFIG` を優先し、
package manager が入れた LLVM を検出し、利用者に global system path の変更を
要求しません。

LLVM 22 を system に入れている場合は CMake も使えます。

```sh
cmake -S . -B build
cmake --build build
```

明示的に指定する場合:

```sh
LLVM_CONFIG=/opt/homebrew/opt/llvm@22/bin/llvm-config bazel build //:ycc
LLVM_DIR=/opt/homebrew/opt/llvm@22/lib/cmake/llvm cmake -S . -B build
```

## コンパイル

```text
単一ファイル:
  examples/01_hello.yc -> ycc build -> native binary
  examples/01_hello.yc -> ycc build-ir -> LLVM IR

プロジェクト:
  YCPL.json -> src/*.yc を走査 -> ycc build -> native binary
  YCPL.json -> src/*.yc を走査 -> ycc build-ir -> LLVM IR
```

```sh
bazel run //:ycc -- build examples/01_hello.yc -o /tmp/ycpl_hello
bazel run //:ycc -- build-ir examples/01_hello.yc -o /tmp/ycpl_hello
cd examples/04_module_project && ../../bazel-bin/ycc build
```

## セルフホスト

```text
移行段階
├─ ycc
│  ├─ C++ bootstrap compiler
│  ├─ native binary と LLVM IR を生成
│  └─ まだ default compiler のまま
└─ ycc-ycpl
   ├─ YCPL で実装
   ├─ YCPL source を lex/parse
   ├─ 小さな self-codegen subset を型検査
   ├─ i32 main、C-style main(argc i32, argv *string)、local、assignment、0〜8 引数の helper/extern call、arithmetic、return は LLVM IR を直接生成
   ├─ function signature を先に宣言し、main から後続 helper を呼べる
   ├─ その subset は bootstrap ycc なしで native binary まで生成
   ├─ src/**/*.yc traversal で compiler/ycpl を parse/check
   ├─ project AST 由来の function-name digest と main presence を保持
   ├─ ast/body と parser/body で parser-owned body statement node arena を保持
   ├─ body node transition digest と local/assign/call/return edge を保持
   ├─ body if/for node count を LLVM C API の conditional / loop block に lower
   ├─ local/call/control-flow 構造用に function-body token/digest summary を保持
   ├─ function body 由来の return-expression count と digest を保持
   ├─ std/llvm C API wrapper 経由で local/assignment/call/return node probe IR を生成
   ├─ std/llvm C API wrapper 経由で project statement/expression lowering IR を生成
   ├─ local/assignment/call/return body node を専用 alloca/load/store/call lowering に分岐
   ├─ lower 済み local/assignment/call/return node state を各 generated function-body の戻り値へ合成
   ├─ semantic role を symbol-env、value-state、control-state、assignment/call/return value-flow IR へ lower
   ├─ compiler/ycpl の parser body arena を per-function slot と全関数 aggregate data として LLVM alloca/call/branch/loop IR に lower
   ├─ per-function body slot table の count/max/digest を parse/check と生成 IR で gate
   ├─ parser-owned body-node arena から identifier/literal/type/control payload table を保持
   ├─ local symbol、assignment target、call target、return symbol/literal、type ref、control ref の semantic role table を保持
   ├─ function、struct、std import、alias、visibility、digest の declaration/import/module symbol summary を構築
   ├─ function signature と call-site arity summary を parser count と照合し、生成 IR に保持
   ├─ function signature と call-site を parser-owned semantic node table として保持
   ├─ primary/call/member/index/binary/unary expression を parser-owned expression node table として保持
   ├─ expression node table を parser expression、call、member、index count と照合
   ├─ parser-owned expression table から per-function expression slot count、max slot size、digest を保持
   ├─ per-function expression table を function body LLVM lowering に投入
   ├─ identifier/literal/call/member/index/binary/unary expression node を専用 LLVM lowering path に分岐
   ├─ binary operator tag を保持し、add/sub/mul/div/rem/compare node を LLVM arithmetic/comparison wrapper で lower
   ├─ expression node value-state を蓄積し、function-body environment lowering に合成
   ├─ expression value-state を assignment、return、body value-state lowering へ戻して反映
   ├─ per-function expression node を statement-owned body-node count から lower し、残りの tail expression を後続で処理
   ├─ parser-owned statement-expression link count、tail expression count、digest を project parse/check と生成 IR gate に公開
   ├─ else/break/continue/for-in body node を記録し、control-surface LLVM wrapper path に lower
   ├─ 小さな代表 sample だけではなく、1024-node cap の拡張 per-function expression node sequence を project_body.ll に lower
   ├─ 600+ expression lowering floor を生成 stage2/stage3 IR の自己検査へ引き継ぐ
   ├─ compiler/ycpl の先頭 64 個の function body に対して per-function LLVM lowering function を生成
   ├─ compiler/ycpl の function body 0 から 447 までを range bucket LLVM lowering として生成
   ├─ 先頭 64 個以降も ycpl_project_function_body_400 などの individual per-function LLVM lowerer として生成
   ├─ metadata/source position/payload table/semantic role 付き可変長 body-node arena を node-sequence LLVM IR block に lower
   ├─ compiler/ycpl source 内の zero-argument i32 constant-return function を lower
   ├─ YCPL_NO_BOOTSTRAP=1 で compiler/ycpl の project LLVM IR を生成
   ├─ project AST IR を bootstrap ycc なしで native smoke binary に変換
   ├─ 生成された stage2 binary は parse/check/build-ir compiler/ycpl に対応
   ├─ 生成された stage2 binary は native stage3 compiler-smoke output を build 可能
   ├─ 生成された stage3 binary は parse/check/build-ir/build compiler/ycpl に対応し stage4 LLVM IR/native output を出力可能
   ├─ 生成された stage4 binary は parse/check/build-ir/build compiler/ycpl に対応し stage5 LLVM IR/native output を出力可能
   ├─ 生成された stage3 binary は source 内容で tiny arithmetic、call/assignment、control-flow、else/helper、1 引数 i32 helper-call、multi-helper chain、2 引数 helper-call、forward helper-call input を別々の IR/native output に lower
   ├─ 生成された stage2 binary は source 内容で tiny arithmetic、call/assignment、control-flow、else/helper、1 引数 i32 helper-call、multi-helper chain、2 引数 helper-call、forward helper-call input を別々の IR に lower
   ├─ 生成された stage2/stage3 binary は未対応 file build-ir input を project compiler IR として成功扱いしない
   └─ 未対応の build/build-ir input は bootstrap ycc に委譲
```

```text
compiler/ycpl
├─ src/ast       kind i32 の tagged structs と body node sequence records
├─ src/checker   tiny i32 typed subset gate と project AST gate
├─ src/codegen   LLVM C API tiny statement IR、node IR、project AST IR emission
├─ src/driver    self-native build と bootstrap stage driver
├─ src/lexer     token stream、nested comments、string/char checks
├─ src/parser    current grammar surface、body node extraction、recovery diagnostics
├─ src/resolver  YCPL.json project root と nested src/**/*.yc traversal
└─ src/source    bounded file loading
```

```sh
bazel-bin/ycc-ycpl lex examples/01_hello.yc
bazel-bin/ycc-ycpl parse examples/01_hello.yc
bazel-bin/ycc-ycpl check examples/53_self_codegen_main.yc
bazel-bin/ycc-ycpl build-ir-self examples/53_self_codegen_main.yc -o /tmp/ycpl-self-tiny
bazel-bin/ycc-ycpl build examples/54_self_codegen_arithmetic.yc -o /tmp/ycpl-self-native
bazel-bin/ycc-ycpl build examples/56_self_codegen_call_assignment.yc -o /tmp/ycpl-self-call
bazel-bin/ycc-ycpl build examples/57_self_codegen_control_flow.yc -o /tmp/ycpl-self-control
bazel-bin/ycc-ycpl build examples/58_self_codegen_else_helper.yc -o /tmp/ycpl-self-else
bazel-bin/ycc-ycpl build examples/59_self_codegen_param_call.yc -o /tmp/ycpl-self-param
bazel-bin/ycc-ycpl build examples/60_self_codegen_helper_chain.yc -o /tmp/ycpl-self-chain
bazel-bin/ycc-ycpl build examples/61_self_codegen_two_arg_call.yc -o /tmp/ycpl-self-twoarg
bazel-bin/ycc-ycpl build-ir-self examples/99_self_codegen_main_args.yc -o /tmp/ycpl-self-main-args
bazel-bin/ycc-ycpl build examples/62_self_codegen_forward_call.yc -o /tmp/ycpl-self-forward
bazel-bin/ycc-ycpl parse compiler/ycpl
bazel-bin/ycc-ycpl check compiler/ycpl
bazel-bin/ycc-ycpl build-ir compiler/ycpl -o /tmp/ycpl-self-ir
# std/llvm 経由で /tmp/ycpl-self-ir/local_return.ll も生成し、その node probe を merged.ll に統合
bazel-bin/ycc-ycpl build compiler/ycpl -o /tmp/ycpl-self-native
YCPL_NO_BOOTSTRAP=1 bazel-bin/ycc-ycpl build-ir compiler/ycpl -o /tmp/ycpl-strict
YCPL_NO_BOOTSTRAP=1 bazel-bin/ycc-ycpl build compiler/ycpl -o /tmp/ycpl-strict-native
```

```text
stage-2 gate
├─ compiler/ycpl project parse/check は ycc-ycpl 側で処理
├─ src/ast や src/codegen のような nested source folder は src/**/*.yc traversal で検出
├─ tiny arithmetic/call/control-flow/else-helper/helper-call/extern-call build は、8 引数 call を含めて YCPL_NO_BOOTSTRAP=1 で実行可能
├─ project build-ir は bootstrap fallback なしで実行
├─ project build-ir は LLVM C API wrapper 経由で local_return.ll と project_body.ll を生成
├─ merged.ll は local、assignment、call、return、transition、if/for control flow 用の LLVM-wrapper-generated node probe を含む
├─ merged.ll は LLVM-wrapper-generated project statement/expression lowering を呼び出す
├─ project_body.ll は source-derived constant-return、parser-owned per-function slot、全関数 body lowering、metadata/payload-table/semantic-role 付き body-node arena lowering を含む
├─ project_body.ll は local/assignment/call/return node state を function ごとに accumulator へ lower し、function_body_lowered_total で返す
├─ project_body.ll は semantic-role data を symbol environment、value state、control state、assignment/call/return value-flow IR へ lower
├─ project parse/check と生成 IR は declaration/import/module symbol table summary を gate
├─ project parse/check と生成 IR は parser-owned expression node table と digest を gate
├─ project_body.ll は per-function expression slot metadata を LLVM-wrapper-generated IR に lower
├─ project_body.ll は body-node lowering と per-function expression node/slot/digest lowering を結合
├─ project_body.ll は parser-owned expression node kind を identifier/literal/call/member/index/binary/unary LLVM IR lowering に分岐
├─ project_body.ll は parser-owned binary operator tag を LLVM add/sub/mul/sdiv/srem/icmp 命令へ lower
├─ project_body.ll は function_expr_value_state を蓄積し、function_expr_lowered_value_state を function_body_expr_value_environment へ合成
├─ project_body.ll は parser-owned else/break/continue/for-in control-surface node を lower
├─ project_body.ll は 600+ node の拡張 expression lowering sequence 用に function_expr_lowered_nodes と function_expression_sequence_lowered を記録
├─ 生成された stage2/stage3 IR は ycpl_stage_expr_lowered_floor で expression lowering floor を gate
├─ project_body.ll は ycpl_project_function_body_0 から ycpl_project_function_body_63 に加え、ycpl_project_function_body_400 など 64+ の dynamic per-function lowerer を生成
├─ project_body.ll は ycpl_project_function_body_range_0_63 から ycpl_project_function_body_range_384_447 までの range bucket lowerer を生成
├─ project_body.ll は dynamic per-function call を function_body_all_individual_lowered へ合成
├─ project parse/check は src/ast/shape.yc 由来の typed AST shape count と typed digest を出す
├─ project AST IR は function symbol、body node、expression-table、typed AST、main presence、return-expression gate を含む
├─ project AST IR は native smoke binary まで変換可能
├─ 生成された stage2 binary は stage3 LLVM IR を出力可能
├─ 生成された stage2 binary は llc/clang で stage3 native output を build 可能
├─ 生成された stage3 native output は compiler/ycpl を parse/check し、llc-valid な stage4 IR/native output を出力可能
├─ 生成された stage4 native output は compiler/ycpl を parse/check し、llc-valid な stage5 IR/native output を出力可能
├─ 生成された stage3 native output は tiny arithmetic、call/assignment、control-flow、else/helper、1 引数 i32 helper-call、multi-helper chain、2 引数 helper-call、forward helper-call input を exit code 13 の native に lower
├─ 生成された stage2/stage3 native output は未対応 file build-ir input を project compiler IR として成功扱いしない
├─ 生成された stage2 binary は examples/54、examples/59、examples/60、examples/61、examples/62、renamed copy を exit code 13 の native に build
└─ compiler として等価な build/native codegen は次段で対応
```

## YCPL から LLVM C API を呼ぶ

```text
YCPL source -> extern fn ... as "LLVM..." -> ycc build
                                                |
                                                v
                                      llvm-config link flags
```

```sh
LLVM_CONFIG=/opt/homebrew/opt/llvm@22/bin/llvm-config \
  bazel-bin/ycc build examples/50_llvm_c_api.yc -o /tmp/ycpl_llvm
```

`std/llvm` を import したプログラムは LLVM の C API を直接呼べます。
生成 IR が `LLVM...` symbol を参照している場合、`ycc build` は LLVM を自動 link
します。明示したい場合は `--link-llvm` も使えます。

## 言語スナップショット

```text
module math        import "math" as math
    |                       |
    v                       v
pub fn add(...)  ---->  math.add(1, 2)

i32 / i64 / bool / string / *T / []T
if / for / break / continue
fn main()
```

```YCPL
import "std/fmt" as fmt

fn main() {
    fmt.println("Hello World")
}
```

## ドキュメント

```text
README.md
└─ docs/*.en.md
   ├─ language.en.md
   ├─ projects.en.md
   ├─ stdlib.en.md
   └─ status.en.md

README-JA.md
└─ docs/*.ja.md
   ├─ language.ja.md
   ├─ projects.ja.md
   ├─ stdlib.ja.md
   └─ status.ja.md
```

- [言語構文](docs/language.ja.md)
- [プロジェクトとモジュール](docs/projects.ja.md)
- [標準ライブラリ](docs/stdlib.ja.md)
- [実装状況](docs/status.ja.md)
- [YCPL LSP](tools/lsp/README.md)
- [Contributing](CONTRIBUTING.md)
- [Security policy](SECURITY.md)

## エディタと LSP

```text
VSCode
  |
  v
editors/vscode/extension -- LSP --> editors/vscode/language-server
  |
  v
workspace index / diagnostics / symbols / semantic tokens
  |
  v
hover / completion / references / formatting / rename / code actions
```

```sh
npm ci --prefix editors/vscode/language-server
npm run check --prefix editors/vscode/language-server
npm ci --prefix editors/vscode/extension
npm run check --prefix editors/vscode/extension
```

従来の YCPL 製 protocol server は引き続き `tools/lsp/` にあり、
`tools/lsp/run_tests.sh` で検証します。

## テスト

```text
examples/run_tests.sh
├─ 単一ファイル成功系
├─ プロジェクトビルド
├─ コンパイル失敗期待
└─ 実行時失敗期待

bazel test //:ycc_ycpl_test
├─ ycc-ycpl lex smoke test
├─ failure ではない examples 全件の parse
└─ 壊れた入力に対する lexer/parser 診断の固定
```

```sh
bazel test //:examples_test //:lsp_protocol_test //:ycc_ycpl_test
```
