import {
  CallHierarchyIncomingCall,
  CallHierarchyItem,
  CallHierarchyOutgoingCall,
  CodeAction,
  CodeActionKind,
  CodeLens,
  CompletionItem,
  CompletionItemKind,
  Diagnostic,
  DiagnosticSeverity,
  DocumentHighlight,
  DocumentHighlightKind,
  DocumentSymbol,
  FoldingRange,
  FoldingRangeKind,
  Hover,
  InlayHint,
  InlayHintKind,
  InsertTextFormat,
  Location,
  MarkupKind,
  Position,
  Range,
  SemanticTokens,
  SemanticTokensBuilder,
  SignatureHelp,
  SignatureInformation,
  SymbolKind,
  TextEdit,
  WorkspaceEdit,
  type CodeActionParams,
  type CodeLensParams,
  type CompletionParams,
  type DefinitionParams,
  type DocumentFormattingParams,
  type DocumentHighlightParams,
  type DocumentRangeFormattingParams,
  type DocumentSymbolParams,
  type FoldingRangeParams,
  type HoverParams,
  type ImplementationParams,
  type InlayHintParams,
  type PrepareRenameParams,
  type ReferenceParams,
  type RenameParams,
  type SelectionRangeParams,
  type SemanticTokensParams,
  type SignatureHelpParams,
  type WorkspaceSymbolParams
} from "vscode-languageserver/node.js";
import type { TextDocument } from "vscode-languageserver-textdocument";
import {
  categoryToSemanticKind,
  isTypeCategory,
  keywords,
  primitiveTypes,
  rangeContains,
  semanticTokenModifiers,
  semanticTokenTypes,
  type ParsedDiagnostic,
  type SemanticKind,
  type YcplDocument,
  type YcplSymbol
} from "../analysis/model.js";
import { StandardLibraryIndex } from "../analysis/stdlib.js";
import { lineText, offsetAt, rangeFromOffsets, wordAtPosition } from "../analysis/text.js";
import type { WorkspaceIndex } from "../analysis/workspaceIndex.js";
import type { CompilerBridge } from "../compiler/compilerBridge.js";

const tokenTypeMap = new Map(semanticTokenTypes.map((name, index) => [name, index]));
const tokenModifierMap = new Map(semanticTokenModifiers.map((name, index) => [name, 1 << index]));

/** Implements all YCPL LSP providers over the workspace index. */
export class YcplProviders {
  constructor(
    private readonly index: WorkspaceIndex,
    private readonly stdlib: StandardLibraryIndex,
    private readonly compiler: CompilerBridge
  ) {}

  /** Builds diagnostics from the editor parser and the compiler bridge. */
  async diagnostics(document: YcplDocument): Promise<Diagnostic[]> {
    const parsed = document.diagnostics.map(toDiagnostic);
    const compilerDiagnostics = await this.compiler.diagnostics(document);
    return [...parsed, ...compilerDiagnostics];
  }

  /** Provides context-aware completions for YCPL documents. */
  async completion(params: CompletionParams): Promise<CompletionItem[]> {
    const document = this.requireDocument(params.textDocument.uri);
    const line = lineText(document.text, document.lineOffsets, params.position.line).slice(0, params.position.character);
    if (/\bimport\s+"[^"]*$/.test(line)) {
      return (await this.stdlib.completionItems())
        .filter((item) => item.kind === CompletionItemKind.Module)
        .map((item) => ({ label: item.modulePath, kind: item.kind, detail: item.detail }));
    }
    if (line.trimEnd().endsWith(".")) {
      const alias = line.trimEnd().match(/([A-Za-z_][A-Za-z0-9_]*)\.$/)?.[1];
      return this.memberCompletions(document, alias, await this.stdlib.completionItems());
    }

