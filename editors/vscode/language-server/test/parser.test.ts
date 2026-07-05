import test from "node:test";
import assert from "node:assert/strict";
import { Position } from "vscode-languageserver/node.js";
import { YcplParser } from "../src/analysis/parser.js";
import { WorkspaceIndex } from "../src/analysis/workspaceIndex.js";

const parser = new YcplParser();

test("parser indexes declarations, imports, and references", () => {
  const document = parser.parse("file:///sample.yc", 1, [
    "import \"std/fmt\" as fmt",
    "struct Point {",
    "    x i32",
    "}",
    "fn print_point(p Point) void {",
    "    fmt.println(\"point\")",
    "}"
  ].join("\n"));

  assert.equal(document.imports[0].modulePath, "std/fmt");
  assert.equal(document.imports[0].alias, "fmt");
  assert.ok(document.symbols.some((symbol) => symbol.name === "Point" && symbol.category === "struct"));
  assert.ok(document.symbols.some((symbol) => symbol.name === "print_point" && symbol.category === "function"));
  assert.ok(document.references.some((reference) => reference.name === "fmt"));
});

test("workspace index resolves local definitions and references", () => {
  const document = parser.parse("file:///sample.yc", 1, "fn main() i32 {\n    value i32\n    return value\n}");
  const index = new WorkspaceIndex();
  index.update(document);

  const definition = index.findDefinition("main", document.uri);
  assert.equal(definition?.symbol.name, "main");
  assert.ok(index.findReferences("value", true).length >= 1);
  assert.equal(index.symbolAt(document.uri, Position.create(0, 3))?.name, "main");
});
