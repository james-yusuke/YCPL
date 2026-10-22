import test from "node:test";
import assert from "node:assert/strict";
import { Position } from "vscode-languageserver/node";
import { YcplParser } from "../src/analysis/parser.js";
import { WorkspaceIndex } from "../src/analysis/workspaceIndex.js";

const parser = new YcplParser();

test("parser indexes declarations, imports, and references", () => {
  const document = parser.parse(
    "file:///sample.yc",
    1,
    [
      'import "std/fmt" as fmt',
      "struct Point {",
      "    x i32",
      "}",
      "fn print_point(p Point) void {",
      '    fmt.println("point")',
      "}"
    ].join("\n")
  );

  assert.equal(document.imports[0].modulePath, "std/fmt");
  assert.equal(document.imports[0].alias, "fmt");
  assert.ok(document.symbols.some((symbol) => symbol.name === "Point" && symbol.category === "struct"));
  assert.ok(
    document.symbols.some((symbol) => symbol.name === "print_point" && symbol.category === "function")
  );
  assert.ok(document.references.some((reference) => reference.name === "fmt"));
});

test("workspace index resolves local definitions and references", () => {
  const document = parser.parse(
    "file:///sample.yc",
    1,
    "fn main() i32 {\n    value := 1\n    return value\n}"
  );
  const index = new WorkspaceIndex();
  index.update(document);

  const definition = index.declarationAt(document.uri, Position.create(0, 3));
  assert.equal(definition?.name, "main");
  const reference = index.referenceAt(document.uri, Position.create(2, 13));
  if (!reference) {
    assert.fail("Expected return value reference");
  }
  assert.equal(index.symbolById(reference.symbolId)?.name, "value");
  assert.ok(reference.symbolId);
  assert.ok(index.findReferencesBySymbolId(reference.symbolId, true).length >= 2);
  assert.equal(index.symbolAt(document.uri, Position.create(0, 3))?.name, "main");
});

test("function parameters are not indexed as duplicate variables", () => {
  const document = parser.parse(
    "file:///params.yc",
    1,
    ["fn echo(message string) void {", "    fmt.println(message)", "}"].join("\n")
  );

  assert.equal(
    document.diagnostics.some((diagnostic) => diagnostic.message.includes("Duplicate variable 'message'")),
    false
  );
  assert.equal(
    document.symbols.filter((symbol) => symbol.name === "message" && symbol.category === "parameter").length,
    1
  );
  assert.equal(
    document.symbols.some((symbol) => symbol.name === "message" && symbol.category === "variable"),
    false
  );
});

test("struct fields are indexed as fields, not variables", () => {
  const document = parser.parse(
    "file:///diagnostic.yc",
    1,
    [
      "pub struct Diagnostic {",
      "    ok bool",
      "    message string",
      "}",
      "",
      "pub fn ok(path string) Diagnostic {",
      '    return Diagnostic{ok: true, message: ""}',
      "}"
    ].join("\n")
  );

  assert.equal(
    document.symbols.some(
      (symbol) => symbol.name === "ok" && symbol.category === "field" && symbol.containerName === "Diagnostic"
    ),
    true
  );
  assert.equal(
    document.symbols.some((symbol) => symbol.name === "ok" && symbol.category === "function"),
    true
  );
  assert.equal(
    document.symbols.some((symbol) => symbol.name === "ok" && symbol.category === "variable"),
    false
  );
  assert.equal(
    document.diagnostics.some((diagnostic) => diagnostic.message.includes("Duplicate variable 'ok'")),
    false
  );
});

test("strings are not indexed as declarations", () => {
  const document = parser.parse(
    "file:///strings.yc",
    1,
    ["fn message() string {", "    return \"expected '{' after struct name\"", "}"].join("\n")
  );

  assert.equal(
    document.symbols.some((symbol) => symbol.name === "name" && symbol.category === "struct"),
    false
  );
  assert.equal(
    document.diagnostics.some((diagnostic) => diagnostic.message.includes("Duplicate struct 'name'")),
    false
  );
});

test("return statements are not indexed as struct fields", () => {
  const document = parser.parse(
    "file:///return.yc",
    1,
    [
      "struct Result {",
      "    ok bool",
      "}",
      "",
      "fn validate(p Result) Result {",
      "    if !p.ok { return p }",
      "    return p",
      "}"
    ].join("\n")
  );

  assert.equal(
    document.symbols.some((symbol) => symbol.name === "return" && symbol.category === "field"),
    false
  );
  assert.equal(
    document.diagnostics.some((diagnostic) => diagnostic.message.includes("Duplicate field 'return'")),
    false
  );
});

test("parser indexes enum and type alias syntax", () => {
  const document = parser.parse(
    "file:///switch.yc",
    1,
    [
      "enum Color {",
      "    Red = 2,",
      "    Green,",
      "}",
      "",
      "type Score = i32",
      "",
      "fn classify(color Score) Score {",
      "    switch color {",
      "        case Color.Red {",
      "            return 10",
      "        }",
      "        case Green {",
      "            return 20",
      "        }",
      "        default {",
      "            return 30",
      "        }",
      "    }",
      "    return 0",
      "}"
    ].join("\n")
  );

  assert.equal(
    document.symbols.some((symbol) => symbol.name === "Color" && symbol.category === "enum"),
    true
  );
  assert.equal(
    document.symbols.some(
      (symbol) =>
        symbol.name === "Red" && symbol.category === "enumMember" && symbol.containerName === "Color"
    ),
    true
  );
  assert.equal(
    document.symbols.some((symbol) => symbol.name === "Score" && symbol.category === "typeAlias"),
    true
  );
  assert.equal(
    document.symbols.find(
      (symbol) => symbol.id === document.references.find((reference) => reference.name === "Green")?.symbolId
    )?.category,
    "enumMember"
  );
  assert.equal(
    document.references.some((reference) => ["switch", "case", "default"].includes(reference.name)),
    false
  );
});

