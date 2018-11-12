if !exists(expand("<sfile>:t:r"))
	finish
endif

for s:l in g:{expand("<sfile>:t:r")}
	exec 'nn <silent>' s:l ':call <sid>bind("'.maparg(s:l, 'n').'")<cr>'
endfor

function! s:bind(map)
	let cmd = eval('"\'.a:map.'"')
	try
		exec 'norm' cmd | silent! call repeat#set(cmd, v:count)
	catch
		echohl WarningMsg
		echo matchstr(v:exception, '^Vim\%((\a\+)\)\=:\zsE\d\+.*')
		echohl None
	endtry
endfunction

" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
