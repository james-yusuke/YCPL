#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"
if [ -z "${LLVM_CONFIG:-}" ]; then
  eval "$(scripts/setup-llvm.sh 22 --print-env)"
fi
export LLVM_BINDIR="${LLVM_BINDIR:-$("$LLVM_CONFIG" --bindir)}"
export PATH="$LLVM_BINDIR:$PATH"

case "${1:-cargo}" in
  cargo)
    cargo fmt --manifest-path bootstrap/rust/Cargo.toml --check
    "$LLVM_BINDIR/clang-format" --dry-run --Werror bootstrap/rust/include/llvm_bridge.h bootstrap/rust/src/llvm_bridge.cc
    cargo test --manifest-path bootstrap/rust/Cargo.toml --locked
    cargo clippy --manifest-path bootstrap/rust/Cargo.toml --all-targets --locked -- -D warnings
    cargo build --manifest-path bootstrap/rust/Cargo.toml --locked --release
    seed="$root/bootstrap/rust/target/release/ycc-bootstrap-rust"
    bootstrap/rust/test_cli.sh "$seed"
    bootstrap/rust/test_conformance.sh "$seed"
    work="${YCPL_RUST_VERIFY_DIR:-$root/build/rust-self-host}"
    mkdir -p "$work"
    "$seed" build compiler/ycpl -o "$work/stage1"
    "$work/stage1/merged" build compiler/ycpl -o "$work/stage2"
    "$work/stage2/merged" build compiler/ycpl -o "$work/stage3"
    bootstrap/rust/test_fixed_point.sh "$work/stage2/merged" "$work/stage3/merged"
    ;;
  bazel)
    "${BAZEL:-bazel}" test \
      --action_env=PATH --action_env=LLVM_CONFIG --action_env=LLVM_BINDIR \
      --action_env=LLC --action_env=CLANG --action_env=LINKFLAGS \
      --test_env=PATH --test_env=LLVM_CONFIG --test_env=LLVM_BINDIR \
      --test_env=LLC --test_env=CLANG --test_env=LINKFLAGS \
      --test_output=errors --test_timeout=1800 \
      //bootstrap/rust:unit_tests //bootstrap/rust:cli_test //:rust_conformance_test //:rust_self_host_test
    ;;
  *) printf 'usage: %s [cargo|bazel]\n' "$0" >&2; exit 2 ;;
esac
