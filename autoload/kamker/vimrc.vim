" Vim settings {{{1

function! kamker#vimrc#load()
	" TODO
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=500
let &viminfofile = SwapDir."_viminfo"

" Display incomplete commands
set showcmd

" Display completion matches in a status line
set wildmenu
set wildcharm=<c-z>

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <Leader>w saves the current file
let mapleader = ","

set timeout ttimeout timeoutlen=500 ttimeoutlen=100
set updatetime=100

" Do not recognize octal numbers for Ctrl-A and Ctrl-X, most users find it
" confusing.
set nrformats-=octal

" I like highlighting strings inside C comments.
" Revert with ":unlet c_comment_strings".
let c_comment_strings=1

if has('langmap') && exists('+langremap')
	" Prevent that the langmap option applies to characters that result from a
	" mapping.  If set (default), this may break plugins (but it's backward
	" compatible).
	set nolangremap
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => GUI related {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set extra options when running in GUI mode
if has("gui_running")
	set guioptions=M
	set guifont=Consolas:h12:w5.7:cANSI:qDEFAULT
	set guifontwide=Kaiti:h12
endif

colorscheme molokai
set background=dark


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable use of the mouse for all modes
set mouse=a
set clipboard=unnamed

" Don't use ALT keys for menus
set winaltkeys=no

" Display line numbers on the left
set number
set relativenumber

" Set 3 lines to the cursor - when moving vertically using j/k
set scrolloff=3
set cursorline

set splitbelow " <C-W>s
set splitright " <C-W>v

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
	set wildignore+=.git\*,.hg\*,.svn\*
else
	set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

"Always show current position
set ruler

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Allow buffers to go in background without saving etc.
set hidden

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" Use case insensitive search, except when using capital letters
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw
set shortmess+=I

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set matchtime=2

" No annoying sound on errors
set noerrorbells
autocmd GUIEnter * set vb t_vb=

" Add a bit extra margin to the left
set foldcolumn=1

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, buffers, backups and undo {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup  " do not keep a backup file, use versions instead
set nowritebackup
set noswapfile
" keep an undo file (undo changes after closing)
set undofile
let &undodir = UndoDir
" Specify the behavior when switching between buffers
try
	set switchbuf=useopen,usetab,newtab
	set stal=2
catch
endtry


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab: default behavior of vim is: add &tabstop spaces unless expandtab is not
" set. You can always insert real tabs by <c-v><tab>. However tabstob should be
" treated as display setting. Use sw setting and c-t, c-d instead.
set list listchars=tab:»·,eol:¬,trail:·

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

"set foldmethod=indent
set autoindent
set smartindent
set nowrap

set formatoptions=qrn1mM
set colorcolumn=85

" Use Unix as the standard file type
set ffs=dos,unix,mac


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Status line {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
finish "{{{1
===============================================================
" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
