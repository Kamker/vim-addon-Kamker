"        File: imaps.vim
"     Authors: Srinath Avadhanula <srinath AT fastmail.fm>
"              Benji Fisher <benji AT member.AMS.org>
" Description: insert mode template expander with cursor placement
"              while preserving filetype indentation.
"
"
" Documentation: {{{
"
" Motivation:
" this script provides a way to generate insert mode mappings which do not
" suffer from some of the problem of mappings and abbreviations while allowing
" cursor placement after the expansion. It can alternatively be thought of as
" a template expander.
"
" Consider an example. If you do
"
" imap lhs something
"
" then a mapping is set up. However, there will be the following problems:
" 1. the 'ttimeout' option will generally limit how easily you can type the
"    lhs. if you type the left hand side too slowly, then the mapping will not
"    be activated.
" 2. if you mistype one of the letters of the lhs, then the mapping is
"    deactivated as soon as you backspace to correct the mistake.
"
" If, in order to take care of the above problems, you do instead
"
" iab lhs something
"
" then the timeout problem is solved and so is the problem of mistyping.
" however, abbreviations are only expanded after typing a non-word character.
" which causes problems of cursor placement after the expansion and invariably
" spurious spaces are inserted.
"
" Usage Example:
" this script attempts to solve all these problems by providing an emulation
" of imaps wchich does not suffer from its attendant problems. Because maps
" are activated without having to press additional characters, therefore
" cursor placement is possible. furthermore, file-type specific indentation is
" preserved, because the rhs is expanded as if the rhs is typed in literally
" by the user.
"
" The script already provides some default mappings. each "mapping" is of the
" form:
"
" call IMAP (lhs, rhs, ft)
"
" Some characters in the RHS have special meaning which help in cursor
" placement.
"
" Example One:
"
"   call IMAP ("bit`", "\\begin{itemize}\<cr>\\item <++>\<cr>\\end{itemize}<++>", "tex")
"
" This effectively sets up the map for "bit`" whenever you edit a latex file.
" When you type in this sequence of letters, the following text is inserted:
"
" \begin{itemize}
" \item *
" \end{itemize}<++>
"
" where * shows the cursor position. The cursor position after inserting the
" text is decided by the position of the first "place-holder". Place holders
" are special characters which decide cursor placement and movement. In the
" example above, the place holder characters are <+ and +>. After you have typed
" in the item, press <C-j> and you will be taken to the next set of <++>'s.
" Therefore by placing the <++> characters appropriately, you can minimize the
" use of movement keys.
"
" NOTE: Set g:Imap_UsePlaceHolders to 0 to disable placeholders altogether.
" Set
"   g:Imap_PlaceHolderStart and g:Imap_PlaceHolderEnd
" to something else if you want different place holder characters.
" Also, b:Imap_PlaceHolderStart and b:Imap_PlaceHolderEnd override the values
" of g:Imap_PlaceHolderStart and g:Imap_PlaceHolderEnd respectively. This is
" useful for setting buffer specific place hoders.
"
" Example Two:
" You can use the <C-r> command to insert dynamic elements such as dates.
" call IMAP ('date`', "\<c-r>=strftime('%b %d %Y')\<cr>", '')
"
" sets up the map for date` to insert the current date.
"
"--------------------------------------%<--------------------------------------
" Bonus: This script also provides a command Snip which puts tearoff strings,
" '----%<----' above and below the visually selected range of lines. The
" length of the string is chosen to be equal to the longest line in the range.
" Recommended Usage: '<,'>Snip
"--------------------------------------%<--------------------------------------


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Start script {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:save_cpo = &cpo
set cpo&vim

" Options
let g:Imap_GoToSelectMode = get(g:, 'Imap_GoToSelectMode', 1)
let g:Imap_StickyPlaceHolders = get(g:, 'Imap_StickyPlaceHolders', 1)
let g:Imap_DeleteEmptyPlaceHolders = get(g:, 'Imap_DeleteEmptyPlaceHolders', 1)


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Functions for easy insert mode mappings {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" IMAP: Adds a "fake" insert mode mapping.
"       For example, doing
"           IMAP('abc', 'def', ft)
"       will mean that if the letters abc are pressed in insert mode, then
"       they will be replaced by def. If ft != '', then the "mapping" will be
"       specific to the files of type ft.
"
"       Using IMAP has a few advantages over simply doing:
"           imap abc def
"       1. with imap, if you begin typing abc, the cursor will not advance and
"          long as there is a possible completion, the letters a, b, c will be
"          displayed on on top of the other. using this function avoids that.
"       2. with imap, if a backspace or arrow key is pressed before completing
"          the word, then the mapping is lost. this function allows movement.
"          (this ofcourse means that this function is only limited to
"          left-hand-sides which do not have movement keys or unprintable
"          characters)
"       It works by only mapping the last character of the left-hand side.
"       when this character is typed in, then a reverse lookup is done and if
"       the previous characters consititute the left hand side of the mapping,
"       the previously typed characters and erased and the right hand side is
"       inserted

" IMAP: set up a filetype specific mapping.
" Description:
"   "maps" the lhs to rhs in files of type 'ft'. If supplied with 2
"   additional arguments, then those are assumed to be the placeholder
"   characters in rhs. If unspecified, then the placeholder characters
"   are assumed to be '<+' and '+>' These placeholder characters in
"   a:rhs are replaced with the users setting of
"   [bg]:Imap_PlaceHolderStart and [bg]:Imap_PlaceHolderEnd settings.

function! IMAP(lhs, rhs, ft, ...) " {{{
  " Map only the last character of the left-hand side.
  let lastLHSChar = strcharpart(a:lhs, strchars(a:lhs) - 1)
  let hash = s:Hash(lastLHSChar)
  let lastLHSChar = lastLHSChar == " " ? "<space>" : lastLHSChar
  call IMAP_add([lastLHSChar])

  " Add lhs to the list of left-hand sides that end with lastLHSChar
  if !exists("s:LHS_".a:ft."_".hash)
    let s:LHS_{a:ft}_{hash} = []
  endif
  call s:addLHS(s:LHS_{a:ft}_{hash}, a:lhs, a:ft)

  " Find the place holders to save for IMAP_PutTextWithMovement()
  let [phs, phe] = a:0 < 2 ? ['<+', '+>'] : [a:1, a:2]

  let hash = s:Hash(a:lhs)
  let s:Map_{a:ft}_{hash} = a:rhs
  let s:phs_{a:ft}_{hash} = phs
  let s:phe_{a:ft}_{hash} = phe

endfunction " }}}

let s:imap_chars = {}
function! IMAP_add(mapKeys) " {{{
  if type(a:mapKeys) != type([]) | return | endif
  let addKeys = filter(a:mapKeys, '!has_key(s:imap_chars, v:val)')
  for key in addKeys
    let s:imap_chars[key] = 'inoremap <silent> '.escape(key, '|')
                             \ .' <C-r>=<SID>LookupCharacter("'
                             \ .escape(key, '\|"').'")<CR>'
    exe s:imap_chars[key]
  endfor
endfunction " }}}

function! IMAP_remove(...) " {{{
  let mapKeys = a:0 <= 0 ? keys(s:imap_chars) :
              \ filter(copy(a:000), 'index(keys(s:imap_chars), v:val) >= 0')
  for key in mapKeys
    exec "iunmap ".key
    unlet s:imap_chars[key]
  endfor
  return mapKeys
endfunction " }}}

" IMAP_list:  list the rhs and place holders corresponding to a:lhs
function! IMAP_list(lhs) " {{{
  let char = strcharpart(a:lhs, strchars(a:lhs) - 1)
  let hash = s:Hash(char)
  if exists("s:LHS_".&ft."_".hash) && s:searchLHS(s:LHS_{&ft}_{hash}, a:lhs) != ""
    let ft = &ft
  elseif exists("s:LHS__".hash) && s:searchLHS(s:LHS__{hash}, a:lhs) != ""
    let ft = ""
  else
    return ""
  endif
  let hash = s:Hash(a:lhs)
  return [s:Map_{ft}_{hash}, s:phs_{ft}_{hash}, s:phe_{ft}_{hash}]
endfunction " }}}

" LookupCharacter: inserts mapping corresponding to this character
"
" This function extracts from s:LHS_{&ft}_{a:char} or s:LHS__{a:char}
" the longest lhs matching the current text.  Then it replaces lhs with the
" corresponding rhs saved in s:Map_{ft}_{lhs} .
" The place-holder variables are passed to IMAP_PutTextWithMovement() .
function! s:LookupCharacter(char) " {{{
  if IMAP_GetVal('Imap_FreezeImap', 0) == 1
    return a:char
  endif
  let hash = s:Hash(a:char)

  " The line so far, including the character that triggered this function
  let text = strpart(getline("."), 0, col(".") - 1) . a:char

  " Find the longest left-hand side that matches the line so far.
  for ft in (&ft == "" ? [""] : [&ft, ""])
    if exists("s:LHS_".ft."_".hash)
      let lhs = s:searchLHS(s:LHS_{ft}_{hash}, text)
      if lhs != ""
        let hash = s:Hash(lhs)
        let rhs = s:Map_{ft}_{hash}
        let phs = s:phs_{ft}_{hash}
        let phe = s:phe_{ft}_{hash}
        break
      endif
    endif
  endfor

  if !exists('rhs')
    " If this is a character which could have been used to trigger an
    " abbreviation, check if an abbreviation exists.
    if a:char !~ '\k'
      let lastword = matchstr(text, '\k\+\ze.$')
      if lastword != ""
        " An extremeley wierd way to get around the fact that vim
        " doesn't have the equivalent of the :mapcheck() function for
        " abbreviations.
        let _a = @a
        exec "redi @a | silent! iab ".lastword." | redi END"
        let abbrRHS = matchstr(@a."\n", "\n".'i\s\+'.lastword.'\s\+\zs.\{-}\ze'."\n")
        let @a = _a
        if abbrRHS == ""
          return a:char
        endif

        " e.g: ia aa bb\<cr>"cc"
        let abbrRHS = eval('"' . escape(abbrRHS, '\<"') . '"')
        let lhs = lastword.a:char
        let rhs = abbrRHS.a:char
        let phs = IMAP_GetPlaceHolderStart()
        let phe = IMAP_GetPlaceHolderEnd()
      else
        return a:char
      endif
    else
      return a:char
    endif
  endif

  " enough back-spaces to erase the left-hand side
  let bs = substitute(lhs, ".", "\<bs>", "g")
  " \<c-g>u inserts an undo point
  return a:char . "\<c-g>u" . bs . IMAP_PutTextWithMovement(rhs, phs, phe)
endfunction " }}}

" IMAP_PutTextWithMovement: returns the string with movement appended
" Description:
"   If a:str contains "placeholders", then appends movement commands to
"   str in a way that the user moves to the first placeholder and enters
"   insert or select mode. If supplied with 2 additional arguments, then
"   they are assumed to be the placeholder specs. Otherwise, they are
"   assumed to be '<+' and '+>'. These placeholder chars are replaced
"   with the users settings of [bg]:Imap_PlaceHolderStart and
"   [bg]:Imap_PlaceHolderEnd.
function! IMAP_PutTextWithMovement(str, ...) " {{{

  " The placeholders used in the particular input string. These can be
  " different from what the user wants to use.
  let [phs, phe] = a:0 < 2 ? ['<+', '+>'] : [escape(a:1, '\'), escape(a:2, '\')]

  " The user's placeholder settings.
  let phsUser = escape(IMAP_GetPlaceHolderStart(), '\')
  let pheUser = escape(IMAP_GetPlaceHolderEnd(), '\')

  let text = a:str
  let pattern = '\V\(\.\{-}\)' .phs. '\(\.\{-}\)' .phe. '\(\.\*\)'
  " If there are no placeholders, just return the text.
  if text !~ pattern
    return text
  endif
  " Break text up into "initial <+template+> final"; any piece may be empty.
  let initial  = substitute(text, pattern, '\1', '')
  let template = substitute(text, pattern, '\2', '')
  let final    = substitute(text, pattern, '\3', '')

  " If the user does not want to use placeholders, then remove all but the
  " first placeholder.
  " Otherwise, replace all occurences of the placeholders here with the
  " user's choice of placeholder settings.
  if exists('g:Imap_UsePlaceHolders') && !g:Imap_UsePlaceHolders
    let final = substitute(final, '\V'.phs.'\.\{-}'.phe, '', 'g')
  else
    let final = substitute(final, '\V'.phs.'\(\.\{-}\)'.phe, phsUser.'\1'.pheUser, 'g')
  endif

  " Build up the text to insert:
  " 1. the initial text plus an extra character;
  " 2. go to Normal mode with <C-\><C-N>, so it works even if 'insertmode'
  " is set, and mark the position;
  " 3. replace the extra character with tamplate and final;
  " 4. back to Normal mode and restore the cursor position;
  " 5. call IMAP_Jumpfunc().
  let template = phsUser . template . pheUser
  " Old trick:  insert and delete a character to get the same behavior at
  " start, middle, or end of line and on empty lines.
  let text = initial . "X\<C-\>\<C-N>:call IMAP_Mark('set')\<CR>\"_s"
  let text = text . template . final
  let text = text . "\<C-\>\<C-N>:call IMAP_Mark('go')\<CR>"
  let text = text . "i\<C-r>=IMAP_Jumpfunc('', 1)\<CR>"

  return text
endfunction " }}}

" IMAP_Mark:  Save the cursor position (if a:action == 'set') in a"
" script-local variable; restore this position if a:action == 'go'.
let s:Mark = "(0,0)"
let s:initBlanks = ''
function! IMAP_Mark(action) " {{{
  if a:action == 'set'
    let s:Mark = "(" . line(".") . "," . col(".") . ")"
    let s:initBlanks = matchstr(getline('.'), '^\s*')
  elseif a:action == 'go'
    execute "call cursor" s:Mark
    let blanksNow = matchstr(getline('.'), '^\s*')
    if strlen(blanksNow) > strlen(s:initBlanks)
      execute 'silent! normal! '.(strlen(blanksNow) - strlen(s:initBlanks)).'l'
    elseif strlen(blanksNow) < strlen(s:initBlanks)
      execute 'silent! normal! '.(strlen(s:initBlanks) - strlen(blanksNow)).'h'
    endif
  endif
endfunction " }}}

" IMAP_Jumpfunc: takes user to next <+place-holder+>
" Author: Luc Hermitte
" Arguments:
" direction: flag for the search() function. If set to '', search forwards,
"            if 'b', then search backwards. See the {flags} argument of the
"            |search()| function for valid values.
" inclusive: In vim, the search() function is 'exclusive', i.e we always goto
"            next cursor match even if there is a match starting from the
"            current cursor position. Setting this argument to 1 makes
"            IMAP_Jumpfunc() also respect a match at the current cursor
"            position. 'inclusive'ness is necessary for IMAP() because a
"            placeholder string can occur at the very beginning of a map which
"            we want to select.
"            We use a non-zero value only in special conditions. Most mappings
"            should use a zero value.
function! IMAP_Jumpfunc(direction, inclusive) " {{{

  " The user's placeholder settings.
  let phsUser = escape(IMAP_GetPlaceHolderStart(), '\')
  let pheUser = escape(IMAP_GetPlaceHolderEnd(), '\')

  let searchString = ''
  " If this is not an inclusive search or if it is inclusive, but the
  " current cursor position does not contain a placeholder character, then
  " search for the placeholder characters.
  if !a:inclusive || strpart(getline('.'), col('.')-1) !~ '\V\^'.phsUser
    let searchString = '\V'.phsUser.'\_.\{-}'.pheUser
  endif

  " If we didn't find any placeholders return quietly.
  if searchString != '' && !search(searchString, a:direction)
    return ''
  endif

  " Open any closed folds and make this part of the text visible.
  silent! foldopen!

  " Search for the end placeholder.
  let [lnum, lcol] = searchpos('\V'.pheUser, 'ne')
  if lnum == 0 || lcol == 0 | return '' | endif

  " Calculate if we have an empty placeholder or if it contains some
  " description.
  let _r = @r
  silent! exec '.,'.lnum.'y r'
  let template =
    \ matchstr(strpart(@r, col('.')-1),
    \          '\V\^'.phsUser.'\zs\.\{-}\ze'.pheUser)
  let @r = _r
  let placeHolderEmpty = !strlen(template)

  " How many characters should be selected?
  let movement = "\<c-o>\<c-\>\<c-n>v"
  " If we are selecting in exclusive mode, then we need to move one step to
  " the right
  " Select till the end placeholder character.
  let movement .= repeat('j', lnum - line('.'))."0"
  let movement .= repeat('l', lcol - 1 + (&selection == 'exclusive'))

  " Now either goto insert mode or select mode.
  if placeHolderEmpty && g:Imap_DeleteEmptyPlaceHolders
    " Delete the empty placeholder into the blackhole.
    return movement . '"_c'
  else
    if g:Imap_GoToSelectMode
      " Go to select mode
      return movement . "\<c-g>"
    else
      " Do not go to select mode
      return movement
    endif
  endif

endfunction " }}}

" Maps for IMAP_Jumpfunc
"
" These mappings use <Plug> and thus provide for easy user customization. When
" the user wants to map some other key to jump forward, he can do for
" instance:
"   nmap ,f   <plug>IMAP_JumpForward
" etc.

" jumping forward and back in insert mode.
imap <silent> <script> <Plug>IMAP_JumpForward  <c-r>=IMAP_Jumpfunc('',0)<CR>
imap <silent> <script> <Plug>IMAP_JumpBack     <c-r>=IMAP_Jumpfunc('b',0)<CR>

" jumping in normal mode
nmap <silent> <script> <Plug>IMAP_JumpForward  i<c-r>=IMAP_Jumpfunc('',0)<CR>
nmap <silent> <script> <Plug>IMAP_JumpBack     i<c-r>=IMAP_Jumpfunc('b',0)<CR>

" jumping forward without deleting present selection.
vmap <silent> <script> <Plug>IMAP_JumpForward  <C-\><C-N>i<c-r>=IMAP_Jumpfunc('',0)<CR>
vmap <silent> <script> <Plug>IMAP_JumpBack     <C-\><C-N>`<i<c-r>=IMAP_Jumpfunc('b',0)<CR>

" deleting the present selection and then jumping forward.
vmap <silent> <script> <Plug>IMAP_DeleteAndJumpForward  "_<Del>i<c-r>=IMAP_Jumpfunc('',0)<CR>
vmap <silent> <script> <Plug>IMAP_DeleteAndJumpBack     "_<Del>i<c-r>=IMAP_Jumpfunc('b',0)<CR>

" Default maps for IMAP_Jumpfunc
" map only if there is no mapping already. allows for user customization.
" NOTE: Default mappings for jumping to the previous placeholder are not
"       provided. It is assumed that if the user will create such mappings
"       hself if e so desires.
if !hasmapto('<Plug>IMAP_JumpForward', 'i')
  imap <C-J> <Plug>IMAP_JumpForward
endif
if !hasmapto('<Plug>IMAP_JumpForward', 'n')
  nmap <C-J> <Plug>IMAP_JumpForward
endif
if exists('g:Imap_StickyPlaceHolders') && g:Imap_StickyPlaceHolders
  if !hasmapto('<Plug>IMAP_JumpForward', 'v')
    vmap <C-J> <Plug>IMAP_JumpForward
  endif
else
  if !hasmapto('<Plug>IMAP_DeleteAndJumpForward', 'v')
    vmap <C-J> <Plug>IMAP_DeleteAndJumpForward
  endif
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => enclosing selected region {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VEnclose: encloses the visually selected region with given arguments
" Description: allows for differing action based on visual line wise
"              selection or visual characterwise selection. preserves the
"              marks and search history.
function! VEnclose(vstart, vend)
  if a:vstart == "" || a:vend == "" | return | endif
  let _r = @r
  exec "normal! \<c-\>\<c-n>gv\"ry"
  if visualmode() ==# 'v' && @r !~ "^\n*$"
    let smove = repeat('j0', strchars(matchstr(@r, "^\n*")))
    let n = strlen(matchstr(@r, '\n*$'))
    let emove = n <= 1 ? repeat('h', n) : repeat('k', n-1).'$h'
    let @r = substitute(@r, '^\n*\|\n*$', "", "g")
    let @r = a:vstart.@r.a:vend
    let normcmd = "normal! \<c-\>\<c-n>`<".smove."v`>".emove."\"rp`>"
    silent! exec normcmd
  else
    exec 'normal! `<O'.a:vstart."\<c-\>\<c-n>"
    exec 'normal! `>o'.a:vend."\<c-\>\<c-n>"
    if &indentexpr != ''
      silent! normal! `<kV`>j=
    endif
    silent! normal! `>
  endif
  let @r = _r
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" s:Hash: Return a version of a string that can be used as part of a variable
" name.
"   Converts every non alphanumeric character into _{ascii}_ where {ascii} is
"   the ASCII code for that character...
fun! s:Hash(text)
  return substitute(a:text, '\([^[:alnum:]]\)', '\="_".char2nr(submatch(1))."_"', 'g')
endfun "

function! s:addLHS(list, lhs, ft)
  " Make sure no duplicates
  if exists("s:Map_" . a:ft . "_" . s:Hash(a:lhs))
    return a:list
  endif

  let lhsLen = strchars(a:lhs)
  let [i, n] = [0, lhsLen - len(a:list)]
  while i < n | call add(a:list, []) | let i += 1 | endwhile

  call add(a:list[lhsLen - 1], a:lhs)
  return a:list
endfunction

" Search for the longest lhs matching the text
function! s:searchLHS(list, text)
  let n = len(a:list) | let i = n
  while i > 0
    let i -= 1
    for lhs in a:list[i]
      if strcharpart(a:text, strchars(a:text) - i - 1) ==# lhs
        return lhs
      endif
    endfor
  endwhile
  return ""
endfunction

" IMAP_GetVal: gets the value of a variable
" Description: first checks window local, then buffer local etc.
function! IMAP_GetVal(name, ...)
  let default = a:0 > 0 ? a:1 : ''
  return exists('w:'.a:name) ? w:{a:name} :
       \ exists('b:'.a:name) ? b:{a:name} :
       \ exists('g:'.a:name) ? g:{a:name} : default
endfunction

" IMAP_GetPlaceHolderStart and IMAP_GetPlaceHolderEnd:
" return the buffer local placeholder variables, or the global one, or the default.
function! IMAP_GetPlaceHolderStart()
  return exists("b:Imap_PlaceHolderStart") && strlen(b:Imap_PlaceHolderStart) ?
       \ b:Imap_PlaceHolderStart :
       \ exists("g:Imap_PlaceHolderStart") && strlen(g:Imap_PlaceHolderStart) ?
       \ g:Imap_PlaceHolderStart : "<+"
endfun

function! IMAP_GetPlaceHolderEnd()
  return exists("b:Imap_PlaceHolderEnd") && strlen(b:Imap_PlaceHolderEnd) ?
       \ b:Imap_PlaceHolderEnd :
       \ exists("g:Imap_PlaceHolderEnd") && strlen(g:Imap_PlaceHolderEnd) ?
       \ g:Imap_PlaceHolderEnd : "+>"
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => A bonus function: Snip() {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Snip: puts a scissor string above and below block of text
" Desciption:
"-------------------------------------%<-------------------------------------
"   this puts a the string "--------%<---------" above and below the visually
"   selected block of lines. the length of the 'tearoff' string depends on the
"   maximum string length in the selected range. this is an aesthetically more
"   pleasing alternative instead of hardcoding a length.
"-------------------------------------%<-------------------------------------
function! s:Snip() range
  let i = a:firstline
  let maxlen = -2
  " find out the maximum virtual length of each line.
  while i <= a:lastline
    exe i
    let length = virtcol('$')
    let maxlen = (length > maxlen ? length : maxlen)
    let i = i + 1
  endwhile
  let maxlen = (maxlen > &tw && &tw != 0 ? &tw : maxlen)
  let half = maxlen/2
  exe a:lastline
  " put a string below
  exe "norm! o\<esc>".(half - 1)."a-\<esc>A%<\<esc>".(half - 1)."a-"
  " and above. its necessary to put the string below the block of lines
  " first because that way the first line number doesnt change...
  exe a:firstline
  exe "norm! O\<esc>".(half - 1)."a-\<esc>A%<\<esc>".(half - 1)."a-"
endfunction

com! -nargs=0 -range Snip :<line1>,<line2>call <sid>Snip()

let &cpo = s:save_cpo

" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
