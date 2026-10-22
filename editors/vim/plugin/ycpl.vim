if exists('g:loaded_ycpl')
  finish
endif
let g:loaded_ycpl = 1

augroup ycpl_lsp
  autocmd!
  autocmd User lsp_setup call ycpl#register_lsp()
augroup END
