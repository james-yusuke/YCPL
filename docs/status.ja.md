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
├─ std: fmt, array, mem, str, math, io, fs, os, text, json, map
└─ tooling: examples, YCPL LSP v0.4, C++ bootstrap ycc
```

## 実験中

```text
experimental
├─ ycc-ycpl lexer/parser self-hosting compiler
├─ tiny i32 subset 用の ycc-ycpl checker、LLVM IR emitter、native build
├─ bootstrap ycc 経由の ycc-ycpl build/build-ir stage driver
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

## セルフホスト進行状況

```text
self-hosting
├─ bootstrap/cpp
│  ├─ src/cli と core/scope/dispatch/pipeline codegen を分離した現行 C++ compiler
│  └─ codegen と native build はまだここが担当
└─ compiler/ycpl
   ├─ source/diag/lexer/parser/cli modules
   ├─ nested source folders: src/ast, src/codegen, src/parser, ...
   ├─ ycc-ycpl lex <file.yc>
   ├─ ycc-ycpl parse <file.yc>
   ├─ ycc-ycpl check examples/53_self_codegen_main.yc
   ├─ ycc-ycpl build-ir-self examples/53_self_codegen_main.yc -o <out>
   ├─ ycc-ycpl build examples/54_self_codegen_arithmetic.yc -o <out>
   ├─ ycc-ycpl build examples/56_self_codegen_call_assignment.yc -o <out>
   ├─ ycc-ycpl build examples/57_self_codegen_control_flow.yc -o <out>
   ├─ ycc-ycpl build examples/58_self_codegen_else_helper.yc -o <out>
   ├─ ycc-ycpl build examples/59_self_codegen_param_call.yc -o <out>
   ├─ ycc-ycpl build examples/60_self_codegen_helper_chain.yc -o <out>
   ├─ ycc-ycpl build examples/61_self_codegen_two_arg_call.yc -o <out>
   ├─ ycc-ycpl build examples/62_self_codegen_forward_call.yc -o <out>
   ├─ ycc-ycpl parse compiler/ycpl
   ├─ ycc-ycpl check compiler/ycpl
   ├─ YCPL_NO_BOOTSTRAP=1 ycc-ycpl build-ir compiler/ycpl -o <out>
   ├─ YCPL_NO_BOOTSTRAP=1 ycc-ycpl build compiler/ycpl -o <out>
   ├─ 生成された stage2 binary parse/check/build-ir compiler/ycpl
   ├─ 生成された stage2 binary build compiler/ycpl -o <stage3-out>
   ├─ 生成された stage2 binary build examples/54_self_codegen_arithmetic.yc、examples/56_self_codegen_call_assignment.yc、examples/57_self_codegen_control_flow.yc、examples/58_self_codegen_else_helper.yc、examples/59_self_codegen_param_call.yc、examples/60_self_codegen_helper_chain.yc、examples/61_self_codegen_two_arg_call.yc、examples/62_self_codegen_forward_call.yc と renamed copy
   ├─ ycc-ycpl build compiler/ycpl -o <out>
   └─ 未対応 input はまだ bootstrap ycc に委譲
```

