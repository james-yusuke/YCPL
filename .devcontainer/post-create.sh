#!/usr/bin/env bash
set -euo pipefail

if ! git config --global --get-all safe.directory | grep -Fxq /workspace/YCPL; then
    git config --global --add safe.directory /workspace/YCPL
fi

bash .devcontainer/github-ssh.sh --configure-only

cmake -S . -B build -G Ninja -DLLVM_DIR="${LLVM_DIR:-/usr/lib/llvm-18/cmake}"

if ! command -v npm >/dev/null 2>&1; then
    printf '%s\n' "npm was not found in this container."
    printf '%s\n' "Rebuild the devcontainer so .devcontainer/Dockerfile installs nodejs/npm."
    exit 1
fi

if [ -f editors/vscode/package-lock.json ]; then
    npm ci --prefix editors/vscode
fi

bash .devcontainer/install-vscode-extension.sh
