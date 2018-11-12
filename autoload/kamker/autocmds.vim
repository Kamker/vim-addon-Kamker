" Autocmds {{{1

function! kamker#autocmds#load()
	" TODO
endfunction


" Put these in an autocmd group, so that you can revert them with:
" ":augroup vimStartup | au! | augroup END"
augroup vimStartup
	au!

	" When editing a file, always jump to the last known cursor position.
	" Don't do it when the position is invalid, when inside an event handler
	" (happens when dropping a file on gvim) and for a commit message (it's
	" likely a different one than last time).
	autocmd BufReadPost *
		\ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
		\ |  exe "normal! g`\""
		\ | endif

	" nested 联动触发自动命令，切换缓冲区、标签、程序
	autocmd BufLeave,TabLeave,FocusLost * nested
		\ if (&modified && &buftype == "" && bufname("%") != "")
		\ |  try
		\ |    w!
		\ |  catch
		\ |    exe 'file '.fnameescape($Temp.'/'.expand("%:t")) | w!
		\ |    echo expand("#:p")." -> ".expand("%:p") | bw! #
		\ |  endtry
		\ | endif

	autocmd! BufWritePost $myvimrc source $myvimrc

	autocmd BufWritePre *.{txt,wiki,java,py,js,vim,xml,cmd,bat,ahk,coffee}
		\ call CleanExtraSpaces()

	autocmd BufWritePre _vimrc,vimrc
		\ call CleanExtraSpaces()

augroup END

augroup SynEnsureHighlight
	autocmd BufRead,BufNewFile * syn match TODO "\ctodo\|fixme" containedin=.*
augroup END

augroup SwapFound
	autocmd SwapExists * echo "swap found (o,e,r,d,a)" | let v:swapchoice=nr2char(getchar())
augroup END

augroup Python
	autocmd BufRead,BufNewFile *.py :setlocal aw
	autocmd BufRead,BufNewFile *.py :setlocal makeprg=python
	autocmd BufRead,BufNewFile *.py nnoremap <buffer> <f3> :make %<cr>
augroup END

augroup CreateMissingDirWhenWrite
	au!
	autocmd BufWritePre * if !isdirectory(expand('%:h', 1)) | call mkdir(expand('%:h', 1),'p') | endif
augroup END


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
finish "{{{1
===============================================================
" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
