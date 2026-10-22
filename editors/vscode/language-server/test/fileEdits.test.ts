import assert from "node:assert/strict";
import test from "node:test";
import { YcplParser } from "../src/analysis/parser.js";
import { renameFileImports } from "../src/analysis/fileEdits.js";

test("renaming modules updates imports and moved files' own relative paths", () => {
  const parser = new YcplParser();
  const main = parser.parse(
    "file:///work/main.yc",
    0,
    'import "./lib/math.yc" as math // keep\nfn main() { math.value() }'
  );
  const math = parser.parse(
    "file:///work/lib/math.yc",
    0,
    'import "../value.yc" as value\npub fn answer() i32 { return value.answer() }'
  );
  const value = parser.parse("file:///work/value.yc", 0, "pub fn answer() i32 { return 42 }");
  const result = renameFileImports(
    [main, math, value],
    [{ oldUri: math.uri, newUri: "file:///work/math.yc" }],
    ["/work"]
  );
  assert.equal(result.changes?.[main.uri][0].newText, '"./math.yc"');
  assert.equal(result.changes?.[math.uri][0].newText, '"./value.yc"');
  assert.deepEqual(result.changes?.[main.uri][0].range, {
    start: { line: 0, character: 7 },
    end: { line: 0, character: 22 }
  });
});

test("directory moves preserve extensionless modules and leave stdlib alone", () => {
  const parser = new YcplParser();
  const main = parser.parse("file:///work/main.yc", 0, 'import "./lib" as lib\nimport "std/fmt" as fmt\n');
  const library = parser.parse("file:///work/lib/index.yc", 0, "pub fn value() i32 { return 1 }");
  const result = renameFileImports(
    [main, library],
    [{ oldUri: "file:///work/lib", newUri: "file:///work/library" }],
    ["/work"]
  );
  assert.equal(result.changes?.[main.uri].length, 1);
  assert.equal(result.changes?.[main.uri][0].newText, '"./library"');
});

test("project imports in nested files use the shared src-relative resolver", () => {
  const parser = new YcplParser();
  const app = parser.parse("file:///work/src/client/main.yc", 0, 'import "math" as math\n');
  const math = parser.parse("file:///work/src/math.yc", 0, "pub fn answer() i32 { return 42 }");
  const result = renameFileImports(
    [app, math],
    [{ oldUri: math.uri, newUri: "file:///work/src/numbers.yc" }],
    ["/work"]
  );
  assert.equal(result.changes?.[app.uri][0].newText, '"numbers"');
});
