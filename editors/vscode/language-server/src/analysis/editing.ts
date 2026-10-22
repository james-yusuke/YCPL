import {
  CodeActionKind,
  TextEdit,
  type CodeAction,
  type FormattingOptions,
  type Range
} from "vscode-languageserver/node";
import { scanLexical } from "./lexical.js";
import type { YcplDocument, YcplSymbol } from "./model.js";
import { offsetAt, rangeFromOffsets } from "./text.js";
import type { WorkspaceIndex } from "./workspaceIndex.js";

/** Indent only executable text; literal and comment contents remain byte-for-byte intact. */
export function formatSource(text: string, options: FormattingOptions): string {
  const { code, spans } = scanLexical(text);
  const lines = text.split(/\r?\n/);
  const unit = options.insertSpaces ? " ".repeat(Math.max(1, Math.min(16, options.tabSize))) : "\t";
  let offset = 0;
  let braces = 0;
  let parentheses = 0;
  let spanIndex = 0;
  const formatted = lines.map((line) => {
    const masked = code.slice(offset, offset + line.length);
    while (spanIndex < spans.length && spans[spanIndex].end <= offset) spanIndex += 1;
    const insideLiteral = spans[spanIndex]?.start < offset && offset < spans[spanIndex].end;
    let tailIndex = spanIndex;
    while (tailIndex < spans.length && spans[tailIndex].end <= offset + line.length) tailIndex += 1;
    const literalAtEnd =
      spans[tailIndex]?.start < offset + line.length && spans[tailIndex].end > offset + line.length;
    const closing = masked.trimStart().match(/^[}\])]+/)?.[0] ?? "";
    const closesBrace = [...closing].filter((c) => c === "}").length;
    const continuation = parentheses > 0 && !/^[)\]]/.test(masked.trimStart()) ? 1 : 0;
    const depth = Math.max(0, braces - closesBrace) + continuation;
    const content = literalAtEnd ? line.trimStart() : line.trim();
    const result = insideLiteral ? line : content ? unit.repeat(depth) + content : "";
    for (const char of masked) {
      if (char === "{") braces += 1;
      if (char === "}") braces = Math.max(0, braces - 1);
      if (char === "(" || char === "[") parentheses += 1;
      if (char === ")" || char === "]") parentheses = Math.max(0, parentheses - 1);
    }
    offset += line.length + (text.slice(offset + line.length, offset + line.length + 2) === "\r\n" ? 2 : 1);
    return result;
  });
  return formatted.join(text.includes("\r\n") ? "\r\n" : "\n");
}

