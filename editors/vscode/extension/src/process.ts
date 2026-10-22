import { spawn } from "node:child_process";
import type { CancellationToken } from "vscode";

export interface ProcessResult {
  code: number;
  stdout: string;
  stderr: string;
  cancelled: boolean;
}

/** Execute argument arrays and stop the owned process group on cancellation. */
export function execute(
  program: string,
  args: readonly string[],
  cwd: string,
  env: NodeJS.ProcessEnv,
  token?: CancellationToken,
  output?: (text: string) => void,
  started?: (pid: number | undefined) => void
): Promise<ProcessResult> {
  if (token?.isCancellationRequested) {
    started?.(undefined);
    return Promise.resolve({ code: -1, stdout: "", stderr: "", cancelled: true });
  }
  return new Promise((resolve) => {
    const child = spawn(program, [...args], {
      cwd,
      env,
      shell: false,
      detached: process.platform !== "win32"
    });
    child.once("spawn", () => started?.(child.pid));
    child.once("error", () => started?.(undefined));
    let stdout = "";
    let stderr = "";
    const limit = 2 * 1024 * 1024;
    let cancelled = false;
    let force: NodeJS.Timeout | undefined;
    const signal = (name: NodeJS.Signals): void => {
      try {
        if (child.pid && process.platform !== "win32") process.kill(-child.pid, name);
        else child.kill(name);
      } catch {
        /* The owned process may already have exited. */
      }
    };
    const terminate = (): void => {
      cancelled = true;
      signal("SIGTERM");
      force ??= setTimeout(() => signal("SIGKILL"), 1500);
      force.unref();
    };
    const cancel = token?.onCancellationRequested(terminate);
    if (token?.isCancellationRequested) terminate();
    child.stdout.on("data", (data: Buffer) => {
      const text = data.toString();
      stdout = (stdout + text).slice(-limit);
      output?.(text);
    });
    child.stderr.on("data", (data: Buffer) => {
      const text = data.toString();
      stderr = (stderr + text).slice(-limit);
      output?.(text);
    });
    child.on("error", (error) => {
      stderr += error.message;
    });
    child.on("close", (code) => {
      if (force) clearTimeout(force);
      cancel?.dispose();
      resolve({ code: code !== null && code >= 0 ? code : -1, stdout, stderr, cancelled });
    });
  });
}
