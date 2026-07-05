import { DiagnosticSeverity, SymbolKind } from "vscode-languageserver/node.js";
import {
  keywords,
  primitiveTypes,
  type CallInfo,
  type ImportInfo,
  type ParameterInfo,
  type ParsedDiagnostic,
  type SymbolCategory,
  type SymbolReference,
  type YcplDocument,
  type YcplSymbol
} from "./model.js";
import {
  computeLineOffsets,
  isIdentifierChar,
  isIdentifierStart,
  rangeFromOffsets
} from "./text.js";

const declarationKeywords = new Set(["fn", "struct", "module", "package", "const", "mut"]);
const keywordSet = new Set<string>(keywords);
const primitiveSet = new Set<string>(primitiveTypes);

interface Token {
  text: string;
  start: number;
  end: number;
}

/**
 * Parses enough YCPL syntax for editor services. The compiler bridge remains
 * the source of truth for complete parsing and typing when it is available.
 */
export class YcplParser {
  /** Parses a YCPL source document into an indexable summary. */
  parse(uri: string, version: number, text: string): YcplDocument {
    const lineOffsets = computeLineOffsets(text);
    const withoutComments = maskCommentsAndStrings(text, true);
    const tokens = tokenize(withoutComments);
    const commentsAndStringsMasked = maskCommentsAndStrings(text, false);

    const imports = this.parseImports(text, lineOffsets);
    const symbols = this.parseSymbols(uri, text, lineOffsets, tokens);
    const references = this.parseReferences(uri, commentsAndStringsMasked, lineOffsets, tokens);
    const calls = this.parseCalls(uri, commentsAndStringsMasked, lineOffsets);
    const diagnostics = this.parseDiagnostics(text, lineOffsets, symbols, imports);
    const moduleName = symbols.find((symbol) => symbol.category === "module" || symbol.category === "package")?.name;

    return {
      uri,
      version,
      text,
      lineOffsets,
      moduleName,
      imports,
      symbols,
      references,
      calls,
      diagnostics
    };
  }

