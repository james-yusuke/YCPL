import test from "node:test";
import assert from "node:assert/strict";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const distRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const serverPath = path.join(distRoot, "src", "server.js");

test("language server initializes and answers completion over stdio", async () => {
  const client = new LspTestClient(serverPath);
  try {
    const init = await client.request("initialize", {
      processId: process.pid,
      rootUri: "file:///tmp/ycpl-test",
      capabilities: {},
      workspaceFolders: [{ uri: "file:///tmp/ycpl-test", name: "ycpl-test" }]
    });
    assert.equal(init.capabilities.hoverProvider, true);
    client.notify("initialized", {});
    client.notify("textDocument/didOpen", {
      textDocument: {
        uri: "file:///tmp/ycpl-test/main.yc",
        languageId: "ycpl",
        version: 1,
        text: "fn main() i32 {\n    ret\n}"
      }
    });
    const completion = await client.request("textDocument/completion", {
      textDocument: { uri: "file:///tmp/ycpl-test/main.yc" },
      position: { line: 1, character: 7 }
    });
    const items = Array.isArray(completion) ? completion : completion.items;
    assert.ok(items.some((item: { label: string }) => item.label === "return"));
    await client.request("shutdown", null);
    client.notify("exit", null);
  } finally {
    client.dispose();
  }
});

class LspTestClient {
  private readonly child: ChildProcessWithoutNullStreams;
  private nextId = 1;
  private buffer = Buffer.alloc(0);
  private stderr = "";
  private readonly pending = new Map<number, (value: any) => void>();

  constructor(server: string) {
    this.child = spawn(process.execPath, [server, "--stdio"], {
      stdio: ["pipe", "pipe", "pipe"]
    });
    this.child.stdout.on("data", (chunk: Buffer) => this.read(chunk));
    this.child.stderr.on("data", (chunk: Buffer) => {
      this.stderr += chunk.toString("utf8");
    });
  }

  request(method: string, params: unknown): Promise<any> {
    const id = this.nextId;
    this.nextId += 1;
    const message = { jsonrpc: "2.0", id, method, params };
    this.write(message);
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`Timed out waiting for ${method}. stderr: ${this.stderr}`));
      }, 5000);
      this.pending.set(id, (value) => {
        clearTimeout(timer);
        resolve(value);
      });
    });
  }

  notify(method: string, params: unknown): void {
    this.write({ jsonrpc: "2.0", method, params });
  }

  dispose(): void {
    this.child.kill();
  }

  private write(message: unknown): void {
    const body = Buffer.from(JSON.stringify(message), "utf8");
    this.child.stdin.write(`Content-Length: ${body.length}\r\n\r\n`);
    this.child.stdin.write(body);
  }

  private read(chunk: Buffer): void {
    this.buffer = Buffer.concat([this.buffer, chunk]);
    while (true) {
      const headerEnd = this.buffer.indexOf("\r\n\r\n");
      if (headerEnd < 0) {
        return;
      }
      const header = this.buffer.slice(0, headerEnd).toString("utf8");
      const lengthMatch = header.match(/Content-Length: (\d+)/i);
      if (!lengthMatch) {
        throw new Error(`Missing Content-Length header: ${header}`);
      }
      const length = Number(lengthMatch[1]);
      const bodyStart = headerEnd + 4;
      const bodyEnd = bodyStart + length;
      if (this.buffer.length < bodyEnd) {
        return;
      }
      const message = JSON.parse(this.buffer.slice(bodyStart, bodyEnd).toString("utf8"));
      this.buffer = this.buffer.slice(bodyEnd);
      if (typeof message.id === "number" && this.pending.has(message.id)) {
        const resolve = this.pending.get(message.id);
        this.pending.delete(message.id);
        resolve?.(message.result);
      }
    }
  }
}
