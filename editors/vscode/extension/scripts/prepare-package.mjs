import fs from "node:fs";

fs.mkdirSync(new URL("../artifacts", import.meta.url), { recursive: true });
fs.rmSync(new URL("../artifacts/ycpl-vscode.vsix", import.meta.url), { force: true });
