import { type Position, Range } from "vscode-languageserver/node";
import type { WordAtPosition } from "./model.js";

/** Returns UTF-16 line start offsets for a document. */
export function computeLineOffsets(text: string): number[] {
  const offsets = [0];
  for (let i = 0; i < text.length; i += 1) {
    if (text.charCodeAt(i) === 10) {
      offsets.push(i + 1);
    }
  }
  return offsets;
}

/** Converts a document offset to an LSP position. */
export function positionAt(lineOffsets: number[], offset: number): Position {
  const clamped = Math.max(0, offset);
  let low = 0;
  let high = lineOffsets.length;
  while (low < high) {
    const mid = Math.floor((low + high) / 2);
    if (lineOffsets[mid] > clamped) {
      high = mid;
    } else {
      low = mid + 1;
    }
  }
  const line = Math.max(0, low - 1);
  return { line, character: clamped - lineOffsets[line] };
}

/** Converts an LSP position to a document offset. */
export function offsetAt(text: string, lineOffsets: number[], position: Position): number {
  if (position.line >= lineOffsets.length) {
    return text.length;
  }
  const lineStart = lineOffsets[position.line];
  const lineEnd = position.line + 1 < lineOffsets.length ? lineOffsets[position.line + 1] - 1 : text.length;
  return Math.max(lineStart, Math.min(lineStart + position.character, lineEnd));
}

/** Builds an LSP range from offsets. */
export function rangeFromOffsets(lineOffsets: number[], start: number, end: number): Range {
  return Range.create(positionAt(lineOffsets, start), positionAt(lineOffsets, end));
}

/** Returns true when the character is valid inside a YCPL identifier. */
export function isIdentifierChar(value: string): boolean {
  return /^[A-Za-z0-9_]$/.test(value);
}

/** Returns true when the character can start a YCPL identifier. */
export function isIdentifierStart(value: string): boolean {
  return /^[A-Za-z_]$/.test(value);
}

/** Finds the identifier under or directly before an LSP position. */
export function wordAtPosition(text: string, lineOffsets: number[], position: Position): WordAtPosition | undefined {
  const offset = offsetAt(text, lineOffsets, position);
  let start = offset;
  let end = offset;
  if (start > 0 && isIdentifierChar(text[start - 1] ?? "")) {
    start -= 1;
  }
  while (start > 0 && isIdentifierChar(text[start - 1] ?? "")) {
    start -= 1;
  }
  while (end < text.length && isIdentifierChar(text[end] ?? "")) {
    end += 1;
  }
  if (end <= start) {
    return undefined;
  }
  return {
    word: text.slice(start, end),
    range: rangeFromOffsets(lineOffsets, start, end),
    before: text.slice(Math.max(0, start - 32), start),
    after: text.slice(end, Math.min(text.length, end + 32))
  };
}

/** Returns text for a single line without the trailing newline. */
export function lineText(text: string, lineOffsets: number[], line: number): string {
  if (line < 0 || line >= lineOffsets.length) {
    return "";
  }
  const start = lineOffsets[line];
  const end = line + 1 < lineOffsets.length ? lineOffsets[line + 1] - 1 : text.length;
  return text.slice(start, end).replace(/\r$/, "");
}
