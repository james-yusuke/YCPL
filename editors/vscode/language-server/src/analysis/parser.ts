import { DiagnosticSeverity, SymbolKind } from "vscode-languageserver/node";
import {
  keywords,
  primitiveTypes,
  type CallInfo,
  type ImportInfo,
  type ParameterInfo,
  type ParsedDiagnostic,
  type ScopeId,
  type SymbolCategory,
  type SymbolReference,
  type YcplDocument,
  type YcplScope,
  type YcplSymbol
} from "./model.js";
import {
  computeLineOffsets,
  isIdentifierChar,
  isIdentifierStart,
  rangeFromOffsets
} from "./text.js";

const declarationKeywords = new Set(["fn", "struct", "enum", "type", "module", "package", "const", "mut"]);
const keywordSet = new Set<string>(keywords);
const primitiveSet = new Set<string>(primitiveTypes);
const typeCategories: SymbolCategory[] = ["struct", "enum", "typeAlias"];

interface Token {
  text: string;
  start: number;
  end: number;
}

interface Span {
  start: number;
  end: number;
}

interface StructBody extends Span {
  name: string;
  bodyStart: number;
  bodyEnd: number;
  scopeId: ScopeId;
}

interface FunctionBody extends Span {
  name: string;
  nameStart: number;
  bodyStart: number;
  bodyEnd: number;
  scopeId: ScopeId;
}

interface EnumBody extends Span {
  name: string;
  bodyStart: number;
  bodyEnd: number;
}

/**
 * Parses enough YCPL syntax for editor services. The compiler bridge remains
 * the source of truth for complete parsing and typing when it is available.
 */
export class YcplParser {
  /** Parses a YCPL source document into an indexable summary. */
  parse(uri: string, version: number, text: string): YcplDocument {
    const lineOffsets = computeLineOffsets(text);
    const withoutComments = maskCommentsAndStrings(text, false);
    const tokens = tokenize(withoutComments);
    const commentsAndStringsMasked = maskCommentsAndStrings(text, false);

    const functionRanges = findFunctionBodies(uri, text);
    const structBodies = parseStructBodies(uri, text, lineOffsets);
    const enumBodies = parseEnumBodies(text, lineOffsets);
    const scopes = buildScopes(uri, text, lineOffsets, functionRanges, structBodies);
    const imports = this.parseImports(text, lineOffsets);
    const symbols = this.parseSymbols(uri, text, lineOffsets, tokens, imports, scopes, functionRanges, structBodies, enumBodies);
    const references = this.parseReferences(uri, commentsAndStringsMasked, lineOffsets, tokens, scopes, symbols);
    const calls = this.parseCalls(uri, commentsAndStringsMasked, lineOffsets, scopes, symbols, functionRanges);
    const diagnostics = this.parseDiagnostics(text, lineOffsets, symbols, imports);
    const moduleName = symbols.find((symbol) => symbol.category === "module" || symbol.category === "package")?.name;

    return {
      uri,
      version,
      text,
      lineOffsets,
      moduleName,
      scopes,
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

  private parseSymbols(
    uri: string,
    text: string,
    lineOffsets: number[],
    tokens: Token[],
    imports: ImportInfo[],
    scopes: YcplScope[],
    functionRanges: FunctionBody[],
    structBodies: StructBody[],
    enumBodies: EnumBody[]
  ): YcplSymbol[] {
    const symbols: YcplSymbol[] = [];
    const globalScope = rootScope(scopes);
    for (const imported of imports) {
      if (imported.alias && imported.aliasRange) {
        symbols.push({
          id: symbolId(uri, "namespace", imported.alias, rangeStartOffset(text, lineOffsets, imported.aliasRange)),
          name: imported.alias,
          category: "namespace",
          kind: SymbolKind.Namespace,
          uri,
          range: imported.range,
          selectionRange: imported.aliasRange,
          detail: imported.modulePath,
          exported: false,
          scopeId: globalScope.id
        });
      }
    }

    for (const body of structBodies) {
      symbols.push(...parseStructFields(uri, text, lineOffsets, body));
    }
    for (const body of enumBodies) {
      symbols.push(...parseEnumMembers(uri, text, lineOffsets, body, globalScope.id));
    }

    const parameterSpans = functionParameterSpans(text);
    for (let i = 0; i < tokens.length; i += 1) {
      const token = tokens[i];
      const previous = tokens[i - 1]?.text;
      const next = tokens[i + 1];
      if (!next) {
        continue;
      }

      const exported = previous === "pub";
      if ((token.text === "module" || token.text === "package") && next.text) {
        symbols.push(this.createSymbol(uri, text, lineOffsets, next, token.text, token.text, exported, globalScope.id));
      }
      if (token.text === "fn" && next.text) {
        symbols.push(this.createFunctionSymbol(uri, text, lineOffsets, tokens, i, scopes, exported || previous === "extern" || previous === "intrinsic"));
      }
      if (token.text === "struct" && next.text) {
        symbols.push(this.createSymbol(uri, text, lineOffsets, next, "struct", token.text, exported, globalScope.id));
      }
      if (token.text === "enum" && next.text) {
        symbols.push(this.createSymbol(uri, text, lineOffsets, next, "enum", token.text, exported, globalScope.id));
      }
      if (token.text === "type" && next.text) {
        symbols.push(this.createTypeAliasSymbol(uri, text, lineOffsets, next, exported, globalScope.id));
      }
      if ((token.text === "const" || token.text === "mut") && next.text && !isInsideSpan(next, structBodies)) {
        symbols.push(this.createSymbol(uri, text, lineOffsets, next, token.text === "const" ? "constant" : "variable", this.variableDetail(text, next.end), exported, scopeForOffset(scopes, next.start).id, enclosingFunctionName(next.start, functionRanges)));
      }
      if (isLikelyVariableDeclaration(text, tokens, i, parameterSpans, structBodies)) {
        symbols.push(this.createSymbol(uri, text, lineOffsets, token, "variable", this.variableDetail(text, token.end), false, scopeForOffset(scopes, token.start).id, enclosingFunctionName(token.start, functionRanges)));
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
          id: symbolId(uri, "parameter", param.name, rangeStartOffset(text, lineOffsets, param.range)),
          scopeId: fnScopeForSymbol(scopes, fn).id,
          containerName: fn.name
        });
      }
    }

    return dedupeSymbols(symbols);
  }

