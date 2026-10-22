#!/usr/bin/env python3
"""Measure a batch of semantic-token requests, including process startup."""
import json
import os
import statistics
import subprocess
import sys
import time
from check_common_protocol import frame, parse_frames


def benchmark(server):
    source = "fn main() {\n" + "\n".join(
        f"    value{i} := {i}\n    value{i} = value{i} + 1" for i in range(100)
    ) + "\n}"
    uri = "file:///benchmark.yc"
    messages = [
        {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"capabilities": {}}},
        {"jsonrpc": "2.0", "method": "initialized", "params": {}},
        {"jsonrpc": "2.0", "method": "textDocument/didOpen", "params": {"textDocument": {
            "uri": uri, "languageId": "ycpl", "version": 1, "text": source,
        }}},
    ]
    for request_id in range(2, 22):
        messages.append({"jsonrpc": "2.0", "id": request_id, "method": "textDocument/semanticTokens/full",
                         "params": {"textDocument": {"uri": uri}}})
    messages.append({"jsonrpc": "2.0", "id": 22, "method": "shutdown", "params": None})
    payload = b"".join(frame(message) for message in messages)
    times = []
    for _ in range(7):
        start = time.perf_counter()
        result = subprocess.run([os.path.abspath(server)], input=payload, capture_output=True, timeout=30, check=True)
        times.append((time.perf_counter() - start) * 1000)
        responses = {message["id"]: message for message in parse_frames(result.stdout) if "id" in message}
        assert len(responses) == 22
        assert all(responses[i]["result"]["data"] for i in range(2, 22))
    return {"server": server, "requests": 20, "medianBatchMs": statistics.median(times), "batchMs": times}


if __name__ == "__main__":
    for server in sys.argv[1:]:
        print(json.dumps(benchmark(server)))
