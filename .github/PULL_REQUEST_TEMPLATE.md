## Summary

<!-- Describe what this pull request changes and why. -->

## Area

- [ ] Bootstrap C++ compiler
- [ ] YCPL compiler
- [ ] Runtime or standard library
- [ ] Build, CI, or packaging
- [ ] VS Code extension or language server
- [ ] Documentation

## Validation

<!-- Check the commands that you ran. If a command was not relevant, leave it unchecked. -->

- [ ] `bazel build //...`
- [ ] `bazel test //:examples_test //:lsp_protocol_test //:ycc_ycpl_test //:self_host_stage_test`
- [ ] `cmake -S . -B /tmp/ycpl-cmake-check`
- [ ] `cmake --build /tmp/ycpl-cmake-check`
- [ ] `npm run check --prefix editors/vscode/extension`
- [ ] `npm run check --prefix editors/vscode/language-server`
- [ ] `git diff --check`

## Notes

- [ ] User-facing behavior changed and documentation was updated.
- [ ] Generated build artifacts are not included.
- [ ] This does not introduce system-wide LLVM, Bazel, or CMake assumptions.

<!-- Add any follow-up work, known limitations, or skipped checks here. -->
