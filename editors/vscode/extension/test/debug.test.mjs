import assert from "node:assert/strict";
import test from "node:test";
import { fileURLToPath } from "node:url";
import { build } from "esbuild";

const { outputFiles } = await build({
  entryPoints: [fileURLToPath(new URL("../src/debug.ts", import.meta.url))],
  bundle: true,
  platform: "node",
  format: "esm",
  write: false,
  plugins: [
    {
      name: "debug-session-fixture",
      setup(builder) {
        builder.onResolve({ filter: /^vscode$/ }, () => ({ path: "vscode", namespace: "fixture" }));
        builder.onLoad({ filter: /.*/, namespace: "fixture" }, () => ({
          contents: "module.exports = globalThis.__ycplDebugFixture;",
          loader: "js"
        }));
      }
    }
  ]
});
let generation = 0;

async function scenario(event) {
  let factory,
    cancelled = false,
    cancel,
    stops = 0,
    disposed = 0;
  const disposable = () => ({
    dispose() {
      disposed++;
    }
  });
  const token = {
    get isCancellationRequested() {
      return cancelled;
    },
    onCancellationRequested(callback) {
      cancel = callback;
      return disposable();
    }
  };
  const fixture = {
    Uri: { file: (fsPath) => ({ fsPath }) },
    workspace: { getWorkspaceFolder() {} },
    debug: {
      registerDebugAdapterTrackerFactory(_type, value) {
        factory = value;
        return disposable();
      },
      onDidTerminateDebugSession() {
        return disposable();
      },
      startDebugging(_folder, configuration) {
        const tracker = factory.createDebugAdapterTracker({ configuration });
        queueMicrotask(() => {
          if (event === "cancel") {
            cancelled = true;
            cancel();
          } else tracker.onDidSendMessage(event);
        });
        // Reproduce a UI promise that does not finish even though DAP has a result.
        return new Promise(() => {});
      },
      stopDebugging() {
        stops++;
        return new Promise(() => {});
      }
    }
  };
  globalThis.__ycplDebugFixture = fixture;
  try {
    const url = `data:text/javascript;base64,${Buffer.from(outputFiles[0].text).toString("base64")}#${generation++}`;
    const { debugTest } = await import(url);
    const result = await debugTest("/test/merged", ["test_pass"], "/test", {}, token);
    assert.equal(stops, 1, "stop is requested without making the test await UI teardown");
    assert.equal(disposed, 3, "all session listeners are released");
    return result;
  } finally {
    delete globalThis.__ycplDebugFixture;
  }
}

test(
  "DAP exit finishes a test independently of VS Code launch and stop promises",
  { timeout: 1000 },
  async () => {
    const result = await scenario({ type: "event", event: "exited", body: { exitCode: 0 } });
    assert.equal(result.code, 0);
    assert.equal(result.cancelled, false);
  }
);

test(
  "DAP launch errors finish with their diagnostics even when the UI is pending",
  { timeout: 1000 },
  async () => {
    const result = await scenario({
      type: "response",
      command: "launch",
      success: false,
      message: "launch denied"
    });
    assert.equal(result.code, -1);
    assert.match(result.stderr, /launch denied/);
  }
);

test("cancelling a debug test does not wait for the debug UI", { timeout: 1000 }, async () => {
  assert.equal((await scenario("cancel")).cancelled, true);
});

test("debug startup uses local symbols by default and preserves explicit LLDB commands", async () => {
  for (const externalSymbols of [false, true]) {
    let provider;
    globalThis.__ycplDebugFixture = {
      workspace: {
        isTrusted: true,
        getConfiguration: () => ({ get: () => externalSymbols })
      },
      commands: { registerCommand: () => ({ dispose() {} }) },
      debug: {
        registerDebugConfigurationProvider(_type, value) {
          provider = value;
          return { dispose() {} };
        },
        registerDebugAdapterDescriptorFactory: () => ({ dispose() {} }),
        onDidTerminateDebugSession: () => ({ dispose() {} })
      }
    };
    try {
      const url = `data:text/javascript;base64,${Buffer.from(outputFiles[0].text).toString("base64")}#${generation++}`;
      const { registerDebugging } = await import(url);
      registerDebugging({ subscriptions: [] }, {});
      const command = "settings set target.max-children-count 64";
      const resolved = provider.resolveDebugConfiguration(undefined, { initCommands: [command] });
      assert.deepEqual(
        resolved.initCommands,
        externalSymbols ? [command] : ["settings set symbols.enable-external-lookup false", command]
      );
    } finally {
      delete globalThis.__ycplDebugFixture;
    }
  }
});
