const assert = require("node:assert/strict");
const vscode = require("vscode");
const { command, deadline, runWorkflows } = require("./workflows.cjs");

async function run() {
  const extension = vscode.extensions.getExtension("ycpl.ycpl-vscode");
  assert.ok(extension, "YCPL extension is installed in the Extension Development Host");
  console.log("YCPL workflow: activate packaged extension");
  await deadline(extension.activate(), 30000, "Extension activation did not finish");
  assert.equal(extension.isActive, true);

  const registered = new Set(await vscode.commands.getCommands(true));
  for (const command of [
    "YCPL.restartLanguageServer",
    "YCPL.check",
    "YCPL.build",
    "YCPL.buildIR",
    "YCPL.run",
    "YCPL.showOutput"
  ]) {
    assert.ok(registered.has(command), `${command} is registered`);
  }
  await command("YCPL.showOutput");

  const files = await vscode.workspace.findFiles("**/main.yc");
  assert.ok(files.length > 0);
  const document = await vscode.workspace.openTextDocument(files[0]);
  await vscode.window.showTextDocument(document);
  await waitFor(async () => {
    const completions = await command(
      "vscode.executeCompletionItemProvider",
      document.uri,
      new vscode.Position(1, 4)
    );
    return completions?.items.some((item) => item.label === "Vec");
  });
  const symbols = await command("vscode.executeDocumentSymbolProvider", document.uri);
  assert.ok(
    symbols.some((symbol) => symbol.name === "main"),
    "packaged server indexes the open document"
  );
  await deadline(runWorkflows(), 180000, "Editor workflows did not finish");
  await command("YCPL.restartLanguageServer");
  await waitFor(async () => {
    const symbols = await command("vscode.executeDocumentSymbolProvider", document.uri);
    return symbols?.some((symbol) => symbol.name === "main");
  });
}

async function waitFor(predicate) {
  const deadline = Date.now() + 15000;
  while (Date.now() < deadline) {
    if (await predicate()) return;
    await new Promise((resolve) => setTimeout(resolve, 50));
  }
  assert.fail("Packaged language server did not answer within 15 seconds");
}

module.exports = { run };
