let python_highlight_all = 1
syn keyword pythonDecorator True None False self

map <buffer> F :set foldmethod=indent<cr>

inoremap <buffer> $r return
inoremap <buffer> $i import
inoremap <buffer> $p print
inoremap <buffer> $f # --- <esc>a
map <buffer> <leader>1 /class
map <buffer> <leader>2 /def
map <buffer> <leader>C ?class
map <buffer> <leader>D ?def
set cindent
set cinkeys-=0#
set indentkeys-=0#
