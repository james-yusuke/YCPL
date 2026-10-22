import { Location, type Position, type Range, SymbolInformation } from "vscode-languageserver/node";
import {
  rangeContains,
  isTypeCategory,
  type SymbolReference,
  type SymbolId,
  type YcplDocument,
  type YcplSymbol
} from "./model.js";
import * as path from "node:path";
import { URI } from "vscode-uri";
import { offsetAt } from "./text.js";

/** Maintains the incremental symbol and reference index for open and scanned files. */
export class WorkspaceIndex {
  private documents = new Map<string, YcplDocument>();
  private symbolsById = new Map<SymbolId, YcplSymbol>();
  private referencesBySymbolId = new Map<SymbolId, Map<string, SymbolReference[]>>();
  private crossReferences: Map<SymbolId, SymbolReference[]> | undefined;
  private names = new Map<string, YcplSymbol[]>();

  /** Adds or replaces a document in the workspace index. */
  update(document: YcplDocument): void {
    this.crossReferences = undefined;
    this.remove(document.uri);
    this.documents.set(document.uri, document);
    for (const symbol of document.symbols) {
      this.symbolsById.set(symbol.id, symbol);
      if (symbol.scopeId === document.scopes.find((scope) => !scope.parentId)?.id) {
        const bucket = this.names.get(symbol.name) ?? [];
        bucket.push(symbol);
        this.names.set(symbol.name, bucket);
      }
    }
    const references = new Map<SymbolId, SymbolReference[]>();
    for (const reference of document.references) {
      if (!reference.symbolId) continue;
      const entries = references.get(reference.symbolId) ?? [];
      entries.push(reference);
      references.set(reference.symbolId, entries);
    }
    for (const [id, entries] of references) {
      const byDocument = this.referencesBySymbolId.get(id) ?? new Map<string, SymbolReference[]>();
      byDocument.set(document.uri, entries);
      this.referencesBySymbolId.set(id, byDocument);
    }
  }

  /** Removes each document's reference bucket once, preserving other files. */
  remove(uri: string): void {
    const document = this.documents.get(uri);
    if (!document) return;
    this.documents.delete(uri);
    this.crossReferences = undefined;
    for (const symbol of document.symbols) {
      this.symbolsById.delete(symbol.id);
      const bucket = this.names.get(symbol.name)?.filter((item) => item.uri !== uri) ?? [];
      if (bucket.length) this.names.set(symbol.name, bucket);
      else this.names.delete(symbol.name);
    }
    const ids = new Set(
      document.references.flatMap((reference) => (reference.symbolId ? [reference.symbolId] : []))
    );
    for (const id of ids) {
      const byDocument = this.referencesBySymbolId.get(id);
      byDocument?.delete(uri);
      if (byDocument?.size === 0) this.referencesBySymbolId.delete(id);
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
      .filter(
        (symbol) => rangeContains(symbol.selectionRange, position) || rangeContains(symbol.range, position)
      )
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
    const reference = document.references.find((reference) => rangeContains(reference.range, position));
    return reference
      ? {
          ...reference,
          symbolId: reference.symbolId ?? this.resolveExternal(document, reference)?.id
        }
      : undefined;
  }

  /** Resolve an imported or same-module symbol without merging unrelated scopes. */
  namedSymbols(name: string): YcplSymbol[] {
    return this.names.get(name) ?? [];
  }

  resolveType(document: YcplDocument, typeName: string): YcplSymbol | undefined {
    const qualified = typeName.replace(/^owned\s+/, "").replace(/^(?:(?:\*|\[\])\s*)+/, "");
    const name = qualified.split(".").at(-1)!;
    const local = this.namedSymbols(name).find(
      (symbol) => symbol.uri === document.uri && isTypeCategory(symbol.category)
    );
    if (local) return local;
    const qualifier = qualified.includes(".") ? qualified.split(".")[0] : null;
    return this.resolveExternal(
      document,
      {
        name,
        uri: document.uri,
        range: {
          start: { line: 0, character: 0 },
          end: { line: 0, character: 0 }
        },
        scopeId: ""
      },
      qualifier,
      true
    );
  }

  private resolveExternal(
    document: YcplDocument,
    reference: SymbolReference,
    qualifierOverride?: string | null,
    typeLookup = false
  ): YcplSymbol | undefined {
    const offset = offsetAt(document.text, document.lineOffsets, reference.range.start);
    const qualifier =
      qualifierOverride === undefined
        ? document.code.slice(Math.max(0, offset - 128), offset).match(/([A-Za-z_]\w*)\s*\.\s*$/)?.[1]
        : qualifierOverride;
    const imports = document.imports.filter((entry) =>
      qualifier ? entry.alias === qualifier : typeLookup || !entry.alias
    );
    const candidates = this.namedSymbols(reference.name).filter((symbol) => {
      if (
        symbol.uri === document.uri ||
        symbol.containerName ||
        ["variable", "parameter", "field", "namespace"].includes(symbol.category)
      )
        return false;
      if (typeLookup && !isTypeCategory(symbol.category)) return false;
      const target = this.documents.get(symbol.uri);
      if (!target) return false;
      if (!qualifier && document.moduleName && document.moduleName === target.moduleName) return true;
      if (!symbol.exported) return false;
      return imports.some((entry) => {
        if (target.moduleName === entry.modulePath.replaceAll("/", ".")) return true;
        const imported = path.resolve(path.dirname(URI.parse(document.uri).fsPath), entry.modulePath);
        const file = URI.parse(symbol.uri).fsPath;
        return file === `${imported}.yc` || file === imported || path.dirname(file) === imported;
      });
    });
    return candidates.length === 1 ? candidates[0] : undefined;
  }

  private externalReferences(): Map<SymbolId, SymbolReference[]> {
    if (this.crossReferences) return this.crossReferences;
    this.crossReferences = new Map();
    for (const document of this.documents.values()) {
      for (const reference of document.references) {
        if (reference.symbolId) continue;
        const target = this.resolveExternal(document, reference);
        if (!target) continue;
        const bucket = this.crossReferences.get(target.id) ?? [];
        bucket.push(reference);
        this.crossReferences.set(target.id, bucket);
      }
    }
    return this.crossReferences;
  }

  /** Returns one symbol by stable ID. */
  symbolById(id: SymbolId | undefined): YcplSymbol | undefined {
    return id ? this.symbolsById.get(id) : undefined;
  }

  /** Finds all references for a resolved symbol ID, optionally including its declaration. */
  findReferencesBySymbolId(symbolId: SymbolId, includeDeclaration: boolean): Location[] {
    const refs = [
      ...[...(this.referencesBySymbolId.get(symbolId)?.values() ?? [])].flat(),
      ...(this.externalReferences().get(symbolId) ?? [])
    ].map((reference) => Location.create(reference.uri, reference.range));
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
      .map((symbol) =>
        SymbolInformation.create(
          symbol.name,
          symbol.kind,
          symbol.selectionRange,
          symbol.uri,
          symbol.containerName
        )
      );
  }
}

function rangeSize(range: Range): number {
  return (range.end.line - range.start.line) * 10000 + (range.end.character - range.start.character);
}
