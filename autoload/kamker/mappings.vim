" Mappings {{{1

function! kamker#mappings#load()
	" TODO
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character(0 ~> g0).
map 0 ^
map <tab> %
" noremap! jj <esc>
nnoremap <silent><leader> :call <sid>ProcessMapleader(mapleader, "n")<cr>
xnoremap <silent><leader> :<c-u>call <sid>ProcessMapleader(mapleader, "x")<cr>
noremap <silent><leader><leader> ,
nnoremap <leader>h :h<space>
nnoremap <Leader>cd :lcd %:p:h<CR>:pwd<CR>

" Select the most recently modified rows.
nnoremap <leader>v V`]

" Generate a '=' line under the current line.
nnoremap <leader>1 yypVr=

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default.
nnoremap Y y$

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
" Revert with ":iunmap <C-U>".
inoremap <c-u> <c-g>u<c-u>

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search.
nnoremap <c-l> :nohl<cr><c-l>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Command mode related {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Smart mappings on the command line.
cnoremap <c-p> <up>
cnoremap <c-n> <down>
cnoremap << <c-\>eCmdMoveOrDel(0)<cr>
cnoremap <> <c-\>eCmdMoveOrDel(1)<cr>
cnoremap <: <c-\>e" ".matchstr(getcmdline(), '^\s*\S\+\s*\zs.*$')<cr><c-b>

" Expand on the command line.
cnoremap >~ <c-r>=fnameescape(expand('~'))<cr>
cnoremap >. <c-r>=fnameescape(getcwd())<cr>
cnoremap >% <c-r>=fnameescape(expand('%:p:h'))<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Visual mode related {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann.
xnoremap <silent> * :<c-u>call VisualSelection('', '')<cr>/<c-r>=@/<cr><cr>
xnoremap <silent> # :<c-u>call VisualSelection('', '')<cr>?<c-r>=@/<cr><cr>
xnoremap <silent> <leader>r :call VisualSelection('replace', '')<cr>
xnoremap <leader>s  :s///g<left><left>
nnoremap <leader>s :%s///g<left><left>
xnoremap / /\v
nnoremap / /\v


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Like eclipse ide.
inoremap <s-cr> <esc>o

" like other editors
inoremap <c-z> <c-o>u

" Fast saving.
nnoremap <leader>w :w!<cr>

" Move a line of text using ALT+[jk] or Command+[jk] on mac.
nnoremap <m-j> mz:m+<cr>`z
nnoremap <m-k> mz:m-2<cr>`z
xnoremap <m-j> :m'>+<cr>`<my`>mzgv`yo`z
xnoremap <m-k> :m'<-2<cr>`>my`<mzgv`yo`z

" Fast editing and reloading of vimrc configs.
nnoremap <leader>ev <c-w><c-v><c-l>:e! $myvimrc<cr>
nnoremap <leader>ec :Es -path <c-r>=fnameescape(RootDir)<cr><bs> !\.git<cr>

" Remove the Windows ^M - when the encodings gets messed up.
nnoremap <leader>dm mmHmt:%s/<c-v><cr>//ge<cr>'tzt'm

" Make a copy and edit.
nnoremap <leader>co :%y<bar>vne<bar>set syntax=qf<cr>pggdd


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable <Up>, <Down>, <Left>, <Right>
for i in ["Up","Down","Left","Right"]
	exec 'noremap  <'.i.'> <nop>'
endfor

" m-X key jump to tab X
for i in range(1,8)
	exec 'noremap <m-'.i.'> '.i.'gt'
endfor

" Useful mappings for managing tabs
nnoremap <leader>tn :tabnew<cr>
nnoremap <leader>to :tabonly<cr>
nnoremap <leader>tc :tabclose<cr>

" Faster novigation in windows:
for i in ["h","j","k","l","q","o"]
	exec 'noremap <m-s-'.i.'> <c-w>'.i
endfor

" Close the current buffer
nnoremap <leader>bd :Bclose<cr>:tabclose<cr>gT
" Close all the buffers
nnoremap <leader>ba :bufdo bd<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Option switch {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle paste mode on and off
nnoremap <leader>ip :<c-u>setlocal paste!<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Parenthesis/bracket {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vnoremap $1 <esc>`>a)<esc>`<i(<esc>
" vnoremap $2 <esc>`>a]<esc>`<i[<esc>
" vnoremap $3 <esc>`>a}<esc>`<i{<esc>
" vnoremap $q <esc>`>a'<esc>`<i'<esc>
" vnoremap $e <esc>`>a"<esc>`<i"<esc>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Utilities {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Open file in chrome browser
nnoremap <silent> <leader>cv :silent!!cd /d %:p:h & cmd /cstart chrome "%:p:t"<cr>
vnoremap <silent> <leader>cv :<c-u>let _#0=@"<cr>gvy:silent!!cmd /cstart chrome <c-r>=escape(@", '%#<')<cr><cr>:let @"=_#0<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ProcessMapleader: adds the ability to correct an normal/visual mode mapping.
" Author: Hari Krishna Dara <hari_vim@yahoo.com> (Modified by kamker)
" Reads a normal mode mapping at the command line and executes it with the
" given prefix. Press <BS> to correct and <Esc> to cancel.
function! s:ProcessMapleader(prefix, mode)
	" Temporarily remove the mapping, otherwise, it will trigger itself
	let trigger = maparg(a:prefix, a:mode)
	if trigger == "" | return | endif
	exec a:mode."unmap ".a:prefix

	let clearline = "\r".repeat(" ", &columns -1)
	let mapCmd = a:prefix
	while 1
		if getchar(1) == 0
			echon clearline
			echon "\rEnter Map: ".mapCmd
		endif
		let char = getchar()
		if char == "\<BS>"
			let mapCmd = strcharpart(mapCmd, 0, strchars(mapCmd) - 1)
		else
			let [oldCmd, char] = [mapCmd, nr2char(char)]
			if char == "\<Esc>" | break | endif
			let mapCmd .= char
			if !empty(maparg(mapCmd, a:mode))
				echon clearline
				exec "normal! \<c-\>\<c-n>"
				let mapCmd = (a:mode == "x" ? "gv" : "").mapCmd
				exec "nmap <expr> <plug>ExecMap <sid>ExecMap(".string(mapCmd).")"
				call feedkeys("\<plug>ExecMap")
				break
			elseif !IsMapSeq(mapCmd, a:mode)
				let mapCmd = oldCmd
			endif
		endif
	endwhile

	" Recovery mapping
	exec a:mode."noremap ".a:prefix." ".trigger
endfunction

function! s:ExecMap(str)
	nunmap <plug>ExecMap
	return a:str
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
finish "{{{1
===============================================================
" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
