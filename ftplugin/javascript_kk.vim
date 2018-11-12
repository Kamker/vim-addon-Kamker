setlocal fen
setlocal nocindent

imap <c-t> $log();<esc>hi
imap <c-a> alert();<esc>hi

inoremap <buffer> $r return
inoremap <buffer> $f // --- PH<esc>FP2xi

setlocal foldmethod=syntax
setlocal foldlevelstart=1
syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

function! FoldText()
  return substitute(getline(v:foldstart), '{.*', '{...}', '')
endfunction
setlocal foldtext=FoldText()
