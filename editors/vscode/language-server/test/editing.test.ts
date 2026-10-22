import test from "node:test";
import assert from "node:assert/strict";
import { TextDocument } from "vscode-languageserver-textdocument";
import { Range, TextEdit } from "vscode-languageserver/node";
import { YcplParser } from "../src/analysis/parser.js";
import { formatSource, organizeImports } from "../src/analysis/editing.js";
import { WorkspaceIndex } from "../src/analysis/workspaceIndex.js";
import { StandardLibraryIndex } from "../src/analysis/stdlib.js";
import { NullCompilerBridge } from "../src/compiler/compilerBridge.js";
import { YcplProviders } from "../src/lsp/providers.js";

const parser = new YcplParser();
function apply(text: string, edits: TextEdit[]): string {
  return TextDocument.applyEdits(TextDocument.create("file:///test.yc", "ycpl", 1, text), edits);
}

test("formatting preserves raw strings, nested comments and CRLF, and is idempotent", () => {
  const source =
    "fn main() {\r\ns := `opening   \r\n  { raw 😀 }   \r\nclosing`\r\n/* { nested /* } */\r\n  content */\r\nif true {\r\nprintln(s)\r\n}\r\n}\r\n";
  const formatted = formatSource(source, { tabSize: 2, insertSpaces: true });
  assert.ok(formatted.includes("  s := `opening   \r\n  { raw 😀 }   \r\nclosing`"));
  assert.ok(formatted.includes("    println(s)\r\n  }"));
  assert.equal(formatSource(formatted, { tabSize: 2, insertSpaces: true }), formatted);
});

test("organizing imports preserves comments and side effects and ignores aliases inside strings", () => {
  const text = [
    "module demo",
    'import "std/text" as text',
    'import "std/fmt" as fmt',
    'import "std/str" as str',
    'import "registration"',
    "// reason to load this module",
    'import "std/io" as io // side effects',
    "fn main() {",
    '    fmt.println("str.eq")',
    '    text.len("hello")',
    "}",
    ""
  ].join("\n");
  const document = parser.parse("file:///test.yc", 1, text);
  const organized = apply(text, organizeImports(document));
  assert.equal(organized.includes('import "std/str"'), false);
  assert.ok(organized.includes('import "registration"'));
  assert.ok(organized.includes('// reason to load this module\nimport "std/io" as io // side effects'));
  assert.ok(organized.indexOf('import "std/fmt"') < organized.indexOf('import "std/text"'));
  assert.equal(organizeImports(parser.parse(document.uri, 2, organized)).length, 0);
});

test("cross-file references resolve public imports, rename together, and respect visibility", () => {
  const index = new WorkspaceIndex();
  const library = parser.parse(
    "file:///project/math.yc",
    1,
    "pub fn twice(value i32) i32 { return value * 2 }\nfn secret() {}\n"
  );
  const app = parser.parse(
    "file:///project/main.yc",
    1,
    'import "math" as math\nfn main() {\n    math.twice(2)\n    math.secret()\n}\n'
  );
  index.update(app);
  index.update(library);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());
  const definition = providers.definition({
    textDocument: { uri: app.uri },
    position: { line: 2, character: 10 }
  });
  assert.equal(definition[0]?.uri, library.uri);
  const edits = providers.rename({
    textDocument: { uri: app.uri },
    position: { line: 2, character: 10 },
    newName: "doubleValue"
  });
  assert.ok(edits?.changes?.[app.uri]);
  assert.ok(edits?.changes?.[library.uri]);
  assert.equal(
    providers.definition({
      textDocument: { uri: app.uri },
      position: { line: 3, character: 10 }
    }).length,
    0
  );
  index.remove(library.uri);
  assert.equal(
    providers.definition({
      textDocument: { uri: app.uri },
      position: { line: 2, character: 10 }
    }).length,
    0
  );
});

test("rename rejects invalid names and collisions; extraction and struct fill produce valid edits", () => {
  const index = new WorkspaceIndex();
  const text = "struct Pair { x i32\n y bool }\nfn main() {\n    value := 1 + 2\n    other := Pair{}\n}\n";
  const document = parser.parse("file:///test.yc", 1, text);
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());
  assert.throws(() =>
    providers.rename({
      textDocument: { uri: document.uri },
      position: { line: 3, character: 7 },
      newName: "bad name"
    })
  );
  assert.throws(() =>
    providers.rename({
      textDocument: { uri: document.uri },
      position: { line: 3, character: 7 },
      newName: "other"
    })
  );
  const extract = providers.codeActions({
    textDocument: { uri: document.uri },
    range: Range.create(3, 13, 3, 18),
    context: { diagnostics: [], only: ["refactor.extract"] }
  });
  assert.equal(extract.length, 1);
  assert.ok(
    apply(text, extract[0].edit!.changes![document.uri]).includes(
      "extracted := 1 + 2\n    value := extracted"
    )
  );
  const fill = providers.codeActions({
    textDocument: { uri: document.uri },
    range: Range.create(4, 18, 4, 18),
    context: { diagnostics: [], only: ["refactor.rewrite"] }
  });
  assert.equal(fill.length, 1);
  assert.ok(apply(text, fill[0].edit!.changes![document.uri]).includes("Pair{x: 0, y: false}"));
  assert.ok(
    providers
      .inlayHints({
        textDocument: { uri: document.uri },
        range: Range.create(0, 0, 6, 0)
      })
      .every((hint) => hint.label !== ": inferred")
  );
  assert.ok(
    providers.codeLens({ textDocument: { uri: document.uri } }).every((lens) => lens.command?.command)
  );
});