```text
stage-2 self-host gate
├─ compiler/ycpl source discovery は nested src/**/*.yc file を traversal
├─ resolver は shell-backed traversal の前に unsafe project path を拒否
├─ project parse/check は AST 由来の count、body node digest、return digest、main presence を出す
├─ project parse/check は body node transition digest と local/assign/call/return edge count を出す
├─ body if/for node は std/llvm 経由で conditional branch と loop block に lower
├─ body else/break/continue/for-in node は body arena に記録し、std/llvm 経由の control-surface path に lower
├─ tiny single-file codegen は local declaration、assignment、複数の 0/1/2 引数 i32 helper call、arithmetic、return を LLVM C API wrapper で lower
├─ tiny single-file codegen は i32 function signature を先に宣言し、main から後続 helper を呼べる
├─ YCPL_NO_BOOTSTRAP=1 の project build-ir は valid LLVM IR を生成
├─ project build-ir は std/llvm の alloca/store/load/call/ret wrapper で local_return.ll を生成
├─ project build-ir は std/llvm の statement/expression lowering wrapper で project_body.ll を生成
├─ merged.ll は local、assignment、call、return、transition、if/for control flow 用の LLVM-wrapper-generated node probe を含む
├─ merged.ll は LLVM-wrapper-generated project statement/expression lowering を呼び出す
├─ project_body.ll は local/assignment/call/return body node を専用 alloca/load/store/call lowering に分岐
├─ project_body.ll は lower 済み local/assignment/call/return node state を generated function body ごとに accumulator へ反映
├─ project_body.ll は semantic role を symbol environment、value state、control state、assignment/call/return value-flow IR へ lower
├─ project_body.ll は source-derived zero-argument i32 constant-return function を lower
├─ project_body.ll は parser-owned per-function body slot と全関数 aggregate body data を alloca/call/conditional/loop IR に lower
├─ project_body.ll は compiler/ycpl の function body 0 から 63 までを per-function body lowerer として生成
├─ project_body.ll は compiler/ycpl の function body 0 から 447 までを range lowerer でカバー
├─ project parse/check と生成 IR は per-function body slot table の count/max/digest を gate する
├─ project parse/check は body-node arena 由来の identifier/literal/type/control payload table count と digest を出す
├─ project parse/check は local symbol、assignment target、call target、return symbol/literal、type ref、control ref の semantic role count を出す
├─ project parse/check は function、struct、std import、alias、visibility、digest の declaration/import/module symbol summary を出す
├─ project parse/check は function signature と call-site arity summary を parser count と照合する
├─ project parse/check は function signature と call-site の parser-owned semantic node table を保持する
├─ signature table は typed return-kind slot を保持し、project check と生成 IR で parser-side typed function return を gate する
├─ project parse/check は primary/call/member/index/binary/unary expression の parser-owned expression node table を保持する
├─ 生成 project IR は expression table count/digest を gate し、project_body.ll 経由で lower する
├─ project parse/check と project_body.ll は per-function expression slot count、max slot size、digest を保持する
├─ project_body.ll は per-function body-node lowering と per-function expression node/slot/digest lowering を結合する
├─ project_body.ll は identifier/literal/call/member/index/binary/unary expression node kind を専用 LLVM lowering path に分岐する
├─ project_body.ll は binary operator tag を保持し、LLVM add/sub/mul/sdiv/srem/icmp 命令へ lower する
├─ project_body.ll は expression value state を蓄積し、function-body environment lowering へ合成する
├─ project_body.ll は expression value state と並べて expression type state も保持し、typed expression value を statement、tail、assignment、return、body environment flow へ合成する
├─ expression table は parser-owned type tag を保持し、project_body.ll は operator だけで型状態を作らず、その type tag を読む
├─ expression parser は同一ファイルの関数戻り型と local declaration を pre-scan し、identifier/call expression node に parser-side resolved type tag を載せて project_body.ll へ渡す
├─ expression parser は primitive/pointer function parameter も各 function body の local type table に取り込む
├─ project_body.ll は共通 SourceList から project-wide function return type table を作り、ファイルをまたぐ call expression type tag を解決する
├─ project_body.ll はその project-wide return type table を一度だけ作り、all/control/individual/range/dynamic function-body scan に注入する
├─ project_body.ll は typed identifier、同一ファイル typed call、project-wide typed call expression node を数え、生成 IR で gate する
├─ project_body.ll は expression value state を assignment、return、body value-state lowering に戻して反映する
├─ project_body.ll は per-function statement-owned body-node count から expression node を lower し、残りの tail expression を後続で lower する
├─ project_body.ll は statement が所有する expression 数を node ごとの owner state と value-flow IR に lower する
├─ statement-owned expression の typed value は owning body node の semantic role に従い、local/assignment/call/return state へ流れる
├─ statement-owned expression は local/assignment/call/return/control lowering の前に statement ごとの AST value へ畳み込まれ、summary-only body lowering path をさらに減らしている
├─ statement ごとの AST value は aggregate state 更新だけでなく、direct local/assignment/call/return LLVM alloca/store/load/call path に流れる
├─ statement ごとの AST value は parser/resolver 由来の expression type tag と結合され、resolved local/assignment/call/return state lowering に流れる
├─ statement-owned expression の typed value は i32/i64/bool/string/pointer/slice/reference/none/unknown の型カテゴリ別 state にも流れ、function-body environment に合成される
├─ statement/expression の role/type flow lowering は `codegen/bodyflow.yc` module に分離し、`projectir.yc` は module 経由で呼び出す
├─ identifier/literal/call/member/index/binary/unary expression lowering は `codegen/exprlower.yc` module に分離し、index expression は LLVM slice-header len/cap、bounds-check branch、array-type GEP/load IR を生成し、member expression は parse した member-name hash と project field-table index から bounded LLVM struct GEP/load IR を生成する
├─ local/assignment/call/return/if/for/else/break/continue/for-in body statement lowering は `codegen/stmtlower.yc` module に分離し、`projectir.yc` は per-function orchestration に集中する
├─ YCPL lexer/parser/checker/tinyir は C++ bootstrap と同じく `:=` を 1 個の ASSIGN token/lexeme として扱い、local initializer を local statement-expression lowering に接続する
├─ project parse/check と生成 IR は parser-owned statement-expression link count、tail expression count、digest を公開する
├─ project_body.ll は 1024-cap / 600+ node の expression sequence lowering pass 用に function_expr_lowered_nodes と function_expression_sequence_lowered を保持する
├─ 生成された stage2/stage3 IR は ycpl_stage_expr_lowered_floor で expression lowering floor を gate する
├─ project_body.ll は compiler/ycpl body slot 0 から 63 までの per-function lowering function を生成する
├─ project_body.ll は compiler/ycpl body slot 0 から 447 までの range bucket lowering function を生成する
├─ project_body.ll は body slot 0 から 63 も dynamic first-body lowerer 経由で再 lower し、固定列挙だけに依存しない gate を持つ
├─ project_body.ll は src/**/*.yc traversal 結果から代表 64 件単位の dynamic range bucket lowerer も生成し、手書き range bucket と照合する
├─ project_body.ll は const/all/control/individual/range scan を共通 SourceList から行い、source traversal gate を生成 IR に持つ
├─ project_body.ll は body slot 64+ の dynamic individual lowerer を生成し、ycpl_project_function_body_400 も gate する
├─ project_body.ll は metadata/source position/payload table/semantic role 付き可変長 statement/expression body-node arena を node-sequence alloca/branch/loop IR に lower
├─ project_body.ll は body payload count、semantic role count、payload digest、semantic digest を各 generated function-body IR score に持ち込む
├─ project parse/check は typed AST shape count と typed digest を出す
├─ 生成 project IR は function、body-node、expression-table、typed AST、signature node table、symbol signature/arity、main-presence、return-expression global を使う
├─ YCPL_NO_BOOTSTRAP=1 の project build は native AST smoke binary を生成
├─ 生成された stage2 binary は stage3 LLVM IR を出力
├─ 生成された stage2 binary は native stage3 compiler-smoke output を build
├─ 生成された stage3 binary は parse/check/build-ir/build compiler/ycpl に対応し、llc-valid な stage4 LLVM IR/native output を出力する
├─ 生成された stage4 binary は parse/check/build-ir/build compiler/ycpl に対応し、llc-valid な stage5 LLVM IR/native output を出力する
├─ 生成された stage native driver は `LLC`/`CLANG`/`LLVM_BINDIR`/`LLVM_CONFIG` を扱い、未指定時は `/usr` を変更せず command-local `PATH` で Homebrew/apt 系 LLVM prefix を探索する
├─ 生成された stage3 binary は source 内容で tiny arithmetic、call/assignment、control-flow、else/helper、1 引数 i32 helper-call、multi-helper chain、2 引数 helper-call、forward helper-call、bool/string/extern/LLVM C API smoke input を別々の IR output に lower する
├─ 生成された stage2 binary は source 内容で tiny arithmetic、call/assignment、control-flow、else/helper、1 引数 i32 helper-call、multi-helper chain、2 引数 helper-call、forward helper-call、bool/string/extern/LLVM C API smoke input を実行可能 IR に lower
├─ 生成された stage2/stage3 binary は fallback 位置で source の `return <整数>` を読み、固定 fixture なしで dynamic constant-return IR を生成する
├─ 生成された stage2/stage3 binary は fallback 位置で `x := <整数>; return x` を読み、固定 fixture なしで alloca/store/load を含む dynamic local-return IR を生成する
├─ 生成された stage2/stage3 binary は fallback 位置で `x := <整数>; x = <整数>; return x` を読み、固定 fixture なしで local assignment の alloca/store/store/load IR を生成する
├─ 生成された stage2/stage3 binary は fallback 位置で `left := <整数>; right := <整数>; return left + right` を読み、固定 fixture なしで binary add return IR を生成する
├─ 生成された stage2/stage3 binary は fallback 位置で `left := <整数>; right := <整数>; if left < right { return <整数> }; return <整数>` を読み、固定 fixture なしで comparison if-return IR を生成する
├─ 生成された stage2/stage3 binary は fallback 位置で `dyn_seed()` helper の `return <整数>` を読み、固定 fixture なしで zero-arg helper call IR を生成する
├─ 生成された stage2/stage3 binary は fallback 位置で `probe := <整数>; if probe == 0 { return <整数> }; return <整数>` を読み、固定 fixture なしで conditional branch IR を生成する
├─ 生成された stage2/stage3 binary は fallback 位置で `sum := <整数>; for (i := 0; i < <整数>; i = i + 1) { sum = sum + <整数> }; return sum` を読み、固定 fixture なしで loop check/body/update/done IR を生成する
├─ checker/tinyir は固定長 3 要素の i32 array literal、index load、element assignment、`for value in items`、`for i in n`、loop 内および `if` 内の `break` / `continue` を型検査し、LLVM array alloca/GEP/store/load/loop IR に lower する。動的 index は `icmp sge`/`icmp slt` bounds check を通し、OOB path は `abort` + `unreachable` に落とす
├─ checker/tinyir は numeric for-in と C-style for の body 内 `return` を実 control-flow として扱い、return path は LLVM `ret` で終端し、loop 後の通常 path は後続 statement へ流す
├─ checker/tinyir は 2/3-field i32 struct declaration、struct literal local、member load/member assignment、2/3-field struct helper parameter call、2/3-field struct helper return を扱い、LLVM struct alloca と `LLVMBuildStructGEP2`/load/store/call/ret IR に lower する
├─ 生成された stage2/stage3 binary は array/index self-codegen fixture を array alloca/GEP/load/store IR に lower する
├─ 生成された stage4/stage5 IR は compiler project の body-node count と statement-expression link から resolved local/assignment/call/return lowering probe を実行する
├─ project body lowering は compact gate のまま、実際の `scan.node_*` / `scan.expr_*` 先頭ノードを bounded に `stmtlower` / `exprlower` / `bodyflow` へ流し、resolved statement value/type と local/assignment/call/return state に接続する
├─ project_body.ll は bounded 実 AST lowering state を function_body_lowered_total に合成し、summary-only total から一段外れている
├─ project_body.ll は実 statement-expression lowering 上限も名前付き IR marker として gate し、次段の拡張点を明示している
├─ tiny single-file codegen は if/else body 内の return を終端済み block として扱い、余分な branch を出さずに後続 block へ進める
├─ function body lowering は statement/expression owner を 1 個固定ではなく、各関数の body node sequence から上限付きで複数 lower し、owner count/limit を IR gate として検証
├─ function body lowering は BodyNodeSequence の kind/meta/source-position/payload/semantic-role/expression-count を generated function body の AST node sequence state に lower
├─ function body lowering は AST node sequence を local/assignment/call/return/control の semantic sequence state に分岐して lower
├─ function body lowering は expression table の identifier/literal/string/bool/none/member/index category を scan に取り込み、literal type/access/call surface を IR value flow に lower
├─ 生成された stage2/stage3 binary は未対応 file build-ir input を project compiler IR として成功扱いしない
├─ YCPL_NO_BOOTSTRAP=1 の通常 ycc-ycpl build/build-ir path は bootstrap fallback を禁止し、未対応 input を明示診断で失敗させる
├─ project_body.ll は固定 expression probe を使わず、statement-owned expression と remaining tail expression を実 scan.expr_* sequence から lower する
├─ statement-owned expression は local/assignment/call/return の semantic role と parser/resolver 由来の type kind を組み合わせ、resolved role/type flow として IR に lower する
├─ project-wide function signature table の arity を call expression の resolved arity として保持し、call value/type lowering に合成する
├─ checker は YCPL helper function 定義、extern signature、call argument type check を 8 引数まで扱い、stage1/stage2 self-host gate で 8 引数 call を検証する
├─ project_body.ll の実 AST lowering cap は body node 32、expression 64、statement expression 32、statement owner 32 まで広げ、IR gate で値を固定している
├─ statement-owned expression lowering は total expression cap も守り、CI は lowered node/expression count が cap を越えたら失敗する
├─ project_body.ll は実 lowering 済み node/expression count と未 lowering node/expression count を名前付き IR marker として出し、summary/smoke の取り残しを CI で検出できる
├─ traversal project gate は i64 と []T/slice parameter を typed AST flow に載せ、i64/reference statement-expression marker を生成 IR で検証する
└─ compiler として等価な native ycc-ycpl は次の実装ステップ
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
