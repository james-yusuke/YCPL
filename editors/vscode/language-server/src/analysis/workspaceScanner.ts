import * as fs from "node:fs/promises";
import * as path from "node:path";
import { pathToFileURL } from "node:url";
import { YcplParser } from "./parser.js";
import { WorkspaceIndex } from "./workspaceIndex.js";

/** Scans YCPL source files into the workspace index with a bounded traversal. */
export class WorkspaceScanner {
  constructor(
    private readonly parser: YcplParser,
    private readonly index: WorkspaceIndex,
    private readonly maxFiles = 100000
  ) {}

  /** Indexes workspace files without blocking on compiler analysis. */
  async scan(root: string): Promise<number> {
    let count = 0;
    for await (const file of walk(root)) {
      if (!file.endsWith(".yc")) {
        continue;
      }
      if (count >= this.maxFiles) {
        break;
      }
      const text = await fs.readFile(file, "utf8");
      this.index.update(this.parser.parse(pathToFileURL(file).toString(), 0, text));
      count += 1;
    }
    return count;
  }
}

async function* walk(root: string): AsyncGenerator<string> {
  const ignored = new Set([".git", "node_modules", "build", "dist", ".vscode"]);
  let entries;
  try {
    entries = await fs.readdir(root, { withFileTypes: true });
  } catch {
    return;
  }
  for (const entry of entries) {
    if (ignored.has(entry.name)) {
      continue;
    }
    const full = path.join(root, entry.name);
    if (entry.isDirectory()) {
      yield* walk(full);
    } else if (entry.isFile()) {
      yield full;
    }
  }
}
