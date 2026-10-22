import type { SymbolReference } from "./model.js";
import { offsetAt } from "./text.js";

/** Public types/constants can be used without their import alias in YCPL. */
export function hasUnresolvedBareNames(
  code: string,
  lineOffsets: number[],
  references: SymbolReference[],
  aliases: (string | undefined)[]
): boolean {
  const importedAliases = new Set(aliases);
  return references.some(
    (reference) =>
      !reference.symbolId &&
      !(
        importedAliases.has(reference.name) &&
        /^\s*\./.test(code.slice(offsetAt(code, lineOffsets, reference.range.end)))
      ) &&
      !code
        .slice(0, offsetAt(code, lineOffsets, reference.range.start))
        .trimEnd()
        .endsWith(".")
  );
}
