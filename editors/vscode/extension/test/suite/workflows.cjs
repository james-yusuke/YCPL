const assert = require("node:assert/strict");
const path = require("node:path");
const fs = require("node:fs/promises");
const vscode = require("vscode");

async function runWorkflows() {
  const root = vscode.workspace.workspaceFolders[0].uri;
  const repository = process.env.YCPL_TEST_REPOSITORY;
  assert.ok(repository, "integration runner supplies the repository");
  const compiler = process.env.YCPL_TEST_COMPILER || path.join(repository, "bazel-bin", "ycc");
  const config = vscode.workspace.getConfiguration("YCPL", root);
  await config.update("compiler.path", compiler, vscode.ConfigurationTarget.Workspace);
  await config.update("stlRoot", path.join(repository, "stl"), vscode.ConfigurationTarget.Workspace);
  await config.update(
    "runtimeSource",
    path.join(repository, "bootstrap/cpp/runtime/yc_runtime.c"),
    vscode.ConfigurationTarget.Workspace
  );
  const write = async (name, content) => {
    const uri = vscode.Uri.joinPath(root, name);
    await fs.writeFile(uri.fsPath, content);
    return uri;
  };
  await write("math.yc", "pub fn add(a i32, b i32) i32 {\n    return a + b\n}\n");
  const tests = await write(
    "math_test.yc",
    'import "./math.yc" as math\npub fn test_pass() bool { return math.add(20, 22) == 42 }\npub fn test_fail() bool { return false }\npub fn benchmark_add() bool { return math.add(1, 2) == 3 }\npub fn fuzz_identity(seed i32) bool { return seed >= 0 }\n'
  );
  await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(tests));
  const result = await vscode.commands.executeCommand("YCPL.testFile", tests);
  assert.deepEqual(
    result,
    { passed: 3, failed: 1, errored: 0, skipped: 0 },
    "Test Explorer compiles and executes real passing/failing tests and benchmarks"
  );
  vscode.window.activeTextEditor.selection = new vscode.Selection(1, 10, 1, 10);
  const debugged = await vscode.commands.executeCommand("YCPL.debugTestAtCursor");
  assert.deepEqual(
    debugged,
    { passed: 1, failed: 0, errored: 0, skipped: 0 },
    "Test Explorer Debug runs a real test through LLDB"
  );
  await write(
    "other_test.yc",
    'import "./math.yc" as math\npub fn test_other() bool { return math.add(1, 1) == 2 }\n'
  );
  const coverage = await vscode.commands.executeCommand("YCPL.coverage");
  assert.deepEqual(
    { ...coverage, coverage: undefined },
    { coverage: undefined, passed: 4, failed: 1, errored: 0, skipped: 0 },
    "LLVM-instrumented test run preserves real results"
  );
  assert.ok(coverage.coverage?.files === 3, "coverage includes imported workspace helpers");
  assert.ok(coverage.coverage.covered > 0 && coverage.coverage.total >= coverage.coverage.covered);
  const utility = await write("utility.yc", "pub fn identity(value i32) i32 { return value }\n");
  await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(utility));
  await vscode.commands.executeCommand("YCPL.generateTests");
  const generated = vscode.window.activeTextEditor.document;
  assert.equal(path.basename(generated.uri.fsPath), "utility_test.yc");
  assert.match(generated.getText(), /test_identity/);
  assert.match(generated.getText(), /return false/);
  await generated.save();
  await vscode.commands.executeCommand("YCPL.toggleTestFile");
  assert.equal(vscode.window.activeTextEditor.document.uri.toString(), utility.toString());
  const tasks = await vscode.tasks.fetchTasks({ type: "ycpl" });
  assert.ok(
    tasks.some((task) => task.definition.command === "build"),
    "workspace build tasks are available"
  );
  const imported = await write(
    "imports.yc",
    'import "std/text" as unused\nimport "std/fmt" as fmt\nfn main() { fmt.println("ok") }\n'
  );
  await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(imported));
  await vscode.commands.executeCommand("YCPL.organizeImports");
  assert.ok(!vscode.window.activeTextEditor.document.getText().includes("unused"));
  await vscode.window.activeTextEditor.document.save();
  const profileSource = await write(
    "profile.yc",
    "fn helper(value i32) i32 { return value + 1 }\nfn main() i32 { return helper(41) - 42 }\n"
  );
  await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(profileSource));
  const profile = await vscode.commands.executeCommand("YCPL.profile");
  assert.ok(profile, "execution profiler returns its saved report");
  assert.match(await fs.readFile(profile.fsPath, "utf8"), /helper/);
  if (process.platform === "darwin") {
    await config.update("profiling.duration", 1, vscode.ConfigurationTarget.Workspace);
    const sampled = await write(
      "sample.yc",
      'import "c/yc_runtime" as runtime\nfn main() i32 { runtime.sleep_millis(3000) return 0 }\n'
    );
    await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(sampled));
    const cpu = await vscode.commands.executeCommand("YCPL.profileCPU");
    assert.ok(cpu, "macOS sample captures the real YCPL process");
    assert.match(await fs.readFile(cpu.fsPath, "utf8"), /Sampling|Call graph/);
    await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(profileSource));
    const memory = await vscode.commands.executeCommand("YCPL.profileMemory");
    assert.ok(memory, "macOS leaks runs the program and returns a report");
    assert.match(await fs.readFile(memory.fsPath, "utf8"), /leak/i);
  }
  const scratch = await vscode.commands.executeCommand("YCPL.playground");
  assert.match(scratch.fsPath, /playground/);
  await runDebugger(write, root);
}

