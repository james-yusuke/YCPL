import * as fs from "node:fs/promises";
import * as path from "node:path";
import * as vscode from "vscode";
import { compilerEnvironment, findCompiler, resolveConfiguredPath } from "./runtime.js";
import { discoverTests, testHarness, type TestFunction } from "./workflow.js";
import { execute } from "./process.js";
import { debugTest } from "./debug.js";
import { coverageDetails, instrument, reportCoverage } from "./testCoverage.js";

export interface TestSummary {
  passed: number;
  failed: number;
  errored: number;
  skipped: number;
  coverage?: { files: number; total: number; covered: number };
}

export class YcplTesting implements vscode.Disposable {
  readonly controller = vscode.tests.createTestController("ycpl", "YCPL Tests");
  private readonly functions = new WeakMap<vscode.TestItem, TestFunction>();
  private readonly watcher = vscode.workspace.createFileSystemWatcher("**/*_test.yc");
  private readonly disposables: vscode.Disposable[] = [];
  private refreshPromise: Promise<void> | undefined;
  private refreshRequested = false;
  private stopped = false;

  constructor(private readonly output: vscode.OutputChannel) {
    this.controller.resolveHandler = async () => this.refresh();
    this.controller.refreshHandler = async () => this.refresh();
    this.disposables.push(
      this.controller.createRunProfile(
        "Run",
        vscode.TestRunProfileKind.Run,
        async (request, token) => {
          await this.run(request, token);
        },
        true
      ),
      this.controller.createRunProfile(
        "Debug",
        vscode.TestRunProfileKind.Debug,
        async (request, token) => {
          await this.run(request, token, true);
        },
        true
      ),
      this.watcher.onDidCreate(() => void this.refresh()),
      this.watcher.onDidChange(() => void this.refresh()),
      this.watcher.onDidDelete((uri) => {
        this.controller.items.delete(uri.toString());
      }),
      vscode.workspace.onDidSaveTextDocument((document) => {
        if (document.uri.fsPath.endsWith("_test.yc")) void this.refresh();
      })
    );
    const coverage = this.controller.createRunProfile(
      "Coverage",
      vscode.TestRunProfileKind.Coverage,
      async (request, token) => {
        await this.run(request, token, false, true);
      },
      true
    );
    coverage.loadDetailedCoverage = async (_run, file) => coverageDetails.get(file) ?? [];
    this.disposables.push(coverage);
    void this.refresh();
  }

  dispose(): void {
    this.stopped = true;
    for (const disposable of this.disposables) disposable.dispose();
    this.watcher.dispose();
    this.controller.dispose();
  }

  async refresh(): Promise<void> {
    if (this.stopped) return;
    this.refreshRequested = true;
    if (!this.refreshPromise) {
      this.refreshPromise = (async () => {
        try {
          do {
            this.refreshRequested = false;
            await this.discover();
          } while (this.refreshRequested && !this.stopped);
        } finally {
          this.refreshPromise = undefined;
        }
      })();
    }
    return this.refreshPromise;
  }

  private async discover(): Promise<void> {
    const files = await vscode.workspace.findFiles(
      "**/*_test.yc",
      "**/{node_modules,build,dist,target,bazel-*,.git,.ycpl,.vscode-test}/**"
    );
    const items: vscode.TestItem[] = [];
    for (const uri of files.sort((a, b) => a.toString().localeCompare(b.toString()))) {
      let document: vscode.TextDocument;
      try {
        document = await vscode.workspace.openTextDocument(uri);
      } catch (error) {
        this.output.appendLine(`Skipping test file ${uri}: ${String(error)}`);
        continue;
      }
      if (this.stopped) return;
      const file = this.controller.createTestItem(uri.toString(), vscode.workspace.asRelativePath(uri), uri);
      for (const entry of discoverTests(uri.toString(), document.getText())) {
        const id = `${uri}#${entry.name}`;
        const child = this.controller.createTestItem(id, entry.name, uri);
        child.range = new vscode.Range(entry.line, 0, entry.endLine, 0);
        child.tags = [new vscode.TestTag(entry.benchmark ? "benchmark" : entry.fuzz ? "fuzz" : "test")];
        file.children.add(child);
        this.functions.set(child, entry);
      }
      if (file.children.size) items.push(file);
    }
    if (!this.stopped) this.controller.items.replace(items);
  }

