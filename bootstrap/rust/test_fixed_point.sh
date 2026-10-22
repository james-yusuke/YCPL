#!/usr/bin/env bash
set -euo pipefail

root="${TEST_SRCDIR:-}/${TEST_WORKSPACE:-_main}"
if [ -z "${TEST_SRCDIR:-}" ]; then
  root="$(cd "$(dirname "$0")/../.." && pwd)"
fi
stage2="${1:-$root/ycc-stage2-from-rust}"
stage3="${2:-$root/ycc-stage3-from-rust}"
cd "$root"
test -x "$stage2"
test -x "$stage3"
export YCPL_STL_ROOT="$root/stl"
export YCPL_RUNTIME_SRC="$root/bootstrap/cpp/runtime/yc_runtime.c"
unset YCC YCPL_BOOTSTRAP_YCC YCPL_NO_BOOTSTRAP YCPL_SELFHOST_STRICT

llvm_bindir="${LLVM_BINDIR:-$("${LLVM_CONFIG:-llvm-config}" --bindir)}"
test "$("$llvm_bindir/llvm-config" --version | cut -d. -f1)" = 22
work="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-rust-fixed-point.XXXXXX")"
trap 'rm -rf "$work"' EXIT

for stage in 2 3; do
  compiler="$stage2"
  if [ "$stage" = 3 ]; then compiler="$stage3"; fi
  "$compiler" check compiler/ycpl
  "$compiler" build-ir compiler/ycpl -o "$work/stage$stage"
  "$llvm_bindir/llvm-as" "$work/stage$stage/merged.ll" -o "$work/stage$stage.bc"
  "$llvm_bindir/llvm-dis" "$work/stage$stage.bc" -o "$work/stage$stage.dis.ll"
  # This is exactly the existing oracle: only source metadata may differ.
  sed -E 's@^; ModuleID = .*@; ModuleID = "<fixed>"@; s@^source_filename = .*@source_filename = "<fixed>"@' \
    "$work/stage$stage.dis.ll" > "$work/stage$stage.canonical.ll"
done
cmp "$work/stage2.canonical.ll" "$work/stage3.canonical.ll"

for stage in 2 3; do
  compiler="$stage2"
  if [ "$stage" = 3 ]; then compiler="$stage3"; fi
  if ! tests/run_conformance.sh "$compiler" > "$work/stage$stage-conformance.log" 2>&1; then
    cat "$work/stage$stage-conformance.log" >&2
    exit 1
  fi
  tail -4 "$work/stage$stage-conformance.log"
  "$compiler" build examples/basics/hello.yc -o "$work/hello$stage"
  test "$("$work/hello$stage/merged")" = "Hello World"
done
printf 'Rust seed: stage2/stage3 canonical IR and conformance verified\n'
