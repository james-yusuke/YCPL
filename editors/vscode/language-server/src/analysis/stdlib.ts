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
  signature?: string;
  returnType?: string;
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
        for (const match of text.matchAll(/\bpub\s+fn\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)\s*([^{\n]*)/g)) {
          const returnType = match[3]?.trim();
          const signature = `${match[1]}(${normalizeParams(match[2])})${returnType ? ` ${returnType}` : ""}`;
          symbols.push({
            label: `${moduleName}.${match[1]}`,
            modulePath,
            moduleAlias: moduleName,
            symbolName: match[1],
            detail: `${signature} - ${uri}`,
            kind: CompletionItemKind.Function,
            signature,
            returnType
          });
        }
        for (const match of text.matchAll(/\bpub\s+struct\s+([A-Za-z_][A-Za-z0-9_]*)\b/g)) {
          symbols.push({
            label: `${moduleName}.${match[1]}`,
            modulePath,
            moduleAlias: moduleName,
            symbolName: match[1],
            detail: `${match[1]} struct - ${uri}`,
            kind: CompletionItemKind.Struct
          });
        }
      }
      return symbols.length > 0 ? symbols : fallbackStdlib();
    } catch {
      return fallbackStdlib();
    }
  }
}

function normalizeParams(params: string): string {
  return params.trim().replace(/\s+/g, " ");
}

function fallbackStdlib(): StandardLibrarySymbol[] {
  return [
    { label: "std/fmt", modulePath: "std/fmt", moduleAlias: "fmt", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "std/array", modulePath: "std/array", moduleAlias: "array", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "std/io", modulePath: "std/io", moduleAlias: "io", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "std/bytes", modulePath: "std/bytes", moduleAlias: "bytes", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "std/hex", modulePath: "std/hex", moduleAlias: "hex", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "std/base64", modulePath: "std/base64", moduleAlias: "base64", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "std/hash", modulePath: "std/hash", moduleAlias: "hash", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "fmt.println", modulePath: "std/fmt", moduleAlias: "fmt", symbolName: "println", detail: "println(value string)", signature: "println(value string)", kind: CompletionItemKind.Function },
    { label: "bytes.from_string", modulePath: "std/bytes", moduleAlias: "bytes", symbolName: "from_string", detail: "from_string(text string) Bytes", signature: "from_string(text string) Bytes", returnType: "Bytes", kind: CompletionItemKind.Function },
    { label: "bytes.to_string", modulePath: "std/bytes", moduleAlias: "bytes", symbolName: "to_string", detail: "to_string(b Bytes) string", signature: "to_string(b Bytes) string", returnType: "string", kind: CompletionItemKind.Function },
    { label: "bytes.free", modulePath: "std/bytes", moduleAlias: "bytes", symbolName: "free", detail: "free(b Bytes)", signature: "free(b Bytes)", kind: CompletionItemKind.Function },
    { label: "hex.encode", modulePath: "std/hex", moduleAlias: "hex", symbolName: "encode", detail: "encode(b Bytes) string", signature: "encode(b Bytes) string", returnType: "string", kind: CompletionItemKind.Function },
    { label: "hex.decode", modulePath: "std/hex", moduleAlias: "hex", symbolName: "decode", detail: "decode(text string) Bytes", signature: "decode(text string) Bytes", returnType: "Bytes", kind: CompletionItemKind.Function },
    { label: "base64.encode", modulePath: "std/base64", moduleAlias: "base64", symbolName: "encode", detail: "encode(b Bytes) string", signature: "encode(b Bytes) string", returnType: "string", kind: CompletionItemKind.Function },
    { label: "base64.decode", modulePath: "std/base64", moduleAlias: "base64", symbolName: "decode", detail: "decode(text string) Bytes", signature: "decode(text string) Bytes", returnType: "Bytes", kind: CompletionItemKind.Function },
    { label: "hash.fnv1a32", modulePath: "std/hash", moduleAlias: "hash", symbolName: "fnv1a32", detail: "fnv1a32(b Bytes) i64", signature: "fnv1a32(b Bytes) i64", returnType: "i64", kind: CompletionItemKind.Function },
    { label: "hash.crc32", modulePath: "std/hash", moduleAlias: "hash", symbolName: "crc32", detail: "crc32(b Bytes) i64", signature: "crc32(b Bytes) i64", returnType: "i64", kind: CompletionItemKind.Function }
  ];
}