/** Conservative import organization: preserve side-effect imports and attached comments. */
export function organizeImports(document: YcplDocument): TextEdit[] {
  const groups: Array<{
    start: number;
    end: number;
    imports: typeof document.imports;
  }> = [];
  for (const imported of document.imports) {
    const start = document.lineOffsets[imported.range.start.line];
    const end = document.lineOffsets[imported.range.end.line + 1] ?? document.text.length;
    const prefix = document.text.slice(
      start,
      offsetAt(document.text, document.lineOffsets, imported.range.start)
    );
    const suffix = document.text
      .slice(offsetAt(document.text, document.lineOffsets, imported.range.end), end)
      .trim();
    if (prefix.trim() || (suffix && !suffix.startsWith("//") && !suffix.startsWith("/*"))) continue;
    const previous = groups.at(-1);
    if (previous && /^\s*$/.test(document.text.slice(previous.end, start))) {
      previous.end = end;
      previous.imports.push(imported);
    } else {
      groups.push({ start, end, imports: [imported] });
    }
  }
  const code = document.code.split("");
  for (const imported of document.imports) {
    const start = offsetAt(document.text, document.lineOffsets, imported.range.start);
    const end = offsetAt(document.text, document.lineOffsets, imported.range.end);
    code.fill(" ", start, end);
  }
  const usedCode = code.join("");
  return groups.flatMap((group) => {
    const seen = new Set<string>();
    const entries = group.imports
      .filter((imported) => {
        const source = document.text.slice(
          document.lineOffsets[imported.range.start.line],
          document.lineOffsets[imported.range.end.line + 1] ?? document.text.length
        );
        // Comments can describe why a module is imported, including side effects.
        if (
          /\/\/|\/\*/.test(
            source.slice(
              offsetAt(document.text, document.lineOffsets, imported.range.end) -
                document.lineOffsets[imported.range.start.line]
            )
          )
        )
          return true;
        if (imported.alias && !new RegExp(`\\b${imported.alias}\\s*\\.`).test(usedCode)) return false;
        const key = `${imported.modulePath}:${imported.alias ?? ""}`;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      })
      .sort(
        (a, b) => a.modulePath.localeCompare(b.modulePath) || (a.alias ?? "").localeCompare(b.alias ?? "")
      );
    const newline = document.text.includes("\r\n") ? "\r\n" : "\n";
    const replacement =
      entries
        .map((entry) => {
          const start = document.lineOffsets[entry.range.start.line];
          const end = document.lineOffsets[entry.range.end.line + 1] ?? document.text.length;
          return document.text.slice(start, end).trimEnd();
        })
        .join(newline) +
      (entries.length && (group.end < document.text.length || document.text.endsWith("\n")) ? newline : "");
    if (replacement === document.text.slice(group.start, group.end)) return [];
    return [TextEdit.replace(rangeFromOffsets(document.lineOffsets, group.start, group.end), replacement)];
  });
}

export function inferredType(document: YcplDocument, symbol: YcplSymbol): string | undefined {
  if (symbol.typeName) return symbol.typeName;
  const start = offsetAt(document.text, document.lineOffsets, symbol.selectionRange.end);
  const rhs = document.text
    .slice(start)
    .match(/^\s*:=\s*([^\n;]+)/)?.[1]
    ?.trim();
  if (!rhs) return undefined;
  if (/^(true|false)$/.test(rhs)) return "bool";
  if (/^"(?:[^"\\]|\\.)*"$/.test(rhs) || /^`[^`]*`$/.test(rhs)) return "string";
  if (/^'(?:[^'\\]|\\.)'$/.test(rhs)) return "char";
  if (/^-?\d+\.\d+(?:[eE][+-]?\d+)?$/.test(rhs)) return "double";
  if (/^-?(?:\d+|0x[\da-f]+)\s*$/i.test(rhs)) return "i32";
  return rhs.match(/^((?:Vec|Map)<[^{}]+>|[A-Za-z_]\w*)\s*\{[^{}]*\}$/)?.[1];
}

/** Offer refactors only where moving an expression cannot reorder preceding evaluation. */
export function extractVariable(document: YcplDocument, range: Range): CodeAction[] {
  const start = offsetAt(document.text, document.lineOffsets, range.start);
  const end = offsetAt(document.text, document.lineOffsets, range.end);
  const selected = document.text.slice(start, end);
  const prefix = document.code.slice(document.lineOffsets[range.start.line], start);
  if (start === end || range.start.line !== range.end.line || !selected.trim()) return [];
  if (!/^\s*(?:return\s+|[A-Za-z_]\w*(?:\s*:\s*[^=]+)?\s*(?::=|=)\s*)$/.test(prefix)) return [];
  const selectedCode = scanLexical(selected).code;
  if (/[{};]/.test(selectedCode)) return [];
  const lineEnd = document.lineOffsets[range.start.line + 1] ?? document.text.length;
  const suffix = document.code.slice(end, lineEnd).trim();
  if (suffix && suffix !== ";") return [];
  const balanced: string[] = [];
  for (const char of selectedCode) {
    if (char === "(" || char === "[") balanced.push(char);
    if ((char === ")" || char === "]") && balanced.pop() !== (char === ")" ? "(" : "[")) return [];
  }
  if (balanced.length) return [];
  const names = new Set(document.symbols.map((symbol) => symbol.name));
  let name = "extracted";
  for (let i = 2; names.has(name); i += 1) name = `extracted${i}`;
  const indent = document.text.slice(document.lineOffsets[range.start.line], start).match(/^\s*/)?.[0] ?? "";
  return [
    {
      title: `Extract variable '${name}'`,
      kind: CodeActionKind.RefactorExtract,
      edit: {
        changes: {
          [document.uri]: [
            TextEdit.insert({ line: range.start.line, character: 0 }, `${indent}${name} := ${selected}\n`),
            TextEdit.replace(range, name)
          ]
        }
      }
    }
  ];
}

