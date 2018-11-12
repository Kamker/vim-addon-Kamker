" just for scratch plugin
if expand('<afile>') == '__Scratch__'
  inoremap <silent><buffer><bar> <bar><c-r>=<sid>align()<cr><bs>
endif

function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
    if getline('.')[0:col('.')] =~# '|\s*$' | call feedkeys("\<right>", "n") | endif
  endif
endfunction