  async runSelection(uri?: vscode.Uri, line?: number, debug = false, coverage = false): Promise<TestSummary> {
    await this.refresh();
    let selected: vscode.TestItem[] | undefined;
    if (uri) {
      const file = this.controller.items.get(uri.toString());
      if (!file) throw new Error("No public test_*() bool functions found in this test file.");
      selected = [];
      file.children.forEach((item) => {
        if (
          line === undefined ||
          (item.range && item.range.start.line <= line && item.range.end.line >= line)
        )
          selected!.push(item);
      });
      if (!selected.length) throw new Error("Place the cursor inside a test function.");
    }
    const source = new vscode.CancellationTokenSource();
    try {
      return await this.run(new vscode.TestRunRequest(selected), source.token, debug, coverage);
    } finally {
      source.dispose();
    }
  }

  private async run(
    request: vscode.TestRunRequest,
    token: vscode.CancellationToken,
    debug = false,
    coverage = false
  ): Promise<TestSummary> {
    const summary: TestSummary = { passed: 0, failed: 0, errored: 0, skipped: 0 };
    if (!vscode.workspace.isTrusted) {
      void vscode.window.showWarningMessage("Trust this workspace before running YCPL tests.");
      return summary;
    }
    await vscode.workspace.saveAll(false);
    const run = this.controller.createTestRun(request);
    const cancellation = new vscode.CancellationTokenSource();
    const cancel = () => cancellation.cancel();
    const subscriptions = [token.onCancellationRequested(cancel), run.token.onCancellationRequested(cancel)];
    if (token.isCancellationRequested || run.token.isCancellationRequested) cancel();
    token = cancellation.token;
    const selected: vscode.TestItem[] = [];
    const finished = new Set<string>();
    const skip = (item: vscode.TestItem): void => {
      run.skipped(item);
      summary.skipped += 1;
      finished.add(item.id);
    };
    const error = (item: vscode.TestItem, message: string): void => {
      if (finished.has(item.id)) return;
      run.errored(item, new vscode.TestMessage(message));
      summary.errored += 1;
      finished.add(item.id);
    };
    const excluded = new Set((request.exclude ?? []).map((item) => item.id));
    const visit = (item: vscode.TestItem): void => {
      if (excluded.has(item.id)) return;
      if (item.children.size) item.children.forEach(visit);
      else selected.push(item);
    };
    if (request.include) request.include.forEach(visit);
    else this.controller.items.forEach(visit);
    const groups = new Map<string, vscode.TestItem[]>();
    const coverageByUri = new Map<string, Map<number, number>>();
    for (const item of selected) {
      run.enqueued(item);
      const key = item.uri!.toString();
      groups.set(key, [...(groups.get(key) ?? []), item]);
    }
    try {
      for (const items of groups.values()) {
        if (token.isCancellationRequested) {
          items.forEach(skip);
          continue;
        }
        const uri = items[0].uri!;
        const roots = vscode.workspace.workspaceFolders?.map((folder) => folder.uri.fsPath) ?? [];
        const config = vscode.workspace.getConfiguration("YCPL", uri);
        const root = vscode.workspace.getWorkspaceFolder(uri)?.uri.fsPath;
        const compiler = findCompiler(
          resolveConfiguredPath(config.get<string>("compiler.path", ""), root),
          roots
        );
        if (!compiler) throw new Error("Self-hosted ycc not found. Configure YCPL.compiler.path.");
        const environment = compilerEnvironment(
          process.env,
          resolveConfiguredPath(config.get<string>("stlRoot", ""), root),
          resolveConfiguredPath(config.get<string>("runtimeSource", ""), root)
        );
        const temporaryRoot = path.join(path.dirname(uri.fsPath), ".ycpl", "tests");
        await fs.mkdir(temporaryRoot, { recursive: true });
        const directory = await fs.mkdtemp(path.join(temporaryRoot, "run-"));
        try {
          const runner = path.join(directory, "runner.yc");
          await fs.writeFile(
            runner,
            testHarness(
              uri.fsPath,
              items.map((item) => this.functions.get(item)!),
              directory
            )
          );
          const append = (text: string): void => {
            this.output.append(text);
            run.appendOutput(text.replace(/\r?\n/g, "\r\n"));
          };
          const build = await execute(
            compiler,
            ["build", runner, ...(debug || coverage ? ["-g"] : []), "-o", directory],
            path.dirname(uri.fsPath),
            environment,
            token,
            append
          );
          if (build.code !== 0) {
            for (const item of items) {
              if (build.cancelled) skip(item);
              else error(item, build.stdout + build.stderr);
            }
            continue;
          }
          if (coverage) await instrument(directory, environment, token, append);
          for (const item of items) {
            if (token.isCancellationRequested) {
              skip(item);
              continue;
            }
            run.started(item);
            const started = performance.now();
            const entry = this.functions.get(item)!;
            const iterations =
              entry.benchmark || entry.fuzz
                ? Math.max(
                    1,
                    Math.min(
                      1000000,
                      config.get<number>(
                        entry.fuzz ? "testing.fuzzIterations" : "testing.benchmarkIterations",
                        1000
                      )
                    )
                  )
                : 1;
            const arguments_ = [
              entry.name,
              String(iterations),
              String(config.get<number>("testing.fuzzStartSeed", 0))
            ];
            const result = debug
              ? {
                  ...(await debugTest(
                    path.join(directory, "merged"),
                    arguments_,
                    directory,
                    environment,
                    token
                  )),
                  stdout: "",
                  stderr: ""
                }
              : await execute(
                  path.join(directory, "merged"),
                  arguments_,
                  directory,
                  environment,
                  token,
                  append
                );
            const elapsed = performance.now() - started;
            if (entry.benchmark)
              append(
                `${entry.name}: ${iterations} iterations, ${elapsed.toFixed(3)} ms total, ${((elapsed * 1000000) / iterations).toFixed(0)} ns/op (includes process startup)\n`
              );
            if (result.cancelled) skip(item);
            else if (result.code === 0) {
              run.passed(item, elapsed);
              summary.passed += 1;
            } else {
              run.failed(
                item,
                new vscode.TestMessage(
                  result.stdout + result.stderr || `Test returned false (exit ${result.code}).`
                ),
                elapsed
              );
              summary.failed += 1;
            }
            finished.add(item.id);
          }
          if (coverage && !token.isCancellationRequested) {
            const files = await reportCoverage(directory, environment, token);
            if (!files.length) throw new Error("No coverage data was produced for workspace sources.");
            for (const file of files) {
              const key = file.uri.toString();
              const lines = coverageByUri.get(key) ?? new Map<number, number>();
              for (const detail of coverageDetails.get(file) ?? []) {
                if (!(detail instanceof vscode.StatementCoverage)) continue;
                const line =
                  detail.location instanceof vscode.Range ? detail.location.start.line : detail.location.line;
                const count = typeof detail.executed === "number" ? detail.executed : Number(detail.executed);
                lines.set(line, (lines.get(line) ?? 0) + count);
              }
              coverageByUri.set(key, lines);
              const details = [...lines]
                .sort(([a], [b]) => a - b)
                .map(([line, count]) => new vscode.StatementCoverage(count, new vscode.Position(line, 0)));
              const merged = vscode.FileCoverage.fromDetails(file.uri, details);
              coverageDetails.set(merged, details);
              run.addCoverage(merged);
            }
            summary.coverage = { files: coverageByUri.size, total: 0, covered: 0 };
            for (const lines of coverageByUri.values()) {
              summary.coverage.total += lines.size;
              summary.coverage.covered += [...lines.values()].filter((count) => count > 0).length;
            }
          }
        } finally {
          await fs.rm(directory, { recursive: true, force: true });
        }
      }
    } catch (error) {
      this.output.appendLine(String(error));
      run.appendOutput(`${String(error)}\r\n`);
      void vscode.window.showErrorMessage(`YCPL tests: ${String(error)}`);
      for (const item of selected) {
        if (!finished.has(item.id)) {
          run.errored(item, new vscode.TestMessage(String(error)));
          summary.errored += 1;
        }
      }
    } finally {
      for (const subscription of subscriptions) subscription.dispose();
      cancellation.dispose();
      run.end();
    }
    return summary;
  }
}
