" Setup {{{1

let s:path  = escape(expand("<sfile>:p:h"), " ").";"
let RootDir = fnamemodify(finddir("plugin", s:path).'/..', ":p")
let SwapDir = fnamemodify(finddir("vim-swap", s:path), ":p")
let UndoDir = fnamemodify(SwapDir."undo", ":p")
let DataDir = fnamemodify(SwapDir."data", ":p")
let TempDir = fnamemodify(SwapDir."temp", ":p")

let s:did_activate = 0
function! vim_addon_Kamker#Activate()
	if s:did_activate | return | endif
	let s:did_activate = 1

	call kamker#vimrc#load()
	call kamker#abbrevs#load()
	call kamker#autocmds#load()
	call kamker#commands#load()
	call kamker#functions#load()
	call kamker#mappings#load()
	call kamker#plugins#load()
endfunction

finish "{{{1
===============================================================
" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
