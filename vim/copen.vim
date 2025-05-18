"===============================================================================

let g:copen_list = []
let g:copen_selected = 0

function! UpdateSelected()
  let numbers = []
  for line in g:copen_list
    let num_str = matchstr(line, '\v:\zs\d+(|)')
    call add(numbers, str2nr(num_str))
  endfor
  for i in range(len(numbers))
    if g:current_line[1] <= numbers[i]
      let g:copen_selected = i - 1
      break
    endif
  endfor
endfunction

function! VimgrepSearch(arg)
  echo "VimgrepSearch"
  let g:current_line = getpos('.')
  if a:arg == ''
    if empty(g:copen_list)
      echo "?_?"
      return 1
    endif
  else
    execute 'silent! vimgrep /' . a:arg . '/ %'
    let g:copen_list = map(getqflist(), 'bufname(v:val.bufnr) .
          \":" . v:val.lnum . "|" . v:val.text')
    if empty(g:copen_list)
      echo "?_?"
      return 1
    endif
    let g:foo = a:arg
  endif
  call setpos('.', g:current_line)

  call UpdateSelected()
  let g:copen_popup_id = popup_create(g:foo, {
        \ 'line': 'cursor',
        \ 'col': 'cursor+13',
        \ 'border': [],
        \ 'filter': 'VimgrepSearchFilter'
        \ })
endfunction

function! VimgrepSearchFilter(id, key)
  if a:key == "\<Esc>" || a:key == "\<CR>" || a:key ==# " "
    call popup_close(a:id)
  elseif a:key == "k" || a:key == "\<Up>"
    let g:copen_selected = (g:copen_selected - 1 +
          \len(g:copen_list)) % len(g:copen_list)
    execute 'silent! cc ' . (g:copen_selected + 1)
  elseif a:key == "j" || a:key == "\<Down>"
    let g:copen_selected = (g:copen_selected + 1) %
          \len(g:copen_list)
    execute 'silent! cc ' . (g:copen_selected + 1)
  else
    return 0
  endif
  call popup_settext(g:copen_popup_id, 1 + g:copen_selected . "/" .
        \len(g:copen_list))
  call popup_move(a:id, {'line': 'cursor+1', 'col': 'cursor+13'})
  return 1
endfunction

command! -nargs=? C call VimgrepSearch(<q-args>)

"===============================================================================

function! JumpToScreenFraction(position)
  let top = line('w0')
  let bottom = line('w$')
  let range = bottom - top
  if a:position ==# 0
    let target = top + float2nr(range / 4)
  elseif a:position ==# 1
    let target = top + float2nr(range * 3 / 4)
  else
    echoerr "Invalid position: " . a:position
    return
  endif
  call setpos('.', [0, target, 1, 0])
  normal! zz
endfunction

"===============================================================================

function! SearchOnCurrentScreen()
  echo "SearchOnCurrentScreen"
  if g:resultGetChar == ""
    return 1
  endif
  let current_line = getpos('.')[1]
  let g:matches = []
  for lnum in range(line('w0'), line('w$'))
    "for lnum in range(125, 125)
    let line_text = getline(lnum)
    let start_col = 0
    while 1
      let col = match(line_text, g:resultGetChar, start_col)
      if col == -1
        break
      endif
      call add(g:matches, [lnum, col + 1])
      let start_col = col + 1
    endwhile
  endfor
  let g:bar = popup_create(g:resultGetChar, {
        \ 'border': [],
        \ 'filter': 'SearchOnCurrentScreenFilter'
        \ })
endfunction

function! SearchOnCurrentScreenFilter(id, key)
  let curline = line('.')
  let target = []
  if a:key ==# " "
    call popup_close(a:id)
  elseif a:key == "h"
    call popup_close(a:id)
    call VimgrepSearch(g:resultGetChar)
  elseif a:key == "j"
    for loc in g:matches
      if loc[0] > curline || (loc[0] == curline && loc[1] > col('.'))
        let target = loc
        break
      endif
    endfor
  elseif a:key == "k"
    for loc in reverse(copy(g:matches))
      if loc[0] < curline || (loc[0] == curline && loc[1] < col('.'))
        let target = loc
        break
      endif
    endfor
  elseif a:key == "l"
    echo 123
  else
    "call popup_close(a:id)
  endif
  if !empty(target)
    call setpos('.', [0, target[0], target[1], 0])
    call popup_settext(a:id, index(g:matches, target) + 1 . "/" . 
          \len(g:matches))
    call popup_move(a:id, {'line': 'cursor+1', 'col': 'cursor+13'})
  endif
  return 1
endfunction

"===============================================================================

function! HJKLmenu()
  echo "HJKLmenu"
  :unmap hl
  :unmap lh
  let s:hjkl_menu = popup_create("/ jk % @_@", {
        \ 'border': [],
        \ 'filter': 'HJKLfilter',
        \ 'callback': 'HJKLcallback'
        \ })
endfunction

noremap hl :call HJKLmenu()<CR>

function! HJKLfilter(id, key)
  if a:key ==# " "
    call popup_close(a:id)
  elseif a:key == "h"
    call popup_close(a:id)
    call FuzzySearch()
  elseif a:key == "j"
    call popup_close(a:id)
    call NavMenu()
  elseif a:key == "k"
    call popup_close(a:id)
    call FileMenu()
  elseif a:key == "l"
    echo 4
  endif
  return 1
endfunction

function! HJKLcallback(id, key)
  noremap hl :call HJKLmenu()<CR>
  noremap lh :call Asu()<CR>
endfunction

"===============================================================================

function! NavMenu()
  echo "NavMenu"
  :unmap hl
  :unmap lh
  let s:nav_menu = popup_create("} j k {", {
        \ 'border': [],
        \ 'filter': 'NavMenuFilter',
        \ 'callback': 'HJKLcallback'
        \ })
endfunction

function! NavMenuFilter(id, key)
  if !exists('s:nav_num')
    let s:nav_num = 0
  endif
  if a:key ==# " "
    call popup_close(a:id)
  elseif a:key == "h"
    normal! }
  elseif a:key == "j"
    if s:nav_num
      call NavJump(a:id, 1)
    else
      call JumpToScreenFraction(1)
    endif
  elseif a:key == "k"
    if s:nav_num
      call NavJump(a:id, 0)
    else
      call JumpToScreenFraction(0)
    endif
  elseif a:key == "l"
    normal! {
  elseif a:key =~# '^[0-9]$'
    let s:nav_num = s:nav_num * 10 + str2nr(a:key)
    if s:nav_num > 71
      let s:nav_num = str2nr(a:key)
    endif
    echo s:nav_num
  endif
  return 1
endfunction

function! NavJump(id, nav)
  let l:current_line = getpos('.')[1]
  let l:nav_num = s:nav_num
  if a:nav
    call setpos('.', [0, l:current_line + l:nav_num, 0, 0])
  else
    call setpos('.', [0, l:current_line - l:nav_num, 0, 0])
  endif
  let s:nav_num = 0
  call popup_close(a:id)
endfunction

"===============================================================================

function! FileMenu()
  echo "FileMenu"
  :unmap hl
  :unmap lh
  let s:file_menu = popup_create("q w q! gG", {
        \ 'border': [],
        \ 'filter': 'FileMenuFilter',
        \ 'callback': 'HJKLcallback'
        \ })
endfunction

function! FileMenuFilter(id, key)
  if a:key ==# " "
  elseif a:key == "h"
    quit
  elseif a:key == "j"
    write
    if &filetype ==# 'typescript' || &filetype ==# 'javascript'
      execute '!prettier --write ' . shellescape(expand('%:p'))
    endif
  elseif a:key == "k"
    quit!
  elseif a:key == "l"
    normal! gg=G''
    write
  endif
  call popup_close(a:id)
  return 1
endfunction

"===============================================================================

function! FuzzySearch()
  echo "FuzzySearch"
  normal! 0
  :unmap hl
  :unmap lh
  let g:fuzzy_search = popup_create(g:tempKeys, {
        \ 'border': [],
        \ 'filter': 'FuzzySearchFilter',
        \ 'callback': 'HJKLcallback'
        \ })
endfunction

let g:tempKeys = ""

function! FuzzySearchFilter(id, key)
  if a:key ==# " "
    let g:tempKeys = ""
    call popup_close(a:id)
    call FuzzySearchFilterNav(a:id, a:key)
  elseif a:key ==# "\<BS>"
    let g:tempKeys = g:tempKeys[:-2]
    if g:tempKeys == ""
      return 1
    endif
    silent! execute 'normal! ?' . "\<CR>"
    echo g:tempKeys
  elseif a:key ==# "\<CR>"
    return 1
  elseif a:key =~# '^[A-Za-z0-9]$'
    let g:tempKeys .= a:key
    call setreg('/', g:tempKeys)
    silent! execute 'normal! /' . "\<CR>"
    echo g:tempKeys
  else
    " For debugging, show special key
    echo "Special key: " . string(a:key)
  endif
  return 1
endfunction

function! FuzzySearchFilterNav(id, key)
  if a:key ==# " "
    echo 1
  elseif a:key == "j"
    echo 2
  elseif a:key == "k"
    echo 3
  endif
  return1
endfunction

"===============================================================================

