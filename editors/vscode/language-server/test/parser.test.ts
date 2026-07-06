import test from "node:test";
import assert from "node:assert/strict";
import { Position } from "vscode-languageserver/node";
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
  const document = parser.parse("file:///sample.yc", 1, "fn main() i32 {\n    value := 1\n    return value\n}");
  const index = new WorkspaceIndex();
  index.update(document);

  const definition = index.declarationAt(document.uri, Position.create(0, 3));
  assert.equal(definition?.name, "main");
  const reference = index.referenceAt(document.uri, Position.create(2, 13));
  assert.equal(index.symbolById(reference?.symbolId)?.name, "value");
  assert.ok(reference?.symbolId);
  assert.ok(index.findReferencesBySymbolId(reference.symbolId, true).length >= 2);
  assert.equal(index.symbolAt(document.uri, Position.create(0, 3))?.name, "main");
});

test("function parameters are not indexed as duplicate variables", () => {
  const document = parser.parse("file:///params.yc", 1, [
    "fn echo(message string) void {",
    "    fmt.println(message)",
    "}"
  ].join("\n"));

  assert.equal(document.diagnostics.some((diagnostic) => diagnostic.message.includes("Duplicate variable 'message'")), false);
  assert.equal(document.symbols.filter((symbol) => symbol.name === "message" && symbol.category === "parameter").length, 1);
  assert.equal(document.symbols.some((symbol) => symbol.name === "message" && symbol.category === "variable"), false);
});

test("struct fields are indexed as fields, not variables", () => {
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

  assert.equal(document.symbols.some((symbol) => symbol.name === "ok" && symbol.category === "field" && symbol.containerName === "Diagnostic"), true);
  assert.equal(document.symbols.some((symbol) => symbol.name === "ok" && symbol.category === "function"), true);
  assert.equal(document.symbols.some((symbol) => symbol.name === "ok" && symbol.category === "variable"), false);
  assert.equal(document.diagnostics.some((diagnostic) => diagnostic.message.includes("Duplicate variable 'ok'")), false);
});

test("strings are not indexed as declarations", () => {
  const document = parser.parse("file:///strings.yc", 1, [
    "fn message() string {",
    "    return \"expected '{' after struct name\"",
    "}"
  ].join("\n"));

  assert.equal(document.symbols.some((symbol) => symbol.name === "name" && symbol.category === "struct"), false);
  assert.equal(document.diagnostics.some((diagnostic) => diagnostic.message.includes("Duplicate struct 'name'")), false);
});

test("return statements are not indexed as struct fields", () => {
  const document = parser.parse("file:///return.yc", 1, [
    "struct Result {",
    "    ok bool",
    "}",
    "",
    "fn validate(p Result) Result {",
    "    if !p.ok { return p }",
    "    return p",
    "}"
  ].join("\n"));

  assert.equal(document.symbols.some((symbol) => symbol.name === "return" && symbol.category === "field"), false);
  assert.equal(document.diagnostics.some((diagnostic) => diagnostic.message.includes("Duplicate field 'return'")), false);
});
