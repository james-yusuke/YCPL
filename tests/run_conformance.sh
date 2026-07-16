#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ "$#" -lt 1 ]; then
  printf 'usage: %s <compiler>\n' "$0" >&2
  exit 2
fi

COMPILER="$1"
if [ ! -x "$COMPILER" ]; then
  printf 'compiler is not executable: %s\n' "$COMPILER" >&2
  exit 2
fi

case "$COMPILER" in
  /*) ;;
  *) COMPILER="$(cd "$(dirname "$COMPILER")" && pwd)/$(basename "$COMPILER")" ;;
esac

# The bootstrap regression suite is deliberately compiler-parameterized. It
# covers positive builds/runs, project/module behavior, runtime ownership and
# negative diagnostic locations/substrings, so the same oracle can be applied
# to stage0 and every self-host stage.
cd "$ROOT_DIR"
export YCPL_STL_ROOT="${YCPL_STL_ROOT:-$ROOT_DIR/stl}"
YCC="$COMPILER" exec "$ROOT_DIR/tests/run_bootstrap_regression.sh"
