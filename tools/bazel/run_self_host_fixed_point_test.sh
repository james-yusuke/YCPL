#!/usr/bin/env bash
set -euo pipefail
trap 'printf "run_self_host_fixed_point_test failed at line %d\n" "$LINENO" >&2' ERR

RUNFILES_ROOT="${TEST_SRCDIR}/${TEST_WORKSPACE}"
STAGE2="${RUNFILES_ROOT}/ycc-stage2"
STAGE3="${RUNFILES_ROOT}/ycc-stage3"
PROMOTED="${RUNFILES_ROOT}/ycc"
YCC_YCPL="${RUNFILES_ROOT}/ycc-ycpl"

for compiler in "$STAGE2" "$STAGE3" "$PROMOTED" "$YCC_YCPL"; do
  test -x "$compiler"
done

cd "$RUNFILES_ROOT"

llvm_bindir="${LLVM_BINDIR:-}"
if [ -z "$llvm_bindir" ]; then
  for candidate in /opt/homebrew/opt/llvm@22/bin /opt/homebrew/opt/llvm/bin /usr/local/opt/llvm@22/bin /usr/lib/llvm-22/bin; do
    if [ -x "$candidate/llvm-as" ]; then
      llvm_bindir="$candidate"
      break
    fi
  done
fi
test -x "$llvm_bindir/llvm-as"
test -x "$llvm_bindir/llvm-dis"

# Once stage1 exists, neither the seed executable nor any fallback environment
# variable participates in the fixed-point build.
unset YCPL_BOOTSTRAP_YCC YCPL_NO_BOOTSTRAP YCPL_SELFHOST_STRICT YCC
export PATH="$llvm_bindir:/usr/bin:/bin"

work="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-fixed-point.XXXXXX")"
trap 'rm -rf "$work"' EXIT

"$STAGE2" build-ir compiler/ycpl -o "$work/stage2"
"$STAGE3" build-ir compiler/ycpl -o "$work/stage3"

"$llvm_bindir/llvm-as" "$work/stage2/merged.ll" -o "$work/stage2.bc"
"$llvm_bindir/llvm-as" "$work/stage3/merged.ll" -o "$work/stage3.bc"
"$llvm_bindir/llvm-dis" "$work/stage2.bc" -o "$work/stage2.dis.ll"
"$llvm_bindir/llvm-dis" "$work/stage3.bc" -o "$work/stage3.dis.ll"
sed -E 's@^; ModuleID = .*@; ModuleID = "<fixed>"@; s@^source_filename = .*@source_filename = "<fixed>"@' "$work/stage2.dis.ll" >"$work/stage2.canonical.ll"
sed -E 's@^; ModuleID = .*@; ModuleID = "<fixed>"@; s@^source_filename = .*@source_filename = "<fixed>"@' "$work/stage3.dis.ll" >"$work/stage3.canonical.ll"
cmp "$work/stage2.canonical.ll" "$work/stage3.canonical.ll"

"$STAGE2" build examples/basics/hello.yc -o "$work/hello2"
"$STAGE3" build examples/basics/hello.yc -o "$work/hello3"
test "$("$work/hello2/merged")" = "Hello World"
test "$("$work/hello3/merged")" = "Hello World"

"$PROMOTED" check compiler/ycpl
"$YCC_YCPL" check compiler/ycpl

if ! LLVM_BINDIR="$llvm_bindir" YCPL_STL_ROOT="$RUNFILES_ROOT/stl" \
  tests/run_conformance.sh "$STAGE2" >"$work/stage2-conformance.log" 2>&1; then
  cat "$work/stage2-conformance.log" >&2
  exit 1
fi
if ! LLVM_BINDIR="$llvm_bindir" YCPL_STL_ROOT="$RUNFILES_ROOT/stl" \
  tests/run_conformance.sh "$STAGE3" >"$work/stage3-conformance.log" 2>&1; then
  cat "$work/stage3-conformance.log" >&2
  exit 1
fi
stage2_result="$(grep -Eo '[0-9]+/[0-9]+ passed' "$work/stage2-conformance.log" | tail -n 1)"
stage3_result="$(grep -Eo '[0-9]+/[0-9]+ passed' "$work/stage3-conformance.log" | tail -n 1)"
test -n "$stage2_result"
test "$stage2_result" = "$stage3_result"
stage_passed="${stage2_result%%/*}"
stage_total="${stage2_result#*/}"
stage_total="${stage_total%% *}"
test "$stage_passed" = "$stage_total"

if strings "$PROMOTED" | grep -E 'YCPL_BOOTSTRAP_YCC|YCPL_NO_BOOTSTRAP|YCPL_SELFHOST_STRICT|--bootstrap|compiler-smoke' >/dev/null; then
  printf 'promoted ycc still contains a bootstrap/fallback route\n' >&2
  exit 1
fi

printf 'stage2/stage3 fixed point and %s-case conformance verified\n' "$stage_total"
