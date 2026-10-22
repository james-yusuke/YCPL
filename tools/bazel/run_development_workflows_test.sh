#!/usr/bin/env bash
set -euo pipefail
root="${TEST_SRCDIR}/${TEST_WORKSPACE}"
export YCC="$root/ycc"
export YCPL_STL_ROOT="$root/stl"
export YCPL_RUNTIME_SRC="$root/bootstrap/cpp/runtime/yc_runtime.c"
exec "$root/tests/test_development_workflows.sh"
