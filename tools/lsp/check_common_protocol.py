#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import time


def frame(message):
    body = json.dumps(message, separators=(",", ":")).encode("utf-8")
    return b"Content-Length: " + str(len(body)).encode("ascii") + b"\r\n\r\n" + body


def parse_frames(data):
    messages = []
    while data:
        header_end = data.find(b"\r\n\r\n")
        if header_end < 0:
            raise AssertionError("incomplete protocol header")
        header = data[:header_end].decode("ascii")
        length = int(next(line for line in header.split("\r\n") if line.lower().startswith("content-length:")).split(":", 1)[1])
        start = header_end + 4
        end = start + length
        messages.append(json.loads(data[start:end]))
        data = data[end:]
    return messages


def request(request_id, method, params):
    return frame({"jsonrpc": "2.0", "id": request_id, "method": method, "params": params})


def notify(method, params):
    return frame({"jsonrpc": "2.0", "method": method, "params": params})


def main():
    if len(sys.argv) != 2:
        print("usage: check_common_protocol.py /path/to/server-or-server.js", file=sys.stderr)
        return 2

    server = os.path.abspath(sys.argv[1])
    command = [sys.executable, server] if server.endswith(".py") else ([os.environ.get("NODE", "node"), server, "--stdio"] if server.endswith((".js", ".cjs")) else [server])
    uri = "file:///common.yc"
    source = "\n".join([
        "fn helper(value i32) i32 {",
        "    return value",
        "}",
        "fn main() i32 {",
        "    result := helper(42)",
        "    return result",
        "}",
    ])
    text_document = {"uri": uri}
    call_item = {
        "name": "helper",
        "kind": 12,
        "uri": uri,
        "range": {"start": {"line": 0, "character": 3}, "end": {"line": 0, "character": 9}},
        "selectionRange": {"start": {"line": 0, "character": 3}, "end": {"line": 0, "character": 9}},
        "data": "helper",
    }
    main_item = {
        "name": "main",
        "kind": 12,
        "uri": uri,
        "range": {"start": {"line": 3, "character": 3}, "end": {"line": 3, "character": 7}},
        "selectionRange": {"start": {"line": 3, "character": 3}, "end": {"line": 3, "character": 7}},
        "data": "main",
    }
    chunks = [
        request(1, "initialize", {"rootUri": "file:///", "capabilities": {}}),
        notify("initialized", {}),
        notify("textDocument/didOpen", {"textDocument": {"uri": uri, "languageId": "ycpl", "version": 1, "text": source}}),
        request(2, "textDocument/completion", {"textDocument": text_document, "position": {"line": 4, "character": 8}}),
        request(3, "textDocument/implementation", {"textDocument": text_document, "position": {"line": 4, "character": 20}}),
        request(4, "textDocument/inlayHint", {"textDocument": text_document, "range": {"start": {"line": 0, "character": 0}, "end": {"line": 7, "character": 0}}}),
        request(5, "textDocument/codeAction", {
            "textDocument": text_document,
            "range": {"start": {"line": 0, "character": 0}, "end": {"line": 0, "character": 1}},
            "context": {"diagnostics": [{
                "range": {"start": {"line": 0, "character": 0}, "end": {"line": 0, "character": 1}},
                "message": "import is not used",
                "severity": 2,
            }]},
        }),
        request(6, "textDocument/codeLens", {"textDocument": text_document}),
        request(7, "textDocument/prepareCallHierarchy", {"textDocument": text_document, "position": {"line": 0, "character": 5}}),
        request(8, "callHierarchy/incomingCalls", {"item": call_item}),
        request(9, "callHierarchy/outgoingCalls", {"item": main_item}),
        request(10, "shutdown", None),
        notify("exit", None),
    ]

    process = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for chunk in chunks:
        try:
            process.stdin.write(chunk)
            process.stdin.flush()
        except BrokenPipeError:
            break
        time.sleep(0.02)
    try:
        process.stdin.close()
    except BrokenPipeError:
        pass
    stdout = process.stdout.read()
    stderr = process.stderr.read()
    returncode = process.wait(timeout=15)
    if b"[DEP0169]" in stderr or b"url.parse()" in stderr:
        raise AssertionError(f"deprecated URL API warning: {stderr.decode('utf-8', errors='replace')}")
    if returncode != 0:
        raise AssertionError(f"server exited with {returncode}: {stderr.decode('utf-8', errors='replace')}")
    responses = {message["id"]: message for message in parse_frames(stdout) if "id" in message}
    capabilities = responses[1]["result"]["capabilities"]
    for capability in [
        "completionProvider", "implementationProvider", "inlayHintProvider",
        "codeActionProvider", "codeLensProvider", "callHierarchyProvider",
    ]:
        assert capabilities.get(capability), capability
    assert responses[2]["result"] is not None
    assert responses[3]["result"] is not None
    assert len(responses[4]["result"]) >= 1
    assert len(responses[5]["result"]) >= 1
    assert len(responses[6]["result"]) >= 1
    assert len(responses[7]["result"]) >= 1
    assert len(responses[8]["result"]) >= 1
    assert len(responses[9]["result"]) >= 1
    print(f"common LSP capabilities verified: {os.path.basename(server)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
