import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import {
  alternateTestFile,
  discoverTests,
  moduleTemplate,
  testHarness,
  testSkeleton
} from "../dist/workflow.js";

test("test discovery ignores comments, raw strings, private functions and incompatible signatures", () => {
  const source = [
    "// pub fn test_comment() bool {}",
    "/* nested /* pub fn test_hidden() bool {} */ */",
    "pub fn helper() { s := `pub fn test_literal() bool {}` }",
    "fn test_private() bool { return true }",
    "pub fn test_argument(value i32) bool { return true }",
    "pub fn test_wrong_return() i32 { return 0 }",
    "pub fn test_real() bool { return true }",
    "pub fn benchmark_real() bool { return true }"
  ].join("\n");
  assert.deepEqual(
    discoverTests("file:///math_test.yc", source).map(({ name, benchmark }) => ({ name, benchmark })),
    [
      { name: "test_real", benchmark: false },
      { name: "benchmark_real", benchmark: true }
    ]
  );
});

test("test runner uses relative imports, exact test names and boolean exit status", () => {
  const source = path.resolve("project with spaces/math_test.yc");
  const runner = path.resolve("project with spaces/.ycpl/tests/run-123");
  const harness = testHarness(source, [{ name: "test_real", line: 0, endLine: 0, benchmark: false }], runner);
  assert.ok(harness.includes('import "../../../math_test.yc" as fixture'));
  assert.ok(harness.includes("fixture.test_real()"));
  assert.ok(harness.includes("return 1"));
  assert.ok(harness.includes("return 2"));
});

test("generation and project scaffolding do not pretend unfinished tests passed", () => {
  const testSource = testSkeleton("math.yc", "pub fn add(a i32, b i32) i32 { return a + b }");
  assert.ok(testSource.includes("test_add() bool"));
  assert.ok(testSource.includes("return false"));
  assert.ok(testSource.includes("TODO"));
  assert.equal(alternateTestFile(alternateTestFile("math.yc")), "math.yc");
  assert.throws(() => moduleTemplate("bad-name"));
  const project = moduleTemplate("demo");
  assert.equal(JSON.parse(project["YCPL.json"]).entry, "src/main.yc");
  assert.ok(project["src/main.yc"].includes("Hello World"));
});

test("seeded property tests require one i32 argument and expose a reproducible seed", () => {
  const tests = discoverTests(
    "file:///property_test.yc",
    "pub fn fuzz_good(seed i32) bool { return true }\npub fn fuzz_bad(seed string) bool { return true }\n"
  );
  assert.equal(tests.length, 1);
  assert.equal(tests[0].fuzz, true);
  const harness = testHarness(path.resolve("property_test.yc"), tests, process.cwd());
  assert.ok(harness.includes("fixture.fuzz_good(i + start_seed)"));
  assert.ok(harness.includes("fuzz seed:"));
});
