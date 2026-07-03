# Contributing to YCPL

YCPL is an experimental systems language and compiler project. Contributions are
welcome, but the codebase is moving quickly while the compiler transitions from
the C++ bootstrap implementation to the YCPL implementation.

## Project Direction

The current goal is full self-hosting:

```text
C++ bootstrap ycc
  -> builds stage1 ycc-ycpl
  -> stage1 builds compiler/ycpl
  -> generated compiler repeats the build without bootstrap fallback
```

Until that gate is stable, keep `ycc` as the C++ bootstrap compiler and improve
`ycc-ycpl` incrementally.

## Development Setup

Use LLVM through explicit discovery. Do not add `/usr` or `/usr/local` symlinks
for YCPL development.

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
bazel build //:ycc //:ycc-ycpl
```

Explicit paths are also supported:

```sh
LLVM_CONFIG=/opt/homebrew/opt/llvm@22/bin/llvm-config bazel build //:ycc-ycpl
LLVM_DIR=/opt/homebrew/opt/llvm@22/lib/cmake/llvm cmake -S . -B build
```

## Validation

Before sending a change, run the smallest relevant tests first, then the broader
gates when compiler behavior changes.

```sh
bazel test //:ycc_ycpl_test //:self_host_stage_test
bazel test //:examples_test //:lsp_protocol_test //:ycc_ycpl_test //:self_host_stage_test
cmake --build /tmp/ycpl-cmake-check
git diff --check
```

For self-hosting work, also check strict project IR generation:

```sh
YCPL_NO_BOOTSTRAP=1 bazel-bin/ycc-ycpl build-ir compiler/ycpl -o /tmp/ycpl-self-ir
llc -filetype=obj /tmp/ycpl-self-ir/merged.ll -o /tmp/ycpl-self-ir/merged.o
```

## Coding Guidelines

- Prefer existing module patterns over new abstractions.
- Keep bootstrap C++ changes separate from YCPL compiler changes when possible.
- Do not mutate system paths or require global LLVM installs.
- Keep generated build artifacts out of source control.
- Make malformed source fail with diagnostics rather than crashes.
- Avoid unchecked writes; builders and arenas should track length and capacity.
- When adding self-hosting support, add a test gate that prevents fallback or
  count-only behavior from silently returning.

## Documentation

Keep English and Japanese documentation in sync when changing user-facing
behavior:

- `README.md`
- `README-JA.md`
- `docs/*.en.md`
- `docs/*.ja.md`

Use `.yc` in examples and `ycc` / `ycc-ycpl` consistently.

## Security

Please read `SECURITY.md` before reporting vulnerabilities. Do not disclose
security issues in public GitHub issues.