async function runDebugger(write, root) {
  const source = await write(
    "debug.yc",
    "fn add(a i32, b i32) i32 {\n    total := a + b\n    return total\n}\nfn main() i32 {\n    point := Point{x: 20, y: 22}\n    value := add(point.x, point.y)\n    return value - 42\n}\nstruct Point { x i32\ny i32 }\n"
  );
  const breakpoint = new vscode.SourceBreakpoint(new vscode.Location(source, new vscode.Position(2, 0)));
  vscode.debug.addBreakpoints([breakpoint]);
  let complete;
  const done = new Promise((resolve, reject) => {
    complete = { resolve, reject };
  });
  const timeout = setTimeout(
    () => complete.reject(new Error("LLDB DAP did not hit the source breakpoint")),
    60000
  );
  let stage = 0;
  const tracker = vscode.debug.registerDebugAdapterTrackerFactory("ycpl", {
    createDebugAdapterTracker(session) {
      if (session.name !== "YCPL integration debug") return;
      return {
        onDidSendMessage(message) {
          if (message.type !== "event" || message.event !== "stopped" || stage > 1) return;
          const current = stage++;
          void (async () => {
            const stack = await session.customRequest("stackTrace", { threadId: message.body.threadId });
            const scopes = await session.customRequest("scopes", { frameId: stack.stackFrames[0].id });
            const variables = await session.customRequest("variables", {
              variablesReference: scopes.scopes[0].variablesReference
            });
            if (current === 0) {
              assert.equal(stack.stackFrames[0].line, 3);
              assert.ok(
                variables.variables.some((value) => value.name === "total" && value.value === "42"),
                "DWARF exposes real local values"
              );
              await session.customRequest("stepOut", { threadId: message.body.threadId });
            } else {
              const point = variables.variables.find((value) => value.name === "point");
              assert.ok(point?.variablesReference, "DWARF exposes a structured local");
              const fields = await session.customRequest("variables", {
                variablesReference: point.variablesReference
              });
              assert.ok(fields.variables.some((value) => value.name === "x" && value.value === "20"));
              assert.ok(fields.variables.some((value) => value.name === "y" && value.value === "22"));
              await session.customRequest("continue", { threadId: message.body.threadId });
              complete.resolve();
            }
          })().catch(complete.reject);
        },
        onError: complete.reject
      };
    }
  });
  try {
    assert.equal(
      await vscode.debug.startDebugging(vscode.workspace.getWorkspaceFolder(root), {
        type: "ycpl",
        request: "launch",
        name: "YCPL integration debug",
        program: source.fsPath,
        console: "internalConsole"
      }),
      true
    );
    await done;
  } finally {
    clearTimeout(timeout);
    tracker.dispose();
    vscode.debug.removeBreakpoints([breakpoint]);
    if (vscode.debug.activeDebugSession?.name === "YCPL integration debug")
      await vscode.debug.stopDebugging();
  }
}
module.exports = { runWorkflows };
