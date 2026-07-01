if exists('b:current_syntax')
  finish
endif

syn case match

syn keyword ycplKeyword module package import as pub extern intrinsic fn
syn keyword ycplKeyword struct enum interface const mut
syn keyword ycplConditional if else match switch
syn keyword ycplRepeat for in break continue
syn keyword ycplStatement return go defer select
syn keyword ycplOperator is or
syn keyword ycplConstant true false none
syn keyword ycplTodo TODO FIXME NOTE contained

syn keyword ycplType i32 i64 bool char byte string float double void size_t Type any

syn match ycplModuleName /\v<(module|package)\s+\zs[A-Za-z_][A-Za-z0-9_.]*/
syn match ycplImportPath /\vimport\s+\zs"[^"]+"/ contains=ycplString
syn match ycplFunction /\v<(pub\s+|extern\s+|intrinsic\s+)?fn\s+\zs[A-Za-z_][A-Za-z0-9_]*/
syn match ycplStruct /\v<(pub\s+)?struct\s+\zs[A-Z_][A-Za-z0-9_]*/
syn match ycplCall /\v<[A-Za-z_][A-Za-z0-9_]*\ze\s*\(/
syn match ycplQualifiedCall /\v<[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*\ze\s*\(/
syn match ycplNumber /\v<\d+(\.\d+)?([eE][+-]?\d+)?>/
syn match ycplNumber /\v<0x[0-9A-Fa-f]+>/
syn match ycplOperator /[-+*\/%=&|!<>:]\+/

syn region ycplString start=/"/ skip=/\\"/ end=/"/ contains=ycplEscape
syn region ycplRawString start=/`/ end=/`/
syn match ycplChar /'\([^'\\]\|\\.\)'/
syn match ycplEscape /\\\(n\|r\|t\|\\\|"\|'\|x[0-9A-Fa-f]\{2}\|u[0-9A-Fa-f]\{4}\|.\)/ contained

syn match ycplLineComment /\/\/.*$/ contains=ycplTodo
syn region ycplBlockComment start=/\/\*/ end=/\*\// contains=ycplTodo,ycplBlockComment

hi def link ycplKeyword Keyword
hi def link ycplConditional Conditional
hi def link ycplRepeat Repeat
hi def link ycplStatement Statement
hi def link ycplOperator Operator
hi def link ycplConstant Constant
hi def link ycplTodo Todo
hi def link ycplType Type
hi def link ycplModuleName Identifier
hi def link ycplImportPath String
hi def link ycplFunction Function
hi def link ycplStruct Structure
hi def link ycplCall Function
hi def link ycplQualifiedCall Function
hi def link ycplNumber Number
hi def link ycplString String
hi def link ycplRawString String
hi def link ycplChar Character
hi def link ycplEscape SpecialChar
hi def link ycplLineComment Comment
hi def link ycplBlockComment Comment

let b:current_syntax = 'ycpl'
