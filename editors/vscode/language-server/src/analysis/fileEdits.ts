import * as path from "node:path";
import { URI } from "vscode-uri";
import { TextEdit, type FileRename, type WorkspaceEdit } from "vscode-languageserver/node";
import type { YcplDocument } from "./model.js";
import { offsetAt, rangeFromOffsets } from "./text.js";
import { importCandidates, projectRoot } from "./importPaths.js";

/** Update relative imports before file/directory moves, including imports inside moved files. */
export function renameFileImports(
  documents: YcplDocument[],
  renames: FileRename[],
  roots: string[]
): WorkspaceEdit {
  const moves = renames
    .filter((item) => URI.parse(item.oldUri).scheme === "file" && URI.parse(item.newUri).scheme === "file")
    .map((item) => ({ before: URI.parse(item.oldUri).fsPath, after: URI.parse(item.newUri).fsPath }))
    .sort((a, b) => b.before.length - a.before.length);
  const mapped = (file: string): string => {
    const move = moves.find(({ before }) => file === before || file.startsWith(before + path.sep));
    return move ? path.join(move.after, path.relative(move.before, file)) : file;
  };
  const known = new Set(
    documents
      .filter((document) => URI.parse(document.uri).scheme === "file")
      .map((document) => URI.parse(document.uri).fsPath)
  );
  for (const move of moves) if (move.before.endsWith(".yc")) known.add(move.before);
  const changes: Record<string, TextEdit[]> = {};
  for (const document of documents) {
    if (URI.parse(document.uri).scheme !== "file") continue;
    const before = URI.parse(document.uri).fsPath,
      after = mapped(before);
    for (const imported of document.imports) {
      const name = imported.modulePath;
      if (/^(?:std|c)\//.test(name) || path.isAbsolute(name)) continue;
      const relative = name.startsWith(".");
      const root = projectRoot(before, roots);
      if (!relative && !root) continue;
      const target = importCandidates(before, name, roots).find((file) => known.has(file));
      if (!target) continue;
      const newTarget = mapped(target);
      if (newTarget === target && before === after) continue;
      let value = path
        .relative(relative ? path.dirname(after) : mapped(root!), newTarget)
        .replaceAll(path.sep, "/");
      if (!relative) value = value.replace(/^src\//, "");
      if (!name.endsWith(".yc"))
        value = value.endsWith("/index.yc") ? value.slice(0, -9) : value.replace(/\.yc$/, "");
      if (relative && !value.startsWith(".")) value = "./" + value;
      const start = offsetAt(document.text, document.lineOffsets, imported.range.start);
      const end = offsetAt(document.text, document.lineOffsets, imported.range.end);
      const literal = document.text.slice(start, end).match(/"(?:[^"\\]|\\.)*"/);
      if (!literal) continue;
      const offset = start + literal.index!;
      (changes[document.uri] ??= []).push(
        TextEdit.replace(
          rangeFromOffsets(document.lineOffsets, offset, offset + literal[0].length),
          JSON.stringify(value)
        )
      );
    }
  }
  return { changes };
}
