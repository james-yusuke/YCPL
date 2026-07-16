import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  compilerArguments,
  compilerTarget,
  findCompiler,
  findNativeServer,
  findProjectRoot,
  parseCompilerDiagnostics
} from "../dist/runtime.js";

function fixture() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "ycpl vscode "));
  fs.mkdirSync(path.join(root, "bazel-bin"), { recursive: true });
  fs.mkdirSync(path.join(root, "tools", "lsp", "build"), { recursive: true });
  fs.writeFileSync(path.join(root, "YCPL.json"), "{}");
  fs.writeFileSync(path.join(root, "main.yc"), "fn main() i32 { return 0 }");
  for (const file of [
    path.join(root, "bazel-bin", "ycc"),
    path.join(root, "tools", "lsp", "build", "YCPL-lsp")
  ]) {
    fs.writeFileSync(file, "#!/bin/sh\n");
    fs.chmodSync(file, 0o755);
  }
  return root;
}

test("discovers self-hosted compiler and native server in a workspace with spaces", () => {
  const root = fixture();
  assert.equal(findCompiler("", [root]), path.join(root, "bazel-bin", "ycc"));
  assert.deepEqual(findNativeServer("", [root]), {
    path: path.join(root, "tools", "lsp", "build", "YCPL-lsp"),
    source: "workspace"
  });
});

test("finds the nearest YCPL project root", () => {
  const root = fixture();
  assert.equal(findProjectRoot(path.join(root, "main.yc"), [root]), root);
  assert.deepEqual(compilerTarget(path.join(root, "main.yc"), [root]), {
    cwd: root,
    input: ".",
    projectRoot: root
  });
});

test("never selects a bootstrap compiler", () => {
  const root = fixture();
  const bootstrap = path.join(root, "ycc-bootstrap");
  fs.writeFileSync(bootstrap, "#!/bin/sh\n");
  fs.chmodSync(bootstrap, 0o755);
  assert.equal(findCompiler(bootstrap, [root]), path.join(root, "bazel-bin", "ycc"));
});

test("parses compiler diagnostics", () => {
  assert.deepEqual(parseCompilerDiagnostics("./src/main.yc:5:7: unknown symbol"), [{
    file: "./src/main.yc",
    line: 5,
    column: 7,
    message: "unknown symbol"
  }]);
});

test("builds compiler arguments for file and run commands", () => {
  const fileRoot = fs.mkdtempSync(path.join(os.tmpdir(), "ycpl single file "));
  const source = path.join(fileRoot, "main.yc");
  fs.writeFileSync(source, "fn main() i32 { return 0 }");
  assert.deepEqual(compilerTarget(source, [fileRoot]), { cwd: fileRoot, input: source });
  assert.deepEqual(compilerArguments("build", source, path.join(fileRoot, ".ycpl", "build")), [
    "build", source, "-o", path.join(fileRoot, ".ycpl", "build")
  ]);
  assert.deepEqual(compilerArguments("run", source, "out", ["one", "two words"]), [
    "run", source, "-o", "out", "--", "one", "two words"
  ]);
});
