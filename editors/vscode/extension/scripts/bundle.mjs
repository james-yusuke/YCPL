import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { build } from "esbuild";

const extensionRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const languageServerRoot = path.resolve(extensionRoot, "..", "language-server");

const modernUrlPlugin = {
  name: "modern-vscode-languageserver-url",
  setup(builder) {
    builder.onLoad(
      { filter: /vscode-languageserver[\\/]lib[\\/]node[\\/]files\.js$/ },
      async ({ path: sourcePath }) => {
        const original = await fs.readFile(sourcePath, "utf8");
        let contents = original
          .replace("const parsed = url.parse(uri);", "const parsed = new url.URL(uri);")
          .replace("!parsed.path", "!parsed.pathname")
          .replace("parsed.path.split(\"/\")", "parsed.pathname.split(\"/\")");
        if (original.includes("url.parse(uri)") && contents.includes("url.parse(uri)")) {
          throw new Error(`Could not replace deprecated url.parse() in ${sourcePath}`);
        }
        return { contents, loader: "js" };
      }
    );
  }
};

await build({
  entryPoints: [path.join(extensionRoot, "src", "extension.ts")],
  outfile: path.join(extensionRoot, "dist", "extension.cjs"),
  bundle: true,
  platform: "node",
  format: "cjs",
  target: "node20",
  external: ["vscode"],
  sourcemap: false,
  logLevel: "info"
});

// Keep the pure discovery/diagnostic helpers executable for the Node unit
// tests. This file is intentionally excluded from the VSIX.
await build({
  entryPoints: [path.join(extensionRoot, "src", "runtime.ts")],
  outfile: path.join(extensionRoot, "dist", "runtime.js"),
  bundle: true,
  platform: "node",
  format: "esm",
  target: "node20",
  sourcemap: false,
  logLevel: "info"
});

await build({
  entryPoints: [path.join(languageServerRoot, "src", "server.ts")],
  outfile: path.join(extensionRoot, "server", "server.cjs"),
  bundle: true,
  platform: "node",
  format: "cjs",
  target: "node20",
  sourcemap: false,
  plugins: [modernUrlPlugin],
  logLevel: "info"
});
