import * as fs from "node:fs";
import * as path from "node:path";
import { spawn } from "node:child_process";
import * as vscode from "vscode";
import {
  LanguageClient,
  CloseAction,
  ErrorAction,
  TransportKind,
  type LanguageClientOptions,
  type ServerOptions
} from "vscode-languageclient/node";
import {
  compilerEnvironment,
  compilerArguments,
  compilerTarget,
  findCompiler,
  findNativeServer,
  parseCompilerDiagnostics,
  resolveConfiguredPath,
  type ServerMode
} from "./runtime.js";
import { registerWorkbench } from "./workbench.js";
import { execute } from "./process.js";

let client: LanguageClient | undefined;
let output: vscode.LogOutputChannel;
let status: vscode.StatusBarItem;
let compilerDiagnostics: vscode.DiagnosticCollection;
const saveTimers = new Map<string, NodeJS.Timeout>();
const automaticChecks = new Map<string, vscode.CancellationTokenSource>();
const diagnosticFiles = new Map<string, Set<string>>();
let sourceWatcher: vscode.FileSystemWatcher | undefined;
let serverOperation: Promise<void> = Promise.resolve();

export async function activate(context: vscode.ExtensionContext): Promise<void> {
  output = vscode.window.createOutputChannel("YCPL", { log: true });
  status = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 40);
  status.name = "YCPL Language Server";
  status.command = "YCPL.showOutput";
  compilerDiagnostics = vscode.languages.createDiagnosticCollection("ycpl-compiler");
  context.subscriptions.push(output, status, compilerDiagnostics);

  registerCommands(context);
  registerWorkbench(context, output);
  context.subscriptions.push(
    vscode.workspace.onDidSaveTextDocument((document) => scheduleCheckOnSave(document)),
    vscode.workspace.onDidChangeTextDocument((event) =>
      automaticChecks.get(event.document.uri.toString())?.cancel()
    ),
    vscode.workspace.onDidGrantWorkspaceTrust(async () => restartLanguageServer(context)),
    vscode.workspace.onDidChangeConfiguration(async (event) => {
      if (event.affectsConfiguration("YCPL.server") || event.affectsConfiguration("YCPL.stlRoot")) {
        await restartLanguageServer(context);
      }
      if (event.affectsConfiguration("YCPL.checkOnSave") && !configuration().get("checkOnSave", true)) {
        clearSaveTimer();
      }
    })
  );

  await restartLanguageServer(context);
}

export async function deactivate(): Promise<void> {
  clearSaveTimer();
  await serverOperation.catch(() => undefined);
  await stopLanguageServer();
}

function registerCommands(context: vscode.ExtensionContext): void {
  const commands: Array<[string, () => Promise<void> | void]> = [
    ["YCPL.restartLanguageServer", () => restartLanguageServer(context)],
    ["YCPL.check", () => runCompilerCommand("check")],
    ["YCPL.build", () => runCompilerCommand("build")],
    ["YCPL.buildIR", () => runCompilerCommand("build-ir")],
    ["YCPL.run", () => runCompilerCommand("run")],
    ["YCPL.showOutput", () => output.show(true)]
  ];
  for (const [name, callback] of commands) {
    context.subscriptions.push(vscode.commands.registerCommand(name, callback));
  }
}

function configuration(resource?: vscode.Uri): vscode.WorkspaceConfiguration {
  const target =
    resource ?? vscode.window.activeTextEditor?.document.uri ?? vscode.workspace.workspaceFolders?.[0]?.uri;
  return vscode.workspace.getConfiguration("YCPL", target);
}

function workspaceRoots(): string[] {
  return vscode.workspace.workspaceFolders?.map((folder) => folder.uri.fsPath) ?? [];
}

async function restartLanguageServer(context: vscode.ExtensionContext): Promise<void> {
  const operation = serverOperation
    .catch(() => undefined)
    .then(async () => {
      await stopLanguageServer();
      await startLanguageServer(context);
    });
  serverOperation = operation;
  return operation;
}

