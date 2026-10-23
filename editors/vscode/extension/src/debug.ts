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
import { execute, type ProcessResult } from "./process.js";

export async function debugTest(
  program: string,
  args: string[],
  cwd: string,
  env: NodeJS.ProcessEnv,
  token: vscode.CancellationToken,
  output?: (text: string) => void,
  testRun?: vscode.TestRun
): Promise<ProcessResult> {
  if (token.isCancellationRequested) return { code: -1, stdout: "", stderr: "", cancelled: true };
  const id = randomUUID();
  let session: vscode.DebugSession | undefined;
  let code = -1;
  let stdout = "",
    stderr = "";
  const result = (): ProcessResult => ({ code, stdout, stderr, cancelled: token.isCancellationRequested });
  const record = (text: string, error = false): void => {
    if (error) stderr = (stderr + text).slice(-2097152);
    else stdout = (stdout + text).slice(-2097152);
    output?.(text);
  };
  let settle: (result: ProcessResult) => void = () => undefined;
  const finished = new Promise<ProcessResult>((resolve) => {
    settle = resolve;
  });
  const tracker = vscode.debug.registerDebugAdapterTrackerFactory("ycpl", {
    createDebugAdapterTracker(candidate) {
      if (candidate.configuration.__ycplTest !== id) return undefined;
      session = candidate;
      return {
        onWillReceiveMessage(message) {
          if (
            message.type === "request" &&
            ["launch", "configurationDone", "disconnect", "terminate"].includes(message.command)
          )
            record(`Debug request: ${message.command}\n`);
        },
        onDidSendMessage(message) {
          if (
            message.type === "event" &&
            ["initialized", "process", "exited", "terminated"].includes(message.event)
          )
            record(`Debug event: ${message.event}\n`);
          if (message.type === "event" && message.event === "exited") {
            code = message.body.exitCode;
            settle(result());
          }
          if (message.type === "event" && message.event === "stopped")
            record(`Debugger stopped: ${message.body.reason} ${message.body.description ?? ""}\n`);
          if (message.type === "event" && message.event === "output")
            record(message.body.output ?? "", message.body.category === "stderr");
          if (message.type === "response" && message.command === "launch") {
            record(`Debug launch: ${message.success ? "accepted" : "failed"}\n`);
            if (!message.success) {
              record(message.message ?? "Debugger launch failed.\n", true);
              settle(result());
            }
          }
        },
        onError(error) {
          record(`${error.message}\n`, true);
          settle(result());
        },
        onExit() {
          if (code === -1 && !token.isCancellationRequested)
            record("Debug adapter exited before reporting the test status.\n", true);
          settle(result());
        }
      };
    }
  });
  const end = vscode.debug.onDidTerminateDebugSession((candidate) => {
    if (candidate.configuration.__ycplTest === id) settle(result());
  });
  const cancel = token.onCancellationRequested(() => {
    settle(result());
  });
  try {
    const starting = vscode.debug.startDebugging(
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
        stopOnEntry: false,
        __ycplTest: id
      },
      { testRun }
    );
    // VS Code may still be settling launch/teardown UI after DAP has already
    // reported an exit or launch failure. The adapter owns the test result.
    const outcome = await Promise.race([
      starting.then((accepted) => ({ accepted })),
      finished.then((result) => ({ result }))
    ]);
    if ("result" in outcome) return outcome.result;
    if (!outcome.accepted) {
      record("Debug session did not start.\n", true);
      return result();
    }
    return await finished;
  } finally {
    if (session)
      void vscode.debug.stopDebugging(session).then(
        () => undefined,
        () => undefined
      );
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
      resolveDebugConfiguration(folder, configuration) {
        if (!vscode.workspace.isTrusted) {
          void vscode.window.showWarningMessage("Trust this workspace before debugging YCPL programs.");
          return undefined;
        }
        const externalSymbols = vscode.workspace
          .getConfiguration("YCPL", folder?.uri)
          .get<boolean>("debug.externalSymbols", false);
        return {
          ...configuration,
          type: configuration.type || "ycpl",
          request: configuration.request || "launch",
          name: configuration.name || "YCPL: Debug",
          program: configuration.program ?? "${file}",
          initCommands: [
            ...(externalSymbols ? [] : ["settings set symbols.enable-external-lookup false"]),
            ...(configuration.initCommands ?? [])
          ]
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
      async createDebugAdapterDescriptor(session) {
        const config = vscode.workspace.getConfiguration("YCPL", session.workspaceFolder?.uri);
        const configured = resolveConfiguredPath(
          config.get<string>("debug.adapterPath", ""),
          session.workspaceFolder?.uri.fsPath
        );
        const candidates = [
          configured,
          ...(process.env.LLVM_BINDIR ? [path.join(process.env.LLVM_BINDIR, "lldb-dap")] : []),
          "/opt/homebrew/opt/lldb/bin/lldb-dap",
          "/usr/local/opt/lldb/bin/lldb-dap",
          findOnPath("lldb-dap"),
          "/opt/homebrew/opt/llvm@22/bin/lldb-dap",
          "/usr/local/opt/llvm@22/bin/lldb-dap",
          "/usr/lib/llvm-22/bin/lldb-dap"
        ];
        const adapter = candidates.find(
          (candidate): candidate is string => !!candidate && isExecutable(candidate)
        );
        if (!adapter) {
          const directory = session.configuration.__ycplOutput as string | undefined;
          if (directory && owned.delete(directory)) await fs.rm(directory, { recursive: true, force: true });
          throw new Error(
            "lldb-dap not found. Install LLDB (brew install lldb on macOS) or set YCPL.debug.adapterPath."
          );
        }
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
