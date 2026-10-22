if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal autoindent
setlocal indentexpr=YCPLIndent(v:lnum)
setlocal indentkeys=0{,0},0),:,!^F,o,O,e

let b:undo_indent = 'setlocal autoindent< indentexpr< indentkeys<'

if exists('*YCPLIndent')
  finish
endif

function! YCPLIndent(lnum) abort
  let l:prevnum = prevnonblank(a:lnum - 1)
  while l:prevnum > 0 && s:CodeLine(l:prevnum) !~# '\S'
    let l:prevnum = prevnonblank(l:prevnum - 1)
  endwhile
  if l:prevnum == 0
    return 0
  endif

  let l:ind = indent(l:prevnum)
  let l:prevline = s:CodeLine(l:prevnum)
  let l:line = s:CodeLine(a:lnum)

  if l:prevline =~# '{\s*\($\|//\)' || l:prevline =~# '(\s*$' || l:prevline =~# '\[\s*$'
    let l:ind += shiftwidth()
  endif

  if l:line =~# '^\s*[})\]]'
    let l:ind -= shiftwidth()
  endif

  return max([l:ind, 0])
endfunction

" Braces in comments and literals must not change the following line's indent.
function! s:CodeLine(lnum) abort
  let l:line = getline(a:lnum)
  let l:code = ''
  for l:col in range(1, strlen(l:line))
    let l:group = synIDattr(synID(a:lnum, l:col, 1), 'name')
    let l:code .= l:group =~# 'ycpl\%(.*Comment\|String\|RawString\|Char\|Escape\|Todo\)' ? ' ' : strpart(l:line, l:col - 1, 1)
  endfor
  return l:code
endfunction