async function stopLanguageServer(): Promise<void> {
  const running = client;
  client = undefined;
  try {
    if (running) await running.stop();
  } catch (error) {
    output.warn(`Language Server had already stopped: ${String(error)}`);
    await running?.dispose();
  } finally {
    sourceWatcher?.dispose();
    sourceWatcher = undefined;
    status.hide();
  }
}

async function startLanguageServer(context: vscode.ExtensionContext): Promise<void> {
  const config = configuration();
  const roots = workspaceRoots();
  const root = roots[0];
  const mode = config.get<ServerMode>("server.mode", "typescript");
  const configuredPath = resolveConfiguredPath(config.get<string>("server.path", "").trim(), root);
  const native =
    mode === "typescript" || !vscode.workspace.isTrusted
      ? undefined
      : findNativeServer(configuredPath, roots);
  if (mode === "native" && vscode.workspace.isTrusted && !native) {
    const message = "YCPL native Language Server was requested but no executable was found.";
    output.error(message);
    status.text = "$(error) YCPL LSP missing";
    status.tooltip = message;
    status.show();
    void vscode.window.showErrorMessage(message);
    return;
  }

  const stlRoot = detectedStlRoot(config, roots);
  const useNative = native !== undefined && (mode !== "auto" || (await probeNative(native.path)));
  if (!vscode.workspace.isTrusted && mode !== "typescript") {
    output.warn("Workspace is not trusted; using the bundled TypeScript Language Server.");
  }
  const serverOptions: ServerOptions = useNative
    ? {
        command: native.path,
        transport: TransportKind.stdio,
        options: { env: compilerEnvironment(process.env, stlRoot, "") }
      }
    : {
        run: {
          module: context.asAbsolutePath(path.join("server", "server.cjs")),
          transport: TransportKind.ipc
        },
        debug: {
          module: context.asAbsolutePath(path.join("server", "server.cjs")),
          transport: TransportKind.ipc,
          options: { execArgv: ["--nolazy", "--inspect=6009"] }
        }
      };

  sourceWatcher = vscode.workspace.createFileSystemWatcher("**/*.yc");
  const clientOptions: LanguageClientOptions = {
    errorHandler: {
      error: () => ({ action: ErrorAction.Shutdown, handled: true }),
      closed: () => ({ action: CloseAction.DoNotRestart, handled: true })
    },
    documentSelector: [{ scheme: "file", language: "ycpl" }],
    outputChannel: output,
    traceOutputChannel: output,
    diagnosticCollectionName: "ycpl",
    synchronize: {
      fileEvents: sourceWatcher
    },
    initializationOptions: {
      inlayHints: { enabled: config.get<boolean>("inlayHints.enabled", true) },
      stlRoot
    },
    middleware: {
      provideInlayHints: (document, range, token, next) => {
        if (!configuration().get<boolean>("inlayHints.enabled", true)) {
          return [];
        }
        return next(document, range, token);
      }
    }
  };

  const label = useNative ? `native (${native.source})` : "TypeScript fallback";
  output.info(`Starting ${label} Language Server${useNative ? `: ${native.path}` : ""}`);
  status.text = useNative ? "$(server-process) YCPL: Native LSP" : "$(server-process) YCPL: TS LSP";
  status.tooltip = `YCPL Language Server: ${label}`;
  status.show();

  client = new LanguageClient("ycpl", "YCPL Language Server", serverOptions, clientOptions);
  try {
    await client.start();
  } catch (error) {
    output.error(`Language Server failed to start: ${String(error)}`);
    const failed = client;
    client = undefined;
    if (failed) {
      try {
        await failed.stop();
      } catch {
        await failed.dispose().catch(() => undefined);
      }
    }
    if (useNative && mode === "auto") {
      output.warn("Falling back to the bundled TypeScript Language Server.");
      await startBundledServer(context, clientOptions);
      return;
    }
    status.text = "$(error) YCPL LSP failed";
    throw error;
  }
}

