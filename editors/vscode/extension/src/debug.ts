import * as fs from "node:fs/promises";
import * as path from "node:path";
import * as vscode from "vscode";
import { randomUUID } from "node:crypto";
import {
  compilerEnvironment,
  compilerTarget,
  findCompiler,
  findOnPath,
  isExecutable,
  resolveConfiguredPath
} from "./runtime.js";
import { execute } from "./process.js";

export async function debugTest(
  program: string,
  args: string[],
  cwd: string,
  env: NodeJS.ProcessEnv,
  token: vscode.CancellationToken
): Promise<{ code: number; cancelled: boolean }> {
  if (token.isCancellationRequested) return { code: -1, cancelled: true };
  const id = randomUUID();
  let session: vscode.DebugSession | undefined;
  let code = -1;
  let settle: (result: { code: number; cancelled: boolean }) => void = () => undefined;
  const finished = new Promise<{ code: number; cancelled: boolean }>((resolve) => {
    settle = resolve;
  });
  const tracker = vscode.debug.registerDebugAdapterTrackerFactory("ycpl", {
    createDebugAdapterTracker(candidate) {
      if (candidate.configuration.__ycplTest !== id) return undefined;
      session = candidate;
      return {
        onDidSendMessage(message) {
          if (message.type === "event" && message.event === "exited") code = message.body.exitCode;
        },
        onError() {
          settle({ code: -1, cancelled: token.isCancellationRequested });
        }
      };
    }
  });
  const end = vscode.debug.onDidTerminateDebugSession((candidate) => {
    if (candidate.configuration.__ycplTest === id)
      settle({ code, cancelled: token.isCancellationRequested || code === -1 });
  });
  const cancel = token.onCancellationRequested(() => {
    if (session) void vscode.debug.stopDebugging(session);
  });
  try {
    const accepted = await vscode.debug.startDebugging(
      vscode.workspace.getWorkspaceFolder(vscode.Uri.file(cwd)),
      {
        type: "ycpl",
        request: "launch",
        name: `YCPL: ${args[0]}`,
        program,
        args,
        cwd,
        env,
        console: "internalConsole",
        __ycplTest: id
      }
    );
    if (!accepted) return { code: -1, cancelled: true };
    if (token.isCancellationRequested && session) await vscode.debug.stopDebugging(session);
    return await finished;
  } finally {
    cancel.dispose();
    end.dispose();
    tracker.dispose();
  }
}

