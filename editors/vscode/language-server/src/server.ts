#!/usr/bin/env node
import * as fs from "node:fs/promises";
import { fileURLToPath } from "node:url";
import {
  CallHierarchyIncomingCallsRequest,
  CallHierarchyOutgoingCallsRequest,
  CallHierarchyPrepareRequest,
  createConnection,
  DidChangeConfigurationNotification,
  FileChangeType,
  ProposedFeatures,
  SemanticTokensBuilder,
  TextDocuments,
  TextDocumentSyncKind,
  type InitializeParams,
  type InitializeResult
} from "vscode-languageserver/node";
import { TextDocument } from "vscode-languageserver-textdocument";
import { URI } from "vscode-uri";
import { YcplParser } from "./analysis/parser.js";
import { StandardLibraryIndex } from "./analysis/stdlib.js";
import { WorkspaceScanner } from "./analysis/workspaceScanner.js";
import { WorkspaceIndex } from "./analysis/workspaceIndex.js";
import { semanticTokenModifiers, semanticTokenTypes } from "./analysis/model.js";
import { NullCompilerBridge } from "./compiler/compilerBridge.js";
import { YcplProviders } from "./lsp/providers.js";

const connection = createConnection(ProposedFeatures.all);
const documents = new TextDocuments(TextDocument);
const parser = new YcplParser();
const index = new WorkspaceIndex();
const compiler = new NullCompilerBridge();

let providers: YcplProviders;
let workspaceRoots: string[] = [];

connection.onInitialize((params: InitializeParams): InitializeResult => {
  workspaceRoots = workspaceRootPaths(params);
  const options = params.initializationOptions as { stlRoot?: string } | undefined;
  providers = new YcplProviders(index, new StandardLibraryIndex(workspaceRoots[0], options?.stlRoot), compiler);

  return {
    capabilities: {
      textDocumentSync: {
        openClose: true,
        change: TextDocumentSyncKind.Incremental,
        save: true
      },
      completionProvider: {
        resolveProvider: false,
        triggerCharacters: [".", "\"", "/"]
      },
      hoverProvider: true,
      definitionProvider: true,
      declarationProvider: true,
      typeDefinitionProvider: true,
      referencesProvider: true,
      renameProvider: {
        prepareProvider: true
      },
      documentSymbolProvider: true,
      workspaceSymbolProvider: true,
      signatureHelpProvider: {
        triggerCharacters: ["(", ","]
      },
      semanticTokensProvider: {
        legend: {
          tokenTypes: [...semanticTokenTypes],
          tokenModifiers: [...semanticTokenModifiers]
        },
        full: true
      },
      documentFormattingProvider: true,
      documentRangeFormattingProvider: true,
      foldingRangeProvider: true,
      selectionRangeProvider: true,
      documentHighlightProvider: true,
      inlayHintProvider: true,
      codeActionProvider: true,
      codeLensProvider: {
        resolveProvider: false
      },
      implementationProvider: true,
      callHierarchyProvider: true,
      workspace: {
        workspaceFolders: {
          supported: true,
          changeNotifications: true
        },
        fileOperations: {}
      }
    }
  };
});

connection.onInitialized(() => {
  connection.client.register(DidChangeConfigurationNotification.type).catch(() => undefined);
  void scanWorkspaces();
});

documents.onDidOpen((event) => {
  void indexAndPublish(event.document);
});

documents.onDidChangeContent((event) => {
  void indexAndPublish(event.document);
});

documents.onDidClose((event) => {
  index.remove(event.document.uri);
  connection.sendDiagnostics({ uri: event.document.uri, diagnostics: [] });
});

connection.onDidChangeWatchedFiles((event) => {
  for (const change of event.changes) {
    if (!change.uri.endsWith(".yc")) {
      continue;
    }
    if (change.type === FileChangeType.Deleted) {
      index.remove(change.uri);
      connection.sendDiagnostics({ uri: change.uri, diagnostics: [] });
    } else {
      void indexFile(change.uri);
    }
  }
});

connection.onCompletion((params) => providers.completion(params));
connection.onHover((params) => providers.hover(params));
connection.onDefinition((params) => providers.definition(params));
connection.onDeclaration((params) => providers.definition(params));
connection.onTypeDefinition((params) => providers.definition(params));
connection.onImplementation((params) => providers.implementation(params));
connection.onReferences((params) => providers.references(params));
connection.onPrepareRename((params) => providers.prepareRename(params));
connection.onRenameRequest((params) => providers.rename(params));
connection.onDocumentSymbol((params) => providers.documentSymbols(params));
connection.onWorkspaceSymbol((params) => providers.workspaceSymbols(params));
connection.onSignatureHelp((params) => providers.signatureHelp(params));
connection.languages.semanticTokens.on((params) => providers.semanticTokens(params));
connection.onDocumentFormatting((params) => providers.formatDocument(params));
connection.onDocumentRangeFormatting((params) => providers.formatRange(params));
connection.onFoldingRanges((params) => providers.foldingRanges(params));
connection.onSelectionRanges((params) => providers.selectionRanges(params));
connection.onDocumentHighlight((params) => providers.documentHighlight(params));
connection.languages.inlayHint.on((params) => providers.inlayHints(params));
connection.onCodeAction((params) => providers.codeActions(params));
connection.onCodeLens((params) => providers.codeLens(params));
connection.onRequest(CallHierarchyPrepareRequest.type, (params) => providers.prepareCallHierarchy(params));
connection.onRequest(CallHierarchyIncomingCallsRequest.type, (params) => providers.incomingCalls(params.item));
connection.onRequest(CallHierarchyOutgoingCallsRequest.type, (params) => providers.outgoingCalls(params.item));

documents.listen(connection);
connection.listen();

async function indexAndPublish(document: TextDocument): Promise<void> {
  const parsed = parser.parse(document.uri, document.version, document.getText());
  index.update(parsed);
  const diagnostics = await providers.diagnostics(parsed);
  connection.sendDiagnostics({ uri: document.uri, diagnostics });
}

async function indexFile(uri: string): Promise<void> {
  const openDocument = documents.get(uri);
  if (openDocument) {
    await indexAndPublish(openDocument);
    return;
  }
  try {
    const text = await fs.readFile(fileURLToPath(uri), "utf8");
    index.update(parser.parse(uri, 0, text));
  } catch (error) {
    connection.console.warn(`Failed to index ${uri}: ${String(error)}`);
  }
}

async function scanWorkspaces(): Promise<void> {
  const scanner = new WorkspaceScanner(parser, index);
  for (const root of workspaceRoots) {
    try {
      const count = await scanner.scan(root);
      connection.console.info(`Indexed ${count} YCPL files under ${root}`);
    } catch (error) {
      connection.console.warn(`Workspace scan failed for ${root}: ${String(error)}`);
    }
  }
}

function workspaceRootPaths(params: InitializeParams): string[] {
  const roots = params.workspaceFolders?.map((folder) => URI.parse(folder.uri).fsPath) ?? [];
  if (roots.length > 0) {
    return roots;
  }
  return params.rootUri ? [URI.parse(params.rootUri).fsPath] : [];
}

void SemanticTokensBuilder;