    const localItems = document.symbols.map(symbolToCompletion);
    const workspaceItems = this.index.workspaceSymbols("").map((symbol) => ({
      label: symbol.name,
      kind: CompletionItemKind.Reference,
      detail: symbol.containerName
    }));
    const stdItems = (await this.stdlib.completionItems()).map((item) => ({
      label: item.label,
      kind: item.kind,
      detail: item.detail
    }));
    return [
      ...keywords.map((label) => ({ label, kind: CompletionItemKind.Keyword })),
      ...primitiveTypes.map((label) => ({ label, kind: CompletionItemKind.TypeParameter })),
      {
        label: "main",
        kind: CompletionItemKind.Snippet,
        insertTextFormat: InsertTextFormat.Snippet,
        insertText: "fn main() i32 {\n    $1\n    return 0\n}",
        detail: "YCPL main function"
      },
      ...localItems,
      ...workspaceItems,
      ...stdItems
    ];
  }

  /** Provides markdown hover contents for the symbol under the cursor. */
  hover(params: HoverParams): Hover | undefined {
    const document = this.requireDocument(params.textDocument.uri);
    const word = wordAtPosition(document.text, document.lineOffsets, params.position);
    if (!word) {
      return undefined;
    }
    const symbol = this.index.findDefinition(word.word, document.uri)?.symbol;
    if (!symbol) {
      return {
        contents: { kind: MarkupKind.Markdown, value: `\`${word.word}\`` },
        range: word.range
      };
    }
    const signature = symbol.detail ? `\`\`\`ycpl\n${symbol.detail}\n\`\`\`` : `\`${symbol.name}\``;
    const doc = symbol.documentation ? `\n\n${symbol.documentation}` : "";
    const type = symbol.typeName ? `\n\nType: \`${symbol.typeName}\`` : "";
    return {
      contents: { kind: MarkupKind.Markdown, value: `${signature}${type}${doc}` },
      range: word.range
    };
  }

  /** Provides definition locations. */
  definition(params: DefinitionParams): Location[] {
    const word = this.wordFor(params.textDocument.uri, params.position);
    if (!word) {
      return [];
    }
    const result = this.index.findDefinition(word.word, params.textDocument.uri);
    return result ? [result.location] : [];
  }

  /** Provides implementation locations. */
  implementation(params: ImplementationParams): Location[] {
    return this.definition(params);
  }

  /** Provides references for the symbol under the cursor. */
  references(params: ReferenceParams): Location[] {
    const word = this.wordFor(params.textDocument.uri, params.position);
    if (!word) {
      return [];
    }
    return this.index.findReferences(word.word, params.context.includeDeclaration);
  }

  /** Provides safe workspace edits for symbol renames. */
  rename(params: RenameParams): WorkspaceEdit | undefined {
    const word = this.wordFor(params.textDocument.uri, params.position);
    if (!word) {
      return undefined;
    }
    const changes: Record<string, TextEdit[]> = {};
    for (const location of this.index.findReferences(word.word, true)) {
      changes[location.uri] = changes[location.uri] ?? [];
      changes[location.uri].push(TextEdit.replace(location.range, params.newName));
    }
    return { changes };
  }

  /** Validates a rename request and returns the target range. */
  prepareRename(params: PrepareRenameParams): Range | undefined {
    return this.wordFor(params.textDocument.uri, params.position)?.range;
  }

  /** Provides outline symbols for one document. */
  documentSymbols(params: DocumentSymbolParams): DocumentSymbol[] {
    const document = this.requireDocument(params.textDocument.uri);
    return document.symbols
      .filter((symbol) => symbol.category !== "parameter")
      .map((symbol) => DocumentSymbol.create(symbol.name, symbol.detail ?? symbol.category, symbol.kind, symbol.range, symbol.selectionRange));
  }

  /** Provides global workspace symbols. */
  workspaceSymbols(params: WorkspaceSymbolParams) {
    return this.index.workspaceSymbols(params.query);
  }

  /** Provides signature help for function calls. */
  signatureHelp(params: SignatureHelpParams): SignatureHelp | undefined {
    const document = this.requireDocument(params.textDocument.uri);
    const offset = offsetAt(document.text, document.lineOffsets, params.position);
    const prefix = document.text.slice(Math.max(0, offset - 160), offset);
    const match = prefix.match(/([A-Za-z_][A-Za-z0-9_]*)(?:\s*\.\s*([A-Za-z_][A-Za-z0-9_]*))?\s*\(([^()]*)$/);
    if (!match) {
      return undefined;
    }
    const name = match[2] ?? match[1];
    const symbol = this.index.findDefinition(name, document.uri)?.symbol;
    if (!symbol?.parameters) {
      return undefined;
    }
    const signature = SignatureInformation.create(symbol.detail ?? `${symbol.name}()`);
    signature.parameters = symbol.parameters.map((param) => ({ label: param.typeName ? `${param.name} ${param.typeName}` : param.name }));
    return {
      signatures: [signature],
      activeSignature: 0,
      activeParameter: Math.max(0, match[3].split(",").length - 1)
    };
  }

  /** Provides semantic token data. */
  semanticTokens(params: SemanticTokensParams): SemanticTokens {
    const document = this.requireDocument(params.textDocument.uri);
    const builder = new SemanticTokensBuilder();
    const pushed = new Set<string>();

    for (const symbol of document.symbols) {
      this.pushToken(builder, symbol.selectionRange, categoryToSemanticKind(symbol.category), symbol.exported ? ["declaration"] : []);
      pushed.add(rangeKey(symbol.selectionRange));
    }

    const pattern = /\b(module|package|import|pub|extern|intrinsic|fn|struct|const|mut|if|else|for|in|return|break|continue|as|true|false|none|i32|i64|bool|char|byte|string|float|double|void|size_t|Type|T|any)\b|\/\/.*$|\/\*[\s\S]*?\*\/|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])'|`[^`]*`|0x[0-9A-Fa-f]+|0b[01]+|[0-9]+(?:\.[0-9]+)?|(:=|==|!=|<=|>=|&&|\|\||[=+\-*/%<>!&|.])/gm;
    for (const match of document.text.matchAll(pattern)) {
      const start = match.index ?? 0;
      const value = match[0];
      const range = rangeFromOffsets(document.lineOffsets, start, start + value.length);
      if (pushed.has(rangeKey(range))) {
        continue;
      }
      if (keywords.includes(value as never)) {
        this.pushToken(builder, range, "keyword");
      } else if (primitiveTypes.includes(value as never)) {
        this.pushToken(builder, range, "type");
      } else if (value.startsWith("//") || value.startsWith("/*")) {
        this.pushToken(builder, range, "comment");
      } else if (value.startsWith("\"") || value.startsWith("'") || value.startsWith("`")) {
        this.pushToken(builder, range, "string");
      } else if (/^[0-9]/.test(value)) {
        this.pushToken(builder, range, "number");
      } else {
        this.pushToken(builder, range, "operator");
      }
    }
    return builder.build();
  }

  /** Formats a full document. */
  async formatDocument(params: DocumentFormattingParams): Promise<TextEdit[]> {
    const document = this.requireDocument(params.textDocument.uri);
    return (await this.compiler.format(document)) ?? [TextEdit.replace(fullRange(document), formatText(document.text))];
  }

  /** Formats a selected range. */
  async formatRange(params: DocumentRangeFormattingParams): Promise<TextEdit[]> {
    const document = this.requireDocument(params.textDocument.uri);
    const compilerEdits = await this.compiler.format(document, params.range);
    if (compilerEdits) {
      return compilerEdits;
    }
    const start = offsetAt(document.text, document.lineOffsets, params.range.start);
    const end = offsetAt(document.text, document.lineOffsets, params.range.end);
    return [TextEdit.replace(params.range, formatText(document.text.slice(start, end)))];
  }

  /** Provides folding ranges from balanced braces and region comments. */
  foldingRanges(params: FoldingRangeParams): FoldingRange[] {
    const document = this.requireDocument(params.textDocument.uri);
    const ranges: FoldingRange[] = [];
    const stack: Position[] = [];
    for (let i = 0; i < document.text.length; i += 1) {
      if (document.text[i] === "{") {
        stack.push(document.lineOffsets ? positionAtIndex(document, i) : Position.create(0, 0));
      } else if (document.text[i] === "}") {
        const start = stack.pop();
        const end = positionAtIndex(document, i);
        if (start && end.line > start.line) {
          ranges.push(FoldingRange.create(start.line, end.line, start.character, end.character, FoldingRangeKind.Region));
        }
      }
    }
    return ranges;
  }

  /** Provides smart selection ranges. */
  selectionRanges(params: SelectionRangeParams) {
    const document = this.requireDocument(params.textDocument.uri);
    return params.positions.map((position) => {
      const word = wordAtPosition(document.text, document.lineOffsets, position);
      const lineRange = Range.create(Position.create(position.line, 0), Position.create(position.line, lineText(document.text, document.lineOffsets, position.line).length));
      return {
        range: word?.range ?? lineRange,
        parent: { range: lineRange, parent: { range: fullRange(document) } }
      };
    });
  }

  /** Highlights all occurrences of the current symbol in the document. */
  documentHighlight(params: DocumentHighlightParams): DocumentHighlight[] {
    const word = this.wordFor(params.textDocument.uri, params.position);
    if (!word) {
      return [];
    }
    return this.index.findReferences(word.word, true)
      .filter((location) => location.uri === params.textDocument.uri)
      .map((location) => DocumentHighlight.create(location.range, DocumentHighlightKind.Text));
  }

  /** Provides inferred type and parameter-name inlay hints. */
  inlayHints(params: InlayHintParams): InlayHint[] {
    const document = this.requireDocument(params.textDocument.uri);
    return document.symbols
      .filter((symbol) => rangeContains(params.range, symbol.selectionRange.start) && symbol.category === "variable" && !symbol.typeName)
      .map((symbol) => InlayHint.create(symbol.selectionRange.end, ": inferred", InlayHintKind.Type));
  }

  /** Provides quick fixes for simple diagnostics. */
  codeActions(params: CodeActionParams): CodeAction[] {
    const actions: CodeAction[] = [];
    for (const diagnostic of params.context.diagnostics) {
      if (diagnostic.message.includes("not used")) {
        actions.push(CodeAction.create("Remove unused import", {
          changes: {
            [params.textDocument.uri]: [TextEdit.del(lineRangeContaining(diagnostic.range))]
          }
        }, CodeActionKind.QuickFix));
      }
    }
    return actions;
  }

  /** Provides reference-count codelenses for declarations. */
  codeLens(params: CodeLensParams): CodeLens[] {
    const document = this.requireDocument(params.textDocument.uri);
    return document.symbols
      .filter((symbol) => symbol.category === "function" || isTypeCategory(symbol.category))
      .map((symbol) => CodeLens.create(symbol.selectionRange, {
        title: `${Math.max(0, this.index.findReferences(symbol.name, false).length)} references`,
        command: ""
      }));
  }

  /** Prepares call hierarchy items. */
  prepareCallHierarchy(params: DefinitionParams): CallHierarchyItem[] {
    const symbol = this.index.symbolAt(params.textDocument.uri, params.position);
    if (!symbol || symbol.category !== "function") {
      return [];
    }
    return [toCallHierarchyItem(symbol)];
  }

  /** Returns incoming calls for a function. */
  incomingCalls(item: CallHierarchyItem): CallHierarchyIncomingCall[] {
    const incoming = new Map<string, CallHierarchyIncomingCall>();
    for (const document of this.index.allDocuments()) {
      for (const call of document.calls.filter((entry) => entry.callee === item.name)) {
        const caller = this.index.findDefinition(call.caller, document.uri)?.symbol;
        if (!caller) {
          continue;
        }
        const key = `${caller.uri}:${caller.name}`;
        const existing = incoming.get(key);
        if (existing) {
          existing.fromRanges.push(call.range);
        } else {
          incoming.set(key, { from: toCallHierarchyItem(caller), fromRanges: [call.range] });
        }
      }
    }
    return [...incoming.values()];
  }

  /** Returns outgoing calls for a function. */
  outgoingCalls(item: CallHierarchyItem): CallHierarchyOutgoingCall[] {
    const document = this.index.getDocument(item.uri);
    if (!document) {
      return [];
    }
    const outgoing = new Map<string, CallHierarchyOutgoingCall>();
    for (const call of document.calls.filter((entry) => entry.caller === item.name)) {
      const callee = this.index.findDefinition(call.callee, document.uri)?.symbol;
      if (!callee) {
        continue;
      }
      const key = `${callee.uri}:${callee.name}`;
      const existing = outgoing.get(key);
      if (existing) {
        existing.fromRanges.push(call.range);
      } else {
        outgoing.set(key, { to: toCallHierarchyItem(callee), fromRanges: [call.range] });
      }
    }
    return [...outgoing.values()];
  }

  private memberCompletions(document: YcplDocument, alias: string | undefined, stdlibItems: Awaited<ReturnType<StandardLibraryIndex["completionItems"]>>): CompletionItem[] {
    if (!alias) {
      return [];
    }
    const imported = document.imports.find((entry) => entry.alias === alias);
    const modulePath = imported?.modulePath ?? stdlibItems.find((item) => item.moduleAlias === alias)?.modulePath;
    if (!modulePath) {
      return [];
    }

    const importEdit = imported ? undefined : importEditFor(document, modulePath, alias);
    const stdlibMembers = stdlibItems
      .filter((item) => item.moduleAlias === alias && item.symbolName)
      .map((item) => ({
        label: item.symbolName ?? item.label,
        kind: item.kind,
        detail: item.detail,
        additionalTextEdits: importEdit ? [importEdit] : undefined
      }));
    const workspaceMembers = this.index.workspaceSymbols("")
      .filter((symbol) => symbol.containerName === modulePath)
      .map((symbol) => ({
        label: symbol.name,
        kind: CompletionItemKind.Reference,
        detail: symbol.containerName,
        additionalTextEdits: importEdit ? [importEdit] : undefined
      }));

    return [...stdlibMembers, ...workspaceMembers];
  }

  private wordFor(uri: string, position: Position) {
    const document = this.requireDocument(uri);
    return wordAtPosition(document.text, document.lineOffsets, position);
  }

  private requireDocument(uri: string): YcplDocument {
    const document = this.index.getDocument(uri);
    if (!document) {
      throw new Error(`YCPL document is not indexed: ${uri}`);
    }
    return document;
  }

  private pushToken(builder: SemanticTokensBuilder, range: Range, tokenType: SemanticKind, modifiers: Array<typeof semanticTokenModifiers[number]> = []): void {
    const type = tokenTypeMap.get(tokenType);
    if (type === undefined || range.start.line !== range.end.line) {
      return;
    }
    const modifierBits = modifiers.reduce((bits, modifier) => bits | (tokenModifierMap.get(modifier) ?? 0), 0);
    builder.push(range.start.line, range.start.character, range.end.character - range.start.character, type, modifierBits);
  }
}

