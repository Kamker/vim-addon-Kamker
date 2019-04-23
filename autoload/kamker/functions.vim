" Functions {{{1

function! kamker#functions#load()
	" TODO
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Delete trailing white space on save, useful for some filetypes ;)
" No more than two blank lines
fun! CleanExtraSpaces()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	silent! %s/\s\+$//e
	silent! %s/\r\n\?/\r/ge
	silent! %s/^\n\n\+$/\r/e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfun

function! CmdLine(str)
	call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
	let l:saved_reg = @"
	execute "normal! vgvy"

	let l:pattern = escape(@", "\\/.*'$^~[]")
	let l:pattern = substitute(l:pattern, "\n$\\?", "\\\\n", "g")

	if a:direction == 'gv'
		call CmdLine('Ack "' . l:pattern . '" ' )
	elseif a:direction == 'replace'
		call CmdLine("%s" . '/'. l:pattern . '/')
	endif

	let @/ = l:pattern
	let @" = l:saved_reg
endfunction

function! CmdMoveOrDel(move)
	let [cmd, cmd_pos, char] = [getcmdline(), getcmdpos(), nr2char(getchar())]
	let skip = a:move ? strlen(char) : 0
	let cmd_edit = strpart(cmd, 0, cmd_pos - 1 - skip)
	let new_pos = strridx(cmd_edit, char)
	if new_pos >= 0
		let cmd = a:move ? cmd : strpart(cmd, 0, new_pos).strpart(cmd, cmd_pos - 1)
		call setcmdpos(new_pos + 1 + skip)
	endif
	return cmd
endfunction

" Returns true if paste mode is enabled
function! HasPaste()
	return &paste ? "PASTE MODE  " : ""
endfunction

function! IsMapSeq(keys, mode)
	return !empty(MapOut(a:keys, a:mode))
endfunction

function! KeyRemapFlag(name, mode)
	if empty(maparg(a:name, a:mode)) | return "" | endif
	let t = MapOut(a:name, a:mode)[0]
	return matchstr(t, '\v^\a*\s*\S+\s+\zs.') == "*" ? "n" : "m"
endfunction

function! MapOut(keys, mode)
	let save_a = @a
	exec "redi @a | silent! ".a:mode."map | redi END"
	let output = split(@a, "\n")
	let @a = save_a
	let keys = eval('"'.escape(a:keys, '\<"').'"')
	return filter(output, 's:pick(v:val, keys)')
endfunction

function! s:pick(val, keys)
	let chars = matchstr(a:val, '\v^\a*\s*\zs\S+\ze.*$')
	let chars = eval('"'.escape(chars, '\<"').'"')
	return stridx(chars, a:keys) == 0
endfunction

" call GenerateUnicode(0x2500,0x2600)
function! GenerateUnicode(first, last)
  let i = a:first
  while i <= a:last
    if (i%256 == 0)
      $put ='----------------------------------------------------'
      $put ='     0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F '
      $put ='----------------------------------------------------'
    endif
    let c = printf('%04X ', i)
    for j in range(16)
      let c = c . nr2char(i) . ' '
      let i += 1
    endfor
    $put =c
  endwhile
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
finish "{{{1
===============================================================
" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