export function extractFunction(document: YcplDocument, range: Range, index: WorkspaceIndex): CodeAction[] {
  if (range.start.character !== 0 || range.end.character !== 0 || range.end.line <= range.start.line)
    return [];
  const start = offsetAt(document.text, document.lineOffsets, range.start);
  const end = offsetAt(document.text, document.lineOffsets, range.end);
  const source = document.text.slice(start, end);
  const code = document.code.slice(start, end);
  if (!code.trim() || /\b(?:return|break|continue|defer|fn)\b/.test(code)) return [];
  if (/^\s*(?:case|default|else)\b/.test(code)) return [];
  const delimiters: string[] = [];
  for (const char of code) {
    if (["(", "[", "{"].includes(char)) delimiters.push(char);
    else if (
      [")", "]", "}"].includes(char) &&
      delimiters.pop() !== ({ ")": "(", "]": "[", "}": "{" } as Record<string, string>)[char]
    )
      return [];
  }
  if (delimiters.length) return [];
  const enclosing = document.scopes.find(
    (scope) => scope.kind === "function" && start > scope.startOffset && end < scope.endOffset
  );
  if (!enclosing) return [];
  const inside = document.references.filter((reference) => {
    const at = offsetAt(document.text, document.lineOffsets, reference.range.start);
    return start <= at && at < end;
  });
  for (const symbol of document.symbols) {
    const at = offsetAt(document.text, document.lineOffsets, symbol.selectionRange.start);
    if (
      at >= start &&
      at < end &&
      index
        .findReferencesBySymbolId(symbol.id, false)
        .some(
          (reference) =>
            reference.uri !== document.uri ||
            offsetAt(document.text, document.lineOffsets, reference.range.start) >= end
        )
    )
      return [];
  }
  const captured = new Map<string, { symbol: YcplSymbol; type: string }>();
  const replacements: Array<{ start: number; end: number; text: string }> = [];
  for (const reference of inside) {
    const symbol = index.symbolById(reference.symbolId);
    if (
      !symbol ||
      symbol.uri !== document.uri ||
      !["variable", "parameter", "constant"].includes(symbol.category)
    )
      continue;
    if (symbol.scopeId === document.scopes.find((scope) => !scope.parentId)?.id) continue;
    const declared = offsetAt(document.text, document.lineOffsets, symbol.selectionRange.start);
    if (declared >= start && declared < end) continue;
    const type = inferredType(document, symbol)?.replace(/^owned\s+/, "");
    if (!type) return [];
    captured.set(symbol.id, { symbol, type });
    replacements.push({
      start: offsetAt(document.text, document.lineOffsets, reference.range.start) - start,
      end: offsetAt(document.text, document.lineOffsets, reference.range.end) - start,
      text: `(*${symbol.name})`
    });
  }
  let body = source;
  for (const edit of replacements.sort((a, b) => b.start - a.start))
    body = body.slice(0, edit.start) + edit.text + body.slice(edit.end);
  const symbols = new Set(document.symbols.map((symbol) => symbol.name));
  let name = "extracted_function";
  for (let n = 2; symbols.has(name); n += 1) name = `extracted_function${n}`;
  const parameters = [...captured.values()];
  const signature = parameters.map(({ symbol, type }) => `${symbol.name} *${type}`).join(", ");
  const arguments_ = parameters.map(({ symbol }) => `&${symbol.name}`).join(", ");
  const indent = source.match(/^\s*/)?.[0].replaceAll("\n", "") ?? "";
  const generated = formatSource(`fn ${name}(${signature}) {\n${body}}\n`, {
    tabSize: 4,
    insertSpaces: true
  });
  return [
    {
      title: "Extract function",
      kind: CodeActionKind.RefactorExtract,
      edit: {
        changes: {
          [document.uri]: [
            TextEdit.replace(range, `${indent}${name}(${arguments_})\n`),
            TextEdit.insert(
              rangeFromOffsets(document.lineOffsets, document.text.length, document.text.length).start,
              `\n${generated}`
            )
          ]
        }
      }
    }
  ];
}

