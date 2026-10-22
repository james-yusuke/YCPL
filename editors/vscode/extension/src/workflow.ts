import * as path from "node:path";
import { YcplParser } from "../../language-server/src/analysis/parser.js";

export interface TestFunction {
  name: string;
  line: number;
  endLine: number;
  benchmark: boolean;
  fuzz?: boolean;
}

/** Test functions have an explicit ABI so a generated runner never guesses arguments. */
export function discoverTests(uri: string, text: string): TestFunction[] {
  const parsed = new YcplParser().parse(uri, 0, text);
  return parsed.symbols.flatMap((symbol) => {
    const fuzz = symbol.name.startsWith("fuzz_");
    const signature = fuzz
      ? symbol.parameters?.length === 1 && symbol.parameters[0].typeName === "i32"
      : !symbol.parameters?.length;
    if (symbol.category !== "function" || !symbol.exported || !signature || symbol.returnType !== "bool")
      return [];
    if (!/^(?:test_|benchmark_|fuzz_)/.test(symbol.name)) return [];
    return [
      {
        name: symbol.name,
        line: symbol.selectionRange.start.line,
        endLine: symbol.range.end.line,
        benchmark: symbol.name.startsWith("benchmark_"),
        ...(fuzz ? { fuzz: true } : {})
      }
    ];
  });
}

export function testHarness(source: string, tests: TestFunction[], runnerDirectory: string): string {
  const relative = path.relative(runnerDirectory, path.resolve(source)).replaceAll(path.sep, "/");
  const input = relative.startsWith(".") ? relative : `./${relative}`;
  return [
    `import ${JSON.stringify(input)} as fixture`,
    'import "std/str" as str',
    'import "c/stdlib" as cstdlib',
    'import "std/fmt" as fmt',
    "fn main(argc i32, argv *string) i32 {",
    "    if argc < 2 { return 2 }",
    ...tests.map(
      (entry) =>
        `    if str.eq(argv[1], ${JSON.stringify(entry.name)}) {\n        iterations := 1\n        if argc > 2 { iterations = cstdlib.atoi(argv[2]) }\n        if iterations < 1 { return 2 }\n        start_seed := 0\n        if argc > 3 { start_seed = cstdlib.atoi(argv[3]) }\n        for (i := 0; i < iterations; i++) {\n            if !fixture.${entry.name}(${entry.fuzz ? "i + start_seed" : ""}) { ${entry.fuzz ? 'fmt.println("fuzz seed:")\n                fmt.println(i + start_seed)\n                ' : ""}return 1 }\n        }\n        return 0\n    }`
    ),
    "    return 2",
    "}",
    ""
  ].join("\n");
}

export function alternateTestFile(file: string): string {
  return file.endsWith("_test.yc") ? file.slice(0, -8) + ".yc" : file.replace(/\.yc$/, "_test.yc");
}

export function testSkeleton(source: string, text: string, functionName?: string): string {
  const document = new YcplParser().parse(source, 0, text);
  const functions = document.symbols.filter(
    (symbol) =>
      symbol.category === "function" &&
      symbol.exported &&
      symbol.name !== "main" &&
      (!functionName || symbol.name === functionName)
  );
  if (!functions.length) throw new Error("Select a public function to generate its test.");
  return (
    `import ${JSON.stringify(`./${path.basename(source)}`)} as sut // implementation under test\n\n` +
    functions
      .map((symbol) =>
        [
          `pub fn test_${symbol.name}() bool {`,
          `    // TODO: call sut.${symbol.name} with test inputs and check the result.`,
          "    return false",
          "}",
          ""
        ].join("\n")
      )
      .join("\n")
  );
}

export function moduleTemplate(name: string): Record<string, string> {
  if (!/^[A-Za-z_]\w*$/.test(name)) throw new Error("Use a YCPL identifier for the project name.");
  return {
    "YCPL.json":
      JSON.stringify(
        { name, version: "0.1.0", entry: "src/main.yc", src: ["src"], output: "build" },
        null,
        2
      ) + "\n",
    "src/main.yc":
      'import "std/fmt" as fmt\n\nfn main() i32 {\n    fmt.println("Hello World")\n    return 0\n}\n',
    ".gitignore": "build/\n.ycpl/\n"
  };
}
