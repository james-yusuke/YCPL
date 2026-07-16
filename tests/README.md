# YCPL Test Fixtures

This directory contains compiler inputs that are intentionally not presented as
user-facing examples.

- `fixtures/negative`: invalid programs and expected runtime failures
- `fixtures/selfhost`: focused YCPL compiler lowering and stage-chain inputs
- `fixtures/runtime`: managed allocation, escape, and cleanup checks
- `fixtures/compat`: deprecated API compatibility checks
- `fixtures/compiler`: parser, resolver, stdlib, and LLVM bridge checks
- `fixtures/projects`: project resolver fixtures
- `runtime`: C-level managed runtime unit tests

Run the bootstrap regression suite with:

```sh
tests/run_bootstrap_regression.sh
```

Apply the same conformance oracle to the promoted self-hosted compiler with:

```sh
tests/run_conformance.sh ./bazel-bin/ycc
```

The Bazel fixed-point gate rebuilds the compiler with stage2 and stage3,
canonicalizes both LLVM IR modules, compares them exactly, and runs the 70-case
conformance suite with both generated compilers:

```sh
bazel test //:self_host_stage_test //:ycc_ycpl_test
```