async function startBundledServer(
  context: vscode.ExtensionContext,
  clientOptions: LanguageClientOptions
): Promise<void> {
  const serverOptions: ServerOptions = {
    run: {
      module: context.asAbsolutePath(path.join("server", "server.cjs")),
      transport: TransportKind.ipc
    },
    debug: {
      module: context.asAbsolutePath(path.join("server", "server.cjs")),
      transport: TransportKind.ipc
    }
  };
  status.text = "$(server-process) YCPL: TS LSP";
  status.tooltip = "YCPL Language Server: TypeScript fallback";
  client = new LanguageClient("ycpl", "YCPL Language Server", serverOptions, clientOptions);
  await client.start();
}

function detectedStlRoot(config: vscode.WorkspaceConfiguration, roots: readonly string[]): string {
  const configured = resolveConfiguredPath(config.get<string>("stlRoot", "").trim(), roots[0]);
  if (configured && fs.existsSync(configured)) {
    return configured;
  }
  for (const root of roots) {
    const candidate = path.join(root, "stl");
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }
  return "";
}

function scheduleCheckOnSave(document: vscode.TextDocument): void {
  if (document.languageId !== "ycpl" || !configuration(document.uri).get<boolean>("checkOnSave", true)) {
    return;
  }
  const key = document.uri.toString();
  clearTimeout(saveTimers.get(key));
  automaticChecks.get(key)?.cancel();
  const version = document.version;
  const timer = setTimeout(() => {
    saveTimers.delete(key);
    const source = new vscode.CancellationTokenSource();
    automaticChecks.set(key, source);
    void runCompilerCommand("check", document.uri, source.token, version)
      .catch((error) => {
        output.error(`Compiler check failed: ${String(error)}`);
      })
      .finally(() => {
        if (automaticChecks.get(key) === source) automaticChecks.delete(key);
        source.dispose();
      });
  }, 300);
  saveTimers.set(key, timer);
}

function clearSaveTimer(): void {
  for (const timer of saveTimers.values()) clearTimeout(timer);
  saveTimers.clear();
  for (const source of automaticChecks.values()) source.cancel();
  automaticChecks.clear();
}

async function runCompilerCommand(
  command: "check" | "build" | "build-ir" | "run",
  documentUri?: vscode.Uri,
  automaticToken?: vscode.CancellationToken,
  documentVersion?: number
): Promise<void> {
  if (!vscode.workspace.isTrusted) {
    void vscode.window.showWarningMessage("Trust this workspace before running the YCPL compiler.");
    return;
  }
  const roots = workspaceRoots();
  const uri = documentUri ?? vscode.window.activeTextEditor?.document.uri;
  const root = workspaceRootFor(uri) ?? roots[0];
  const config = configuration(uri);
  const configuredCompiler = resolveConfiguredPath(config.get<string>("compiler.path", "").trim(), root);
  const compiler = findCompiler(configuredCompiler, roots);
  if (!compiler) {
    const message = "Self-hosted ycc was not found. Configure YCPL.compiler.path or build //:ycc.";
    output.error(message);
    void vscode.window.showErrorMessage(message);
    return;
  }

  const sourcePath = uri?.scheme === "file" ? uri.fsPath : root;
  if (!sourcePath) {
    void vscode.window.showWarningMessage("Open a YCPL file or workspace before running ycc.");
    return;
  }
  const target = compilerTarget(sourcePath, roots);
  const cwd = target.cwd;
  const outputSetting = config.get<string>("outputDirectory", ".ycpl/build");
  const outputDirectory = path.isAbsolute(outputSetting) ? outputSetting : path.resolve(cwd, outputSetting);
  const args = compilerArguments(command === "run" ? "build" : command, target.input, outputDirectory);

  const stlRoot = detectedStlRoot(config, roots);
  const runtimeSource = resolveConfiguredPath(config.get<string>("runtimeSource", "").trim(), root);
  if (!automaticToken) await vscode.workspace.saveAll(false);
  if (!automaticToken) output.show(true);
  output.info(`$ ${quote(compiler)} ${args.map(quote).join(" ")}`);
  const environment = compilerEnvironment(process.env, stlRoot, runtimeSource);
  const invoke = (token: vscode.CancellationToken) =>
    execute(compiler, args, cwd, environment, token, (text) => output.append(text));
  const result = automaticToken
    ? await invoke(automaticToken)
    : await vscode.window.withProgress(
        {
          location: vscode.ProgressLocation.Notification,
          title: `YCPL: ${command}`,
          cancellable: true
        },
        (_progress, token) => invoke(token)
      );
  if (
    result.cancelled ||
    (documentVersion !== undefined &&
      vscode.workspace.textDocuments.find((document) => document.uri.toString() === uri?.toString())
        ?.version !== documentVersion)
  )
    return;
  publishCompilerDiagnostics(`${result.stdout}\n${result.stderr}`, cwd);
  if (result.code === 0) {
    output.info(`ycc ${command} completed successfully.`);
    if (command === "run") {
      const terminal = vscode.window.createTerminal({
        name: "YCPL Run",
        shellPath: path.join(outputDirectory, process.platform === "win32" ? "merged.exe" : "merged"),
        shellArgs: config.get<string[]>("run.arguments", []),
        cwd,
        env: environment
      });
      terminal.show();
    }
  } else {
    output.error(`ycc ${command} exited with code ${result.code}.`);
  }
}

