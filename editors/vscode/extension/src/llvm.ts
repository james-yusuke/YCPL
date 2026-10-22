import * as path from "node:path";
import { findOnPath, isExecutable } from "./runtime.js";

export function llvmTool(name: string, env: NodeJS.ProcessEnv = process.env): string {
  const configured = name === "clang" ? env.CLANG : name === "llc" ? env.LLC : undefined;
  const candidates = [
    configured,
    ...(env.LLVM_BINDIR ? [path.join(env.LLVM_BINDIR, name)] : []),
    `/opt/homebrew/opt/llvm@22/bin/${name}`,
    `/usr/local/opt/llvm@22/bin/${name}`,
    `/usr/lib/llvm-22/bin/${name}`,
    findOnPath(name)
  ];
  const result = candidates.find((candidate): candidate is string => !!candidate && isExecutable(candidate));
  if (!result) throw new Error(`LLVM 22 ${name} not found. Set LLVM_BINDIR.`);
  return result;
}

/** Shell-style quoting only. No expansion or command execution is performed. */
export function flagArguments(text: string): string[] {
  const result: string[] = [];
  let value = "",
    quote = "",
    present = false;
  for (let at = 0; at < text.length; at++) {
    const ch = text[at];
    if (ch === "\\" && quote !== "'") {
      if (++at === text.length) throw new Error("Unterminated escape in LINKFLAGS.");
      value += text[at];
      present = true;
    } else if (quote) {
      if (ch === quote) quote = "";
      else value += ch;
    } else if (ch === '"' || ch === "'") {
      quote = ch;
      present = true;
    } else if (/\s/.test(ch)) {
      if (present) result.push(value);
      value = "";
      present = false;
    } else {
      value += ch;
      present = true;
    }
  }
  if (quote) throw new Error("Unterminated quote in LINKFLAGS.");
  if (present) result.push(value);
  return result;
}

export interface LineCoverage {
  file: string;
  lines: Map<number, number>;
}

/** LLVM gcov's intermediate format uses one file record followed by line counts. */
export function parseCoverage(text: string): LineCoverage[] {
  const files = new Map<string, Map<number, number>>();
  let lines: Map<number, number> | undefined;
  for (const line of text.split(/\r?\n/)) {
    if (line.startsWith("file:")) {
      const file = line.slice(5);
      lines = files.get(file) ?? new Map();
      files.set(file, lines);
    } else if (lines && line.startsWith("lcount:")) {
      const [number, hits] = line.slice(7).split(",").map(Number);
      if (Number.isSafeInteger(number) && number > 0 && Number.isFinite(hits) && hits >= 0)
        lines.set(number, (lines.get(number) ?? 0) + hits);
    }
  }
  return [...files].map(([file, lines]) => ({ file, lines }));
}
