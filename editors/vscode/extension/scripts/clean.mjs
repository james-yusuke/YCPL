import fs from "node:fs";

for (const directory of ["dist", "server"]) {
  fs.rmSync(new URL(`../${directory}`, import.meta.url), { recursive: true, force: true });
}
