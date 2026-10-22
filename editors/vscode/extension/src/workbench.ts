import * as fs from "node:fs/promises";
import * as path from "node:path";
import * as vscode from "vscode";
import { organizeImports } from "../../language-server/src/analysis/editing.js";
import { YcplParser } from "../../language-server/src/analysis/parser.js";
import { alternateTestFile, discoverTests, moduleTemplate, testSkeleton } from "./workflow.js";
import { findCompiler, resolveConfiguredPath } from "./runtime.js";
import { registerTasks } from "./tasks.js";
import { YcplTesting } from "./testing.js";
import { registerDebugging } from "./debug.js";
import { profile } from "./profile.js";

export function registerWorkbench(
  context: vscode.ExtensionContext,
  output: vscode.OutputChannel
): YcplTesting {
  const testing = new YcplTesting(output);
  registerDebugging(context, output);
  context.subscriptions.push(testing, registerTasks());
  const command = (name: string, action: (...args: any[]) => unknown): void => {
    context.subscriptions.push(
      vscode.commands.registerCommand(name, async (...args: any[]) => {
        try {
          return await action(...args);
        } catch (error) {
          output.appendLine(String(error));
          void vscode.window.showErrorMessage(String(error instanceof Error ? error.message : error));
        }
      })
    );
  };
  command("YCPL.references", async (source: string, position: { line: number; character: number }) => {
    const uri = vscode.Uri.parse(source);
    const at = new vscode.Position(position.line, position.character);
    const references =
      (await vscode.commands.executeCommand<vscode.Location[]>("vscode.executeReferenceProvider", uri, at)) ??
      [];
    await vscode.commands.executeCommand("editor.action.showReferences", uri, at, references);
    return references.length;
  });
  command("YCPL.testWorkspace", () => testing.runSelection());
  command("YCPL.testFile", (uri?: vscode.Uri) => testing.runSelection(uri ?? activeDocument().uri));
  command("YCPL.testAtCursor", () =>
    testing.runSelection(activeDocument().uri, vscode.window.activeTextEditor!.selection.active.line)
  );
  command("YCPL.testFunction", (uri: string, line: number) =>
    testing.runSelection(vscode.Uri.parse(uri), line)
  );
  command("YCPL.debugTestAtCursor", () =>
    testing.runSelection(activeDocument().uri, vscode.window.activeTextEditor!.selection.active.line, true)
  );
  command("YCPL.coverage", (uri?: vscode.Uri) => testing.runSelection(uri, undefined, false, true));
  command("YCPL.refreshTests", () => testing.refresh());
  command("YCPL.toggleTestFile", async () => {
    const uri = vscode.Uri.file(alternateTestFile(activeDocument().uri.fsPath));
    await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(uri));
  });
  command("YCPL.generateTests", async () => {
    const document = activeDocument();
    const target = vscode.Uri.file(alternateTestFile(document.uri.fsPath));
    if (document.uri.fsPath.endsWith("_test.yc"))
      throw new Error("Generate tests from the implementation file.");
    try {
      await fs.access(target.fsPath);
      throw new Error("The test file already exists; open it with Toggle Test File.");
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error;
    }
    const skeleton = testSkeleton(document.uri.fsPath, document.getText());
    const edit = new vscode.WorkspaceEdit();
    edit.createFile(target, { overwrite: false });
    edit.insert(target, new vscode.Position(0, 0), skeleton);
    if (!(await vscode.workspace.applyEdit(edit))) throw new Error("Could not create the test file.");
    await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(target));
  });
  command("YCPL.organizeImports", async () => {
    const document = activeDocument();
    const edits = importEdits(document);
    const edit = new vscode.WorkspaceEdit();
    edit.set(document.uri, edits);
    await vscode.workspace.applyEdit(edit);
  });
  command("YCPL.profile", () => profile(activeDocument(), output));
  command("YCPL.profileCPU", () => profile(activeDocument(), output, "cpu"));
  command("YCPL.profileMemory", () => profile(activeDocument(), output, "memory"));
  command("YCPL.playground", async () => {
    const root = vscode.workspace.workspaceFolders?.[0]?.uri;
    if (!root) throw new Error("Open a workspace folder to create a local playground.");
    const parent = path.join(root.fsPath, ".ycpl", "playground");
    await fs.mkdir(parent, { recursive: true });
    const directory = await fs.mkdtemp(path.join(parent, "scratch-"));
    const uri = vscode.Uri.file(path.join(directory, "main.yc"));
    await fs.writeFile(uri.fsPath, moduleTemplate("playground")["src/main.yc"]);
    await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(uri));
    return uri;
  });
  command("YCPL.addImport", async () => {
    const document = activeDocument();
    const folders = await vscode.workspace.findFiles(
      "**/*.yc",
      "**/{build,node_modules,target,.ycpl,bazel-*,.git}/**"
    );
    const local = folders
      .filter((uri) => uri.toString() !== document.uri.toString())
      .map((uri) => {
        let name = path.relative(path.dirname(document.uri.fsPath), uri.fsPath).replaceAll(path.sep, "/");
        if (!name.startsWith(".")) name = "./" + name;
        return name;
      });
    const choice = await vscode.window.showQuickPick(
      [
        ...new Set(["std/fmt", "std/str", "std/text", "std/os", "std/fs", "std/json", "std/array", ...local])
      ].sort(),
      { title: "YCPL: Add Import", placeHolder: "Choose a local or standard-library module" }
    );
    if (!choice) return;
    const alias = await vscode.window.showInputBox({
      title: "Import alias",
      value: path.basename(choice, ".yc"),
      validateInput: (value) => (/^[A-Za-z_]\w*$/.test(value) ? undefined : "Use a YCPL identifier.")
    });
    if (!alias) return;
    const parsed = new YcplParser().parse(document.uri.toString(), document.version, document.getText());
    if (parsed.imports.some((item) => item.alias === alias))
      throw new Error("That import alias is already used.");
    const line = /^\s*(?:module|package)\s+[^\n]+/.test(document.getText()) ? 1 : 0;
    const edit = new vscode.WorkspaceEdit();
    edit.insert(
      document.uri,
      new vscode.Position(line, 0),
      `import ${JSON.stringify(choice)} as ${alias} // imported module\n`
    );
    await vscode.workspace.applyEdit(edit);
  });
  command("YCPL.newProject", async () => {
    const folder = await vscode.window.showOpenDialog({
      canSelectFolders: true,
      canSelectFiles: false,
      canSelectMany: false,
      openLabel: "Create YCPL Project Here"
    });
    if (!folder?.[0]) return;
    const name = await vscode.window.showInputBox({
      title: "YCPL project name",
      value: path.basename(folder[0].fsPath).replace(/\W/g, "_"),
      validateInput: (value) =>
        /^[A-Za-z_]\w*$/.test(value)
          ? undefined
          : "Use letters, digits and underscores, starting with a letter."
    });
    if (!name) return;
    const edit = new vscode.WorkspaceEdit();
    for (const [file, text] of Object.entries(moduleTemplate(name))) {
      const uri = vscode.Uri.joinPath(folder[0], file);
      edit.createFile(uri, { overwrite: false, ignoreIfExists: false });
      edit.insert(uri, new vscode.Position(0, 0), text);
    }
    if (!(await vscode.workspace.applyEdit(edit)))
      throw new Error("Project files already exist or could not be created.");
    await vscode.commands.executeCommand("vscode.openFolder", folder[0], { forceNewWindow: true });
  });
  command("YCPL.showEnvironment", async () => {
    const roots = vscode.workspace.workspaceFolders?.map((item) => item.uri.fsPath) ?? [];
    const config = vscode.workspace.getConfiguration("YCPL");
    const compiler = findCompiler(
      resolveConfiguredPath(config.get<string>("compiler.path", ""), roots[0]),
      roots
    );
    const content = [
      "# YCPL development environment",
      "",
      `Workspace trust: ${vscode.workspace.isTrusted ? "trusted" : "restricted"}`,
      `Compiler: ${compiler ?? "not found — configure YCPL.compiler.path"}`,
      `Language server: ${config.get("server.mode", "auto")}`,
      `STL: ${config.get("stlRoot", "") || process.env.YCPL_STL_ROOT || "compiler discovery"}`,
      `LLVM: ${process.env.LLVM_CONFIG ?? "compiler discovery"}`,
      `Output: ${config.get("outputDirectory", ".ycpl/build")}`,
      "",
      "Run **YCPL: Configure Compiler** to select a self-hosted ycc executable.",
      ""
    ].join("\n\n");
    await vscode.window.showTextDocument(
      await vscode.workspace.openTextDocument({ content, language: "markdown" })
    );
  });
  command("YCPL.configureCompiler", async () => {
    const selected = await vscode.window.showOpenDialog({
      canSelectFiles: true,
      canSelectFolders: false,
      canSelectMany: false,
      openLabel: "Select self-hosted ycc"
    });
    if (selected?.[0])
      await vscode.workspace
        .getConfiguration("YCPL")
        .update("compiler.path", selected[0].fsPath, vscode.ConfigurationTarget.Workspace);
  });
  command("YCPL.runFunction", async (uri: string) => {
    await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(vscode.Uri.parse(uri)));
    await vscode.commands.executeCommand("YCPL.run");
  });

  context.subscriptions.push(
    vscode.languages.registerCodeLensProvider(
      { language: "ycpl", scheme: "file" },
      {
        provideCodeLenses(document) {
          const parsed = new YcplParser().parse(
            document.uri.toString(),
            document.version,
            document.getText()
          );
          const lenses: vscode.CodeLens[] = [];
          for (const symbol of parsed.symbols) {
            if (symbol.category === "function" && symbol.name === "main") {
              lenses.push(
                new vscode.CodeLens(
                  new vscode.Range(symbol.selectionRange.start.line, 0, symbol.selectionRange.end.line, 0),
                  { title: "Run", command: "YCPL.runFunction", arguments: [document.uri.toString()] }
                )
              );
            }
          }
          for (const test of discoverTests(document.uri.toString(), document.getText())) {
            lenses.push(
              new vscode.CodeLens(new vscode.Range(test.line, 0, test.line, 0), {
                title: "Run Test",
                command: "YCPL.testFunction",
                arguments: [document.uri.toString(), test.line]
              })
            );
          }
          return lenses;
        }
      }
    )
  );
  context.subscriptions.push(
    vscode.workspace.onWillSaveTextDocument((event) => {
      if (
        event.document.languageId === "ycpl" &&
        vscode.workspace
          .getConfiguration("YCPL", event.document.uri)
          .get<boolean>("organizeImportsOnSave", false)
      ) {
        event.waitUntil(Promise.resolve(importEdits(event.document)));
      }
    })
  );
  return testing;
}

function importEdits(document: vscode.TextDocument): vscode.TextEdit[] {
  const parsed = new YcplParser().parse(document.uri.toString(), document.version, document.getText());
  return organizeImports(parsed).map((edit) =>
    vscode.TextEdit.replace(
      new vscode.Range(
        edit.range.start.line,
        edit.range.start.character,
        edit.range.end.line,
        edit.range.end.character
      ),
      edit.newText
    )
  );
}

function activeDocument(): vscode.TextDocument {
  const document = vscode.window.activeTextEditor?.document;
  if (!document || document.languageId !== "ycpl" || document.uri.scheme !== "file")
    throw new Error("Open a YCPL source file first.");
  return document;
}
