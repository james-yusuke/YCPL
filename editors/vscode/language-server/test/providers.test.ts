import test from "node:test";
import assert from "node:assert/strict";
import { Position, Range } from "vscode-languageserver/node";
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
  assert.equal(items.some((item) => item.label === "mut"), false);
});

test("stdlib member completion adds missing import edits", async () => {
  const parser = new YcplParser();
  const index = new WorkspaceIndex();
  const document = parser.parse("file:///auto-import.yc", 1, "fn main() i32 {\n    fmt.\n    return 0\n}");
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());

  const items = await providers.completion({ textDocument: { uri: document.uri }, position: Position.create(1, 8) });
  const println = items.find((item) => item.label === "println");
  if (!println) {
    assert.fail("Expected println completion");
  }
  assert.equal(println.additionalTextEdits?.[0].newText, "import \"std/fmt\" as fmt\n");
});

test("stdlib function completion adds missing import edits", async () => {
  const parser = new YcplParser();
  const index = new WorkspaceIndex();
  const document = parser.parse("file:///stdlib-functions.yc", 1, "fn main() i32 {\n    \n    return 0\n}");
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());

  const items = await providers.completion({ textDocument: { uri: document.uri }, position: Position.create(1, 4) });
  const fromString = items.find((item) => item.label === "bytes.from_string");
  if (!fromString) {
    assert.fail("Expected bytes.from_string completion");
  }
  assert.equal(fromString.additionalTextEdits?.[0].newText, "import \"std/bytes\" as bytes\n");
  assert.equal(fromString.insertText, "bytes.from_string($0)");
});

test("stdlib completion supports std modules and UFCS methods", async () => {
  const parser = new YcplParser();
  const index = new WorkspaceIndex();
  const document = parser.parse("file:///std-ufcs.yc", 1, [
    "import \"std/bytes\" as bytes",
    "",
    "fn main() {",
    "    b: owned Bytes := bytes.from_string(\"YCPL\")",
    "    b.",
    "}"
  ].join("\n"));
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());

  const memberItems = await providers.completion({ textDocument: { uri: document.uri }, position: Position.create(4, 6) });
  assert.equal(memberItems.some((item) => item.label === "free"), false);

  const normalItems = await providers.completion({ textDocument: { uri: document.uri }, position: Position.create(2, 4) });
  const base32 = normalItems.find((item) => item.label === "base32.encode");
  if (!base32) {
    assert.fail("Expected std base32.encode completion");
  }
  assert.equal(base32.additionalTextEdits?.[0].newText, "import \"std/base32\" as base32\n");
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

test("definition and rename use resolved symbol ids for shadowed locals", () => {
  const parser = new YcplParser();
  const index = new WorkspaceIndex();
  const document = parser.parse("file:///shadow.yc", 1, [
    "value := 10",
    "fn test() i32 {",
    "    value := 20",
    "    return value",
    "}",
    "fn other() i32 {",
    "    return value",
    "}"
  ].join("\n"));
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());

  const innerDefinition = providers.definition({ textDocument: { uri: document.uri }, position: Position.create(3, 13) })[0];
  assert.deepEqual(innerDefinition.range.start, Position.create(2, 4));

  const outerDefinition = providers.definition({ textDocument: { uri: document.uri }, position: Position.create(6, 13) })[0];
  assert.deepEqual(outerDefinition.range.start, Position.create(0, 0));

  const edit = providers.rename({ textDocument: { uri: document.uri }, position: Position.create(3, 13), newName: "inner" });
  assert.deepEqual(edit?.changes?.[document.uri]?.map((change) => change.range.start), [
    Position.create(2, 4),
    Position.create(3, 11)
  ]);
});

test("rename does not cross files by matching names", () => {
  const parser = new YcplParser();
  const index = new WorkspaceIndex();
  const first = parser.parse("file:///file1.yc", 1, "value := 10\nfn one() i32 {\n    return value\n}");
  const second = parser.parse("file:///file2.yc", 1, "value := 20\nfn two() i32 {\n    return value\n}");
  index.update(first);
  index.update(second);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());

  const edit = providers.rename({ textDocument: { uri: first.uri }, position: Position.create(2, 13), newName: "renamed" });
  assert.ok(edit?.changes?.[first.uri]);
  assert.equal(edit?.changes?.[second.uri], undefined);
});

test("block scopes shadow outer symbols", () => {
  const parser = new YcplParser();
  const index = new WorkspaceIndex();
  const document = parser.parse("file:///blocks.yc", 1, [
    "value := 1",
    "fn test(flag bool) i32 {",
    "    if flag {",
    "        value := 2",
    "        return value",
    "    }",
    "    return value",
    "}"
  ].join("\n"));
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());

  const innerDefinition = providers.definition({ textDocument: { uri: document.uri }, position: Position.create(4, 16) })[0];
  assert.deepEqual(innerDefinition.range.start, Position.create(3, 8));

  const outerDefinition = providers.definition({ textDocument: { uri: document.uri }, position: Position.create(6, 12) })[0];
  assert.deepEqual(outerDefinition.range.start, Position.create(0, 0));
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
