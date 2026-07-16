import { spawn } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import * as vscode from "vscode";
import {
  LanguageClient,
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

let client: LanguageClient | undefined;
let output: vscode.LogOutputChannel;
let status: vscode.StatusBarItem;
let compilerDiagnostics: vscode.DiagnosticCollection;
let saveTimer: NodeJS.Timeout | undefined;

export async function activate(context: vscode.ExtensionContext): Promise<void> {
  output = vscode.window.createOutputChannel("YCPL", { log: true });
  status = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 40);
  status.name = "YCPL Language Server";
  status.command = "YCPL.showOutput";
  compilerDiagnostics = vscode.languages.createDiagnosticCollection("ycpl-compiler");
  context.subscriptions.push(output, status, compilerDiagnostics);

  registerCommands(context);
  context.subscriptions.push(
    vscode.workspace.onDidSaveTextDocument((document) => scheduleCheckOnSave(document)),
    vscode.workspace.onDidChangeConfiguration(async (event) => {
      if (event.affectsConfiguration("YCPL.server") || event.affectsConfiguration("YCPL.stlRoot")) {
        await restartLanguageServer(context);
      }
      if (event.affectsConfiguration("YCPL.checkOnSave") && !configuration().get("checkOnSave", true)) {
        clearSaveTimer();
      }
    })
  );

  await startLanguageServer(context);
}

export async function deactivate(): Promise<void> {
  clearSaveTimer();
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
  const target = resource
    ?? vscode.window.activeTextEditor?.document.uri
    ?? vscode.workspace.workspaceFolders?.[0]?.uri;
  return vscode.workspace.getConfiguration("YCPL", target);
}

function workspaceRoots(): string[] {
  return vscode.workspace.workspaceFolders?.map((folder) => folder.uri.fsPath) ?? [];
}

async function restartLanguageServer(context: vscode.ExtensionContext): Promise<void> {
  await stopLanguageServer();
  await startLanguageServer(context);
}

async function stopLanguageServer(): Promise<void> {
  const running = client;
  client = undefined;
  if (running) {
    await running.stop();
  }
  status.hide();
}

async function startLanguageServer(context: vscode.ExtensionContext): Promise<void> {
  const config = configuration();
  const roots = workspaceRoots();
  const root = roots[0];
  const mode = config.get<ServerMode>("server.mode", "auto");
  const configuredPath = resolveConfiguredPath(config.get<string>("server.path", "").trim(), root);
  const native = mode === "typescript" ? undefined : findNativeServer(configuredPath, roots);
  if (mode === "native" && !native) {
    const message = "YCPL native Language Server was requested but no executable was found.";
    output.error(message);
    status.text = "$(error) YCPL LSP missing";
    status.tooltip = message;
    status.show();
    void vscode.window.showErrorMessage(message);
    return;
  }

  const stlRoot = detectedStlRoot(config, roots);
  const useNative = native !== undefined;
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

  const clientOptions: LanguageClientOptions = {
    documentSelector: [{ scheme: "file", language: "ycpl" }],
    outputChannel: output,
    traceOutputChannel: output,
    diagnosticCollectionName: "ycpl",
    synchronize: {
      fileEvents: vscode.workspace.createFileSystemWatcher("**/*.{yc,json}")
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
        failed.dispose();
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
  clearSaveTimer();
  saveTimer = setTimeout(() => {
    saveTimer = undefined;
    void runCompilerCommand("check", document.uri);
  }, 300);
}

function clearSaveTimer(): void {
  if (saveTimer) {
    clearTimeout(saveTimer);
    saveTimer = undefined;
  }
}

async function runCompilerCommand(
  command: "check" | "build" | "build-ir" | "run",
  documentUri?: vscode.Uri
): Promise<void> {
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
  const args = compilerArguments(command, target.input, outputDirectory, config.get<string[]>("run.arguments", []));

  const stlRoot = detectedStlRoot(config, roots);
  const runtimeSource = resolveConfiguredPath(config.get<string>("runtimeSource", "").trim(), root);
  output.show(true);
  output.info(`$ ${quote(compiler)} ${args.map(quote).join(" ")}`);
  const result = await spawnCompiler(compiler, args, cwd, compilerEnvironment(process.env, stlRoot, runtimeSource));
  publishCompilerDiagnostics(`${result.stdout}\n${result.stderr}`, cwd);
  if (result.code === 0) {
    output.info(`ycc ${command} completed successfully.`);
  } else {
    output.error(`ycc ${command} exited with code ${result.code}.`);
  }
}

function spawnCompiler(
  executable: string,
  args: readonly string[],
  cwd: string,
  env: NodeJS.ProcessEnv
): Promise<{ code: number; stdout: string; stderr: string }> {
  return new Promise((resolve) => {
    const child = spawn(executable, [...args], { cwd, env, shell: false });
    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (chunk: Buffer) => {
      const text = chunk.toString("utf8");
      stdout += text;
      output.append(text);
    });
    child.stderr.on("data", (chunk: Buffer) => {
      const text = chunk.toString("utf8");
      stderr += text;
      output.append(text);
    });
    child.on("error", (error) => {
      stderr += String(error);
      resolve({ code: 1, stdout, stderr });
    });
    child.on("close", (code) => resolve({ code: code ?? 1, stdout, stderr }));
  });
}

function publishCompilerDiagnostics(text: string, cwd: string): void {
  compilerDiagnostics.clear();
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
