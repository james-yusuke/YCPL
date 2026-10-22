export interface LexicalSpan {
  start: number;
  end: number;
  kind: "comment" | "string";
}

/** Mask literals and nested comments once, retaining UTF-16 offsets and lines. */
export function scanLexical(text: string): {
  code: string;
  spans: LexicalSpan[];
} {
  const spans: LexicalSpan[] = [];
  const parts: string[] = [];
  let copied = 0;
  let i = 0;
  while (i < text.length) {
    const start = i;
    let kind: LexicalSpan["kind"];
    if (text.startsWith("//", i)) {
      kind = "comment";
      const end = text.indexOf("\n", i + 2);
      i = end < 0 ? text.length : end;
    } else if (text.startsWith("/*", i)) {
      kind = "comment";
      let depth = 1;
      i += 2;
      while (i < text.length && depth > 0) {
        if (text.startsWith("/*", i)) {
          depth += 1;
          i += 2;
        } else if (text.startsWith("*/", i)) {
          depth -= 1;
          i += 2;
        } else {
          i += 1;
        }
      }
    } else if (text[i] === '"' || text[i] === "'" || text[i] === "`") {
      kind = "string";
      const quote = text[i++];
      while (i < text.length) {
        if (text[i] === "\\" && quote !== "`") {
          i = Math.min(text.length, i + 2);
        } else if (text[i++] === quote) {
          break;
        }
      }
    } else {
      i += 1;
      continue;
    }
    parts.push(text.slice(copied, start), text.slice(start, i).replace(/[^\r\n]/g, " "));
    spans.push({ start, end: i, kind });
    copied = i;
  }
  parts.push(text.slice(copied));
  return { code: parts.join(""), spans };
}
