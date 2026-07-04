import type { Diagnostic, TextEdit } from "vscode-languageserver/node.js";
import type { YcplDocument } from "../analysis/model.js";

/**
 * Boundary to the YCPL compiler frontend. Implementations can delegate parsing,
 * type checking, formatting, and diagnostics to the real compiler without
 * changing LSP providers.
 */
export interface CompilerBridge {
  /** Returns compiler diagnostics for a parsed YCPL document. */
  diagnostics(document: YcplDocument): Promise<Diagnostic[]>;

  /** Returns formatter edits for a full document or selection. */
  format(document: YcplDocument, range?: import("vscode-languageserver/node.js").Range): Promise<TextEdit[] | undefined>;
}

/** Fallback bridge used until the compiler exposes a stable editor API. */
export class NullCompilerBridge implements CompilerBridge {
  async diagnostics(): Promise<Diagnostic[]> {
    return [];
  }

  async format(): Promise<TextEdit[] | undefined> {
    return undefined;
  }
}
