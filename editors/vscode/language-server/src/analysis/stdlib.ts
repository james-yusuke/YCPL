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
  parameters?: StandardLibraryParameter[];
}

export interface StandardLibraryParameter {
  name: string;
  typeName?: string;
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
    const stlRoot = path.join(this.workspaceRoot, "stl");
    try {
      const files = await collectYcFiles(stlRoot);
      const symbols: StandardLibrarySymbol[] = [];
      for (const file of files) {
        const text = await fs.readFile(file, "utf8");
        const modulePath = modulePathFor(file, text, stlRoot);
        if (!modulePath) {
          continue;
        }
        const moduleAlias = modulePath.slice(modulePath.lastIndexOf("/") + 1);
        symbols.push({
          label: modulePath,
          modulePath,
          moduleAlias,
          detail: "YCPL standard library module",
          kind: CompletionItemKind.Module
        });
        const uri = pathToFileURL(file).toString();
        for (const match of text.matchAll(/\bpub\s+fn\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)\s*([^{\n]*)/g)) {
          const returnType = match[3]?.trim();
          const parameters = parseParameters(match[2]);
          const signature = `${match[1]}(${formatParameters(parameters)})${returnType ? ` ${returnType}` : ""}`;
          symbols.push({
            label: `${moduleAlias}.${match[1]}`,
            modulePath,
            moduleAlias,
            symbolName: match[1],
            detail: `${signature} - ${uri}`,
            kind: CompletionItemKind.Function,
            signature,
            returnType,
            parameters
          });
        }
        for (const match of text.matchAll(/\bpub\s+struct\s+([A-Za-z_][A-Za-z0-9_]*)\b/g)) {
          symbols.push({
            label: `${moduleAlias}.${match[1]}`,
            modulePath,
            moduleAlias,
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

async function collectYcFiles(root: string): Promise<string[]> {
  const files: string[] = [];
  const entries = await fs.readdir(root, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      files.push(...await collectYcFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith(".yc")) {
      files.push(fullPath);
    }
  }
  return files;
}

function modulePathFor(file: string, text: string, stlRoot: string): string | undefined {
  const declared = text.match(/^\s*module\s+([A-Za-z_][A-Za-z0-9_.]*)/m)?.[1];
  if (declared) {
    return declared.replace(/\./g, "/");
  }
  const relative = path.relative(stlRoot, file).replace(/\\/g, "/");
  if (relative.endsWith("/index.yc")) {
    return relative.slice(0, -"/index.yc".length);
  }
  return relative.endsWith(".yc") ? relative.slice(0, -".yc".length) : undefined;
}

function parseParameters(params: string): StandardLibraryParameter[] {
  return params
    .split(",")
    .map((param) => param.trim())
    .filter((param) => param.length > 0)
    .map((param) => {
      const match = param.match(/^([A-Za-z_][A-Za-z0-9_]*)\s+(.+)$/);
      return match ? { name: match[1], typeName: normalizeTypeName(match[2]) } : { name: param };
    });
}

function formatParameters(parameters: StandardLibraryParameter[]): string {
  return parameters.map((param) => param.typeName ? `${param.name} ${param.typeName}` : param.name).join(", ");
}

function normalizeTypeName(typeName: string): string {
  return typeName.trim().replace(/\s+/g, " ").replace(/\s*(\[\]|\*)\s*/g, "$1");
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
    { label: "std/base32", modulePath: "std/base32", moduleAlias: "base32", detail: "YCPL standard library module", kind: CompletionItemKind.Module },
    { label: "fmt.println", modulePath: "std/fmt", moduleAlias: "fmt", symbolName: "println", detail: "println(value string)", signature: "println(value string)", parameters: [{ name: "value", typeName: "string" }], kind: CompletionItemKind.Function },
    { label: "array.make", modulePath: "std/array", moduleAlias: "array", symbolName: "make", detail: "make(typ Type) []T", signature: "make(typ Type) []T", returnType: "[]T", parameters: [{ name: "typ", typeName: "Type" }], kind: CompletionItemKind.Function },
    { label: "array.push", modulePath: "std/array", moduleAlias: "array", symbolName: "push", detail: "push(xs []T, value T) []T", signature: "push(xs []T, value T) []T", returnType: "[]T", parameters: [{ name: "xs", typeName: "[]T" }, { name: "value", typeName: "T" }], kind: CompletionItemKind.Function },
    { label: "text.concat", modulePath: "std/text", moduleAlias: "text", symbolName: "concat", detail: "concat(left string, right string) string", signature: "concat(left string, right string) string", returnType: "string", parameters: [{ name: "left", typeName: "string" }, { name: "right", typeName: "string" }], kind: CompletionItemKind.Function },
    { label: "text.join", modulePath: "std/text", moduleAlias: "text", symbolName: "join", detail: "join(left string, sep string, right string) string", signature: "join(left string, sep string, right string) string", returnType: "string", parameters: [{ name: "left", typeName: "string" }, { name: "sep", typeName: "string" }, { name: "right", typeName: "string" }], kind: CompletionItemKind.Function },
    { label: "map.make_i32", modulePath: "std/map", moduleAlias: "map", symbolName: "make_i32", detail: "make_i32(capacity i32) Map<string, i32>", signature: "make_i32(capacity i32) Map<string, i32>", returnType: "Map<string, i32>", parameters: [{ name: "capacity", typeName: "i32" }], kind: CompletionItemKind.Function },
    { label: "map.set_i32", modulePath: "std/map", moduleAlias: "map", symbolName: "set_i32", detail: "set_i32(handle Map<string, i32>, key string, value i32) i32", signature: "set_i32(handle Map<string, i32>, key string, value i32) i32", returnType: "i32", parameters: [{ name: "handle", typeName: "Map<string, i32>" }, { name: "key", typeName: "string" }, { name: "value", typeName: "i32" }], kind: CompletionItemKind.Function },
    { label: "map.get_i32_or", modulePath: "std/map", moduleAlias: "map", symbolName: "get_i32_or", detail: "get_i32_or(handle Map<string, i32>, key string, missing i32) i32", signature: "get_i32_or(handle Map<string, i32>, key string, missing i32) i32", returnType: "i32", parameters: [{ name: "handle", typeName: "Map<string, i32>" }, { name: "key", typeName: "string" }, { name: "missing", typeName: "i32" }], kind: CompletionItemKind.Function },
    { label: "bytes.from_string", modulePath: "std/bytes", moduleAlias: "bytes", symbolName: "from_string", detail: "from_string(text string) Bytes", signature: "from_string(text string) Bytes", returnType: "Bytes", parameters: [{ name: "text", typeName: "string" }], kind: CompletionItemKind.Function },
    { label: "bytes.to_string", modulePath: "std/bytes", moduleAlias: "bytes", symbolName: "to_string", detail: "to_string(b Bytes) string", signature: "to_string(b Bytes) string", returnType: "string", parameters: [{ name: "b", typeName: "Bytes" }], kind: CompletionItemKind.Function },
    { label: "bytes.free", modulePath: "std/bytes", moduleAlias: "bytes", symbolName: "free", detail: "free(b Bytes)", signature: "free(b Bytes)", parameters: [{ name: "b", typeName: "Bytes" }], kind: CompletionItemKind.Function },
    { label: "hex.encode", modulePath: "std/hex", moduleAlias: "hex", symbolName: "encode", detail: "encode(b Bytes) string", signature: "encode(b Bytes) string", returnType: "string", parameters: [{ name: "b", typeName: "Bytes" }], kind: CompletionItemKind.Function },
    { label: "hex.decode", modulePath: "std/hex", moduleAlias: "hex", symbolName: "decode", detail: "decode(text string) Bytes", signature: "decode(text string) Bytes", returnType: "Bytes", parameters: [{ name: "text", typeName: "string" }], kind: CompletionItemKind.Function },
    { label: "base64.encode", modulePath: "std/base64", moduleAlias: "base64", symbolName: "encode", detail: "encode(b Bytes) string", signature: "encode(b Bytes) string", returnType: "string", parameters: [{ name: "b", typeName: "Bytes" }], kind: CompletionItemKind.Function },
    { label: "base64.decode", modulePath: "std/base64", moduleAlias: "base64", symbolName: "decode", detail: "decode(text string) Bytes", signature: "decode(text string) Bytes", returnType: "Bytes", parameters: [{ name: "text", typeName: "string" }], kind: CompletionItemKind.Function },
    { label: "hash.fnv1a32", modulePath: "std/hash", moduleAlias: "hash", symbolName: "fnv1a32", detail: "fnv1a32(b Bytes) i64", signature: "fnv1a32(b Bytes) i64", returnType: "i64", parameters: [{ name: "b", typeName: "Bytes" }], kind: CompletionItemKind.Function },
    { label: "hash.crc32", modulePath: "std/hash", moduleAlias: "hash", symbolName: "crc32", detail: "crc32(b Bytes) i64", signature: "crc32(b Bytes) i64", returnType: "i64", parameters: [{ name: "b", typeName: "Bytes" }], kind: CompletionItemKind.Function },
    { label: "bytes.eq", modulePath: "std/bytes", moduleAlias: "bytes", symbolName: "eq", detail: "eq(a Bytes, b Bytes) bool", signature: "eq(a Bytes, b Bytes) bool", returnType: "bool", parameters: [{ name: "a", typeName: "Bytes" }, { name: "b", typeName: "Bytes" }], kind: CompletionItemKind.Function },
    { label: "base32.encode", modulePath: "std/base32", moduleAlias: "base32", symbolName: "encode", detail: "encode(b Bytes) string", signature: "encode(b Bytes) string", returnType: "string", parameters: [{ name: "b", typeName: "Bytes" }], kind: CompletionItemKind.Function },
    { label: "base32.decode", modulePath: "std/base32", moduleAlias: "base32", symbolName: "decode", detail: "decode(text string) Bytes", signature: "decode(text string) Bytes", returnType: "Bytes", parameters: [{ name: "text", typeName: "string" }], kind: CompletionItemKind.Function }
  ];
}
