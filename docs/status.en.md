# Implementation Status

[Japanese](status.ja.md) | [Docs index](README.en.md)

```text
Feature status
├─ stable enough for examples
├─ experimental
└─ reserved, not implemented
```

## Stable Enough For Examples

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

## Experimental

```text
experimental
├─ ycc-ycpl lexer/parser self-hosting compiler
├─ ycc-ycpl checker, LLVM IR emitter, and native build for tiny i32 subset
├─ ycc-ycpl build/build-ir stage driver through bootstrap ycc
├─ intrinsic fn in bundled std
├─ sprintf
├─ cast
├─ new([]T)
├─ variadic user functions
├─ pointer-heavy expressions
├─ nested/inline structs
├─ runtime slice returns
└─ broad C/Unix FFI
```

## Self-Hosting Track

```text
self-hosting
├─ bootstrap/cpp
│  ├─ current C++ compiler with src/cli and core/scope/dispatch/pipeline codegen split
│  └─ still owns codegen and native builds
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
   ├─ generated stage2 binary parse/check/build-ir compiler/ycpl
   ├─ generated stage2 binary build compiler/ycpl -o <stage3-out>
   ├─ generated stage2 binary build examples/54_self_codegen_arithmetic.yc, examples/56_self_codegen_call_assignment.yc, examples/57_self_codegen_control_flow.yc, examples/58_self_codegen_else_helper.yc, examples/59_self_codegen_param_call.yc, examples/60_self_codegen_helper_chain.yc, examples/61_self_codegen_two_arg_call.yc, examples/62_self_codegen_forward_call.yc, and renamed copies
   ├─ ycc-ycpl build compiler/ycpl -o <out>
   └─ unsupported inputs still delegate to bootstrap ycc
```

