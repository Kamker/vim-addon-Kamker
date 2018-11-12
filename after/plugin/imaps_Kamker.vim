" --------------------------------------------------------------------------
"  filename: *_{ft}.file fileformat: utf8 & latin1
" --------------------------------------------------------------------------
" #key --- odd line
" expr -- even line
" --------------------------------------------------------------------------
function! s:s()
	return matchstr(expand('<sfile>'), '<SNR>\d\+_\zes$')
endfunction

function! s:load(f)
	let ft = matchstr(fnamemodify(a:f, ":t:r"), '_\zs[^_]*$')
	let keys = map(filter(readfile(a:f), 'v:val =~ "^#"'), 'strpart(v:val, 1)')
	let maps = map(filter(readfile(a:f), 'v:val !~ "^#"'), 'eval(v:val)')
	let [i, len] = [0, len(keys)]
	while i < len
		call IMAP(keys[i], maps[i], ft)
		let i += 1
	endwhile
endfunction

call filter(split(globpath(RootDir."templates", '*.file'), "\n"), s:s().'load(v:val)')

" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