test("parser handles managed values and ordinary blocks", () => {
  const document = parser.parse(
    "file:///lifetime.yc",
    1,
    [
      'import "std/bytes" as bytes',
      "",
      "fn main() {",
      '    b: owned Bytes := bytes.from_string("YCPL")',
      "    {",
      "        b.len",
      "    }",
      "}"
    ].join("\n")
  );

  assert.equal(document.symbols.find((symbol) => symbol.name === "b")?.typeName, "owned Bytes");
  assert.equal(
    document.references.some((reference) => ["owned", "defer"].includes(reference.name)),
    false
  );
  assert.equal(
    document.scopes.some((scope) => scope.kind === "block"),
    true
  );
});

test("retired language words are ordinary identifiers", () => {
  const document = parser.parse(
    "file:///retired-identifiers.yc",
    1,
    [
      "fn main() i32 {",
      "    mut := 1",
      "    match := mut + 1",
      "    go := match + 1",
      "    scope := go + 1",
      "    return scope",
      "}"
    ].join("\n")
  );

  assert.equal(
    document.symbols.some((symbol) => symbol.name === "mut" && symbol.category === "variable"),
    true
  );
  assert.equal(
    document.symbols.some((symbol) => symbol.name === "match" && symbol.category === "variable"),
    true
  );
  assert.equal(
    document.symbols.some((symbol) => symbol.name === "go" && symbol.category === "variable"),
    true
  );
  assert.equal(
    document.symbols.some((symbol) => symbol.name === "scope" && symbol.category === "variable"),
    true
  );
  const scopeReference = document.references.find((reference) => reference.name === "scope");
  assert.ok(scopeReference?.symbolId);
});

test("parser preserves Vec and Map generic types", () => {
  const document = parser.parse(
    "file:///generic-types.yc",
    1,
    [
      "fn collect(values Vec<i32>, lookup Map<string, Vec<i32>>) Vec<i32> {",
      "    result: Vec<i32> := Vec<i32>{capacity: 16}",
      "    return result",
      "}"
    ].join("\n")
  );
  const fn = document.symbols.find((symbol) => symbol.name === "collect");
  assert.deepEqual(
    fn?.parameters?.map((parameter) => parameter.typeName),
    ["Vec<i32>", "Map<string,Vec<i32>>"]
  );
  assert.equal(fn?.returnType, "Vec<i32>");
  assert.equal(document.symbols.find((symbol) => symbol.name === "result")?.typeName, "Vec<i32>");
});

test("nested comments and raw strings cannot create declarations, imports, or scopes", () => {
  const document = parser.parse(
    "file:///lexical.yc",
    1,
    [
      "/* outer /* inner */ struct Hidden { fake i32 } */",
      "fn main() {",
      '    message := `import "fake" as fake',
      "fn hidden() { }`",
      "    actual := 1 // fn commented() {",
      "    actual = actual + 1",
      "}"
    ].join("\n")
  );
  assert.deepEqual(
    document.symbols.map((symbol) => symbol.name),
    ["main", "message", "actual"]
  );
  assert.equal(document.imports.length, 0);
  assert.equal(document.scopes.length, 2);
  assert.deepEqual(document.diagnostics, []);
  assert.deepEqual(document.calls, []);
});

test("fields retain managed, qualified and nested container types", () => {
  const document = parser.parse(
    "file:///fields.yc",
    1,
    [
      "struct Data {",
      "    pub values Vec<i32> // managed",
      "    lookup Map<string, Vec<i32>>",
      "    payload owned bytes.Bytes",
      "}"
    ].join("\n")
  );
  assert.deepEqual(
    document.symbols.filter((symbol) => symbol.category === "field").map((symbol) => symbol.typeName),
    ["Vec<i32>", "Map<string,Vec<i32>>", "owned bytes.Bytes"]
  );
});

test("extern declarations do not consume the following function's scope", () => {
  const document = parser.parse(
    "file:///extern.yc",
    1,
    [
      'extern fn puts(message string) i32 as "puts"',
      "fn main() {",
      "    value := 1",
      "    puts(value)",
      "}"
    ].join("\n")
  );
  assert.equal(document.scopes.find((scope) => scope.kind === "function")?.name, "main");
  assert.equal(document.symbols.find((symbol) => symbol.name === "value")?.containerName, "main");
  assert.deepEqual(
    document.calls.map((call) => [call.caller, call.callee]),
    [["main", "puts"]]
  );
});

test("replacing and removing documents preserve external references and discard stale ones", () => {
  const index = new WorkspaceIndex();
  const original = parser.parse("file:///definition.yc", 1, "fn target() {}\nfn main() { target() }\n");
  const target = original.symbols.find((symbol) => symbol.name === "target")!;
  const external = parser.parse("file:///caller.yc", 1, "fn caller() { target() }\n");
  external.references.find((reference) => reference.name === "target")!.symbolId = target.id;
  index.update(original);
  index.update(external);
  assert.equal(index.findReferencesBySymbolId(target.id, false).length, 2);
  index.update(parser.parse(original.uri, 2, "fn target() {}\n"));
  assert.deepEqual(
    index.findReferencesBySymbolId(target.id, false).map((reference) => reference.uri),
    [external.uri]
  );
  index.remove(external.uri);
  assert.deepEqual(index.findReferencesBySymbolId(target.id, false), []);
});
