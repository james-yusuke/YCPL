#!/usr/bin/env python3
import json
import subprocess
import sys
import time


def make_msg(body):
    data = body.encode("utf-8")
    return b"Content-Length: " + str(len(data)).encode("ascii") + b"\r\n\r\n" + data


def parse_frames(data):
    frames = []
    offset = 0
    while offset < len(data):
        header_end = data.find(b"\r\n\r\n", offset)
        if header_end < 0:
            raise AssertionError(f"incomplete LSP header at byte {offset}")

        header = data[offset:header_end].decode("ascii")
        length = None
        for line in header.split("\r\n"):
            if line.startswith("Content-Length:"):
                length = int(line.split(":", 1)[1].strip())

        if length is None:
            raise AssertionError(f"missing Content-Length at byte {offset}")

        body_start = header_end + 4
        body_end = body_start + length
        body = data[body_start:body_end]
        if len(body) != length:
            raise AssertionError(f"declared length {length}, actual {len(body)}")

        frames.append((body.decode("utf-8"), json.loads(body)))
        offset = body_end

    return frames


def run_server(binary, chunks):
    proc = subprocess.Popen(
        [binary],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    for chunk in chunks:
        proc.stdin.write(chunk)
        proc.stdin.flush()
        time.sleep(0.02)
    proc.stdin.close()
    stdout = proc.stdout.read()
    stderr = proc.stderr.read()
    status = proc.wait()
    if status != 0:
        raise AssertionError(f"server exited with {status}: {stderr.decode(errors='replace')}")
    return parse_frames(stdout)


def assert_any(frames, predicate, label):
    for raw, obj in frames:
        if predicate(raw, obj):
            return
    raise AssertionError(f"missing expected frame: {label}\nframes={frames!r}")


TOKEN_TYPES = [
    "namespace",
    "type",
    "function",
    "variable",
    "property",
    "keyword",
    "string",
    "number",
    "operator",
    "comment",
]


def decode_semantic_types(data):
    line = 0
    character = 0
    decoded = []
    for offset in range(0, len(data), 5):
        delta_line, delta_char, length, token_type, modifiers = data[offset:offset + 5]
        if delta_line == 0:
            character += delta_char
        else:
            line += delta_line
            character = delta_char
        decoded.append({
            "line": line,
            "character": character,
            "length": length,
            "type": TOKEN_TYPES[token_type],
            "modifiers": modifiers,
        })
    return decoded


def case(binary, name, chunks, predicate, label):
    frames = run_server(binary, chunks)
    assert_any(frames, predicate, label)
    print(f"  {name}... PASS")


def main():
    if len(sys.argv) != 2:
        print("usage: check_protocol.py /path/to/YCPL-lsp", file=sys.stderr)
        return 2

    binary = sys.argv[1]
    initialize = make_msg('{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}')
    completion = make_msg('{"jsonrpc":"2.0","id":2,"method":"textDocument/completion","params":{}}')
    hover = make_msg('{"jsonrpc":"2.0","id":3,"method":"textDocument/hover","params":{}}')
    shutdown = make_msg('{"jsonrpc":"2.0","id":5,"method":"shutdown","params":null}')
    did_open = make_msg('{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///main.yc","text":"fn main(){return 0}"}}}')
    did_open_multiline = make_msg('{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///main.yc","text":"fn main() {\\n    return 0\\n}"}}}')
    document_symbol = make_msg('{"jsonrpc":"2.0","id":4,"method":"textDocument/documentSymbol","params":{"textDocument":{"uri":"file:///main.yc"}}}')
    semantic_tokens = make_msg('{"jsonrpc":"2.0","id":6,"method":"textDocument/semanticTokens/full","params":{"textDocument":{"uri":"file:///main.yc"}}}')
    formatting = make_msg('{"jsonrpc":"2.0","id":7,"method":"textDocument/formatting","params":{"textDocument":{"uri":"file:///main.yc"},"options":{"tabSize":4,"insertSpaces":true}}}')
    range_formatting = make_msg('{"jsonrpc":"2.0","id":8,"method":"textDocument/rangeFormatting","params":{"textDocument":{"uri":"file:///main.yc"},"range":{"start":{"line":0,"character":0},"end":{"line":0,"character":19}},"options":{"tabSize":4,"insertSpaces":true}}}')
    folding = make_msg('{"jsonrpc":"2.0","id":9,"method":"textDocument/foldingRange","params":{"textDocument":{"uri":"file:///main.yc"}}}')
    signature = make_msg('{"jsonrpc":"2.0","id":10,"method":"textDocument/signatureHelp","params":{"textDocument":{"uri":"file:///main.yc"},"position":{"line":0,"character":12}}}')
    bad_open = make_msg('{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///bad.yc","text":"fn main() { missing_brace"}}}')
    direct_open = make_msg('{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///direct.yc","text":"import \\"std/fmt\\"\\nprintln(\\"bad\\")"}}}')
    bad_import = make_msg('{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///import.yc","text":"import \\"std/fmt\\" as\\nfn main() {\\n}"}}}')
    did_close = make_msg('{"jsonrpc":"2.0","method":"textDocument/didClose","params":{"textDocument":{"uri":"file:///bad.yc"}}}')
    rich_source = "\n".join([
        'import "std/fmt" as fmt',
        "// semantic color sample",
        "struct Point {",
        "    x i32",
        "}",
        "fn helper(value i32) i32 {",
        "    value += 1",
        "    return value",
        "}",
        "fn main() i32 {",
        "    total := helper(41)",
        "    p := Point{x: total}",
        "    p.x += 1",
        "    fmt.println(total)",
        "    return total",
        "}",
    ])
    rich_open = make_msg(json.dumps({
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {"textDocument": {"uri": "file:///rich.yc", "text": rich_source}},
    }, separators=(",", ":")))
    rich_symbols = make_msg('{"jsonrpc":"2.0","id":11,"method":"textDocument/documentSymbol","params":{"textDocument":{"uri":"file:///rich.yc"}}}')
    rich_semantic_tokens = make_msg('{"jsonrpc":"2.0","id":12,"method":"textDocument/semanticTokens/full","params":{"textDocument":{"uri":"file:///rich.yc"}}}')
    definition = make_msg('{"jsonrpc":"2.0","id":13,"method":"textDocument/definition","params":{"textDocument":{"uri":"file:///rich.yc"},"position":{"line":10,"character":16}}}')
    references = make_msg('{"jsonrpc":"2.0","id":14,"method":"textDocument/references","params":{"textDocument":{"uri":"file:///rich.yc"},"position":{"line":13,"character":19},"context":{"includeDeclaration":true}}}')
    highlights = make_msg('{"jsonrpc":"2.0","id":15,"method":"textDocument/documentHighlight","params":{"textDocument":{"uri":"file:///rich.yc"},"position":{"line":13,"character":19}}}')
    rename = make_msg('{"jsonrpc":"2.0","id":16,"method":"textDocument/rename","params":{"textDocument":{"uri":"file:///rich.yc"},"position":{"line":13,"character":19},"newName":"sum"}}')
    cross_lib_source = "\n".join([
        "module lib",
        "struct Widget {",
        "    name string",
        "}",
        "fn compute(value i32) i32 {",
        "    return value",
        "}",
    ])
    cross_app_source = "\n".join([
        'import "lib" as lib',
        "fn main() i32 {",
        '    widget := Widget{name: "demo"}',
        "    total := compute(10)",
        "    other := compute(total)",
        "    return other",
        "}",
    ])
    cross_lib_open = make_msg(json.dumps({
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {"textDocument": {"uri": "file:///lib.yc", "text": cross_lib_source}},
    }, separators=(",", ":")))
    cross_app_open = make_msg(json.dumps({
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {"textDocument": {"uri": "file:///app.yc", "text": cross_app_source}},
    }, separators=(",", ":")))
    cross_definition = make_msg('{"jsonrpc":"2.0","id":17,"method":"textDocument/definition","params":{"textDocument":{"uri":"file:///app.yc"},"position":{"line":3,"character":15}}}')
    cross_declaration = make_msg('{"jsonrpc":"2.0","id":18,"method":"textDocument/declaration","params":{"textDocument":{"uri":"file:///app.yc"},"position":{"line":3,"character":15}}}')
    cross_type_definition = make_msg('{"jsonrpc":"2.0","id":19,"method":"textDocument/typeDefinition","params":{"textDocument":{"uri":"file:///app.yc"},"position":{"line":2,"character":7}}}')
    cross_references = make_msg('{"jsonrpc":"2.0","id":20,"method":"textDocument/references","params":{"textDocument":{"uri":"file:///app.yc"},"position":{"line":3,"character":15},"context":{"includeDeclaration":true}}}')
    cross_prepare_rename = make_msg('{"jsonrpc":"2.0","id":21,"method":"textDocument/prepareRename","params":{"textDocument":{"uri":"file:///app.yc"},"position":{"line":3,"character":5}}}')
    cross_rename = make_msg('{"jsonrpc":"2.0","id":22,"method":"textDocument/rename","params":{"textDocument":{"uri":"file:///app.yc"},"position":{"line":3,"character":15},"newName":"calculate"}}')
    workspace_symbol = make_msg('{"jsonrpc":"2.0","id":23,"method":"workspace/symbol","params":{"query":"comp"}}')
    selection_range = make_msg('{"jsonrpc":"2.0","id":24,"method":"textDocument/selectionRange","params":{"textDocument":{"uri":"file:///app.yc"},"positions":[{"line":4,"character":4}]}}')
    contextual_hover = make_msg('{"jsonrpc":"2.0","id":25,"method":"textDocument/hover","params":{"textDocument":{"uri":"file:///app.yc"},"position":{"line":2,"character":7}}}')

    print("YCPL LSP protocol tests")
    case(binary, "initialize", [initialize], lambda _raw, obj: "semanticTokensProvider" in obj.get("result", {}).get("capabilities", {}) and obj["result"]["capabilities"].get("definitionProvider") is True and obj["result"]["capabilities"].get("declarationProvider") is True and obj["result"]["capabilities"].get("typeDefinitionProvider") is True and obj["result"]["capabilities"].get("workspaceSymbolProvider") is True and obj["result"]["capabilities"].get("renameProvider", {}).get("prepareProvider") is True, "initialize rich capabilities")
    case(binary, "completion", [completion], lambda raw, _obj: '"label":"Vec"' in raw and '"std/utf8"' in raw and '"insertTextFormat":2' in raw, "managed and stdlib completion")
    case(binary, "hover", [hover], lambda raw, _obj: '"YCPL symbol"' in raw, "hover content")
    case(binary, "symbols", [did_open + document_symbol], lambda raw, _obj: '"name":"main"' in raw, "main documentSymbol")
    case(binary, "semantic_tokens", [did_open + semantic_tokens], lambda _raw, obj: len(obj.get("result", {}).get("data", [])) >= 10, "semantic token data")
    case(binary, "rich_symbols", [rich_open + rich_symbols], lambda raw, _obj: '"name":"Point"' in raw and '"name":"helper"' in raw and '"name":"main"' in raw, "multiple document symbols")
    case(binary, "rich_semantic_tokens", [rich_open + rich_semantic_tokens], lambda _raw, obj: {"namespace", "type", "function", "variable", "property", "keyword", "string", "number", "operator", "comment"}.issubset({token["type"] for token in decode_semantic_types(obj.get("result", {}).get("data", []))}), "rich semantic token classes")
    case(binary, "definition", [rich_open + definition], lambda _raw, obj: obj.get("result", {}).get("range", {}).get("start", {}).get("line") == 5 and obj["result"]["range"]["start"]["character"] == 3, "definition range for helper")
    case(binary, "references", [rich_open + references], lambda _raw, obj: len(obj.get("result", [])) >= 4, "references for total")
    case(binary, "document_highlight", [rich_open + highlights], lambda _raw, obj: len(obj.get("result", [])) >= 4 and obj["result"][0].get("kind") == 1, "document highlights for total")
    case(binary, "rename", [rich_open + rename], lambda _raw, obj: len(obj.get("result", {}).get("changes", {}).get("file:///rich.yc", [])) >= 4 and obj["result"]["changes"]["file:///rich.yc"][0].get("newText") == "sum", "rename edits for total")
    case(binary, "cross_file_definition", [cross_lib_open + cross_app_open + cross_definition], lambda _raw, obj: obj.get("result", {}).get("uri") == "file:///lib.yc" and obj["result"]["range"]["start"]["line"] == 4, "definition across open documents")
    case(binary, "cross_file_declaration", [cross_lib_open + cross_app_open + cross_declaration], lambda _raw, obj: obj.get("result", {}).get("uri") == "file:///lib.yc" and obj["result"]["range"]["start"]["line"] == 4, "declaration across open documents")
    case(binary, "type_definition", [cross_lib_open + cross_app_open + cross_type_definition], lambda _raw, obj: obj.get("result", {}).get("uri") == "file:///lib.yc" and obj["result"]["range"]["start"]["line"] == 1, "type definition for inferred struct variable")
    case(binary, "cross_file_references", [cross_lib_open + cross_app_open + cross_references], lambda _raw, obj: len(obj.get("result", [])) == 3 and any(item.get("uri") == "file:///lib.yc" for item in obj["result"]) and any(item.get("uri") == "file:///app.yc" for item in obj["result"]), "references across open documents")
    case(binary, "prepare_rename", [cross_app_open + cross_prepare_rename], lambda _raw, obj: obj.get("result", {}).get("start", {}).get("line") == 3 and obj["result"]["start"]["character"] == 4, "prepare rename word range")
    case(binary, "cross_file_rename", [cross_lib_open + cross_app_open + cross_rename], lambda _raw, obj: len(obj.get("result", {}).get("changes", {}).get("file:///lib.yc", [])) == 1 and len(obj["result"]["changes"].get("file:///app.yc", [])) == 2 and obj["result"]["changes"]["file:///app.yc"][0]["newText"] == "calculate", "rename across open documents")
    case(binary, "workspace_symbol", [cross_lib_open + cross_app_open + workspace_symbol], lambda _raw, obj: any(item.get("name") == "compute" and item.get("location", {}).get("uri") == "file:///lib.yc" for item in obj.get("result", [])), "workspace symbol query")
    case(binary, "selection_range", [cross_app_open + selection_range], lambda _raw, obj: len(obj.get("result", [])) == 1 and obj["result"][0]["range"]["start"]["line"] == 4 and obj["result"][0]["range"]["start"]["character"] == 4, "selection range for word")
    case(binary, "contextual_hover", [cross_lib_open + cross_app_open + contextual_hover], lambda raw, _obj: "Widget" in raw and "YCPL variable or field" in raw, "contextual hover")
    case(binary, "formatting", [did_open + formatting], lambda raw, _obj: '"newText":"fn main() {\\n    return 0\\n}\\n"' in raw, "formatted document text")
    case(binary, "range_formatting", [did_open + range_formatting], lambda raw, _obj: '"newText":"fn main() {\\n    return 0\\n}\\n"' in raw, "formatted range text")
    case(binary, "folding", [did_open_multiline + folding], lambda _raw, obj: len(obj.get("result", [])) == 1 and obj["result"][0]["startLine"] == 0, "folding range")
    case(binary, "signature_help", [signature], lambda raw, _obj: "fmt.println(value any)" in raw, "signature help")
    case(binary, "diagnostics", [bad_open], lambda raw, _obj: '"unbalanced brace"' in raw, "unbalanced brace diagnostic")
    case(binary, "direct_import_diagnostics", [direct_open], lambda raw, _obj: "imported std symbols must be called through their alias" in raw, "direct import diagnostic")
    case(binary, "bad_import_diagnostics", [bad_import], lambda raw, _obj: "malformed import declaration" in raw, "bad import diagnostic")
    case(binary, "did_close", [bad_open + did_close], lambda raw, _obj: '"uri":"file:///bad.yc","diagnostics":[]' in raw, "empty diagnostics after close")
    case(binary, "partial_header", [initialize[:9], initialize[9:25], initialize[25:]], lambda _raw, obj: "capabilities" in obj.get("result", {}), "partial header initialize")

    header_end = initialize.find(b"\r\n\r\n") + 4
    case(binary, "partial_body", [initialize[:header_end + 5], initialize[header_end + 5:]], lambda _raw, obj: "capabilities" in obj.get("result", {}), "partial body initialize")

    changes = [did_open]
    for index in range(100):
        text = f"fn main() {{\\n}}\\n// change {index}"
        body = json.dumps({
            "jsonrpc": "2.0",
            "method": "textDocument/didChange",
            "params": {
                "textDocument": {"uri": "file:///main.yc"},
                "contentChanges": [{"text": text}],
            },
        }, separators=(",", ":"))
        changes.append(make_msg(body))
    changes.append(document_symbol)
    case(binary, "did_change_stress", [b"".join(changes)], lambda raw, _obj: '"name":"main"' in raw, "documentSymbol after repeated didChange")
    case(binary, "shutdown", [shutdown], lambda raw, _obj: '"result":null' in raw, "shutdown result")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
