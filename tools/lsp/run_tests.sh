#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
LSP_BIN="$("$ROOT_DIR/tools/lsp/build.sh" | tail -1)"

python3 "$ROOT_DIR/tools/lsp/check_protocol.py" "$LSP_BIN"
