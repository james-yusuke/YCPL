#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
OUT_DIR="$ROOT_DIR/build/local-verification"
mkdir -p "$OUT_DIR"

# Fail early when editor dependencies have not been installed from the lockfiles.
for project in editors/vscode/language-server editors/vscode/extension; do
  if ! npm ls --prefix "$project" --depth=0 >/dev/null; then
    printf 'Install dependencies first: npm ci --prefix %s\n' "$project" >&2
    exit 1
  fi
done

if [ -z "${LLVM_CONFIG:-}" ]; then
  llvm_env="$(scripts/setup-llvm.sh 22 --print-env)"
  eval "$llvm_env"
fi
case "$("$LLVM_CONFIG" --version)" in
  22.*) ;;
  *) printf 'LLVM 22 is required. Set LLVM_CONFIG to its llvm-config.\n' >&2; exit 1 ;;
esac
export LLVM_BINDIR="$("$LLVM_CONFIG" --bindir)"
export LLVM_DIR="$("$LLVM_CONFIG" --cmakedir)"
export LLC="${LLC:-$LLVM_BINDIR/llc}"
export CLANG="${CLANG:-$LLVM_BINDIR/clang}"
export PATH="$LLVM_BINDIR:$PATH"
export YCPL_STL_ROOT="$ROOT_DIR/stl"
export YCPL_RUNTIME_SRC="$ROOT_DIR/bootstrap/cpp/runtime/yc_runtime.c"
if [ -z "${LINKFLAGS+x}" ]; then
  case "$(uname -s)" in
    Darwin) export LINKFLAGS="" ;;
    *) export LINKFLAGS="-no-pie" ;;
  esac
fi

cmake -S . -B "$OUT_DIR/bootstrap" -DCMAKE_BUILD_TYPE=Release
cmake --build "$OUT_DIR/bootstrap" --parallel 4

# Assertions stay enabled for the C runtime suite, including overflow rejection.
"$CLANG" -std=c11 -D_POSIX_C_SOURCE=200809L -g -fsanitize=address,undefined \
  -I . tests/runtime/yc_runtime_test.c "$YCPL_RUNTIME_SRC" -o "$OUT_DIR/runtime-test"
"$OUT_DIR/runtime-test"

YCC="$OUT_DIR/bootstrap/ycc" tests/run_conformance.sh "$OUT_DIR/bootstrap/ycc"
(cd compiler/ycpl && "$OUT_DIR/bootstrap/ycc" build -o "$OUT_DIR/stage1")
"$OUT_DIR/stage1/ycc" build compiler/ycpl -o "$OUT_DIR/stage2"
"$OUT_DIR/stage2/merged" build compiler/ycpl -o "$OUT_DIR/stage3"

# Reuse the same fixed-point and stage2/stage3 conformance oracle as Bazel.
RUNFILES_DIR="$OUT_DIR/runfiles"
mkdir -p "$RUNFILES_DIR"
for resource in compiler stl examples tests; do
  ln -sfn "$ROOT_DIR/$resource" "$RUNFILES_DIR/$resource"
done
ln -sfn "$OUT_DIR/stage2/merged" "$RUNFILES_DIR/ycc-stage2"
for compiler in ycc-stage3 ycc ycc-ycpl; do
  ln -sfn "$OUT_DIR/stage3/merged" "$RUNFILES_DIR/$compiler"
done
TEST_SRCDIR="$OUT_DIR" TEST_WORKSPACE=runfiles \
  tools/bazel/run_self_host_fixed_point_test.sh

export YCC="$OUT_DIR/stage3/merged"
npm run check --prefix editors/vscode/language-server
npm run check --prefix editors/vscode/extension
tools/lsp/run_tests.sh
npm run package --prefix editors/vscode/extension
npm run check-package --prefix editors/vscode/extension

# These tests launch the packaged VSIX in VS Code and need a desktop or Xvfb.
if [ "${YCPL_VERIFY_VSCODE_GUI:-0}" = 1 ]; then
  node editors/vscode/extension/test/run-extension-tests.mjs
  node editors/vscode/extension/test/run-native-extension-tests.mjs
fi

"$YCC" build examples/basics/hello.yc -o "$OUT_DIR/hello"
test "$("$OUT_DIR/hello/merged")" = 'Hello World'
printf '\nVerification passed. Self-hosted compiler: %s\n' "$YCC"
