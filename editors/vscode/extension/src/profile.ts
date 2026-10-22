import * as fs from "node:fs/promises";
import * as path from "node:path";
import * as vscode from "vscode";
import {
  compilerEnvironment,
  compilerTarget,
  findCompiler,
  findOnPath,
  resolveConfiguredPath
} from "./runtime.js";
import { execute } from "./process.js";
import { flagArguments, llvmTool } from "./llvm.js";

/** Instrumentation profile: exact function/block counts, independent of sampling permissions. */
export async function profile(
  document: vscode.TextDocument,
  output: vscode.OutputChannel,
  kind: "execution" | "cpu" | "memory" = "execution"
): Promise<vscode.Uri | undefined> {
  if (!vscode.workspace.isTrusted) throw new Error("Trust the workspace before profiling programs.");
  await vscode.workspace.saveAll(false);
  const roots = vscode.workspace.workspaceFolders?.map((folder) => folder.uri.fsPath) ?? [];
  const root =
    vscode.workspace.getWorkspaceFolder(document.uri)?.uri.fsPath ?? path.dirname(document.uri.fsPath);
  const config = vscode.workspace.getConfiguration("YCPL", document.uri);
  const compiler = findCompiler(resolveConfiguredPath(config.get<string>("compiler.path", ""), root), roots);
  if (!compiler) throw new Error("Self-hosted ycc not found. Configure YCPL.compiler.path.");
  const env = compilerEnvironment(
    process.env,
    resolveConfiguredPath(config.get<string>("stlRoot", ""), root),
    resolveConfiguredPath(config.get<string>("runtimeSource", ""), root)
  );
  const runtime =
    env.YCPL_RUNTIME_SRC ??
    (env.YCPL_STL_ROOT ? path.resolve(env.YCPL_STL_ROOT, "../bootstrap/cpp/runtime/yc_runtime.c") : "");
  if (!runtime) throw new Error("Set YCPL.runtimeSource to collect an execution profile.");
  const target = compilerTarget(document.uri.fsPath, roots);
  const parent = path.join(root, ".ycpl", "profiles");
  await fs.mkdir(parent, { recursive: true });
  const directory = await fs.mkdtemp(path.join(parent, "run-"));
  let saved = false;
  try {
    return await vscode.window.withProgress(
      {
        location: vscode.ProgressLocation.Notification,
        title: `YCPL: collecting ${kind} profile`,
        cancellable: true
      },
      async (_progress, token) => {
        const run = async (
          program: string,
          args: string[],
          cwd = directory,
          processEnv = env
        ): Promise<string> => {
          const result = await execute(program, args, cwd, processEnv, token, (text) => output.append(text));
          if (result.cancelled) throw new Error("Profile cancelled.");
          if (result.code !== 0)
            throw new Error(result.stdout + result.stderr || `Program exited with ${result.code}.`);
          return result.stdout;
        };
        if (kind !== "execution") {
          await run(compiler, ["build", target.input, "-g", "-o", directory], target.cwd);
          const program = path.join(directory, "merged");
          const args = config.get<string[]>("run.arguments", []);
          let report: string;
          if (kind === "cpu" && process.platform === "darwin") {
            const cancellation = new vscode.CancellationTokenSource();
            const cancel = token.onCancellationRequested(() => cancellation.cancel());
            let signal: (pid: number | undefined) => void = () => undefined;
            const ready = new Promise<number | undefined>((resolve) => {
              signal = resolve;
            });
            const workload = execute(
              program,
              args,
              target.cwd,
              env,
              cancellation.token,
              (text) => output.append(text),
              signal
            );
            try {
              const pid = await ready;
              if (!pid) throw new Error("Could not start the program to sample.");
              await run("/usr/bin/sample", [
                String(pid),
                String(config.get<number>("profiling.duration", 5)),
                "-file",
                path.join(directory, "cpu-samples.txt")
              ]);
              report = await fs.readFile(path.join(directory, "cpu-samples.txt"), "utf8");
            } finally {
              cancellation.cancel();
              await workload;
              cancel.dispose();
              cancellation.dispose();
            }
          } else if (kind === "cpu") {
            const perf = findOnPath("perf");
            if (!perf)
              throw new Error(
                "Install Linux perf to collect CPU samples. The kernel must permit perf_event access."
              );
            await run(
              perf,
              [
                "record",
                "-g",
                "--call-graph",
                "dwarf",
                "-o",
                path.join(directory, "cpu.data"),
                "--",
                program,
                ...args
              ],
              target.cwd
            );
            report = await run(perf, ["report", "--stdio", "-i", path.join(directory, "cpu.data")]);
          } else if (process.platform === "darwin") {
            report = await run("/usr/bin/leaks", ["--atExit", "--", program, ...args], target.cwd);
          } else {
            const valgrind = findOnPath("valgrind");
            const print = findOnPath("ms_print");
            if (!valgrind || !print)
              throw new Error("Install valgrind (including ms_print) to collect heap profiles.");
            await run(
              valgrind,
              ["--tool=massif", `--massif-out-file=${path.join(directory, "heap.massif")}`, program, ...args],
              target.cwd
            );
            report = await run(print, ["heap.massif"]);
          }
          const uri = vscode.Uri.file(path.join(directory, `${kind}-profile.txt`));
          await fs.writeFile(uri.fsPath, report);
          await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(uri));
          saved = true;
          return uri;
        }
        await run(compiler, ["build-ir", target.input, "-g", "-o", directory], target.cwd);
        await run(llvmTool("opt", env), [
          "-passes=pgo-instr-gen,instrprof",
          "-S",
          "merged.ll",
          "-o",
          "profile.ll"
        ]);
        await run(llvmTool("clang", env), [
          "-g",
          "-O0",
          "-fprofile-instr-generate",
          "-D_POSIX_C_SOURCE=200809L",
          "profile.ll",
          runtime,
          "-lm",
          ...flagArguments(env.LINKFLAGS ?? ""),
          "-o",
          "merged"
        ]);
        await run(path.join(directory, "merged"), config.get<string[]>("run.arguments", []), target.cwd, {
          ...env,
          LLVM_PROFILE_FILE: path.join(directory, "execution.profraw")
        });
        await run(llvmTool("llvm-profdata", env), ["merge", "execution.profraw", "-o", "execution.profdata"]);
        const report = await run(llvmTool("llvm-profdata", env), [
          "show",
          "--all-functions",
          "--counts",
          "execution.profdata"
        ]);
        const uri = vscode.Uri.file(path.join(directory, "execution-profile.txt"));
        await fs.writeFile(
          uri.fsPath,
          `YCPL execution profile\nExact function and block execution counts; these are not CPU samples or allocation measurements.\n\n${report}`
        );
        await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(uri));
        saved = true;
        return uri;
      }
    );
  } finally {
    if (!saved) await fs.rm(directory, { recursive: true, force: true });
  }
}