function toDiagnostic(diagnostic: ParsedDiagnostic): Diagnostic {
  return Diagnostic.create(
    diagnostic.range,
    diagnostic.message,
    diagnostic.severity === "error" ? DiagnosticSeverity.Error : DiagnosticSeverity.Warning,
    undefined,
    diagnostic.source
  );
}

function symbolToCompletion(symbol: YcplSymbol): CompletionItem {
  return {
    label: symbol.name,
    kind: completionKindForSymbol(symbol),
    detail: symbol.detail
  };
}

function completionKindForSymbol(symbol: YcplSymbol): CompletionItemKind {
  switch (symbol.category) {
    case "function":
      return CompletionItemKind.Function;
    case "struct":
    case "constant":
      return CompletionItemKind.Constant;
    case "module":
    case "namespace":
    case "package":
      return CompletionItemKind.Module;
    default:
      return CompletionItemKind.Variable;
  }
}

function fullRange(document: YcplDocument): Range {
  const lines = document.lineOffsets.length;
  const lastLine = Math.max(0, lines - 1);
  return Range.create(Position.create(0, 0), Position.create(lastLine, lineText(document.text, document.lineOffsets, lastLine).length));
}

function formatText(text: string): string {
  let depth = 0;
  const lines = text.split(/\r?\n/);
  return lines.map((line) => {
    const trimmed = line.trim();
    if (trimmed.startsWith("}")) {
      depth = Math.max(0, depth - 1);
    }
    const formatted = trimmed.length === 0 ? "" : `${"    ".repeat(depth)}${trimmed}`;
    if (trimmed.endsWith("{")) {
      depth += 1;
    }
    return formatted;
  }).join("\n");
}