/** Source debugging through LLVM's real DAP adapter; no shell or generated launch script. */
export function registerDebugging(context: vscode.ExtensionContext, output: vscode.OutputChannel): void {
  const owned = new Set<string>();
  context.subscriptions.push(
    vscode.debug.registerDebugConfigurationProvider("ycpl", {
      provideDebugConfigurations: () => [
        { type: "ycpl", request: "launch", name: "YCPL: Debug File", program: "${file}", stopOnEntry: false }
      ],
      resolveDebugConfiguration(_folder, configuration) {
        if (!vscode.workspace.isTrusted) {
          void vscode.window.showWarningMessage("Trust this workspace before debugging YCPL programs.");
          return undefined;
        }
        return {
          ...configuration,
          type: configuration.type || "ycpl",
          request: configuration.request || "launch",
          name: configuration.name || "YCPL: Debug",
          program: configuration.program ?? "${file}"
        };
      },
      async resolveDebugConfigurationWithSubstitutedVariables(folder, configuration, token) {
        if (!vscode.workspace.isTrusted) return undefined;
        if (configuration.request === "attach") return configuration;
        const program = configuration.program as string | undefined;
        if (!program) throw new Error("Select a YCPL source file or project to debug.");
        const source = path.resolve(folder?.uri.fsPath ?? process.cwd(), program);
        const info = await fs.stat(source);
        if (!source.endsWith(".yc") && !info.isDirectory()) return configuration;
        await vscode.workspace.saveAll(false);
        const roots = vscode.workspace.workspaceFolders?.map((item) => item.uri.fsPath) ?? [];
        const uri = vscode.Uri.file(source);
        const config = vscode.workspace.getConfiguration("YCPL", uri);
        const root = vscode.workspace.getWorkspaceFolder(uri)?.uri.fsPath ?? path.dirname(source);
        const compiler = findCompiler(
          resolveConfiguredPath(config.get<string>("compiler.path", ""), root),
          roots
        );
        if (!compiler) throw new Error("Self-hosted ycc not found. Configure YCPL.compiler.path.");
        const target = compilerTarget(source, roots);
        const parent = path.join(root, ".ycpl", "debug");
        await fs.mkdir(parent, { recursive: true });
        const directory = await fs.mkdtemp(path.join(parent, "session-"));
        owned.add(directory);
        const env = compilerEnvironment(
          process.env,
          resolveConfiguredPath(config.get<string>("stlRoot", ""), root),
          resolveConfiguredPath(config.get<string>("runtimeSource", ""), root)
        );
        const result = await vscode.window.withProgress(
          { location: vscode.ProgressLocation.Notification, title: "YCPL: building for debugging" },
          () =>
            execute(
              compiler,
              ["build", target.input, "-g", "-o", directory],
              target.cwd,
              env,
              token,
              (text) => output.append(text)
            )
        );
        if (result.code !== 0 || result.cancelled) {
          await fs.rm(directory, { recursive: true, force: true });
          owned.delete(directory);
          if (!result.cancelled) throw new Error(result.stdout + result.stderr);
          return undefined;
        }
        return {
          ...configuration,
          program: path.join(directory, process.platform === "win32" ? "merged.exe" : "merged"),
          cwd: configuration.cwd ?? target.cwd,
          args: configuration.args ?? config.get<string[]>("run.arguments", []),
          env: { ...env, ...configuration.env },
          console: configuration.console ?? "integratedTerminal",
          __ycplOutput: directory
        };
      }
    })
  );
  context.subscriptions.push(
    vscode.debug.registerDebugAdapterDescriptorFactory("ycpl", {
      createDebugAdapterDescriptor(session) {
        const config = vscode.workspace.getConfiguration("YCPL", session.workspaceFolder?.uri);
        const configured = resolveConfiguredPath(
          config.get<string>("debug.adapterPath", ""),
          session.workspaceFolder?.uri.fsPath
        );
        const candidates = [
          configured,
          ...(process.env.LLVM_BINDIR ? [path.join(process.env.LLVM_BINDIR, "lldb-dap")] : []),
          findOnPath("lldb-dap"),
          "/opt/homebrew/opt/llvm@22/bin/lldb-dap",
          "/usr/local/opt/llvm@22/bin/lldb-dap",
          "/usr/lib/llvm-22/bin/lldb-dap"
        ];
        const adapter = candidates.find(
          (candidate): candidate is string => !!candidate && isExecutable(candidate)
        );
        if (!adapter)
          throw new Error("LLVM 22 lldb-dap not found. Set YCPL.debug.adapterPath to its executable.");
        return new vscode.DebugAdapterExecutable(adapter);
      }
    })
  );
  context.subscriptions.push(
    vscode.debug.onDidTerminateDebugSession((session) => {
      const directory = session.configuration.__ycplOutput as string | undefined;
      if (directory && owned.delete(directory)) void fs.rm(directory, { recursive: true, force: true });
    })
  );
  context.subscriptions.push(
    vscode.commands.registerCommand("YCPL.debug", async () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor || editor.document.languageId !== "ycpl") throw new Error("Open a YCPL source file first.");
      return vscode.debug.startDebugging(vscode.workspace.getWorkspaceFolder(editor.document.uri), {
        type: "ycpl",
        request: "launch",
        name: "YCPL: Debug",
        program: editor.document.uri.fsPath
      });
    })
  );
}
