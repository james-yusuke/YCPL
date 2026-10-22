import * as fs from "node:fs/promises";
import * as path from "node:path";
import * as vscode from "vscode";
import { execute } from "./process.js";
import { flagArguments, llvmTool, parseCoverage } from "./llvm.js";

export async function instrument(
  directory: string,
  env: NodeJS.ProcessEnv,
  token: vscode.CancellationToken,
  output: (text: string) => void
): Promise<void> {
  const runtime =
    env.YCPL_RUNTIME_SRC ??
    (env.YCPL_STL_ROOT ? path.resolve(env.YCPL_STL_ROOT, "../bootstrap/cpp/runtime/yc_runtime.c") : "");
  if (!runtime) throw new Error("Set YCPL.runtimeSource to collect coverage.");
  const commands: [string, string[]][] = [
    [llvmTool("opt", env), ["-passes=insert-gcov-profiling", "-S", "merged.ll", "-o", "covered.ll"]],
    [
      llvmTool("clang", env),
      [
        "-g",
        "-O0",
        "--coverage",
        "-D_POSIX_C_SOURCE=200809L",
        "covered.ll",
        runtime,
        "-lm",
        ...flagArguments(env.LINKFLAGS ?? ""),
        "-o",
        "merged"
      ]
    ]
  ];
  for (const [command, args] of commands) {
    const result = await execute(command, args, directory, env, token, output);
    if (result.code !== 0 || result.cancelled)
      throw new Error(result.stdout + result.stderr || "Coverage instrumentation cancelled.");
  }
}

export async function reportCoverage(
  directory: string,
  env: NodeJS.ProcessEnv,
  token: vscode.CancellationToken
): Promise<vscode.FileCoverage[]> {
  const notes = (await fs.readdir(directory)).filter((name) => name.endsWith(".gcno"));
  if (!notes.length) throw new Error("LLVM did not produce coverage notes.");
  const result: vscode.FileCoverage[] = [];
  for (const note of notes) {
    const stem = note.slice(0, -5);
    const report = await execute(
      llvmTool("llvm-cov", env),
      ["gcov", "-i", "-o", note, `${stem}.yc`],
      directory,
      env,
      token
    );
    if (report.code !== 0) throw new Error(report.stdout + report.stderr);
  }
  for (const file of (await fs.readdir(directory)).filter((name) => name.endsWith(".gcov"))) {
    for (const entry of parseCoverage(await fs.readFile(path.join(directory, file), "utf8"))) {
      const uri = vscode.Uri.file(entry.file);
      if (
        !vscode.workspace.getWorkspaceFolder(uri) ||
        !entry.lines.size ||
        entry.file.startsWith(directory + path.sep)
      )
        continue;
      const details = [...entry.lines]
        .sort(([a], [b]) => a - b)
        .map(([line, count]) => new vscode.StatementCoverage(count, new vscode.Position(line - 1, 0)));
      const coverage = vscode.FileCoverage.fromDetails(uri, details);
      coverageDetails.set(coverage, details);
      result.push(coverage);
    }
  }
  return result;
}

export const coverageDetails = new WeakMap<vscode.FileCoverage, vscode.FileCoverageDetail[]>();
