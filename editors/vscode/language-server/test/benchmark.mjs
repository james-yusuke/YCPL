import { performance } from "node:perf_hooks";
import { YcplParser } from "../dist/src/analysis/parser.js";
import { WorkspaceIndex } from "../dist/src/analysis/workspaceIndex.js";

const text = Array.from({ length: 30 }, (_, f) => `fn f${f}() i32 {\n${Array.from({ length: 80 }, (_, i) => `    v${i} := ${i}\n    v${i} = v${i} + 1`).join("\n")}\n    return v79\n}`).join("\n");
const parser = new YcplParser();
const times = [];
let document;
for (let i = 0; i < 6; i += 1) {
  const start = performance.now();
  document = parser.parse("file:///benchmark.yc", i, text);
  times.push(performance.now() - start);
}
const index = new WorkspaceIndex();
index.update(document);
const start = performance.now();
for (let i = 0; i < 30; i += 1) index.update(document);
const median = [...times.slice(1)].sort((a, b) => a - b)[2];
console.log(JSON.stringify({ bytes: text.length, symbols: document.symbols.length, parseMs: times, medianParseMs: median, indexUpdateMs: (performance.now() - start) / 30 }, null, 2));
