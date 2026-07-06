import * as path from "node:path";
import { fileURLToPath } from "node:url";
import * as vscode from "vscode";
import {
  LanguageClient,
  TransportKind,
  type LanguageClientOptions,
  type ServerOptions
} from "vscode-languageclient/node";

let client: LanguageClient | undefined;

const currentFile = fileURLToPath(import.meta.url);
const currentDir = path.dirname(currentFile);

/**
 * Activates the YCPL VS Code extension and starts the language client.
 */
export async function activate(context: vscode.ExtensionContext): Promise<void> {
  context.subscriptions.push(
    vscode.commands.registerCommand("YCPL.restartLanguageServer", async () => {
      await restartLanguageServer(context);
    })
  );

  await startLanguageServer(context);
}

/**
 * Stops the language server when VS Code deactivates the extension.
 */
export async function deactivate(): Promise<void> {
  await stopLanguageServer();
}

async function restartLanguageServer(context: vscode.ExtensionContext): Promise<void> {
  await stopLanguageServer();
  await startLanguageServer(context);
}

async function stopLanguageServer(): Promise<void> {
  if (!client) {
    return;
  }
  const running = client;
  client = undefined;
  await running.stop();
}

async function startLanguageServer(context: vscode.ExtensionContext): Promise<void> {
  const config = vscode.workspace.getConfiguration("YCPL");
  const configuredServerPath = config.get<string>("server.path", "").trim();
  const serverModule = configuredServerPath.length > 0
    ? configuredServerPath
    : path.resolve(currentDir, "..", "..", "language-server", "dist", "src", "server.js");

  const serverOptions: ServerOptions = configuredServerPath.length > 0
    ? {
        command: serverModule,
        transport: TransportKind.stdio
      }
    : {
        run: {
          module: serverModule,
          transport: TransportKind.ipc
        },
        debug: {
          module: serverModule,
          transport: TransportKind.ipc,
          options: {
            execArgv: ["--nolazy", "--inspect=6009"]
          }
        }
      };

  const outputChannel = vscode.window.createOutputChannel("YCPL Language Server", { log: true });
  const clientOptions: LanguageClientOptions = {
    documentSelector: [{ scheme: "file", language: "ycpl" }],
    outputChannel,
    traceOutputChannel: outputChannel,
    diagnosticCollectionName: "ycpl",
    synchronize: {
      fileEvents: vscode.workspace.createFileSystemWatcher("**/*.yc")
    },
    initializationOptions: {
      inlayHints: {
        enabled: config.get<boolean>("inlayHints.enabled", true)
      }
    }
  };

  client = new LanguageClient("ycpl", "YCPL Language Server", serverOptions, clientOptions);
  context.subscriptions.push(client, outputChannel);
  await client.start();
}
