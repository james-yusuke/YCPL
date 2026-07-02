#!/usr/bin/env bash
set -euo pipefail

LLVM_VERSION="${1:-22}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
usage: scripts/setup-llvm.sh [version]

Installs or locates LLVM without creating /usr or /usr/local symlinks.

After install, run:
  eval "\$(scripts/setup-llvm.sh ${LLVM_VERSION} --print-env)"

EOF
}

PRINT_ENV=0
if [ "${2:-}" = "--print-env" ] || [ "${1:-}" = "--print-env" ]; then
  PRINT_ENV=1
  if [ "${1:-}" = "--print-env" ]; then
    LLVM_VERSION="22"
  fi
fi

print_env() {
  local prefix="$1"
  local bindir="$prefix/bin"
  local cmakedir="$prefix/lib/cmake/llvm"
  if [ ! -x "$bindir/llvm-config" ]; then
    if [ -x "$bindir/llvm-config-$LLVM_VERSION" ]; then
      printf 'export LLVM_CONFIG=%q\n' "$bindir/llvm-config-$LLVM_VERSION"
    else
      printf 'LLVM llvm-config not found under %s\n' "$bindir" >&2
      return 1
    fi
  else
    printf 'export LLVM_CONFIG=%q\n' "$bindir/llvm-config"
  fi
  printf 'export LLVM_BINDIR=%q\n' "$bindir"
  printf 'export LLVM_DIR=%q\n' "$cmakedir"
  printf 'export PATH=%q:"$PATH"\n' "$bindir"
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ "$PRINT_ENV" -eq 1 ]; then
  case "$(uname -s)" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        if brew --prefix "llvm@$LLVM_VERSION" >/dev/null 2>&1; then
          print_env "$(brew --prefix "llvm@$LLVM_VERSION")"
        else
          print_env "$(brew --prefix llvm)"
        fi
      else
        printf 'Homebrew is required to locate LLVM on macOS.\n' >&2
        exit 1
      fi
      ;;
    Linux)
      print_env "/usr/lib/llvm-$LLVM_VERSION"
      ;;
    *)
      printf 'Unsupported platform: %s\n' "$(uname -s)" >&2
      exit 1
      ;;
  esac
  exit 0
fi

if ! command -v sudo >/dev/null 2>&1; then
  SUDO=""
else
  SUDO="sudo"
fi

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      printf 'Homebrew is required to install LLVM on macOS.\n' >&2
      exit 1
    fi
    if ! brew --prefix "llvm@$LLVM_VERSION" >/dev/null 2>&1; then
      brew install "llvm@$LLVM_VERSION"
    fi
    "$SCRIPT_DIR/setup-llvm.sh" "$LLVM_VERSION" --print-env
    ;;
  Linux)
    if ! command -v apt-get >/dev/null 2>&1; then
      printf 'Only apt-based Linux setup is automated. Set LLVM_CONFIG/LLVM_DIR manually.\n' >&2
      exit 1
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

    rm -f llvm.sh
    "$SCRIPT_DIR/setup-llvm.sh" "$LLVM_VERSION" --print-env
    ;;
  *)
    printf 'Unsupported platform: %s\n' "$(uname -s)" >&2
    exit 1
    ;;
esac
