import {
  type Location,
  type Position,
  type Range,
  SymbolKind
} from "vscode-languageserver/node.js";

export const keywords = [
  "module",
  "package",
  "import",
  "pub",
  "extern",
  "intrinsic",
  "fn",
  "struct",
  "const",
  "mut",
  "if",
  "else",
  "for",
  "in",
  "return",
  "break",
  "continue",
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
  "any"
] as const;

export const semanticTokenTypes = [
  "namespace",
  "type",
  "struct",
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

export type SymbolCategory =
  | "function"
  | "variable"
  | "constant"
  | "parameter"
  | "field"
  | "struct"
  | "module"
  | "namespace"
  | "package";

export interface YcplDocument {
  uri: string;
  version: number;
  text: string;
  lineOffsets: number[];
  moduleName?: string;
  imports: ImportInfo[];
  symbols: YcplSymbol[];
  references: SymbolReference[];
  calls: CallInfo[];
  diagnostics: ParsedDiagnostic[];
}

export interface ImportInfo {
  modulePath: string;
  alias?: string;
  range: Range;
  aliasRange?: Range;
}

export interface YcplSymbol {
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
}

export interface CallInfo {
  caller: string;
  callee: string;
  uri: string;
  range: Range;
}

export interface ParsedDiagnostic {
  message: string;
  range: Range;
  severity: "error" | "warning";
  source: "ycpl";
}

export interface DefinitionResult {
  symbol: YcplSymbol;
  location: Location;
}

export interface WordAtPosition {
  word: string;
  range: Range;
  before: string;
  after: string;
}

export function isTypeCategory(category: SymbolCategory): boolean {
  return category === "struct";
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
