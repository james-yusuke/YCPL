#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
LSP_BIN="$("$ROOT_DIR/tools/lsp/build.sh" | tail -1)"

python3 "$ROOT_DIR/tools/lsp/check_protocol.py" "$LSP_BIN"
python3 "$ROOT_DIR/tools/lsp/check_common_protocol.py" "$LSP_BIN"

npm run build --prefix "$ROOT_DIR/editors/vscode/extension" >/dev/null
python3 "$ROOT_DIR/tools/lsp/check_common_protocol.py" \
  "$ROOT_DIR/editors/vscode/extension/server/server.cjs"
