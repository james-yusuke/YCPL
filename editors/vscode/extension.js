const vscode = require("vscode");
const resolver = require("./serverResolver");

let client;
let output;

function log(message) {
  if (output) {
    output.appendLine(message);
  }
}

function showStartupError(message) {
  log(message);
  vscode.window.showErrorMessage(message);
}

function loadLanguageClient() {
  try {
    return require("vscode-languageclient/node").LanguageClient;
  } catch (err) {
    throw new Error(`Missing vscode-languageclient dependency. Run "npm ci --prefix editors/vscode". ${err.message}`);
  }
}

function activate(context) {
  output = vscode.window.createOutputChannel("YCPL Language Server");
  context.subscriptions.push(output);

  const config = vscode.workspace.getConfiguration("YCPL");
  const configured = config.get("server.path");
  const buildOnActivate = config.get("server.buildOnActivate");
  const workspaceFolders = vscode.workspace.workspaceFolders || [];

  if (resolver.shouldBuildDefaultServer({
    configured,
    buildOnActivate,
    workspaceFolders
  })) {
    log("Building YCPL LSP with tools/lsp/build.sh...");
    const build = resolver.buildDefaultServer({ workspaceFolders });
    if (build.stdout) {
      log(build.stdout.trim());
    }
    if (build.stderr) {
      log(build.stderr.trim());
    }
    if (build.error || build.status !== 0) {
      showStartupError(`YCPL LSP build failed. See the "YCPL Language Server" output for details.`);
      return undefined;
    }
    log(`Built YCPL LSP: ${build.serverPath}`);
  }

  const resolved = resolver.resolveServerPath({
    configured,
    workspaceFolders,
    extensionPath: context.extensionPath,
    homeDir: process.env.HOME || process.env.USERPROFILE || ""
  });
  const serverPath = resolved.command;

  log(`Resolved YCPL LSP (${resolved.source}): ${serverPath}`);
  if (resolver.isLinuxElfOnNonLinux(serverPath)) {
    showStartupError("YCPL LSP is a Linux binary. Open this workspace in the YCPL devcontainer or set YCPL.server.path to a host-native YCPL-lsp binary.");
    return undefined;
  }

  let LanguageClient;
  try {
    LanguageClient = loadLanguageClient();
  } catch (err) {
    showStartupError(err.message);
    return undefined;
  }

  client = new LanguageClient(
    "YCPL",
    "YCPL Language Server",
    {
      command: serverPath,
      args: [],
      options: {}
    },
    {
      documentSelector: [{ scheme: "file", language: "YCPL" }],
      synchronize: {
        fileEvents: vscode.workspace.createFileSystemWatcher("**/*.yc")
      }
    }
  );

  context.subscriptions.push(client);
  return client.start().catch((err) => {
    showStartupError(`YCPL LSP failed to start at ${serverPath}: ${err.message}`);
  });
}

function deactivate() {
  if (!client) {
    return undefined;
  }
  return client.stop();
}

module.exports = {
  activate,
  deactivate
};