  private createFunctionSymbol(uri: string, text: string, lineOffsets: number[], tokens: Token[], fnIndex: number, scopes: YcplScope[], exported: boolean): YcplSymbol {
    const name = tokens[fnIndex + 1];
    const start = tokens[fnIndex].start;
    const signatureEnd = findNext(text, name.end, "{", "\n");
    const signature = text.slice(start, signatureEnd > start ? signatureEnd : name.end).trim();
    const parameters = parseParameters(text, lineOffsets, name.end, signatureEnd);
    const returnType = parseReturnType(text.slice(name.end, signatureEnd));
    return {
      id: symbolId(uri, "function", name.text, name.start),
      name: name.text,
      category: "function",
      kind: SymbolKind.Function,
      uri,
      range: rangeFromOffsets(lineOffsets, start, Math.max(name.end, signatureEnd)),
      selectionRange: rangeFromOffsets(lineOffsets, name.start, name.end),
      detail: signature,
      exported,
      scopeId: rootScope(scopes).id,
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
    exported: boolean,
    scopeId: ScopeId,
    containerName?: string
  ): YcplSymbol {
    return {
      id: symbolId(uri, category, name.text, name.start),
      name: name.text,
      category,
      kind: kindForCategory(category),
      uri,
      range: declarationRange(text, lineOffsets, name.start, name.end),
      selectionRange: rangeFromOffsets(lineOffsets, name.start, name.end),
      detail,
      typeName: category === "variable" || category === "constant" ? parseTypeAfterName(text, name.end) : undefined,
      exported,
      scopeId,
      containerName
    };
  }

  private createTypeAliasSymbol(uri: string, text: string, lineOffsets: number[], name: Token, exported: boolean, scopeId: ScopeId): YcplSymbol {
    const target = parseTypeAliasTarget(text, name.end);
    return {
      id: symbolId(uri, "typeAlias", name.text, name.start),
      name: name.text,
      category: "typeAlias",
      kind: kindForCategory("typeAlias"),
      uri,
      range: declarationRange(text, lineOffsets, name.start, name.end),
      selectionRange: rangeFromOffsets(lineOffsets, name.start, name.end),
      detail: target ? `type ${name.text} = ${target}` : `type ${name.text}`,
      typeName: target,
      exported,
      scopeId
    };
  }

  private variableDetail(text: string, nameEnd: number): string {
    const typeName = parseTypeAfterName(text, nameEnd);
    return typeName ? `: ${typeName}` : "inferred";
  }

  private parseReferences(uri: string, text: string, lineOffsets: number[], tokens: Token[], scopes: YcplScope[], symbols: YcplSymbol[]): SymbolReference[] {
    const references: SymbolReference[] = [];
    for (const token of tokens) {
      if (keywordSet.has(token.text) || primitiveSet.has(token.text)) {
        continue;
      }
      if (symbols.some((symbol) => sameRangeOffset(text, lineOffsets, symbol.selectionRange, token.start, token.end))) {
        continue;
      }
      const scope = scopeForOffset(scopes, token.start);
      const resolved = resolveTokenSymbol(text, token, scopes, symbols);
      references.push({
        name: token.text,
        uri,
        range: rangeFromOffsets(lineOffsets, token.start, token.end),
        scopeId: scope.id,
        symbolId: resolved?.id
      });
    }
    return references;
  }

  private parseCalls(uri: string, text: string, lineOffsets: number[], scopes: YcplScope[], symbols: YcplSymbol[], functionRanges: FunctionBody[]): CallInfo[] {
    const calls: CallInfo[] = [];
    const callPattern = /\b([A-Za-z_][A-Za-z0-9_]*)(?:\s*\.\s*([A-Za-z_][A-Za-z0-9_]*))?\s*\(/g;
    for (const match of text.matchAll(callPattern)) {
      const start = match.index ?? 0;
      const callee = match[2] ?? match[1];
      if (callee === "if" || callee === "for") {
        continue;
      }
      const callerRange = functionRanges.find((range) => start >= range.start && start <= range.end);
      const caller = callerRange?.name ?? "<top-level>";
      const calleeStart = start + match[0].lastIndexOf(callee);
      const calleeSymbol = resolveTokenSymbol(text, { text: callee, start: calleeStart, end: calleeStart + callee.length }, scopes, symbols);
      calls.push({
        caller,
        callee,
        uri,
        range: rangeFromOffsets(lineOffsets, start, start + match[0].length),
        callerSymbolId: callerRange ? symbolId(uri, "function", callerRange.name, callerRange.nameStart) : undefined,
        calleeSymbolId: calleeSymbol?.id
      });
    }
    return calls;
  }

  private parseDiagnostics(text: string, lineOffsets: number[], symbols: YcplSymbol[], imports: ImportInfo[]): ParsedDiagnostic[] {
    const diagnostics: ParsedDiagnostic[] = [];
    pushDelimiterDiagnostics(text, lineOffsets, diagnostics);
    const seen = new Map<string, YcplSymbol>();
    for (const symbol of symbols.filter((entry) => shouldCheckDuplicate(entry))) {
      const key = duplicateKey(symbol);
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
      return SymbolKind.Function;
    case "constant":
      return SymbolKind.Constant;
    case "struct":
      return SymbolKind.Struct;
    case "enum":
      return SymbolKind.Enum;
    case "enumMember":
      return SymbolKind.EnumMember;
    case "typeAlias":
      return SymbolKind.TypeParameter;
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

function parseTypeAliasTarget(text: string, nameEnd: number): string | undefined {
  const lineEnd = findNext(text, nameEnd, "\n", "{");
  const end = lineEnd > nameEnd ? lineEnd : Math.min(text.length, nameEnd + 120);
  const match = text.slice(nameEnd, end).match(/^\s*=?\s*([A-Za-z_][A-Za-z0-9_.]*|\*?[A-Za-z_][A-Za-z0-9_.]*|\[\]\s*[A-Za-z_][A-Za-z0-9_.]*)/);
  return match?.[1].replace(/\s+/g, "");
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

function isLikelyVariableDeclaration(text: string, tokens: Token[], index: number, parameterSpans: Span[], structBodies: Span[]): boolean {
  const token = tokens[index];
  if (!token || declarationKeywords.has(token.text) || keywordSet.has(token.text) || primitiveSet.has(token.text)) {
    return false;
  }
  if (isInsideSpan(token, parameterSpans) || isInsideSpan(token, structBodies)) {
    return false;
  }
  const previous = tokens[index - 1];
  if (previous?.text === "fn" || previous?.text === "struct") {
    return false;
  }

  const after = text.slice(token.end, Math.min(text.length, token.end + 96));
  return /^\s*:=/.test(after) || /^\s*:\s*(?:\*?\s*)?(?:\[\]\s*)?[A-Za-z_][A-Za-z0-9_]*\s*:=/.test(after);
}

function functionParameterSpans(text: string): Array<{ start: number; end: number }> {
  const spans: Array<{ start: number; end: number }> = [];
  const pattern = /\bfn\s+[A-Za-z_][A-Za-z0-9_]*\s*\(/g;
  for (const match of text.matchAll(pattern)) {
    const open = (match.index ?? 0) + match[0].length - 1;
    const close = text.indexOf(")", open + 1);
    const brace = text.indexOf("{", open + 1);
    if (close > open && (brace < 0 || close < brace)) {
      spans.push({ start: open + 1, end: close });
    }
  }
  return spans;
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

function findFunctionBodies(uri: string, text: string): FunctionBody[] {
  const ranges: FunctionBody[] = [];
  const pattern = /\bfn\s+([A-Za-z_][A-Za-z0-9_]*)[^{]*\{/g;
  for (const match of text.matchAll(pattern)) {
    const start = match.index ?? 0;
    const nameStart = start + match[0].indexOf(match[1]);
    const bodyStart = start + match[0].length - 1;
    const end = findMatchingBrace(text, bodyStart);
    ranges.push({
      name: match[1],
      nameStart,
      start,
      end,
      bodyStart: bodyStart + 1,
      bodyEnd: end,
      scopeId: scopeId(uri, "function", match[1], start)
    });
  }
  return ranges;
}

function parseStructBodies(uri: string, text: string, lineOffsets: number[]): StructBody[] {
  const bodies: StructBody[] = [];
  const pattern = /\bstruct\s+([A-Za-z_][A-Za-z0-9_]*)[^{]*\{/g;
  for (const match of text.matchAll(pattern)) {
    const start = match.index ?? 0;
    const open = start + match[0].length - 1;
    const close = findMatchingBrace(text, open);
    const nameStart = start + match[0].indexOf(match[1]);
    if (close > open) {
      bodies.push({
        name: match[1],
        start: nameStart,
        end: close + 1,
        bodyStart: open + 1,
        bodyEnd: close,
        scopeId: scopeId(uri, "struct", match[1], nameStart)
      });
    }
  }
  void lineOffsets;
  return bodies;
}

function parseEnumBodies(text: string, lineOffsets: number[]): EnumBody[] {
  const bodies: EnumBody[] = [];
  const masked = maskCommentsAndStrings(text, false);
  const pattern = /\benum\s+([A-Za-z_][A-Za-z0-9_]*)[^{]*\{/g;
  for (const match of masked.matchAll(pattern)) {
    const start = match.index ?? 0;
    const open = start + match[0].length - 1;
    const close = findMatchingBrace(masked, open);
    const nameStart = start + match[0].indexOf(match[1]);
    if (close > open) {
      bodies.push({
        name: match[1],
        start: nameStart,
        end: close + 1,
        bodyStart: open + 1,
        bodyEnd: close
      });
    }
  }
  void lineOffsets;
  return bodies;
}

function parseEnumMembers(uri: string, text: string, lineOffsets: number[], body: EnumBody, scopeId: ScopeId): YcplSymbol[] {
  const members: YcplSymbol[] = [];
  const variantPattern = /^\s*([A-Za-z_][A-Za-z0-9_]*)(?:\s*=\s*-?(?:0x[0-9A-Fa-f]+|0b[01]+|[0-9]+))?\s*,?\s*$/gm;
  const bodyText = text.slice(body.bodyStart, body.bodyEnd);
  for (const match of bodyText.matchAll(variantPattern)) {
    if (keywordSet.has(match[1]) || primitiveSet.has(match[1])) {
      continue;
    }
    const lineStart = body.bodyStart + (match.index ?? 0);
    const nameStart = lineStart + match[0].indexOf(match[1]);
    const nameEnd = nameStart + match[1].length;
    members.push({
      id: symbolId(uri, "enumMember", match[1], nameStart),
      name: match[1],
      category: "enumMember",
      kind: SymbolKind.EnumMember,
      uri,
      range: rangeFromOffsets(lineOffsets, nameStart, lineStart + match[0].length),
      selectionRange: rangeFromOffsets(lineOffsets, nameStart, nameEnd),
      detail: `${body.name}.${match[1]}`,
      exported: false,
      scopeId,
      containerName: body.name
    });
  }
  return members;
}

function buildScopes(uri: string, text: string, lineOffsets: number[], functionRanges: FunctionBody[], structBodies: StructBody[]): YcplScope[] {
  const masked = maskCommentsAndStrings(text, false);
  const root: YcplScope = {
    id: scopeId(uri, "global", "global", 0),
    kind: "global",
    uri,
    range: rangeFromOffsets(lineOffsets, 0, text.length),
    startOffset: 0,
    endOffset: text.length,
    name: "global"
  };
  const scopes: YcplScope[] = [root];
  for (const body of structBodies) {
    scopes.push({
      id: body.scopeId,
      kind: "struct",
      uri,
      range: rangeFromOffsets(lineOffsets, body.start, body.end),
      startOffset: body.start,
      endOffset: body.end,
      parentId: root.id,
      name: body.name
    });
  }
  for (const body of functionRanges) {
    const functionScope: YcplScope = {
      id: body.scopeId,
      kind: "function",
      uri,
      range: rangeFromOffsets(lineOffsets, body.start, body.end),
      startOffset: body.start,
      endOffset: body.end,
      parentId: root.id,
      name: body.name
    };
    scopes.push(functionScope);
    const stack: YcplScope[] = [functionScope];
    for (let offset = body.bodyStart; offset < body.bodyEnd; offset += 1) {
      const char = masked[offset];
      if (char === "{") {
        const kind = classifyBlockScope(masked, offset);
        const blockScope: YcplScope = {
          id: scopeId(uri, kind, `${kind}@${offset}`, offset),
          kind,
          uri,
          range: rangeFromOffsets(lineOffsets, offset, body.bodyEnd),
          startOffset: offset + 1,
          endOffset: body.bodyEnd,
          parentId: stack[stack.length - 1]?.id,
          name: kind
        };
        scopes.push(blockScope);
        stack.push(blockScope);
      } else if (char === "}" && stack.length > 1) {
        const completed = stack.pop();
        if (completed) {
          completed.endOffset = offset;
          completed.range = rangeFromOffsets(lineOffsets, completed.startOffset - 1, offset + 1);
        }
      }
    }
  }
  return scopes;
}

function classifyBlockScope(text: string, openBraceOffset: number): YcplScope["kind"] {
  const before = text.slice(Math.max(0, openBraceOffset - 160), openBraceOffset);
  if (/\bdefault\s*$/.test(before)) {
    return "default";
  }
  if (/\bcase\b[^{;]*$/.test(before)) {
    return "case";
  }
  if (/\bswitch\b[^{;]*$/.test(before)) {
    return "switch";
  }
  if (/\belse\s*$/.test(before)) {
    return "else";
  }
  if (/\bif\b[^{;]*$/.test(before)) {
    return "if";
  }
  if (/\bfor\b[^{;]*$/.test(before)) {
    return "for";
  }
  return "block";
}

function rootScope(scopes: YcplScope[]): YcplScope {
  return scopes.find((scope) => scope.kind === "global") ?? scopes[0];
}

function scopeForOffset(scopes: YcplScope[], offset: number): YcplScope {
  return scopes
    .filter((scope) => offset >= scope.startOffset && offset <= scope.endOffset)
    .sort((left, right) => (left.endOffset - left.startOffset) - (right.endOffset - right.startOffset))[0] ?? rootScope(scopes);
}

function fnScopeForSymbol(scopes: YcplScope[], symbol: YcplSymbol): YcplScope {
  return scopes.find((scope) => scope.kind === "function" && scope.name === symbol.name) ?? rootScope(scopes);
}

function resolveTokenSymbol(text: string, token: Token, scopes: YcplScope[], symbols: YcplSymbol[]): YcplSymbol | undefined {
  const field = resolveFieldAccess(text, token, scopes, symbols) ?? resolveStructLiteralField(text, token, symbols);
  if (field) {
    return field;
  }
  const wantedKind: readonly SymbolCategory[] | undefined = isFunctionCallToken(text, token)
    ? ["function"]
    : isTypeTokenContext(text, token)
      ? typeCategories
      : undefined;
  return resolveLexical(token.text, scopeForOffset(scopes, token.start), scopes, symbols, wantedKind);
}

function resolveLexical(name: string, startScope: YcplScope, scopes: YcplScope[], symbols: YcplSymbol[], wantedKinds?: readonly SymbolCategory[]): YcplSymbol | undefined {
  let scope: YcplScope | undefined = startScope;
  while (scope) {
    const found = symbols
      .filter((symbol) => symbol.name === name && symbol.scopeId === scope?.id && (!wantedKinds || wantedKinds.includes(symbol.category)))
      .sort((left, right) => symbolPriority(left) - symbolPriority(right))[0];
    if (found) {
      return found;
    }
    scope = scope.parentId ? scopes.find((candidate) => candidate.id === scope?.parentId) : undefined;
  }
  return symbols
    .filter((symbol) => symbol.name === name && symbol.scopeId === rootScope(scopes).id && (!wantedKinds || wantedKinds.includes(symbol.category)))
    .sort((left, right) => symbolPriority(left) - symbolPriority(right))[0];
}

function resolveFieldAccess(text: string, token: Token, scopes: YcplScope[], symbols: YcplSymbol[]): YcplSymbol | undefined {
  const before = text.slice(Math.max(0, token.start - 80), token.start);
  const receiver = before.match(/([A-Za-z_][A-Za-z0-9_]*)\s*\.\s*$/)?.[1];
  if (!receiver) {
    return undefined;
  }
  const receiverOffset = token.start - before.length + before.lastIndexOf(receiver);
  const receiverSymbol = resolveLexical(receiver, scopeForOffset(scopes, receiverOffset), scopes, symbols);
  if (receiverSymbol?.category === "enum") {
    return symbols.find((symbol) => symbol.category === "enumMember" && symbol.containerName === receiverSymbol.name && symbol.name === token.text);
  }
  const receiverType = receiverSymbol?.typeName;
  if (!receiverType) {
    return undefined;
  }
  return symbols.find((symbol) => symbol.category === "field" && symbol.containerName === receiverType && symbol.name === token.text);
}

function resolveStructLiteralField(text: string, token: Token, symbols: YcplSymbol[]): YcplSymbol | undefined {
  if (!/^\s*:/.test(text.slice(token.end, Math.min(text.length, token.end + 16)))) {
    return undefined;
  }
  const open = text.lastIndexOf("{", token.start);
  if (open < 0) {
    return undefined;
  }
  const typeName = text.slice(0, open).match(/([A-Za-z_][A-Za-z0-9_]*)\s*$/)?.[1];
  return typeName ? symbols.find((symbol) => symbol.category === "field" && symbol.containerName === typeName && symbol.name === token.text) : undefined;
}

function parseStructFields(uri: string, text: string, lineOffsets: number[], body: StructBody): YcplSymbol[] {
  const fields: YcplSymbol[] = [];
  const fieldPattern = /^\s*([A-Za-z_][A-Za-z0-9_]*)\s+(\*?\s*(?:\[\]\s*)?[A-Za-z_][A-Za-z0-9_]*)\s*$/gm;
  const bodyText = text.slice(body.bodyStart, body.bodyEnd);
  for (const match of bodyText.matchAll(fieldPattern)) {
    if (keywordSet.has(match[1]) || primitiveSet.has(match[1]) || keywordSet.has(match[2]) || !isFieldTypeName(match[2])) {
      continue;
    }
    const lineStart = body.bodyStart + (match.index ?? 0);
    const nameStart = lineStart + match[0].indexOf(match[1]);
    const nameEnd = nameStart + match[1].length;
    const typeName = match[2].replace(/\s+/g, "");
    fields.push({
      id: symbolId(uri, "field", match[1], nameStart),
      name: match[1],
      category: "field",
      kind: SymbolKind.Field,
      uri,
      range: rangeFromOffsets(lineOffsets, nameStart, lineStart + match[0].length),
      selectionRange: rangeFromOffsets(lineOffsets, nameStart, nameEnd),
      detail: `${match[1]}: ${typeName}`,
      typeName,
      exported: false,
      scopeId: body.scopeId,
      containerName: body.name
    });
  }
  return fields;
}

function enclosingFunctionName(offset: number, functionRanges: Array<{ name: string; start: number; end: number }>): string | undefined {
  return functionRanges.find((range) => offset >= range.start && offset <= range.end)?.name;
}

function isInsideSpan(token: Token, spans: Span[]): boolean {
  return spans.some((span) => token.start >= span.start && token.end <= span.end);
}

function shouldCheckDuplicate(symbol: YcplSymbol): boolean {
  return symbol.category === "function"
    || symbol.category === "struct"
    || symbol.category === "enum"
    || symbol.category === "enumMember"
    || symbol.category === "typeAlias"
    || symbol.category === "module"
    || symbol.category === "package"
    || symbol.category === "constant"
    || symbol.category === "field";
}

function duplicateKey(symbol: YcplSymbol): string {
  if (symbol.category === "field") {
    return `${symbol.category}:${symbol.containerName ?? ""}:${symbol.name}`;
  }
  if (symbol.category === "enumMember") {
    return `${symbol.category}:${symbol.containerName ?? ""}:${symbol.name}`;
  }
  if (symbol.category === "constant" && symbol.containerName) {
    return `${symbol.category}:${symbol.containerName}:${symbol.name}`;
  }
  return `${symbol.category}:${symbol.name}`;
}

function isFieldTypeName(typeName: string): boolean {
  const normalized = typeName.replace(/\s+/g, "").replace(/^\*+/, "").replace(/^(\[\])+/, "");
  return primitiveSet.has(normalized) || /^[A-Z][A-Za-z0-9_]*$/.test(normalized);
}

function symbolId(uri: string, category: SymbolCategory, name: string, offset: number): string {
  return `${uri}#symbol:${category}:${name}:${offset}`;
}

function scopeId(uri: string, kind: string, name: string, offset: number): ScopeId {
  return `${uri}#scope:${kind}:${name}:${offset}`;
}

function rangeStartOffset(text: string, lineOffsets: number[], range: { start: { line: number; character: number } }): number {
  void text;
  return (lineOffsets[range.start.line] ?? 0) + range.start.character;
}

function sameRangeOffset(text: string, lineOffsets: number[], range: { start: { line: number; character: number }; end: { line: number; character: number } }, start: number, end: number): boolean {
  void text;
  return rangeStartOffset("", lineOffsets, range) === start && ((lineOffsets[range.end.line] ?? 0) + range.end.character) === end;
}

function isFunctionCallToken(text: string, token: Token): boolean {
  return /^\s*\(/.test(text.slice(token.end, Math.min(text.length, token.end + 16)));
}

function isTypeTokenContext(text: string, token: Token): boolean {
  const before = text.slice(Math.max(0, token.start - 48), token.start);
  const after = text.slice(token.end, Math.min(text.length, token.end + 32));
  if (/\.\s*$/.test(before)) {
    return false;
  }
  if (/\b(?:case|switch|return|if|for|in)\s+$/.test(before)) {
    return false;
  }
  return /\)\s*$/.test(before)
    || /:\s*$/.test(before)
    || /\b[A-Za-z_][A-Za-z0-9_]*\s+$/.test(before) && /^\s*(?:,|\)|\{|$)/.test(after);
}

function symbolPriority(symbol: YcplSymbol): number {
  switch (symbol.category) {
    case "parameter":
      return 0;
    case "variable":
      return 1;
    case "constant":
      return 2;
    case "function":
      return 3;
    case "struct":
      return 4;
    case "enum":
    case "typeAlias":
      return 5;
    case "enumMember":
      return 6;
    case "namespace":
      return 7;
    case "field":
      return 8;
    default:
      return 10;
  }
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