  private parseImports(text: string, lineOffsets: number[]): ImportInfo[] {
    const imports: ImportInfo[] = [];
    const pattern = /\bimport\s+"([^"]+)"(?:\s+as\s+([A-Za-z_][A-Za-z0-9_]*))?/g;
    for (const match of text.matchAll(pattern)) {
      const start = match.index ?? 0;
      const end = start + match[0].length;
      const aliasStart = match[2] ? start + match[0].lastIndexOf(match[2]) : undefined;
      imports.push({
        modulePath: match[1],
        alias: match[2],
        range: rangeFromOffsets(lineOffsets, start, end),
        aliasRange: aliasStart === undefined ? undefined : rangeFromOffsets(lineOffsets, aliasStart, aliasStart + match[2].length)
      });
    }
    return imports;
  }

  private parseSymbols(uri: string, text: string, lineOffsets: number[], tokens: Token[]): YcplSymbol[] {
    const symbols: YcplSymbol[] = [];
    for (let i = 0; i < tokens.length; i += 1) {
      const token = tokens[i];
      const previous = tokens[i - 1]?.text;
      const next = tokens[i + 1];
      if (!next) {
        continue;
      }

      const exported = previous === "pub";
      if ((token.text === "module" || token.text === "package") && next.text) {
        symbols.push(this.createSymbol(uri, text, lineOffsets, next, token.text, token.text, exported));
      }
      if (token.text === "fn" && next.text) {
        symbols.push(this.createFunctionSymbol(uri, text, lineOffsets, tokens, i, exported || previous === "extern" || previous === "intrinsic"));
      }
      if (token.text === "struct" && next.text) {
        symbols.push(this.createSymbol(uri, text, lineOffsets, next, "struct", token.text, exported));
      }
      if ((token.text === "const" || token.text === "mut") && next.text) {
        symbols.push(this.createSymbol(uri, text, lineOffsets, next, token.text === "const" ? "constant" : "variable", this.variableDetail(text, next.end), exported));
      }
      if (isLikelyVariableDeclaration(tokens, i)) {
        symbols.push(this.createSymbol(uri, text, lineOffsets, token, "variable", this.variableDetail(text, token.end), false));
      }
    }

    for (const fn of symbols.filter((symbol) => symbol.category === "function")) {
      const params = fn.parameters ?? [];
      for (const param of params) {
        symbols.push({
          name: param.name,
          category: "parameter",
          kind: SymbolKind.Variable,
          uri,
          range: param.range,
          selectionRange: param.range,
          typeName: param.typeName,
          detail: param.typeName ? `${param.name}: ${param.typeName}` : param.name,
          exported: false,
          containerName: fn.name
        });
      }
    }

    return dedupeSymbols(symbols);
  }

  private createFunctionSymbol(uri: string, text: string, lineOffsets: number[], tokens: Token[], fnIndex: number, exported: boolean): YcplSymbol {
    const name = tokens[fnIndex + 1];
    const start = tokens[fnIndex].start;
    const signatureEnd = findNext(text, name.end, "{", "\n");
    const signature = text.slice(start, signatureEnd > start ? signatureEnd : name.end).trim();
    const parameters = parseParameters(text, lineOffsets, name.end, signatureEnd);
    const returnType = parseReturnType(text.slice(name.end, signatureEnd));
    return {
      name: name.text,
      category: "function",
      kind: SymbolKind.Function,
      uri,
      range: rangeFromOffsets(lineOffsets, start, Math.max(name.end, signatureEnd)),
      selectionRange: rangeFromOffsets(lineOffsets, name.start, name.end),
      detail: signature,
      exported,
      parameters,
      returnType
    };
  }

  private createSymbol(
    uri: string,
    text: string,
    lineOffsets: number[],
    name: Token,
    category: SymbolCategory,
    detail: string,
    exported: boolean
  ): YcplSymbol {
    return {
      name: name.text,
      category,
      kind: kindForCategory(category),
      uri,
      range: declarationRange(text, lineOffsets, name.start, name.end),
      selectionRange: rangeFromOffsets(lineOffsets, name.start, name.end),
      detail,
      typeName: category === "variable" || category === "constant" ? parseTypeAfterName(text, name.end) : undefined,
      exported
    };
  }

  private variableDetail(text: string, nameEnd: number): string {
    const typeName = parseTypeAfterName(text, nameEnd);
    return typeName ? `: ${typeName}` : "inferred";
  }

  private parseReferences(uri: string, text: string, lineOffsets: number[], tokens: Token[]): SymbolReference[] {
    const references: SymbolReference[] = [];
    for (const token of tokens) {
      if (keywordSet.has(token.text) || primitiveSet.has(token.text)) {
        continue;
      }
      references.push({
        name: token.text,
        uri,
        range: rangeFromOffsets(lineOffsets, token.start, token.end)
      });
    }
    return references;
  }

  private parseCalls(uri: string, text: string, lineOffsets: number[]): CallInfo[] {
    const calls: CallInfo[] = [];
    const functionRanges = findFunctionBodies(text);
    const callPattern = /\b([A-Za-z_][A-Za-z0-9_]*)(?:\s*\.\s*([A-Za-z_][A-Za-z0-9_]*))?\s*\(/g;
    for (const match of text.matchAll(callPattern)) {
      const start = match.index ?? 0;
      const callee = match[2] ?? match[1];
      if (callee === "if" || callee === "for") {
        continue;
      }
      const caller = functionRanges.find((range) => start >= range.start && start <= range.end)?.name ?? "<top-level>";
      calls.push({
        caller,
        callee,
        uri,
        range: rangeFromOffsets(lineOffsets, start, start + match[0].length)
      });
    }
    return calls;
  }

  private parseDiagnostics(text: string, lineOffsets: number[], symbols: YcplSymbol[], imports: ImportInfo[]): ParsedDiagnostic[] {
    const diagnostics: ParsedDiagnostic[] = [];
    pushDelimiterDiagnostics(text, lineOffsets, diagnostics);
    const seen = new Map<string, YcplSymbol>();
    for (const symbol of symbols.filter((entry) => entry.category !== "parameter")) {
      const key = `${symbol.category}:${symbol.name}`;
      const existing = seen.get(key);
      if (existing) {
        diagnostics.push({
          message: `Duplicate ${symbol.category} '${symbol.name}'.`,
          range: symbol.selectionRange,
          severity: "error",
          source: "ycpl"
        });
      } else {
        seen.set(key, symbol);
      }
    }

    const importedAliases = new Set(imports.map((entry) => entry.alias).filter((entry): entry is string => !!entry));
    for (const alias of importedAliases) {
      const pattern = new RegExp(`\\b${escapeRegExp(alias)}\\s*\\.`, "g");
      if (!pattern.test(text)) {
        const imported = imports.find((entry) => entry.alias === alias);
        if (imported?.aliasRange) {
          diagnostics.push({
            message: `Imported module alias '${alias}' is not used.`,
            range: imported.aliasRange,
            severity: "warning",
            source: "ycpl"
          });
        }
      }
    }

    void DiagnosticSeverity.Error;
    return diagnostics;
  }
}

