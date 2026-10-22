# Rust bootstrap

[日本語](README.ja.md)

An independent YCPL seed compiler. Rust owns lexing, parsing, name resolution,
type checking, ownership and LLVM instruction selection. A small C++ wrapper
includes LLVM headers and exposes checked operations through `cxx`. Native
programs share the existing C managed runtime and STL.

## Build and run

Requires Rust **1.97.1** (edition 2024), LLVM **22**, a C++20 compiler, `llc` and
`clang`. `cxx`, `cxx-build` and the Bazel `cxxbridge-cmd` host tool are pinned to
**1.0.205**; `rules_rust` is **0.74.0**. Bazel compiles the bridge and wrapper
directly and shares the application's Cargo manifest and lockfile.

Run from the repository root:

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
cargo build --manifest-path bootstrap/rust/Cargo.toml --release --locked
bootstrap/rust/target/release/ycc-bootstrap-rust run examples/basics/hello.yc -o build/rust-hello

bazel build //:ycc-bootstrap-rust
bazel-bin/bootstrap/rust/ycc-bootstrap-rust build examples/basics/hello.yc -o build/rust-hello
build/rust-hello/merged
```

Commands: `build`, `build-ir` (`ll` alias), `run`, `debug`, `lex`, `parse`,
`check`, `resolve`, `help`. Options: `-o DIRECTORY`, `--keep-obj`, `--link-llvm`,
and `-- PROGRAM_ARGUMENTS`. Inputs may be `.yc` files, directories or
`YCPL.json` projects. Output priority is `-o`, project `output`, then `build`.
Verified IR is `merged.ll`, native output is `merged`; a single file also
produces `<stem>.ll` for the shared test harness.

The driver honors `LLVM_CONFIG`, `LLVM_BINDIR`, `LLVM_DIR`, `LLC`, `CLANG`,
`LINKFLAGS`, `YCPL_STL_ROOT`, `YCPL_RUNTIME_SRC` and `YCPL_RUNTIME_LIB`.
External tools receive argument arrays, including paths containing spaces.
`LINKFLAGS` supports quoting without executing a shell.

## Reproduce every gate

```sh
bootstrap/rust/verify.sh cargo
bootstrap/rust/verify.sh bazel
```

Cargo verification checks rustfmt, clang-format and Clippy, Rust/native and CLI
regressions, and the full shared conformance suite. It builds stage1 using the
Rust seed, stage2 using stage1, and stage3 using stage2. Both final stages run
conformance. Their LLVM IR is assembled/disassembled and compared with the
existing oracle: only ModuleID and source filename are stabilized.

Individual Bazel targets:

```sh
bazel build //:ycc-stage1-from-rust //:ycc-stage2-from-rust //:ycc-stage3-from-rust
bazel test //bootstrap/rust:unit_tests //bootstrap/rust:cli_test \
  //:rust_conformance_test //:rust_self_host_test
```

Conformance/fixed-point Bazel tests are `exclusive`, because the shared harness
uses common temporary filenames. Run Cargo and Bazel verification sequentially.
The standard C++ seed and promoted `//:ycc` chain remain available. CI runs both
paths on macOS and Ubuntu 24.04.

## Source layout

| Source | Responsibility |
|---|---|
| `src/{lexer,parser,ast}.rs` | Located tokens and dynamic AST arenas |
| `src/project.rs` | Sorted source discovery, imports and cycle termination |
| `src/codegen/mod.rs` | Symbols, type visibility and type resolution |
| `src/codegen/{control,expressions,calls,collections,ir}.rs` | Lowering and ownership |
| `src/{bridge,llvm}.rs` | `cxx` declarations and typed Rust handles |
| `include/llvm_bridge.h`, `src/llvm_bridge.cc` | LLVM context, module and builder owner |
| `src/tests.rs`, `test_cli.sh` | Isolation, malformed input, lifetime, ABI and CLI regressions |

Handles carry a session ID, kind and index. Foreign, stale or mistyped handles
return `Result` errors. The native target's data layout governs aggregate sizes;
module verification precedes serialization. Cargo,
Bazel and generated FFI outputs are ignored and must not be committed.