function publishCompilerDiagnostics(text: string, cwd: string): void {
  for (const uri of diagnosticFiles.get(cwd) ?? []) compilerDiagnostics.delete(vscode.Uri.parse(uri));
  const grouped = new Map<string, vscode.Diagnostic[]>();
  for (const item of parseCompilerDiagnostics(text)) {
    const file = path.isAbsolute(item.file) ? item.file : path.resolve(cwd, item.file);
    const range = new vscode.Range(item.line - 1, item.column - 1, item.line - 1, item.column);
    const diagnostic = new vscode.Diagnostic(range, item.message, vscode.DiagnosticSeverity.Error);
    diagnostic.source = "ycc";
    const key = vscode.Uri.file(file).toString();
    grouped.set(key, [...(grouped.get(key) ?? []), diagnostic]);
  }
  for (const [uri, diagnostics] of grouped) {
    compilerDiagnostics.set(vscode.Uri.parse(uri), diagnostics);
  }
  diagnosticFiles.set(cwd, new Set(grouped.keys()));
}

function quote(value: string): string {
  return /\s/.test(value) ? JSON.stringify(value) : value;
}

function workspaceRootFor(uri: vscode.Uri | undefined): string | undefined {
  if (!uri || uri.scheme !== "file") {
    return undefined;
  }
  return vscode.workspace.getWorkspaceFolder(uri)?.uri.fsPath;
}

/** Check the protocol before giving a crashing auto-discovered process to the client. */
async function probeNative(program: string): Promise<boolean> {
  return new Promise((resolve) => {
    const child = spawn(program, [], { shell: false, stdio: ["pipe", "pipe", "pipe"] });
    let response = "";
    const timer = setTimeout(() => {
      child.kill("SIGKILL");
    }, 5000);
    child.stdout.on("data", (data: Buffer) => {
      response = (response + data.toString()).slice(0, 1048576);
    });
    child.stderr.resume();
    child.stdin.on("error", () => undefined);
    child.on("error", () => {
      clearTimeout(timer);
      resolve(false);
    });
    child.on("close", (code) => {
      clearTimeout(timer);
      resolve(code === 0 && response.includes('"capabilities"'));
    });
    const messages = [
      { jsonrpc: "2.0", id: 1, method: "initialize", params: { capabilities: {} } },
      { jsonrpc: "2.0", id: 2, method: "shutdown", params: null },
      { jsonrpc: "2.0", method: "exit" }
    ];
    child.stdin.end(
      messages
        .map((message) => {
          const body = JSON.stringify(message);
          return `Content-Length: ${Buffer.byteLength(body)}\r\n\r\n${body}`;
        })
        .join("")
    );
  });
}