function tokenize(text: string): Token[] {
  const tokens: Token[] = [];
  for (let i = 0; i < text.length; i += 1) {
    if (!isIdentifierStart(text[i] ?? "")) {
      continue;
    }
    const start = i;
    i += 1;
    while (i < text.length && isIdentifierChar(text[i] ?? "")) {
      i += 1;
    }
    tokens.push({ text: text.slice(start, i), start, end: i });
    i -= 1;
  }
  return tokens;
}

function maskCommentsAndStrings(text: string, preserveImportStrings: boolean): string {
  let result = "";
  let i = 0;
  while (i < text.length) {
    if (text.startsWith("//", i)) {
      const end = text.indexOf("\n", i);
      const stop = end < 0 ? text.length : end;
      result += " ".repeat(stop - i);
      i = stop;
      continue;
    }
    if (text.startsWith("/*", i)) {
      const end = text.indexOf("*/", i + 2);
      const stop = end < 0 ? text.length : end + 2;
      result += text.slice(i, stop).replace(/[^\n]/g, " ");
      i = stop;
      continue;
    }
    const quote = text[i];
    if (quote === "\"" || quote === "'" || quote === "`") {
      const start = i;
      i += 1;
      while (i < text.length) {
        if (text[i] === "\\" && quote !== "`") {
          i += 2;
          continue;
        }
        if (text[i] === quote) {
          i += 1;
          break;
        }
        i += 1;
      }
      const literal = text.slice(start, i);
      result += preserveImportStrings ? literal : literal.replace(/[^\n]/g, " ");
      continue;
    }
    result += text[i];
    i += 1;
  }
  return result;
}

function kindForCategory(category: SymbolCategory): SymbolKind {
  switch (category) {
    case "function":
    case "constant":
      return SymbolKind.Constant;
    case "struct":
      return SymbolKind.Struct;
    case "module":
    case "namespace":
    case "package":
      return SymbolKind.Module;
    case "field":
      return SymbolKind.Field;
    default:
      return SymbolKind.Variable;
  }
}

function declarationRange(text: string, lineOffsets: number[], start: number, fallbackEnd: number) {
  const end = findNext(text, start, "{", "\n");
  return rangeFromOffsets(lineOffsets, start, end > start ? end : fallbackEnd);
}

function findNext(text: string, start: number, ...needles: string[]): number {
  let best = -1;
  for (const needle of needles) {
    const found = text.indexOf(needle, start);
    if (found >= 0 && (best < 0 || found < best)) {
      best = found;
    }
  }
  return best;
}

function parseTypeAfterName(text: string, nameEnd: number): string | undefined {
  const after = text.slice(nameEnd, Math.min(text.length, nameEnd + 80));
  const match = after.match(/^\s*:\s*([A-Za-z_][A-Za-z0-9_]*|\*?[A-Za-z_][A-Za-z0-9_]*|\[\]\s*[A-Za-z_][A-Za-z0-9_]*)/);
  if (match) {
    return match[1].replace(/\s+/g, "");
  }
  const spaceType = after.match(/^\s+([A-Za-z_][A-Za-z0-9_]*|\*?[A-Za-z_][A-Za-z0-9_]*|\[\]\s*[A-Za-z_][A-Za-z0-9_]*)\s*(?:,|\)|\{|\n)/);
  return spaceType?.[1].replace(/\s+/g, "");
}

