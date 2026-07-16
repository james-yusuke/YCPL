import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { runTests } from "@vscode/test-electron";

const sourceExtensionPath = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const extensionTestsPath = path.join(sourceExtensionPath, "test", "suite", "index.cjs");
const packagedExtension = fs.mkdtempSync(path.join(os.tmpdir(), "ycpl-vscode-vsix-"));
execFileSync("unzip", ["-q", path.join(sourceExtensionPath, "artifacts", "ycpl-vscode.vsix"), "-d", packagedExtension]);
const extensionDevelopmentPath = path.join(packagedExtension, "extension");
const workspace = fs.mkdtempSync(path.join(os.tmpdir(), "ycpl-vscode-fallback-"));
fs.mkdirSync(path.join(workspace, ".vscode"), { recursive: true });
fs.mkdirSync(path.join(workspace, "tools", "lsp", "build"), { recursive: true });
fs.writeFileSync(path.join(workspace, ".vscode", "settings.json"), JSON.stringify({
  "YCPL.server.mode": "auto",
  "YCPL.checkOnSave": false
}));
fs.writeFileSync(path.join(workspace, "main.yc"), "fn main() i32 {\n    return 0\n}\n");
const failingNative = path.join(workspace, "tools", "lsp", "build", "YCPL-lsp");
fs.writeFileSync(failingNative, "#!/bin/sh\nexit 1\n");
fs.chmodSync(failingNative, 0o755);

try {
  await runTests({
    extensionDevelopmentPath,
    extensionTestsPath,
    launchArgs: [workspace, "--disable-extensions"]
  });
} finally {
  fs.rmSync(workspace, { recursive: true, force: true });
  fs.rmSync(packagedExtension, { recursive: true, force: true });
}