test("function extraction preserves writes through pointers and rejects escaping locals", () => {
  const index = new WorkspaceIndex();
  const text = "fn main() i32 {\n    value := 1\n    value += 2\n    value *= 3\n    return value - 9\n}\n";
  const document = parser.parse("file:///refactor.yc", 1, text);
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());
  const actions = providers.codeActions({
    textDocument: { uri: document.uri },
    range: Range.create(2, 0, 4, 0),
    context: { diagnostics: [], only: ["refactor.extract"] }
  });
  assert.equal(actions.length, 1);
  const edited = apply(text, actions[0].edit!.changes![document.uri]);
  assert.ok(edited.includes("extracted_function(&value)"));
  assert.ok(edited.includes("fn extracted_function(value *i32)"));
  assert.ok(edited.includes("(*value) += 2"));
  assert.equal(
    providers.codeActions({
      textDocument: { uri: document.uri },
      range: Range.create(1, 0, 2, 0),
      context: { diagnostics: [], only: ["refactor.extract"] }
    }).length,
    0
  );
});

test("inline literal and parameter hints are actionable; type definition targets the type", () => {
  const index = new WorkspaceIndex();
  const text =
    "struct Point { x i32 }\nfn add(left i32, right i32) i32 { return left + right }\nfn main() {\n    number := 42\n    point := Point{x: number}\n    add(1, 2)\n}\n";
  const document = parser.parse("file:///hints.yc", 1, text);
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());
  const hints = providers.inlayHints({
    textDocument: { uri: document.uri },
    range: Range.create(0, 0, 7, 0)
  });
  assert.ok(hints.some((hint) => hint.label === "left:"));
  assert.ok(hints.some((hint) => hint.label === "right:"));
  assert.equal(
    providers.typeDefinition({
      textDocument: { uri: document.uri },
      position: { line: 4, character: 7 }
    })[0]?.range.start.line,
    0
  );
  const actions = providers.codeActions({
    textDocument: { uri: document.uri },
    range: Range.create(3, 4, 3, 4),
    context: { diagnostics: [], only: ["refactor.inline"] }
  });
  assert.equal(actions.length, 1);
  assert.ok(apply(text, actions[0].edit!.changes![document.uri]).includes("Point{x: (42)}"));
});

test("variable extraction rejects partial expressions that change precedence", () => {
  const index = new WorkspaceIndex();
  const source = "fn main() i32 {\n    return 1 + 2 * 3\n}\n";
  const document = parser.parse("file:///precedence.yc", 0, source);
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());
  assert.equal(
    providers.codeActions({
      textDocument: { uri: document.uri },
      range: Range.create(1, 11, 1, 16),
      context: { diagnostics: [], only: ["refactor.extract"] }
    }).length,
    0
  );
  assert.equal(
    providers.codeActions({
      textDocument: { uri: document.uri },
      range: Range.create(1, 11, 1, 20),
      context: { diagnostics: [], only: ["refactor.extract"] }
    }).length,
    1
  );
});

test("hints do not guess comparison or method-call types from their first literal", () => {
  const index = new WorkspaceIndex();
  const source = 'fn main() {\n    a := "x" == "y"\n    b := 1.5 < 2.0\n    c := Vec<i32>{}.len()\n}\n';
  const document = parser.parse("file:///hint-types.yc", 0, source);
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());
  assert.deepEqual(
    providers
      .inlayHints({ textDocument: { uri: document.uri }, range: Range.create(0, 0, 5, 0) })
      .filter((hint) => typeof hint.label === "string" && hint.label.startsWith(":")),
    []
  );
});

test("struct filling declines fields without a valid generated zero expression", () => {
  const index = new WorkspaceIndex();
  const source = "struct Collection { items []i32 }\nfn main() {\n    value := Collection{}\n}\n";
  const document = parser.parse("file:///fill-slice.yc", 0, source);
  index.update(document);
  const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());
  assert.equal(
    providers.codeActions({
      textDocument: { uri: document.uri },
      range: Range.create(2, 24, 2, 24),
      context: { diagnostics: [], only: ["refactor.rewrite"] }
    }).length,
    0
  );
});

test("inlining preserves storage identity and rejects parenthesized writes", () => {
  for (const use of ["pointer := &value", "(value) += 1"]) {
    const index = new WorkspaceIndex();
    const document = parser.parse(
      "file:///inline-address.yc",
      0,
      `fn main() {\n    value := 42\n    ${use}\n}\n`
    );
    index.update(document);
    const providers = new YcplProviders(index, new StandardLibraryIndex(undefined), new NullCompilerBridge());
    assert.equal(
      providers.codeActions({
        textDocument: { uri: document.uri },
        range: Range.create(1, 7, 1, 7),
        context: { diagnostics: [], only: ["refactor.inline"] }
      }).length,
      0
    );
  }
});
