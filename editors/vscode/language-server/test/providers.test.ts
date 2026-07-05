import test from "node:test";
import assert from "node:assert/strict";
import { Position, Range } from "vscode-languageserver/node.js";
import { YcplParser } from "../src/analysis/parser.js";
import { StandardLibraryIndex } from "../src/analysis/stdlib.js";
import { WorkspaceIndex } from "../src/analysis/workspaceIndex.js";
import { NullCompilerBridge } from "../src/compiler/compilerBridge.js";
import { YcplProviders } from "../src/lsp/providers.js";

function fixture() {
  const parser = new YcplParser();
  const index = new WorkspaceIndex();
  const document = parser.parse("file:///sample.yc", 1, [
    "import \"std/fmt\" as fmt",
    "fn greet(name string) void {",
    "    fmt.println(name)",
    "}"
  ].join("\n"));
  index.update(document);
  return { document, providers: new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge()) };
}

test("completion returns keywords and indexed symbols", async () => {
  const { document, providers } = fixture();
  const items = await providers.completion({ textDocument: { uri: document.uri }, position: Position.create(1, 2) });
  assert.ok(items.some((item) => item.label === "fn"));
  assert.ok(items.some((item) => item.label === "greet"));
  assert.equal(items.some((item) => item.label === "match"), false);
});

test("stdlib member completion adds missing import edits", async () => {
  const parser = new YcplParser();
  const index = new WorkspaceIndex();
  const document = parser.parse("file:///auto-import.yc", 1, "fn main() i32 {\n    fmt.\n    return 0\n}");
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());

  const items = await providers.completion({ textDocument: { uri: document.uri }, position: Position.create(1, 8) });
  const println = items.find((item) => item.label === "println");
  assert.ok(println);
  assert.equal(println.additionalTextEdits?.[0].newText, "import \"std/fmt\" as fmt\n");
});

test("hover, definition, rename, symbols, and semantic tokens work", () => {
  const { document, providers } = fixture();
  const hover = providers.hover({ textDocument: { uri: document.uri }, position: Position.create(1, 4) });
  const contents = hover?.contents;
  assert.match(String(typeof contents === "object" && !Array.isArray(contents) && "value" in contents ? contents.value : ""), /greet/);
  assert.equal(providers.definition({ textDocument: { uri: document.uri }, position: Position.create(1, 4) })[0].uri, document.uri);
  assert.ok(providers.rename({ textDocument: { uri: document.uri }, position: Position.create(1, 4), newName: "hello" })?.changes?.[document.uri]?.length);
  assert.ok(providers.documentSymbols({ textDocument: { uri: document.uri } }).some((symbol) => symbol.name === "greet"));
  assert.ok(providers.semanticTokens({ textDocument: { uri: document.uri } }).data.length > 0);
});

test("definition distinguishes same-named struct fields and functions", () => {
  const parser = new YcplParser();
  const index = new WorkspaceIndex();
  const document = parser.parse("file:///diagnostic.yc", 1, [
    "pub struct Diagnostic {",
    "    ok bool",
    "    message string",
    "}",
    "",
    "pub fn ok(path string) Diagnostic {",
    "    return Diagnostic{ok: true, message: \"\"}",
    "}"
  ].join("\n"));
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());

  const functionDefinition = providers.definition({ textDocument: { uri: document.uri }, position: Position.create(5, 8) })[0];
  assert.deepEqual(functionDefinition.range.start, Position.create(5, 7));

  const fieldDefinition = providers.definition({ textDocument: { uri: document.uri }, position: Position.create(6, 23) })[0];
  assert.deepEqual(fieldDefinition.range.start, Position.create(1, 4));
});

test("formatting, folding, highlights, inlay hints, codelens, and call hierarchy work", async () => {
  const { document, providers } = fixture();
  assert.ok((await providers.formatDocument({ textDocument: { uri: document.uri }, options: { tabSize: 4, insertSpaces: true } })).length > 0);
  assert.ok(providers.foldingRanges({ textDocument: { uri: document.uri } }).length > 0);
  assert.ok(providers.documentHighlight({ textDocument: { uri: document.uri }, position: Position.create(1, 9) }).length > 0);
  assert.ok(providers.inlayHints({ textDocument: { uri: document.uri }, range: Range.create(0, 0, 3, 1) }));
  assert.ok(providers.codeLens({ textDocument: { uri: document.uri } }).length > 0);
  assert.ok(providers.prepareCallHierarchy({ textDocument: { uri: document.uri }, position: Position.create(1, 4) }).length > 0);
});
