const assert = require("node:assert/strict");
const vscode = require("vscode");

async function run() {
  const extension = vscode.extensions.getExtension("ycpl.ycpl-vscode");
  assert.ok(extension, "YCPL extension is installed in the Extension Development Host");
  await extension.activate();
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
  await vscode.commands.executeCommand("YCPL.showOutput");

  const files = await vscode.workspace.findFiles("**/main.yc");
  assert.ok(files.length > 0);
  const document = await vscode.workspace.openTextDocument(files[0]);
  await vscode.window.showTextDocument(document);
  await waitFor(async () => {
    const completions = await vscode.commands.executeCommand("vscode.executeCompletionItemProvider", document.uri, new vscode.Position(1, 4));
    return completions?.items.some((item) => item.label === "Vec");
  });
  const symbols = await vscode.commands.executeCommand("vscode.executeDocumentSymbolProvider", document.uri);
  assert.ok(symbols.some((symbol) => symbol.name === "main"), "packaged server indexes the open document");
  await vscode.commands.executeCommand("YCPL.restartLanguageServer");
  await waitFor(async () => {
    const symbols = await vscode.commands.executeCommand("vscode.executeDocumentSymbolProvider", document.uri);
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