```text
stage-2 self-host gate
├─ compiler/ycpl source discovery traverses nested src/**/*.yc files
├─ resolver rejects unsafe project paths before shell-backed traversal
├─ project parse/check emits AST-derived counts, body node digest, return digest, and main presence
├─ project parse/check emits body node transition digest and local/assign/call/return edge counts
├─ body if/for nodes lower through std/llvm into conditional branch and loop blocks
├─ body else/break/continue/for-in nodes are recorded in the body arena and lower through std/llvm control-surface paths
├─ tiny single-file codegen lowers local declarations, assignments, zero-through-eight-argument helper/extern calls, arithmetic, and returns through LLVM C API wrappers
├─ tiny single-file codegen predeclares i32 function signatures so main can call helpers defined later in the file
├─ YCPL_NO_BOOTSTRAP=1 project build-ir emits valid LLVM IR
├─ project build-ir writes local_return.ll via std/llvm alloca/store/load/call/ret wrappers
├─ project build-ir writes project_body.ll via std/llvm statement/expression lowering wrappers
├─ merged.ll includes the LLVM-wrapper-generated node probe for local, assignment, call, return, transitions, and if/for control flow
├─ merged.ll calls LLVM-wrapper-generated project statement/expression lowering
├─ project_body.ll dispatches local/assignment/call/return body nodes into dedicated alloca/load/store/call lowering
├─ project_body.ll accumulates lowered local/assignment/call/return node state per generated function body
├─ project_body.ll lowers semantic roles into symbol environment, value state, control state, and assignment/call/return value-flow IR
├─ project_body.ll lowers source-derived zero-argument i32 constant-return functions
├─ project_body.ll lowers parser-owned per-function body slots and all-function aggregate body data into alloca/call/conditional/loop IR
├─ project_body.ll emits per-function body lowerers for compiler/ycpl function bodies 0 through 63
├─ project_body.ll emits range lowerers covering compiler/ycpl function bodies 0 through 447
├─ project parse/check and generated IR gate per-function body slot table counts, max size, and digest
├─ project parse/check exposes identifier/literal/type/control payload table counts and digest from body-node arenas
├─ project parse/check exposes semantic role counts for local symbols, assignment targets, call targets, return symbols/literals, type refs, and control refs
├─ project parse/check exposes declaration/import/module symbol summaries for functions, structs, std imports, aliases, visibility, and digests
├─ project parse/check cross-checks function signature and call-site arity summaries against parser counts
├─ project parse/check stores parser-owned semantic node tables for function signatures and call sites
├─ signature tables now retain typed return-kind slots and gate parser-side typed function returns in project check and generated IR
├─ project parse/check stores parser-owned expression node tables for primary/call/member/index/binary/unary expressions
├─ generated project IR gates expression table counts/digests and lowers them through project_body.ll
├─ project parse/check and project_body.ll now track per-function expression slot counts, max slot size, and digest
├─ project_body.ll combines per-function body-node lowering with per-function expression node/slot/digest lowering
├─ project_body.ll dispatches identifier/literal/call/member/index/binary/unary expression node kinds into dedicated LLVM lowering paths
├─ project_body.ll preserves binary operator tags and lowers them into LLVM add/sub/mul/sdiv/srem/icmp instructions
├─ project_body.ll accumulates expression value state and folds it into the function-body environment lowering
├─ project_body.ll now tracks expression type state beside value state and folds typed expression values into statement, tail, assignment, return, and body environment flows
├─ expression tables now carry parser-owned type tags, and project_body.ll reads those tags instead of deriving every type state only from operators
├─ expression parsing now pre-scans same-file function return types and local declarations, so identifier/call expression nodes can carry resolved parser-side type tags into project_body.ll
├─ expression parsing now imports primitive and pointer function parameters into each function body's local type table
├─ project_body.ll now builds a project-wide function return type table from the shared SourceList and uses it to resolve call expression type tags across files
├─ project_body.ll now builds that project-wide return type table once and injects it into all/control/individual/range/dynamic function-body scans
├─ project_body.ll now counts typed identifier, same-file typed call, and project-wide typed call expression nodes and gates them in generated IR
├─ project_body.ll feeds expression value state back into assignment, return, and body value-state lowering
├─ project_body.ll lowers expression nodes from per-function statement-owned body-node counts, then lowers remaining tail expressions
├─ project_body.ll lowers each statement-owned expression count into per-node owner state and value-flow IR
├─ statement-owned expression typed values now flow into local/assignment/call/return state according to the owning body node semantic role
├─ statement-owned expressions now fold into a per-statement AST value before local/assignment/call/return/control lowering, reducing the remaining summary-only body lowering path
├─ per-statement AST values now feed direct local/assignment/call/return LLVM alloca/store/load/call paths instead of only updating aggregate state
├─ per-statement AST values now combine with parser/resolver expression type tags and flow into resolved local/assignment/call/return state lowering
├─ statement-owned expression typed values also flow into i32/i64/bool/string/pointer/slice/reference/none/unknown type-category state and are folded into the function-body environment
├─ statement/expression role/type flow lowering now lives in the `codegen/bodyflow.yc` module, with `projectir.yc` calling it through the module boundary
├─ identifier/literal/call/member/index/binary/unary expression lowering now lives in the `codegen/exprlower.yc` module; index expressions emit LLVM slice-header len/cap, bounds-check branch, and array-type GEP/load IR, while member expressions use parsed member-name hash plus project field-table index to drive bounded LLVM struct GEP/load IR
├─ local/assignment/call/return/if/for/else/break/continue/for-in body statement lowering now lives in the `codegen/stmtlower.yc` module, leaving `projectir.yc` focused on per-function orchestration
├─ the YCPL lexer/parser/checker/tinyir now match the C++ bootstrap by treating `:=` as one ASSIGN token/lexeme and routing local initializers into local statement-expression lowering
├─ project parse/check and generated IR expose parser-owned statement-expression link counts, tail expression counts, and digest
├─ project_body.ll now tracks function_expr_lowered_nodes and function_expression_sequence_lowered for a 1024-cap, 600+ node expression sequence lowering pass
├─ generated stage2/stage3 IR now gates the expression lowering floor with ycpl_stage_expr_lowered_floor
├─ project_body.ll emits per-function lowering functions for compiler/ycpl body slots 0 through 63
├─ project_body.ll emits range bucket lowering functions for compiler/ycpl body slots 0 through 447
├─ project_body.ll also re-lowers body slots 0 through 63 through a dynamic first-body lowerer, so the gate no longer depends only on the fixed listing
├─ project_body.ll also emits representative 64-body dynamic range bucket lowerers from the src/**/*.yc traversal result and gates them against the hand-listed range buckets
├─ project_body.ll runs const/all/control/individual/range scans from one shared SourceList and carries a source traversal gate in generated IR
├─ project_body.ll emits dynamic individual lowerers for body slots 64+ and gates ycpl_project_function_body_400
├─ project_body.ll lowers variable-length statement/expression body-node arenas with metadata/source positions/payload tables/semantic roles into node-sequence alloca/branch/loop IR
├─ project_body.ll now carries body payload counts, semantic role counts, payload digest, and semantic digest into each generated function-body IR score
├─ project parse/check emits typed AST shape counts and a typed digest
├─ generated project IR uses function, body-node, expression-table, typed-AST, signature node table, symbol signature/arity, main-presence, and return-expression globals
├─ YCPL_NO_BOOTSTRAP=1 project build emits a native AST smoke binary
├─ generated stage2 binary emits stage3 LLVM IR
├─ generated stage2 binary builds native stage3 compiler-smoke output
├─ generated stage3 binary supports parse/check/build-ir/build compiler/ycpl and emits llc-valid stage4 LLVM IR/native output
├─ generated stage4 binary supports parse/check/build-ir/build compiler/ycpl and emits llc-valid stage5 LLVM IR/native output
├─ generated stage native drivers handle `LLC`/`CLANG`/`LLVM_BINDIR`/`LLVM_CONFIG`, then search Homebrew/apt LLVM prefixes through command-local `PATH` without mutating `/usr`
├─ generated stage3 binary lowers tiny arithmetic, call/assignment, control-flow, else/helper, one-argument i32 helper-call, multi-helper chain, two-argument helper-call, forward helper-call, and bool/string/extern/LLVM C API smoke inputs to distinct IR output by source content
├─ generated stage2 binary lowers tiny arithmetic, call/assignment, control-flow, else/helper, one-argument i32 helper-call, multi-helper chain, two-argument helper-call, forward helper-call, and bool/string/extern/LLVM C API smoke inputs to executable IR by source content
├─ generated stage2/stage3 binaries parse `return <integer>` at the fallback position and emit dynamic constant-return IR without a fixed fixture string
├─ generated stage2/stage3 binaries parse `x := <integer>; return x` at the fallback position and emit dynamic local-return IR with alloca/store/load without a fixed fixture string
├─ generated stage2/stage3 binaries parse `x := <integer>; x = <integer>; return x` at the fallback position and emit dynamic local-assignment IR with alloca/store/store/load without a fixed fixture string
├─ generated stage2/stage3 binaries parse `left := <integer>; right := <integer>; return left + right` at the fallback position and emit dynamic binary-add return IR without a fixed fixture string
├─ generated stage2/stage3 binaries parse `left := <integer>; right := <integer>; if left < right { return <integer> }; return <integer>` at the fallback position and emit dynamic comparison if-return IR without a fixed fixture string
├─ generated stage2/stage3 binaries parse a `dyn_seed()` helper's `return <integer>` at the fallback position and emit zero-argument helper-call IR without a fixed fixture string
├─ generated stage2/stage3 binaries parse `probe := <integer>; if probe == 0 { return <integer> }; return <integer>` at the fallback position and emit conditional-branch IR without a fixed fixture string
├─ generated stage2/stage3 binaries parse `sum := <integer>; for (i := 0; i < <integer>; i = i + 1) { sum = sum + <integer> }; return sum` at the fallback position and emit loop check/body/update/done IR without a fixed fixture string
├─ checker/tinyir now type-check and lower fixed three-element i32 array literals, index loads, element assignments, `for value in items`, `for i in n`, and `break` / `continue` inside loops and nested `if` branches into LLVM array alloca/GEP/store/load/loop IR. Dynamic indexes go through `icmp sge`/`icmp slt` bounds checks, and the OOB path lowers to `abort` + `unreachable`
├─ checker/tinyir now treats `return` inside numeric for-in and C-style for bodies as real control flow: the return path terminates with LLVM `ret`, while the loop's normal path can continue to following statements
├─ checker/tinyir now handles two- and three-field i32 struct declarations, struct-literal locals, member loads/assignments, two- and three-field struct helper-parameter calls, and two- and three-field struct helper returns, lowering them into LLVM struct allocas plus `LLVMBuildStructGEP2`/load/store/call/ret IR
├─ generated stage2/stage3 binaries lower the array/index self-codegen fixture into array alloca/GEP/load/store IR
├─ generated stage4/stage5 IR now runs a resolved local/assignment/call/return lowering probe from compiler project body-node counts and statement-expression links
├─ project body lowering keeps the compact gate but now feeds bounded leading real `scan.node_*` / `scan.expr_*` entries through `stmtlower` / `exprlower` / `bodyflow`, connecting resolved statement values/types to local/assignment/call/return state
├─ project_body.ll now folds the bounded real AST lowering state into function_body_lowered_total, moving one step away from a summary-only total
├─ project_body.ll now gates the real statement-expression lowering limit as a named IR marker, making the next expansion point explicit
├─ tiny single-file codegen now treats returns inside if/else bodies as terminated blocks and continues through the join block without emitting extra branches
├─ function body lowering now lowers multiple statement/expression owner nodes per function from the body node sequence with a bounded cap, and verifies the owner count/limit through IR gates
├─ function body lowering now lowers BodyNodeSequence kind/meta/source-position/payload/semantic-role/expression-count data into generated function-body AST node sequence state
├─ function body lowering now dispatches AST node sequences into local/assignment/call/return/control semantic sequence state
├─ function body lowering now carries expression-table identifier/literal/string/bool/none/member/index categories into the scan and lowers literal type/access/call surfaces into the IR value flow
├─ generated stage2/stage3 binaries reject unsupported file build-ir inputs instead of returning project compiler IR
├─ regular ycc-ycpl build/build-ir paths now forbid bootstrap fallback under YCPL_NO_BOOTSTRAP=1 and fail unsupported inputs with an explicit diagnostic
├─ project_body.ll no longer relies on fixed expression probes in the compact path; it lowers statement-owned expressions and remaining tail expressions from the real scan.expr_* sequence
├─ statement-owned expressions now combine local/assignment/call/return semantic roles with parser/resolver-derived type kinds and lower that resolved role/type flow into IR
├─ project-wide function signature arity now survives as resolved call-expression arity and is folded into call value/type lowering
├─ checker and tinyir now handle YCPL helper function definitions, extern signatures, fixed LLVM function types, and call argument lowering up to eight arguments, with stage1/stage2 self-host gates covering eight-argument calls
├─ checker and tinyir now accept C-style `main(argc i32, argv *string) i32`; `build-ir-self` lowers the argv pointer parameter into LLVM alloca/store/load IR and verifies the output with the main-args fixture
├─ checker helper-function registration/lookup slots now extend to 16, with stage1/stage2 self-host gates covering a call to the ninth helper
├─ checker local-variable and i32[3] array backing slots now extend to 16, with stage1/stage2 self-host gates covering array load/store through the ninth local
├─ tinyir self-codegen helper/local slots now extend to 16, and build-ir-self gates the ninth helper plus eight-argument helper/extern calls and ninth-local array/index/assignment lowering into LLVM IR
├─ project_body.ll now raises the real AST lowering caps to 64 body nodes, 128 expressions, 64 statement expressions, and 64 statement owners, with IR gates pinning those values
├─ statement-owned expression lowering also respects the total expression cap, and CI fails if lowered node/expression counts exceed the configured caps
├─ project_body.ll now emits named IR markers for lowered and still-unlowered real node/expression counts, so CI can detect remaining summary/smoke coverage
├─ traversal project gates now carry i64 and []T/slice parameters through typed AST flow and verify i64/reference statement-expression markers in generated IR
└─ compiler-equivalent native ycc-ycpl is still the next implementation step
```

## Reserved But Not Implemented

```text
enum interface match is go defer select switch or type importas
```

```text
reserved token
├─ prevents future syntax collision
└─ has no parser/codegen support yet
```

Notes: `none` is a null literal, not an optional type; imported direct calls are
rejected; LSP navigation currently scans open documents rather than a full
project index.
