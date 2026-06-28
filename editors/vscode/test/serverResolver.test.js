const assert = require("assert");
const fs = require("fs");
const path = require("path");
const resolver = require("../serverResolver");

function existsOnly(paths) {
  const set = new Set(paths);
  return (candidate) => set.has(candidate);
}

const workspace = path.join(path.sep, "workspace", "YCPL");
const extensionPath = path.join(workspace, "editors", "vscode");
const workspaceServer = path.join(workspace, "tools", "lsp", "build", "YCPL-lsp");
const buildScript = path.join(workspace, "tools", "lsp", "build.sh");
const extensionRoot = path.resolve(__dirname, "..");

{
  const resolved = resolver.resolveServerPath({
    configured: "${workspaceFolder}/custom/YCPL-lsp",
    workspaceFolders: [workspace],
    extensionPath,
    existsSync: existsOnly([workspaceServer]),
    homeDir: "/home/ubuntu"
  });
  assert.strictEqual(resolved.command, path.join(workspace, "custom", "YCPL-lsp"));
  assert.strictEqual(resolved.source, "configured");
}

{
  const resolved = resolver.resolveServerPath({
    configured: "",
    workspaceFolders: [workspace],
    extensionPath,
    existsSync: existsOnly([workspaceServer])
  });
  assert.strictEqual(resolved.command, workspaceServer);
  assert.strictEqual(resolved.source, "workspace");
}

{
  const developmentServer = path.join(workspace, "tools", "lsp", "build", "YCPL-lsp");
  const resolved = resolver.resolveServerPath({
    configured: "",
    workspaceFolders: [],
    extensionPath,
    existsSync: existsOnly([developmentServer])
  });
  assert.strictEqual(resolved.command, developmentServer);
  assert.strictEqual(resolved.source, "development");
}

{
  const resolved = resolver.resolveServerPath({
    configured: "",
    workspaceFolders: [workspace],
    extensionPath,
    existsSync: existsOnly([])
  });
  assert.strictEqual(resolved.command, "YCPL-lsp");
  assert.strictEqual(resolved.source, "path");
}

{
  assert.strictEqual(resolver.shouldBuildDefaultServer({
    configured: "",
    buildOnActivate: true,
    workspaceFolders: [workspace],
    existsSync: existsOnly([buildScript])
  }), true);
  assert.strictEqual(resolver.shouldBuildDefaultServer({
    configured: workspaceServer,
    buildOnActivate: true,
    workspaceFolders: [workspace],
    existsSync: existsOnly([buildScript])
  }), false);
}

{
  const build = resolver.buildDefaultServer({
    workspaceFolders: [workspace],
    spawnSync: () => ({
      status: 0,
      stdout: "compile log\n/workspace/YCPL/tools/lsp/build/YCPL-lsp\n",
      stderr: ""
    })
  });
  assert.strictEqual(build.serverPath, "/workspace/YCPL/tools/lsp/build/YCPL-lsp");
  assert.strictEqual(build.status, 0);
}

{
  const elf = Buffer.from([0x7f, 0x45, 0x4c, 0x46, 0x02]);
  assert.strictEqual(resolver.isLinuxElfOnNonLinux("/tmp/YCPL-lsp", "darwin", () => elf), true);
  assert.strictEqual(resolver.isLinuxElfOnNonLinux("/tmp/YCPL-lsp", "linux", () => elf), false);
}

{
  const pkg = JSON.parse(fs.readFileSync(path.join(extensionRoot, "package.json"), "utf8"));
  assert.deepStrictEqual(pkg.extensionKind, ["workspace"]);
  assert.strictEqual(pkg.contributes.configurationDefaults["[YCPL]"]["editor.tabSize"], 4);
  assert.strictEqual(pkg.contributes.configurationDefaults["[YCPL]"]["editor.insertSpaces"], true);
  assert.strictEqual(pkg.contributes.configurationDefaults["[YCPL]"]["editor.semanticHighlighting.enabled"], true);
  assert.ok(pkg.contributes.snippets.some((entry) => entry.language === "YCPL" && entry.path === "./snippets/YCPL.code-snippets"));
  assert.ok(pkg.contributes.semanticTokenScopes[0].scopes.function.includes("entity.name.function.YCPL"));
  assert.ok(pkg.contributes.semanticTokenScopes[0].scopes.property.includes("variable.other.property.YCPL"));
}

{
  const snippets = JSON.parse(fs.readFileSync(path.join(extensionRoot, "snippets", "YCPL.code-snippets"), "utf8"));
  for (const name of ["Main function", "Import with alias", "Struct", "For in", "Print line"]) {
    assert.ok(snippets[name], `missing snippet: ${name}`);
  }
  assert.strictEqual(snippets["Main function"].prefix, "main");
}

{
  const grammar = JSON.parse(fs.readFileSync(path.join(extensionRoot, "syntaxes", "YCPL.tmLanguage.json"), "utf8"));
  assert.strictEqual(grammar.scopeName, "source.YCPL");
  for (const key of ["module", "imports", "functions", "structs", "calls", "fields", "operators"]) {
    assert.ok(grammar.repository[key], `missing grammar repository entry: ${key}`);
  }

  const sample = 'import "std/fmt" as fmt\nstruct Point {\n    x i32\n}\nfn main() i32 {\n    fmt.println(42)\n}';
  const importPattern = new RegExp(grammar.repository.imports.patterns[0].match);
  const functionPattern = new RegExp(grammar.repository.functions.patterns[0].match);
  const callPattern = new RegExp(grammar.repository.calls.patterns[0].match);
  const operatorPattern = new RegExp(grammar.repository.operators.patterns[0].match);
  assert.ok(importPattern.test(sample), "import grammar should match");
  assert.ok(functionPattern.test(sample), "function grammar should match");
  assert.ok(callPattern.test(sample), "qualified call grammar should match");
  assert.ok(operatorPattern.test("x += 1"), "operator grammar should match");
}

{
  const languageConfig = JSON.parse(fs.readFileSync(path.join(extensionRoot, "language-configuration.json"), "utf8"));
  assert.ok(languageConfig.indentationRules);
  assert.ok(languageConfig.onEnterRules.length >= 3);
  assert.strictEqual(languageConfig.comments.lineComment, "//");
}

console.log("VSCode extension tests passed");
