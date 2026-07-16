import {
  type Position,
  type Range,
  SymbolKind
} from "vscode-languageserver/node";

export const keywords = [
  "module",
  "package",
  "import",
  "pub",
  "extern",
  "intrinsic",
  "fn",
  "struct",
  "enum",
  "type",
  "const",
  "owned",
  "if",
  "else",
  "for",
  "in",
  "switch",
  "case",
  "default",
  "return",
  "break",
  "continue",
  "defer",
  "scope",
  "as",
  "true",
  "false",
  "none"
] as const;

export const primitiveTypes = [
  "i32",
  "i64",
  "bool",
  "char",
  "byte",
  "string",
  "float",
  "double",
  "void",
  "size_t",
  "Type",
  "T",
  "any",
  "Bytes",
  "Vec",
  "Map"
] as const;

export const semanticTokenTypes = [
  "namespace",
  "type",
  "struct",
  "enum",
  "enumMember",
  "parameter",
  "variable",
  "property",
  "function",
  "keyword",
  "modifier",
  "comment",
  "string",
  "number",
  "operator"
] as const;

export const semanticTokenModifiers = [
  "declaration",
  "definition",
  "readonly",
  "static",
  "deprecated",
  "abstract",
  "async",
  "modification",
  "documentation",
  "defaultLibrary"
] as const;

export type SemanticKind = typeof semanticTokenTypes[number];
export type SymbolId = string;
export type ScopeId = string;

export type ScopeKind =
  | "global"
  | "module"
  | "namespace"
  | "function"
  | "struct"
  | "enum"
  | "switch"
  | "case"
  | "default"
  | "scope"
  | "block"
  | "if"
  | "else"
  | "for";

export type SymbolCategory =
  | "function"
  | "variable"
  | "constant"
  | "parameter"
  | "field"
  | "struct"
  | "enum"
  | "enumMember"
  | "typeAlias"
  | "module"
  | "namespace"
  | "package";

export interface YcplDocument {
  uri: string;
  version: number;
  text: string;
  lineOffsets: number[];
  moduleName?: string;
  scopes: YcplScope[];
  imports: ImportInfo[];
  symbols: YcplSymbol[];
  references: SymbolReference[];
  calls: CallInfo[];
  diagnostics: ParsedDiagnostic[];
}

export interface YcplScope {
  id: ScopeId;
  kind: ScopeKind;
  uri: string;
  range: Range;
  startOffset: number;
  endOffset: number;
  parentId?: ScopeId;
  ownerSymbolId?: SymbolId;
  name?: string;
}

export interface ImportInfo {
  modulePath: string;
  alias?: string;
  range: Range;
  aliasRange?: Range;
}

export interface YcplSymbol {
  id: SymbolId;
  name: string;
  category: SymbolCategory;
  kind: SymbolKind;
  uri: string;
  range: Range;
  selectionRange: Range;
  detail?: string;
  typeName?: string;
  documentation?: string;
  exported: boolean;
  scopeId: ScopeId;
  containerName?: string;
  parameters?: ParameterInfo[];
  returnType?: string;
}

export interface ParameterInfo {
  name: string;
  typeName?: string;
  range: Range;
}

export interface SymbolReference {
  name: string;
  uri: string;
  range: Range;
  scopeId: ScopeId;
  symbolId?: SymbolId;
}

export interface CallInfo {
  caller: string;
  callee: string;
  uri: string;
  range: Range;
  callerSymbolId?: SymbolId;
  calleeSymbolId?: SymbolId;
}

export interface ParsedDiagnostic {
  message: string;
  range: Range;
  severity: "error" | "warning";
  source: "ycpl";
}

export interface WordAtPosition {
  word: string;
  range: Range;
  before: string;
  after: string;
}

export function isTypeCategory(category: SymbolCategory): boolean {
  return category === "struct" || category === "enum" || category === "typeAlias";
}

export function categoryToSemanticKind(category: SymbolCategory): SemanticKind {
  switch (category) {
    case "function":
      return "function";
    case "constant":
      return "variable";
    case "parameter":
      return "parameter";
    case "field":
      return "property";
    case "struct":
      return "struct";
    case "enum":
      return "enum";
    case "enumMember":
      return "enumMember";
    case "typeAlias":
      return "type";
    case "module":
    case "namespace":
    case "package":
      return "namespace";
    default:
      return "variable";
  }
}

export function rangeContains(range: Range, position: Position): boolean {
  if (position.line < range.start.line || position.line > range.end.line) {
    return false;
  }
  if (position.line === range.start.line && position.character < range.start.character) {
    return false;
  }
  if (position.line === range.end.line && position.character > range.end.character) {
    return false;
  }
  return true;
}
