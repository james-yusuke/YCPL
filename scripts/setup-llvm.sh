#!/usr/bin/env bash
set -euo pipefail

LLVM_VERSION="${1:-22}"

if ! command -v sudo >/dev/null 2>&1; then
  SUDO=""
else
  SUDO="sudo"
fi

$SUDO apt-get update
$SUDO apt-get install -y curl gnupg wget

wget -q https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
$SUDO ./llvm.sh "$LLVM_VERSION"
$SUDO apt-get install -y \
  "clang-$LLVM_VERSION" \
  "llvm-$LLVM_VERSION-dev" \
  "llvm-$LLVM_VERSION-runtime" \
  "llvm-$LLVM_VERSION-tools"

$SUDO ln -sf "/usr/bin/clang-$LLVM_VERSION" /usr/local/bin/clang
$SUDO ln -sf "/usr/bin/llc-$LLVM_VERSION" /usr/local/bin/llc
$SUDO ln -sf "/usr/bin/llvm-config-$LLVM_VERSION" /usr/local/bin/llvm-config

rm -f llvm.sh
