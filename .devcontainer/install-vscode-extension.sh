#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-/workspace/YCPL}"
EXT_SRC="${ROOT_DIR}/editors/vscode"

if [ ! -f "${EXT_SRC}/package.json" ]; then
    printf 'YCPL VSCode extension package not found: %s\n' "${EXT_SRC}/package.json" >&2
    exit 1
fi

if ! command -v node >/dev/null 2>&1; then
    printf '%s\n' "node was not found. Rebuild the devcontainer so nodejs/npm are installed." >&2
    exit 1
fi

PUBLISHER="$(node -e "process.stdout.write(require('${EXT_SRC}/package.json').publisher)")"
NAME="$(node -e "process.stdout.write(require('${EXT_SRC}/package.json').name)")"
VERSION="$(node -e "process.stdout.write(require('${EXT_SRC}/package.json').version)")"
EXT_ID="${PUBLISHER}.${NAME}-${VERSION}"

install_link() {
    base="$1"
    mkdir -p "${base}"
    target="${base}/${EXT_ID}"

    if [ -e "${target}" ] && [ ! -L "${target}" ]; then
        printf 'YCPL extension target exists and is not a symlink, leaving it alone: %s\n' "${target}"
        return 0
    fi

    ln -sfn "${EXT_SRC}" "${target}"
    printf 'Linked YCPL VSCode extension: %s -> %s\n' "${target}" "${EXT_SRC}"
}

install_link "${HOME}/.vscode-server/extensions"
install_link "${HOME}/.vscode-server-insiders/extensions"

printf '%s\n' "Reload the VSCode window after this script runs so the extension host rescans extensions."
