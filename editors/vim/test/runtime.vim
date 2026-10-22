set nocompatible
set runtimepath^=editors/vim
set runtimepath^=editors/vim/test/fixtures
filetype plugin indent on
syntax on
runtime plugin/ycpl.vim
new editor-test.yc
call setline(1, ['type Count = i32', 'switch value {', 'case 0 {', 'default {', 'values: Vec<Map<string, i32>> := Vec<i32>{}', 'is := 0b101', 'scope := 1', '/* outer /* inner */ fn hidden() {} */', 'fn main() {', 'value := "{"', 'value = 1 // }', '}'])
call assert_equal('ycpl', &filetype)
call assert_equal('// %s', &commentstring)
call assert_equal('ycplKeyword', synIDattr(synID(1, 1, 1), 'name'))
call assert_equal('ycplConditional', synIDattr(synID(3, 1, 1), 'name'))
call assert_equal('ycplConditional', synIDattr(synID(4, 1, 1), 'name'))
call assert_equal('ycplType', synIDattr(synID(5, 9, 1), 'name'))
call assert_equal('', synIDattr(synID(6, 1, 1), 'name'))
call assert_equal('ycplNumber', synIDattr(synID(6, 7, 1), 'name'))
call assert_equal('', synIDattr(synID(7, 1, 1), 'name'))
call assert_equal('ycplBlockComment', synIDattr(synID(8, 25, 1), 'name'))
%delete _
call setline(1, ['fn main() {', 'message := "{"', '// }', 'value := 1', 'if value { // note', 'value = 2', '}', '}'])
normal! gg=G
call assert_equal([0, 4, 4, 4, 4, 8, 4, 0], map(range(1, 8), 'indent(v:val)'))
let g:ycpl_lsp_command = ['/a path/YCPL-lsp', '--stdio']
call assert_equal(g:ycpl_lsp_command, ycpl#lsp_command())
doautocmd User lsp_setup
call assert_equal(['ycpl'], g:ycpl_test_server.allowlist)
call assert_equal(g:ycpl_lsp_command, g:ycpl_test_server.cmd({}))
unlet g:ycpl_test_server
let g:ycpl_lsp_enabled = 0
doautocmd User lsp_setup
call assert_false(exists('g:ycpl_test_server'))
unlet g:ycpl_lsp_enabled
unlet g:ycpl_lsp_command
if !empty(v:errors)
  call writefile(v:errors, '/dev/stderr')
  cquit
endif
qall!
