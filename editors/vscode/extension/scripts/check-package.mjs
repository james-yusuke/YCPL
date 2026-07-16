import assert from "node:assert/strict";
import fs from "node:fs";
import { execFileSync } from "node:child_process";

const vsix = process.argv[2];
assert.ok(vsix && fs.existsSync(vsix), `Missing VSIX: ${vsix ?? ""}`);
const listing = execFileSync("unzip", ["-Z1", vsix], { encoding: "utf8" });
for (const required of [
  "extension/dist/extension.cjs",
  "extension/server/server.cjs",
  "extension/syntaxes/ycpl.tmLanguage.json",
  "extension/snippets/ycpl.code-snippets",
  "extension/language-configuration.json"
]) {
  assert.match(listing, new RegExp(`^${required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}$`, "m"));
}
assert.doesNotMatch(listing, /node_modules|src\/|test\/|scripts\/|\.map$/m);
for (const bundled of ["extension/dist/extension.cjs", "extension/server/server.cjs"]) {
  const contents = execFileSync("unzip", ["-p", vsix, bundled], { encoding: "utf8" });
  assert.doesNotMatch(contents, /\burl\.parse\s*\(/, `${bundled} must use the WHATWG URL API`);
}
console.log(`Verified packaged YCPL extension: ${vsix}`);
