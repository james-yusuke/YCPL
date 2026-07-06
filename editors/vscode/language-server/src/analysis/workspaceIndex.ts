import {
  Location,
  type Position,
  type Range,
  SymbolInformation
} from "vscode-languageserver/node.js";
import {
  rangeContains,
  type SymbolReference,
  type SymbolId,
  type YcplDocument,
  type YcplSymbol
} from "./model.js";

/** Maintains the incremental symbol and reference index for open and scanned files. */
export class WorkspaceIndex {
  private documents = new Map<string, YcplDocument>();
  private symbolsById = new Map<SymbolId, YcplSymbol>();
  private referencesBySymbolId = new Map<SymbolId, SymbolReference[]>();

  /** Adds or replaces a document in the workspace index. */
  update(document: YcplDocument): void {
    this.remove(document.uri);
    this.documents.set(document.uri, document);
    for (const symbol of document.symbols) {
      this.symbolsById.set(symbol.id, symbol);
    }
    for (const reference of document.references) {
      if (reference.symbolId) {
        const byId = this.referencesBySymbolId.get(reference.symbolId) ?? [];
        byId.push(reference);
        this.referencesBySymbolId.set(reference.symbolId, byId);
      }
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
      this.symbolsById.delete(symbol.id);
      this.referencesBySymbolId.set(symbol.id, (this.referencesBySymbolId.get(symbol.id) ?? []).filter((entry) => entry.uri !== uri));
    }
    for (const reference of document.references) {
      if (reference.symbolId) {
        this.referencesBySymbolId.set(reference.symbolId, (this.referencesBySymbolId.get(reference.symbolId) ?? []).filter((entry) => entry.uri !== uri));
      }
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

  /** Finds a declaration whose selected identifier contains the position. */
  declarationAt(uri: string, position: Position): YcplSymbol | undefined {
    const document = this.documents.get(uri);
    if (!document) {
      return undefined;
    }
    return document.symbols.find((symbol) => rangeContains(symbol.selectionRange, position));
  }

  /** Finds the resolved reference at a position. */
  referenceAt(uri: string, position: Position): SymbolReference | undefined {
    const document = this.documents.get(uri);
    if (!document) {
      return undefined;
    }
    return document.references.find((reference) => rangeContains(reference.range, position));
  }

  /** Returns one symbol by stable ID. */
  symbolById(id: SymbolId | undefined): YcplSymbol | undefined {
    return id ? this.symbolsById.get(id) : undefined;
  }

  /** Finds all references for a resolved symbol ID, optionally including its declaration. */
  findReferencesBySymbolId(symbolId: SymbolId, includeDeclaration: boolean): Location[] {
    const refs = (this.referencesBySymbolId.get(symbolId) ?? []).map((reference) => Location.create(reference.uri, reference.range));
    if (!includeDeclaration) {
      return refs;
    }
    const symbol = this.symbolsById.get(symbolId);
    return symbol ? [Location.create(symbol.uri, symbol.selectionRange), ...refs] : refs;
  }

  /** Returns all symbols matching a workspace-symbol query. */
  workspaceSymbols(query: string): SymbolInformation[] {
    const lower = query.trim().toLowerCase();
    return [...this.symbolsById.values()]
      .filter((symbol) => lower.length === 0 || symbol.name.toLowerCase().includes(lower))
      .map((symbol) => SymbolInformation.create(symbol.name, symbol.kind, symbol.selectionRange, symbol.uri, symbol.containerName));
  }
}

function rangeSize(range: Range): number {
  return (range.end.line - range.start.line) * 10000 + (range.end.character - range.start.character);
}
