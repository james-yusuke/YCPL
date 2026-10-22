let s:repository = fnamemodify(expand('<sfile>:p'), ':h:h:h:h')

" Return an argv list, preserving spaces without shell interpolation.
function! ycpl#lsp_command() abort
  if exists('g:ycpl_lsp_command')
    return copy(g:ycpl_lsp_command)
  endif
  let l:native = s:repository . '/tools/lsp/build/YCPL-lsp'
  if executable(l:native)
    return [l:native]
  endif
  if executable('YCPL-lsp')
    return [exepath('YCPL-lsp')]
  endif
  let l:server = s:repository . '/editors/vscode/language-server/dist/src/server.js'
  if executable('node') && filereadable(l:server)
    return [exepath('node'), l:server, '--stdio']
  endif
  return []
endfunction

function! ycpl#register_lsp() abort
  if get(g:, 'ycpl_lsp_enabled', 1) && !empty(ycpl#lsp_command())
    call lsp#register_server({
          \ 'name': 'ycpl',
          \ 'cmd': {server_info -> ycpl#lsp_command()},
          \ 'allowlist': ['ycpl'],
          \ })
  endif
endfunction
