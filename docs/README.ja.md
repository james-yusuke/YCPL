# YCPL ドキュメント

[English](README.en.md) | [Repository README](../README-JA.md)

この docs は、現在のコンパイラが意図して対応している構文とツールチェーンを
まとめています。YCPLソースの拡張子は`.yc`です。標準の`ycc`はセルフホスト済みで、
C++実装はseed/reference用の`ycc-bootstrap`として残しています。

```text
docs/
├─ README.en.md      英語 index
├─ README.ja.md      日本語 index
├─ language.*.md     構文、型、文、式
├─ projects.*.md     YCPL.json、import、公開範囲
├─ stdlib.*.md       std/* ソースモジュール
└─ status.*.md       安定、実験中、予約済み機能
```

| 入口 | 内容 |
|---|---|
| [言語構文](language.ja.md) | 構文、型、文、式 |
| [プロジェクトとモジュール](projects.ja.md) | `YCPL.json`、import、公開範囲 |
| [標準ライブラリ](stdlib.ja.md) | `std/*` ソースモジュールと intrinsic bridge |
| [実装状況](status.ja.md) | 安定、実験中、予約済み機能 |
| [YCPL LSP](../tools/lsp/README.md) | エディタプロトコル対応 |

```text
ここに載っている      -> 現在の examples で対象
載っていない          -> 未対応または予約扱い
experimental          -> 互換性なしで変わる可能性あり
```
