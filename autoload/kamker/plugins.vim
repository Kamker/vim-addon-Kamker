" Plugins {{{1

function! kamker#plugins#load()
	" TODO
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => ack {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use the the_silver_searcher if possible (much faster than Ack)
if executable('ag')
	let g:ackprg = 'ag --vimgrep --smart-case --silent'
endif

" When you press gv you Ack after the selected text
xnoremap <silent> gv :call VisualSelection('gv', '')<cr>
" Open Ack and put the cursor in the right position
nnoremap <leader>gv :Ack<space>
nnoremap <leader>ag :exe 'Ack "'.iconv(" ","gbk","utf8").'"'<c-left><bs>
" When you search with Ack, display your results in cope
nnoremap <leader>oo :botright copen<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => indentLine {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:indentLine_char = '┆'
let g:indentLine_fileTypeExclude = ['text']
let g:indentLine_bufTypeExclude = ['help']
let g:indentLine_bufNameExclude = ['_.*', 'NERD_tree.*']


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => auto-pairs-gentle {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use <M-b> insert the key at the Fly Mode jumped position.
let g:AutoPairsFlyMode = 1
let g:AutoPairsMapSpace = 0
" Disable Fast Wrap: <M-e>
let g:AutoPairsShortcutFastWrap = ''


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-multiple-cursors {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd User MultipleCursorsPre  call s:RemoveIMAPsAutoPairs()
autocmd User MultipleCursorsPost call s:RecoverIMAPsAutoPairs()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => fugitive {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => The_NERD_tree {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeWinSize = 35
let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeWinPos = "right"
let g:NERDTreeAutoDeleteBuffer = 1
let NERDTreeIgnore = ['^\cntuser\.']
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeBookmarksFile = DataDir.".NERDTreeBookmarks"

function! s:NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
	exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
	exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call <sid>NERDTreeHighlightFile('jade', 'green', 'none', 'green', 'NONE')
call <sid>NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', 'NONE')
call <sid>NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', 'NONE')
call <sid>NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', 'NONE')
call <sid>NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', 'NONE')
call <sid>NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', 'NONE')
call <sid>NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', 'NONE')
call <sid>NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', 'NONE')
call <sid>NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', 'NONE')
call <sid>NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', 'NONE')
call <sid>NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', 'NONE')
call <sid>NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', 'NONE')
call <sid>NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', 'NONE')
call <sid>NERDTreeHighlightFile('vim', 'green', 'none', 'green', 'NONE')

augroup NERDTree
	autocmd!
	" Close vim if the only window left open is a NERDTree
	autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

nnoremap <leader>nn :NERDTreeToggle<cr>
nnoremap <leader>nb :NERDTreeFromBookmark<space>
nnoremap <leader>nf :NERDTreeFind<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => The_NERD_Commenter {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => YouCompleteMe {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" http://eclim.org/gettingstarted.html
let g:EclimCompletionMethod = 'omnifunc'
let g:ycm_cache_omnifunc = 0
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_key_list_select_completion = []
let g:ycm_key_list_previous_completion = []
let g:ycm_key_invoke_completion = '<c-s-space>'
nnoremap <f5> :YcmForceCompileAndDiagnostics<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => UltiSnips {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsEditSplit = 'vertical'
let g:UltiSnipsEnableSnipMate = 0
let g:UltiSnipsNoPythonWarning = 1
let g:UltiSnipsSnippetsDir = RootDir."UltiSnips"
inoremap <c-x><c-k> <c-x><c-k>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => surround {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:surround_insert_tail = "<++>"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => repeat {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:unimpaired_repeat = ['[a', ']a', '[b', ']b', '[q', ']q']


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Solarized {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:solarized_menu       = 1
let g:solarized_hitrail    = 1
let g:solarized_visibility = "high"

colorscheme solarized
set background=dark


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-airline {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#left_alt_sep = '»'
let g:airline#extensions#tabline#right_alt_sep = '«'
let g:airline#extensions#tabline#close_symbol = '×'
let g:airline#extensions#tabline#show_close_button = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VimTweak {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>tw :VimTweak<c-z>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => scratch {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:scratch_persistence_file = DataDir.'_scratch'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => yankring {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:yankring_history_dir = DataDir
nnoremap <silent> <leader>ys :YRShow<cr>
let g:yankring_replace_n_pkey = '<Char-172>'
let g:yankring_replace_n_nkey = '<Char-174>'
function! YRRunAfterMaps()
	nnoremap Y :<c-u>YRYankCount 'y$'<cr>
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => ctrlp {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_map = '<c-f>'
let g:ctrlp_max_height = 20
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_cache_dir = TempDir.'.cache/ctrlp'
let g:ctrlp_reuse_window = 'netrw\|help\|quickfix'
let g:ctrlp_extensions = ['autoignore', 'changes', 'bookmarkdir']
let g:ctrlp_cmd = 'exe "CtrlP".get(["", "Buffer", "MRU", "BookmarkDir", "Change"], v:count)'

" Use: ctrl-z... ctrl-o or ctrl-o a ctrl-z...
" Help: ctrlp-mappings, g:ctrlp_prompt_mappings
let g:ctrlp_open_multiple_files = '5vjr'

" Press <F5> in ctrlp to clear the cache
let g:ctrlp_custom_ignore = {'file': '\v\.(exe|dll)$'}

augroup CtrlPDirMRU
	autocmd!
	autocmd FileType * if &modifiable | execute 'silent CtrlPBookmarkDirAdd! %:p:h' | endif
augroup END


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => matchup {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:loaded_matchparen = 1
let g:matchup_transmute_enabled = 1
function! s:matchup_convenience_maps()
	xnoremap <sid>(std-I) I
	xnoremap <sid>(std-A) A
	xmap <expr> I mode()=='<c-v>'?'<sid>(std-I)':(v:count?'':'1').'i'
	xmap <expr> A mode()=='<c-v>'?'<sid>(std-A)':(v:count?'':'1').'a'
	for l:v in ['', 'v', 'V', '<c-v>']
		execute 'omap <expr>' l:v.'I%' "(v:count?'':'1').'".l:v."i%'"
		execute 'omap <expr>' l:v.'A%' "(v:count?'':'1').'".l:v."a%'"
	endfor
endfunction
call s:matchup_convenience_maps()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => easymotion {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable default mappings
let g:EasyMotion_do_mapping = 0

" ,f{char}{char} to move to {char}{char}
map <leader>f <Plug>(easymotion-bd-f2)
nmap <leader>f <Plug>(easymotion-overwin-f2)

" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <leader>j <Plug>(easymotion-j)
map <leader>k <Plug>(easymotion-k)


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => previm {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:previm_enable_realtime = 1
let g:previm_open_cmd = 'cmd /cstart chrome'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Tabular {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>ga :<c-u>call <sid>OpenTabularize()<cr>
fun! s:OpenTabularize()
	let cmd = ":Tabularize"
	if !exists(cmd)
		:ActivateAddons Tabular
	endif
	call feedkeys(cmd." /", "n")
endfu


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => csscomplete {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS noci


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-addon-local-vimrc {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Project specific settings
let g:local_vimrc = {'names':['_project.vim'], 'cache_file':DataDir.'.vim_local_rc_cache'}
autocmd GUIEnter * ActivateAddons vim-addon-local-vimrc


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:RemoveIMAPsAutoPairs()
	let s:Imap_keys = IMAP_remove()
	if exists("b:autopairs_loaded")
		imapclear<buffer>
		unlet b:autopairs_loaded
	endif
endfunction

function! s:RecoverIMAPsAutoPairs()
	if exists("s:Imap_keys")
		call IMAP_add(s:Imap_keys)
		unlet s:Imap_keys
	endif
	call AutoPairsTryInit()
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
finish "{{{1
===============================================================
" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
