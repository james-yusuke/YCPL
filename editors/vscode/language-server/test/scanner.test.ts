import test from "node:test";
import assert from "node:assert/strict";
import * as fs from "node:fs/promises";
import * as os from "node:os";
import * as path from "node:path";
import { pathToFileURL } from "node:url";
import { YcplParser } from "../src/analysis/parser.js";
import { WorkspaceIndex } from "../src/analysis/workspaceIndex.js";
import { WorkspaceScanner } from "../src/analysis/workspaceScanner.js";

test("scans source once, skips generated directories, and preserves unsaved buffers", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "ycpl-scan-"));
  try {
    for (const directory of ["src", ".ycpl", ".vscode-test", "bazel-out", "target", "node_modules"]) {
      await fs.mkdir(path.join(root, directory));
      await fs.writeFile(path.join(root, directory, "generated.yc"), "fn disk() {}\n");
    }
    const parser = new YcplParser();
    const index = new WorkspaceIndex();
    const uri = pathToFileURL(path.join(root, "src", "generated.yc")).toString();
    const buffer = parser.parse(uri, 4, "fn unsaved() {}\n");
    index.update(buffer);
    const scanner = new WorkspaceScanner(parser, index);
    assert.equal(await scanner.scan(root), 0);
    assert.equal(index.getDocument(uri), buffer);
    index.remove(uri);
    assert.equal(await scanner.scan(root), 1);
    assert.equal(await scanner.scan(root), 0);
    assert.deepEqual(index.workspaceSymbols("").map((symbol) => symbol.name), ["disk"]);
  } finally {
    await fs.rm(root, { recursive: true, force: true });
  }
});
