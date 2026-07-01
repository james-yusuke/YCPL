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
  if l:prevnum == 0
    return 0
  endif

  let l:ind = indent(l:prevnum)
  let l:prevline = getline(l:prevnum)
  let l:line = getline(a:lnum)

  if l:prevline =~# '{\s*\($\|//\)' || l:prevline =~# '(\s*$' || l:prevline =~# '\[\s*$'
    let l:ind += shiftwidth()
  endif

  if l:line =~# '^\s*[})\]]'
    let l:ind -= shiftwidth()
  endif

  return max([l:ind, 0])
endfunction
