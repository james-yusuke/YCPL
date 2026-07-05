import {
  Location,
  type Position,
  type Range,
  SymbolInformation
} from "vscode-languageserver/node.js";
import {
  rangeContains,
  type DefinitionResult,
  type SymbolReference,
  type YcplDocument,
  type YcplSymbol
} from "./model.js";

/** Maintains the incremental symbol and reference index for open and scanned files. */
export class WorkspaceIndex {
  private documents = new Map<string, YcplDocument>();
  private symbolsByName = new Map<string, YcplSymbol[]>();
  private referencesByName = new Map<string, SymbolReference[]>();

  /** Adds or replaces a document in the workspace index. */
  update(document: YcplDocument): void {
    this.remove(document.uri);
    this.documents.set(document.uri, document);
    for (const symbol of document.symbols) {
      const bucket = this.symbolsByName.get(symbol.name) ?? [];
      bucket.push(symbol);
      this.symbolsByName.set(symbol.name, bucket);
    }
    for (const reference of document.references) {
      const bucket = this.referencesByName.get(reference.name) ?? [];
      bucket.push(reference);
      this.referencesByName.set(reference.name, bucket);
    }
  }

  /** Removes one document from the index. */
  remove(uri: string): void {
    const document = this.documents.get(uri);
    if (!document) {
      return;
    }
    this.documents.delete(uri);
    for (const symbol of document.symbols) {
      this.symbolsByName.set(symbol.name, (this.symbolsByName.get(symbol.name) ?? []).filter((entry) => entry.uri !== uri));
    }
    for (const reference of document.references) {
      this.referencesByName.set(reference.name, (this.referencesByName.get(reference.name) ?? []).filter((entry) => entry.uri !== uri));
    }
  }

  /** Returns the parsed document for a URI. */
  getDocument(uri: string): YcplDocument | undefined {
    return this.documents.get(uri);
  }

  /** Iterates all indexed documents. */
  allDocuments(): YcplDocument[] {
    return [...this.documents.values()];
  }

  /** Finds the most specific symbol under a position. */
  symbolAt(uri: string, position: Position): YcplSymbol | undefined {
    const document = this.documents.get(uri);
    if (!document) {
      return undefined;
    }
    return document.symbols
      .filter((symbol) => rangeContains(symbol.selectionRange, position) || rangeContains(symbol.range, position))
      .sort((left, right) => rangeSize(left.selectionRange) - rangeSize(right.selectionRange))[0];
  }

  /** Finds a definition by name, preferring the current document. */
  findDefinition(name: string, currentUri?: string): DefinitionResult | undefined {
    const symbols = this.symbolsByName.get(name) ?? [];
    const symbol = symbols.find((entry) => entry.uri === currentUri) ?? symbols[0];
    if (!symbol) {
      return undefined;
    }
    return {
      symbol,
      location: Location.create(symbol.uri, symbol.selectionRange)
    };
  }

  /** Finds all references for a symbol name, including its declaration. */
  findReferences(name: string, includeDeclaration: boolean): Location[] {
    const refs = (this.referencesByName.get(name) ?? []).map((reference) => Location.create(reference.uri, reference.range));
    if (!includeDeclaration) {
      return refs;
    }
    const decls = (this.symbolsByName.get(name) ?? []).map((symbol) => Location.create(symbol.uri, symbol.selectionRange));
    return [...decls, ...refs];
  }

  /** Returns all symbols matching a workspace-symbol query. */
  workspaceSymbols(query: string): SymbolInformation[] {
    const lower = query.trim().toLowerCase();
    return [...this.symbolsByName.values()]
      .flat()
      .filter((symbol) => lower.length === 0 || symbol.name.toLowerCase().includes(lower))
      .map((symbol) => SymbolInformation.create(symbol.name, symbol.kind, symbol.selectionRange, symbol.uri, symbol.containerName));
  }

  /** Returns all symbols with a given name. */
  symbolsNamed(name: string): YcplSymbol[] {
    return this.symbolsByName.get(name) ?? [];
  }
}

function rangeSize(range: Range): number {
  return (range.end.line - range.start.line) * 10000 + (range.end.character - range.start.character);
}
