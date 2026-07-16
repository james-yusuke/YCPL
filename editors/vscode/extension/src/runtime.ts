import * as fs from "node:fs";
import * as path from "node:path";

export type ServerMode = "auto" | "native" | "typescript";

export interface NativeServerCandidate {
  path: string;
  source: "configured" | "workspace" | "path";
}

export interface CompilerDiagnostic {
  file: string;
  line: number;
  column: number;
  message: string;
}

export interface CompilerTarget {
  cwd: string;
  input: string;
  projectRoot?: string;
}

export function isExecutable(candidate: string): boolean {
  if (!candidate) {
    return false;
  }
  try {
    fs.accessSync(candidate, fs.constants.F_OK | fs.constants.X_OK);
    return fs.statSync(candidate).isFile();
  } catch {
    return false;
  }
}

export function findOnPath(name: string, envPath = process.env.PATH ?? ""): string | undefined {
  for (const entry of envPath.split(path.delimiter)) {
    if (!entry) {
      continue;
    }
    const candidate = path.join(entry, name);
    if (isExecutable(candidate)) {
      return candidate;
    }
  }
  return undefined;
}

export function findNativeServer(
  configuredPath: string,
  workspaceRoots: readonly string[],
  envPath = process.env.PATH ?? ""
): NativeServerCandidate | undefined {
  if (configuredPath && isExecutable(configuredPath)) {
    return { path: configuredPath, source: "configured" };
  }
  for (const root of workspaceRoots) {
    const candidate = path.join(root, "tools", "lsp", "build", "YCPL-lsp");
    if (isExecutable(candidate)) {
      return { path: candidate, source: "workspace" };
    }
  }
  const fromPath = findOnPath("YCPL-lsp", envPath);
  return fromPath ? { path: fromPath, source: "path" } : undefined;
}

export function findCompiler(
  configuredPath: string,
  workspaceRoots: readonly string[],
  envPath = process.env.PATH ?? ""
): string | undefined {
  if (configuredPath && isExecutable(configuredPath) && !isBootstrapCompiler(configuredPath)) {
    return configuredPath;
  }
  for (const root of workspaceRoots) {
    for (const relative of [path.join("bazel-bin", "ycc"), path.join("build", "ycc")]) {
      const candidate = path.join(root, relative);
      if (isExecutable(candidate)) {
        return candidate;
      }
    }
  }
  const fromPath = findOnPath("ycc", envPath);
  return fromPath && !isBootstrapCompiler(fromPath) ? fromPath : undefined;
}

export function isBootstrapCompiler(candidate: string): boolean {
  const base = path.basename(candidate).toLowerCase();
  return base.includes("bootstrap") || base === "ycc_bootstrap_bin";
}

export function findProjectRoot(startPath: string, workspaceRoots: readonly string[]): string | undefined {
  let current = fs.existsSync(startPath) && fs.statSync(startPath).isDirectory()
    ? path.resolve(startPath)
    : path.dirname(path.resolve(startPath));
  const boundaries = workspaceRoots.map((root) => path.resolve(root));
  while (true) {
    if (fs.existsSync(path.join(current, "YCPL.json"))) {
      return current;
    }
    const parent = path.dirname(current);
    if (parent === current || boundaries.some((root) => current === root)) {
      return undefined;
    }
    current = parent;
  }
}

export function compilerTarget(sourcePath: string, workspaceRoots: readonly string[]): CompilerTarget {
  const projectRoot = findProjectRoot(sourcePath, workspaceRoots);
  if (projectRoot) {
    return { cwd: projectRoot, input: ".", projectRoot };
  }
  const resolved = path.resolve(sourcePath);
  const directory = fs.existsSync(resolved) && fs.statSync(resolved).isDirectory()
    ? resolved
    : path.dirname(resolved);
  return { cwd: directory, input: resolved };
}

export function compilerArguments(
  command: "check" | "build" | "build-ir" | "run",
  input: string,
  outputDirectory: string,
  runArguments: readonly string[] = []
): string[] {
  const args = [command, input];
  if (command !== "check") {
    args.push("-o", outputDirectory);
  }
  if (command === "run" && runArguments.length > 0) {
    args.push("--", ...runArguments);
  }
  return args;
}

export function resolveConfiguredPath(value: string, workspaceRoot: string | undefined): string {
  if (!value) {
    return "";
  }
  return path.isAbsolute(value) || !workspaceRoot ? value : path.resolve(workspaceRoot, value);
}

export function parseCompilerDiagnostics(output: string): CompilerDiagnostic[] {
  const diagnostics: CompilerDiagnostic[] = [];
  const pattern = /^(.+?):(\d+):(\d+):\s*(.+)$/gm;
  for (const match of output.matchAll(pattern)) {
    diagnostics.push({
      file: match[1],
      line: Math.max(1, Number(match[2])),
      column: Math.max(1, Number(match[3])),
      message: match[4].trim()
    });
  }
  return diagnostics;
}

export function compilerEnvironment(
  base: NodeJS.ProcessEnv,
  stlRoot: string,
  runtimeSource: string
): NodeJS.ProcessEnv {
  const env = { ...base };
  if (stlRoot) {
    env.YCPL_STL_ROOT = stlRoot;
  }
  if (runtimeSource) {
    env.YCPL_RUNTIME_SRC = runtimeSource;
  }
  return env;
}
