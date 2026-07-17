---
name: ycpl-verification
description: Build, test, and diagnose YCPL across the C++ bootstrap, stage1-stage3 self-host chain, fixed-point IR comparison, conformance fixtures, runtime, standard library, LSP, VS Code extension, and GitHub Actions. Use after YCPL changes, when checking self-host completion, reproducing CI failures, validating Linux/macOS behavior, or preparing a release-quality handoff.
---

# YCPL Verification

Verify the smallest relevant surface first, then run every gate implied by the changed files.

## Prepare LLVM 22

Run from the repository root:

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
```

Preserve `LLVM_CONFIG`, `LLVM_BINDIR`, `LLC`, `CLANG`, and `LINKFLAGS` when reproducing CI. Do not silently substitute another LLVM major version.

## Select the gates

- `bootstrap/cpp/**`: build `//:ycc-bootstrap` and run the bootstrap regression.
- `compiler/ycpl/**`, `stl/**`, runtime, or language fixtures: rebuild all stages and run fixed-point plus conformance.
- `tools/lsp/**`: run native and common protocol tests.
- `editors/vscode/language-server/**`: run TypeScript build/unit tests and common protocol tests.
- `editors/vscode/extension/**`: typecheck, unit test, package, inspect, and load the packaged VSIX.
- `.github/workflows/**`: reproduce the exact failing command with the same exported environment; fix the implementation rather than weakening the oracle.

## Compiler and self-host gates

```sh
bazel build //:ycc-bootstrap //:ycc-stage1 //:ycc-stage2 //:ycc-stage3 //:ycc //:ycc-ycpl
bazel test //:examples_test --test_output=errors --test_timeout=1800
bazel test //:self_host_stage_test //:ycc_ycpl_test --test_output=errors --test_timeout=1800
bazel test --test_output=errors --test_timeout=1800 //...
```

Apply the same oracle directly when needed:

```sh
tests/run_conformance.sh "$PWD/bazel-bin/ycc"
YCC="$PWD/bazel-bin/ycc_bootstrap_bin" LINKFLAGS="" tests/run_bootstrap_regression.sh
```

The fixed-point gate must prove that stage2 and stage3 canonical LLVM IR match exactly. Do not normalize target triple, data layout, symbols, or instructions away.

## Manual compiler smoke test

```sh
rm -rf /tmp/ycpl-skill-hello
bazel-bin/ycc build examples/basics/hello.yc -o /tmp/ycpl-skill-hello
/tmp/ycpl-skill-hello/merged
```

Require `Hello World`. Confirm `bazel-bin/ycc` does not route to the C++ seed during normal commands.

To generate stage1 manually, run the bootstrap from the compiler project directory:

```sh
mkdir -p /tmp/ycpl-stage1
(
  cd compiler/ycpl
  ../../bazel-bin/ycc-bootstrap build -o /tmp/ycpl-stage1
)
```

Do not run `ycc-bootstrap build compiler/ycpl` from the repository root; the bootstrap project driver expects the project as its current directory.

## LSP and VS Code gates

```sh
npm ci --prefix editors/vscode/language-server
npm run check --prefix editors/vscode/language-server
npm ci --prefix editors/vscode/extension
npm run check --prefix editors/vscode/extension
tools/lsp/run_tests.sh
npm run test:extension --prefix editors/vscode/extension
npm run test:extension:native --prefix editors/vscode/extension
npm run package --prefix editors/vscode/extension
npm run check-package --prefix editors/vscode/extension
```

The VSIX must contain the bundled extension and TypeScript server without source, tests, or `node_modules`. Load the extracted/package artifact in the Extension Development Host so source-tree dependencies cannot hide packaging defects.

## Diagnose platform-only CI failures

Compare the first mismatching output line with the fixture and inspect the emitted LLVM IR around that value. Common ABI boundaries include:

- C variadic default argument promotions
- aggregate return and struct-field layout
- pointer/slice extern signatures
- POSIX feature macros and linker flags
- stdout flushing for LSP framing
- symlink traversal and runfiles paths

Do not change expected output merely because one platform exposes undefined behavior. Fix the lowering or ABI declaration and add a focused fixture when the boundary was previously unprotected.

## Report evidence

State the exact commands and counts that passed. Distinguish local macOS evidence from Linux CI evidence. If Linux was not executed locally, cite the ABI-correct IR or focused regression but do not claim the GitHub runner passed until it actually does.
