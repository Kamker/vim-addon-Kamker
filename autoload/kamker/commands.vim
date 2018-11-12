" Commands {{{1

function! kamker#commands#load()
	" TODO
endfunction


" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Revert with: ":delcommand DiffOrig".
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
command! -nargs=0 RemoveTrailingWhiteSpace call CleanExtraSpaces()

command! -nargs=1 TJump call <sid>SelectTag(<f-args>)
command! -nargs=0 SelectBuffer exe 'b '.matchstr(tlib#input#List('s', 'select buffer', tlib#cmd#OutputAsList('ls')), '^\s*\zs\d\+\ze')
command! -nargs=* -complete=file -bang Es call <sid>Es(!empty('<bang>'), [<f-args>])
command! -nargs=? -range -bang -complete=customlist,<sid>CompleteMReplaceCommand MReplace <line1>,<line2>call MReplace(empty('<bang>'), <q-args>)

" Don't close window, when deleting a buffer
command! Bclose call <sid>BufcloseCloseIt()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:Es(flag, args)
	let f = tlib#input#List('s', 'select file', split(<sid>FastGlob(a:flag, a:args), "\n"))
	if !empty(f) | exe 'e '.fnameescape(f) | endif
endfunction

function! s:FastGlob(flag, args)
	let cmd = "es /a-d -s"
	if !a:flag | let cmd .= " -n ".&history | endif
	if index(a:args, "-path") < 0
		let cmd .= " -path ".shellescape(getcwd())
	endif
	let cmd .= " ".join(map(a:args, 'v:val =~# "^[-/|!\"]" ? v:val : shellescape(v:val)'), " ")
	return iconv(system(cmd), "default", "utf-8")
endfunction

function! s:SelectTag(regex)
	let tagstr = tlib#input#List('s','select tag', map(taglist(a:regex), 'string([v:val.kind, v:val.filename, v:val.cmd])'))
	if empty(tagstr) | return | endif
	let tag = eval(tagstr)
	exec 'e '.fnameescape(tag[1])
	exec tag[2]
endfunction

function! <sid>BufcloseCloseIt()
	let l:currentBufNum = bufnr("%")
	let l:alternateBufNum = bufnr("#")

	if buflisted(l:alternateBufNum)
		buffer #
	else
		bnext
	endif

	if bufnr("%") == l:currentBufNum
		new
	endif

	if buflisted(l:currentBufNum)
		execute("bdelete! ".l:currentBufNum)
	endif
endfunction

let s:mreplace_command_history = []
function! MReplace(trim, command) range
	if empty(a:command)
		if empty(s:mreplace_command_history)
			echohl ErrorMsg
			echomsg "MReplace hasn't been called yet; no pattern to reuse!"
			echohl None | return
		endif
	else
		call insert(s:mreplace_command_history, a:command, 0)
	endif
	let command = s:mreplace_command_history[0]
	let sources = getline(a:firstline, a:lastline)
	let sources = a:trim ? map(sources, 'trim(v:val)') : sources
	silent! exec ":".a:firstline.",".a:lastline "d_"

	" Used to mark the position of the replacement
	let replace_tag = get(g:, 'mreplace_tag', '@<C-A><C-B>@')
	let replace_tag = eval('"'.escape(replace_tag, '\<"').'"')

	" Mark position
	let [reg_#0, reg_pat] = [@", @/]
	let [@/, i, n, ln] = [command, 0, len(sources), line('.')]
	while (i < n) && search(@/, "cW")
		s//\=replace_tag."\n"/ | let i += 1
	endwhile

	" Really replace
	let [@/, i, n] = [replace_tag.'\n', 0, i]
	exec ":".ln
	while (i < n) && search(@/, "cW")
		s//\=remove(sources, 0)/ | let i += 1
	endwhile

	" Recovery register
	let [@", @/] = [reg_#0, reg_pat]
endfunction

function! s:CompleteMReplaceCommand(argstart, cmdline, cursorpos)
	let cmdstart = '^\V'.escape(a:argstart, '\')
	return filter(s:mreplace_command_history, 'v:val =~# cmdstart')
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
finish "{{{1
===============================================================
" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
