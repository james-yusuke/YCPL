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
}

module.exports = { run };