export function inlineVariable(
  document: YcplDocument,
  symbol: YcplSymbol | undefined,
  index: WorkspaceIndex
): CodeAction[] {
  if (!symbol || symbol.category !== "variable" || symbol.typeName || symbol.uri !== document.uri) return [];
  const start = document.lineOffsets[symbol.selectionRange.start.line];
  const end = document.lineOffsets[symbol.selectionRange.start.line + 1] ?? document.text.length;
  const line = document.text.slice(start, end);
  const match = line.match(/^\s*[A-Za-z_]\w*\s*:=\s*(-?\d+(?:\.\d+)?|true|false)\s*(\/\/[^\n]*)?\s*$/);
  if (!match) return [];
  const references = index.findReferencesBySymbolId(symbol.id, false);
  if (
    !references.length ||
    references.some(
      (reference) =>
        reference.uri !== document.uri ||
        /^\s*(?:=(?!=)|[+*/%-]=|\+\+|--)/.test(
          document.code.slice(offsetAt(document.text, document.lineOffsets, reference.range.end))
        )
    )
  )
    return [];
  return [
    {
      title: `Inline '${symbol.name}'`,
      kind: CodeActionKind.RefactorInline,
      edit: {
        changes: {
          [document.uri]: [
            TextEdit.replace(
              rangeFromOffsets(document.lineOffsets, start, end),
              match[2] ? `${line.match(/^\s*/)?.[0] ?? ""}${match[2]}\n` : ""
            ),
            ...references.map((reference) => TextEdit.replace(reference.range, `(${match[1]})`))
          ]
        }
      }
    }
  ];
}

export function fillStruct(
  document: YcplDocument,
  range: Range,
  resolve: (name: string) => YcplSymbol[]
): CodeAction[] {
  const cursor = offsetAt(document.text, document.lineOffsets, range.start);
  const pattern = /\b([A-Za-z_]\w*)\s*\{\s*\}/g;
  for (const match of document.code.matchAll(pattern)) {
    if (cursor < match.index! || cursor > match.index! + match[0].length) continue;
    const symbols = resolve(match[1]);
    const type = symbols.find((symbol) => symbol.category === "struct" && symbol.name === match[1]);
    if (!type) return [];
    const fields = symbols.filter(
      (symbol) => symbol.category === "field" && symbol.containerName === type.name && symbol.uri === type.uri
    );
    const values = fields.map((field) => {
      const name = field.typeName?.replace(/^owned\s+/, "") ?? "";
      const value =
        name === "bool"
          ? "false"
          : /^(?:[iu]\d+|size|byte|char|float|double)$/.test(name)
            ? "0"
            : name === "string" || name.startsWith("*")
              ? "none"
              : undefined;
      return value === undefined ? undefined : `${field.name}: ${value}`;
    });
    if (!fields.length || values.some((value) => value === undefined)) return [];
    const start = match.index! + match[0].indexOf("{") + 1;
    if (document.text.slice(start, match.index! + match[0].length - 1).trim()) return [];
    return [
      {
        title: `Fill ${type.name} fields`,
        kind: CodeActionKind.RefactorRewrite,
        edit: {
          changes: {
            [document.uri]: [
              TextEdit.replace(
                rangeFromOffsets(document.lineOffsets, start, match.index! + match[0].length - 1),
                values.join(", ")
              )
            ]
          }
        }
      }
    ];
  }
  return [];
}
