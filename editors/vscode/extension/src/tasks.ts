import * as path from "node:path";
import * as vscode from "vscode";
import { compilerArguments, compilerEnvironment, findCompiler, resolveConfiguredPath } from "./runtime.js";

const commands = ["check", "build", "build-ir", "run"] as const;
type BuildCommand = (typeof commands)[number];

export function createTask(folder: vscode.WorkspaceFolder, command: BuildCommand, input = "."): vscode.Task {
  const config = vscode.workspace.getConfiguration("YCPL", folder.uri);
  const roots = vscode.workspace.workspaceFolders?.map((item) => item.uri.fsPath) ?? [];
  const compiler = findCompiler(
    resolveConfiguredPath(config.get<string>("compiler.path", ""), folder.uri.fsPath),
    roots
  );
  if (!compiler) throw new Error("Self-hosted ycc not found. Configure YCPL.compiler.path.");
  const output = path.resolve(folder.uri.fsPath, config.get<string>("outputDirectory", ".ycpl/build"));
  const environment = compilerEnvironment(
    process.env,
    resolveConfiguredPath(config.get<string>("stlRoot", ""), folder.uri.fsPath),
    resolveConfiguredPath(config.get<string>("runtimeSource", ""), folder.uri.fsPath)
  );
  const task = new vscode.Task(
    { type: "ycpl", command, input },
    folder,
    command,
    "YCPL",
    new vscode.ProcessExecution(
      compiler,
      compilerArguments(command, input, output, config.get<string[]>("run.arguments", [])),
      { cwd: folder.uri.fsPath, env: environment as Record<string, string> }
    ),
    "$ycpl"
  );
  if (command === "build") task.group = vscode.TaskGroup.Build;
  task.presentationOptions = { reveal: vscode.TaskRevealKind.Always, clear: true };
  return task;
}

export function registerTasks(): vscode.Disposable {
  return vscode.tasks.registerTaskProvider("ycpl", {
    provideTasks: () => {
      if (!vscode.workspace.isTrusted) return [];
      return (vscode.workspace.workspaceFolders ?? []).flatMap((folder) => {
        try {
          return commands.map((command) => createTask(folder, command));
        } catch {
          return [];
        }
      });
    },
    resolveTask: (task) => {
      if (!vscode.workspace.isTrusted || !task.scope || typeof task.scope === "number") return undefined;
      const command = task.definition.command as BuildCommand;
      return commands.includes(command)
        ? createTask(task.scope, command, task.definition.input ?? ".")
        : undefined;
    }
  });
}
