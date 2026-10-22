#!/usr/bin/env bash
set -euo pipefail

root="${TEST_SRCDIR:-}/${TEST_WORKSPACE:-_main}"
if [ -z "${TEST_SRCDIR:-}" ]; then
  root="$(cd "$(dirname "$0")/../.." && pwd)"
fi
seed="${1:-$root/bootstrap/rust/target/release/ycc-bootstrap-rust}"
cd "$root"
if [[ "$seed" != /* ]]; then seed="$root/$seed"; fi
export YCPL_STL_ROOT="$root/stl"
export YCPL_RUNTIME_SRC="$root/bootstrap/cpp/runtime/yc_runtime.c"
exec tests/run_conformance.sh "$seed"
