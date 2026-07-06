import * as fs from "node:fs/promises";
import * as path from "node:path";
import { pathToFileURL } from "node:url";
import { CompletionItemKind } from "vscode-languageserver/node";

export interface StandardLibrarySymbol {
  label: string;
  modulePath: string;
  moduleAlias: string;
  symbolName?: string;
  detail: string;
  kind: CompletionItemKind;
}

/** Provides lazily indexed YCPL standard-library modules and exported symbols. */
export class StandardLibraryIndex {
  private symbols: StandardLibrarySymbol[] | undefined;

  constructor(private readonly workspaceRoot: string | undefined) {}

  /** Returns known stdlib completion symbols. */
  async completionItems(): Promise<StandardLibrarySymbol[]> {
    if (this.symbols) {
      return this.symbols;
    }
    this.symbols = await this.scan();
    return this.symbols;
  }

  private async scan(): Promise<StandardLibrarySymbol[]> {
    if (!this.workspaceRoot) {
      return fallbackStdlib();
    }
    const stdRoot = path.join(this.workspaceRoot, "stl", "std");
    try {
      const entries = await fs.readdir(stdRoot, { withFileTypes: true });
      const symbols: StandardLibrarySymbol[] = [];
      for (const entry of entries) {
        if (!entry.isFile() || !entry.name.endsWith(".yc")) {
          continue;
        }
        const moduleName = entry.name.slice(0, -3);
        const modulePath = `std/${moduleName}`;
        symbols.push({
          label: modulePath,
          modulePath,
          moduleAlias: moduleName,
          detail: "YCPL standard library module",
          kind: CompletionItemKind.Module
        });
        const uri = pathToFileURL(path.join(stdRoot, entry.name)).toString();
        const text = await fs.readFile(path.join(stdRoot, entry.name), "utf8");
        for (const match of text.matchAll(/\bpub\s+fn\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)\s*([A-Za-z_][A-Za-z0-9_]*)?/g)) {
          symbols.push({
            label: `${moduleName}.${match[1]}`,
            modulePath,
            moduleAlias: moduleName,
            symbolName: match[1],
            detail: `${match[1]}(${match[2]})${match[3] ? ` ${match[3]}` : ""} - ${uri}`,
            kind: CompletionItemKind.Function
          });
        }
      }
      return symbols.length > 0 ? symbols : fallbackStdlib();
    } catch {
      return fallbackStdlib();
    }
  }
}

function fallbackStdlib(): StandardLibrarySymbol[] {
  return [
    { label: "std/fmt", modulePath: "std/fmt", moduleAlias: "fmt", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "std/array", modulePath: "std/array", moduleAlias: "array", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "std/io", modulePath: "std/io", moduleAlias: "io", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "fmt.println", modulePath: "std/fmt", moduleAlias: "fmt", symbolName: "println", detail: "println(value: string)", kind: CompletionItemKind.Function }
  ];
}
