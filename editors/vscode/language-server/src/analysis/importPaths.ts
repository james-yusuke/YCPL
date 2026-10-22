import * as path from "node:path";

/** Use the most specific configured project when workspaces contain one another. */
export function projectRoot(file: string, roots: readonly string[]): string | undefined {
  return roots
    .filter((root) => file === root || file.startsWith(root + path.sep))
    .sort((a, b) => b.length - a.length)[0];
}

/** Mirror project import_path: src/ is optional and directory entries use index.yc. */
export function importCandidates(file: string, name: string, roots: readonly string[]): string[] {
  const root = projectRoot(file, roots);
  const bases =
    name.startsWith(".") || path.isAbsolute(name)
      ? [path.resolve(path.dirname(file), name)]
      : root
        ? [path.resolve(root, name), path.resolve(root, "src", name)]
        : [path.resolve(path.dirname(file), name)];
  return [...new Set(bases.flatMap((base) => [base, base + ".yc", path.join(base, "index.yc")]))];
}
