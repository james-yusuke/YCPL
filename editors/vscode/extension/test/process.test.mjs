import assert from "node:assert/strict";
import test from "node:test";
import { execute } from "../dist/process.js";
import { flagArguments, parseCoverage } from "../dist/llvm.js";

test("process arguments are literal and output is bounded", async () => {
  const value = 'space $(touch injected); `echo unsafe` "quoted"';
  const result = await execute(
    process.execPath,
    ["-e", "process.stdout.write(process.argv[1]);process.stderr.write('x'.repeat(3*1024*1024))", value],
    process.cwd(),
    process.env
  );
  assert.equal(result.code, 0);
  assert.equal(result.stdout, value);
  assert.equal(result.stderr.length, 2 * 1024 * 1024);
});

test("process errors resolve and a signal-ignoring child is forcibly cancelled", async () => {
  assert.equal((await execute("/nonexistent/ycpl-compiler", [], process.cwd(), process.env)).code, -1);
  let cancelled = false,
    callback;
  const token = {
    get isCancellationRequested() {
      return cancelled;
    },
    onCancellationRequested(listener) {
      callback = listener;
      return { dispose() {} };
    }
  };
  const result = execute(
    process.execPath,
    ["-e", "process.on('SIGTERM',()=>{}); console.log('ready'); setInterval(()=>{},100)"],
    process.cwd(),
    process.env,
    token,
    () => {
      cancelled = true;
      callback();
    }
  );
  assert.equal((await result).cancelled, true);
});

test("quoted link flags and LLVM line counts preserve paths and zero-hit lines", () => {
  assert.deepEqual(flagArguments("-L\"a directory\" -Wl,$(touch) 'literal`value`'"), [
    "-La directory",
    "-Wl,$(touch)",
    "literal`value`"
  ]);
  assert.throws(() => flagArguments('"unfinished'));
  const report = parseCoverage("file:/a path/math.yc\nlcount:2,0\nlcount:3,7\nfile:/other.yc\nlcount:1,1\n");
  assert.deepEqual(
    [...report[0].lines],
    [
      [2, 0],
      [3, 7]
    ]
  );
  assert.equal(report[0].file, "/a path/math.yc");
});