function positionAtIndex(document: YcplDocument, offset: number): Position {
  let line = 0;
  while (line + 1 < document.lineOffsets.length && document.lineOffsets[line + 1] <= offset) {
    line += 1;
  }
  return Position.create(line, offset - document.lineOffsets[line]);
}

function rangeKey(range: Range): string {
  return `${range.start.line}:${range.start.character}:${range.end.line}:${range.end.character}`;
}

function lineRangeContaining(range: Range): Range {
  return Range.create(Position.create(range.start.line, 0), Position.create(range.end.line + 1, 0));
}

function importEditFor(document: YcplDocument, modulePath: string, alias: string): TextEdit | undefined {
  if (document.imports.some((entry) => entry.modulePath === modulePath || entry.alias === alias)) {
    return undefined;
  }
  const insertion = importInsertionPosition(document);
  return TextEdit.insert(insertion, `import "${modulePath}" as ${alias}\n`);
}

function importInsertionPosition(document: YcplDocument): Position {
  if (document.imports.length > 0) {
    const lastImport = document.imports[document.imports.length - 1];
    return Position.create(lastImport.range.end.line + 1, 0);
  }
  const firstLine = lineText(document.text, document.lineOffsets, 0);
  if (/^\s*(module|package)\b/.test(firstLine)) {
    return Position.create(1, 0);
  }
  return Position.create(0, 0);
}

function toCallHierarchyItem(symbol: YcplSymbol): CallHierarchyItem {
  return {
    name: symbol.name,
    kind: SymbolKind.Function,
    detail: symbol.detail ?? "",
    uri: symbol.uri,
    range: symbol.range,
    selectionRange: symbol.selectionRange
  };
}