function parseParameters(text: string, lineOffsets: number[], nameEnd: number, signatureEnd: number): ParameterInfo[] {
  const open = text.indexOf("(", nameEnd);
  const close = text.indexOf(")", open + 1);
  if (open < 0 || close < 0 || close > signatureEnd) {
    return [];
  }
  const params: ParameterInfo[] = [];
  const paramPattern = /([A-Za-z_][A-Za-z0-9_]*)\s+(\*?\[?\]?\s*[A-Za-z_][A-Za-z0-9_]*)/g;
  const body = text.slice(open + 1, close);
  for (const match of body.matchAll(paramPattern)) {
    const start = open + 1 + (match.index ?? 0);
    params.push({
      name: match[1],
      typeName: match[2].replace(/\s+/g, ""),
      range: rangeFromOffsets(lineOffsets, start, start + match[1].length)
    });
  }
  return params;
}

function parseReturnType(signatureTail: string): string | undefined {
  const match = signatureTail.match(/\)\s+([A-Za-z_][A-Za-z0-9_]*|\*?[A-Za-z_][A-Za-z0-9_]*|\[\]\s*[A-Za-z_][A-Za-z0-9_]*)/);
  return match?.[1].replace(/\s+/g, "");
}

function isLikelyVariableDeclaration(tokens: Token[], index: number): boolean {
  const token = tokens[index];
  if (!token || declarationKeywords.has(token.text) || keywordSet.has(token.text) || primitiveSet.has(token.text)) {
    return false;
  }
  const next = tokens[index + 1];
  const previous = tokens[index - 1];
  if (previous?.text === "fn" || previous?.text === "struct") {
    return false;
  }
  return !!next && (next.start - token.end <= 4) && !keywordSet.has(next.text) && primitiveSet.has(next.text);
}

function dedupeSymbols(symbols: YcplSymbol[]): YcplSymbol[] {
  const seen = new Set<string>();
  return symbols.filter((symbol) => {
    const key = `${symbol.category}:${symbol.name}:${symbol.range.start.line}:${symbol.range.start.character}`;
    if (seen.has(key)) {
      return false;
    }
    seen.add(key);
    return true;
  });
}

function findFunctionBodies(text: string): Array<{ name: string; start: number; end: number }> {
  const ranges: Array<{ name: string; start: number; end: number }> = [];
  const pattern = /\bfn\s+([A-Za-z_][A-Za-z0-9_]*)[^{]*\{/g;
  for (const match of text.matchAll(pattern)) {
    const start = match.index ?? 0;
    const bodyStart = start + match[0].length - 1;
    ranges.push({ name: match[1], start, end: findMatchingBrace(text, bodyStart) });
  }
  return ranges;
}

function findMatchingBrace(text: string, open: number): number {
  let depth = 0;
  for (let i = open; i < text.length; i += 1) {
    if (text[i] === "{") {
      depth += 1;
    } else if (text[i] === "}") {
      depth -= 1;
      if (depth === 0) {
        return i;
      }
    }
  }
  return text.length;
}

function pushDelimiterDiagnostics(text: string, lineOffsets: number[], diagnostics: ParsedDiagnostic[]): void {
  const stack: Array<{ char: string; offset: number }> = [];
  const pairs = new Map([["}", "{"], [")", "("], ["]", "["]]);
  const openers = new Set(["{", "(", "["]);
  const masked = maskCommentsAndStrings(text, false);
  for (let i = 0; i < masked.length; i += 1) {
    const char = masked[i];
    if (openers.has(char)) {
      stack.push({ char, offset: i });
    } else if (pairs.has(char)) {
      const expected = pairs.get(char);
      const actual = stack.pop();
      if (!actual || actual.char !== expected) {
        diagnostics.push({
          message: `Unmatched '${char}'.`,
          range: rangeFromOffsets(lineOffsets, i, i + 1),
          severity: "error",
          source: "ycpl"
        });
      }
    }
  }
  for (const item of stack) {
    diagnostics.push({
      message: `Unclosed '${item.char}'.`,
      range: rangeFromOffsets(lineOffsets, item.offset, item.offset + 1),
      severity: "error",
      source: "ycpl"
    });
  }
}

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
