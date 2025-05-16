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

let g:resultGetChar = ""
let g:jancokBool = 0
let g:jancokNum = 0
function! CycleJancok()
  let current_val = get(g:, 'jancokBool', 0)
  let idx = (current_val + 1) % len(g:jancokTitle)
  let g:jancokBool = idx
endfunction

let g:jancokTitle = [
      \["?? j k @_@"],
      \["gG } { ._."]
      \]

function! JancokMenu()
  :unmap hl
  :unmap lh
  let g:gg = popup_create(g:jancokTitle[0], {
        \ 'border': [],
        \ 'filter': 'JancokFilter',
        \ 'callback': 'AsuTenan'
        \ })
endfunction

function! JancokFilter(id, key)
  if g:jancokBool == 0
    call Filter1(a:id, a:key)
    return 1
  elseif g:jancokBool == 1
    call Filter2(a:id, a:key)
    return 1
  endif
endfunction

noremap hl :call JancokMenu()<CR>
function! AsuTenan(id, key)
  noremap hl :call JancokMenu()<CR>
  noremap lh :call Asu()<CR>
endfunction

function! Filter1(id, key)
  if a:key ==# " "
    call popup_close(a:id)
  elseif a:key == "h"
    call popup_close(a:id)
    call FuzzySearch()
  elseif a:key == "j"
    if g:jancokNum
      call JancokJump(a:id, 1)
      return 1
    endif
    call JumpToScreenFraction(1)
  elseif a:key == "k"
    if g:jancokNum
      call JancokJump(a:id, 0)
      return 1
    endif
    call JumpToScreenFraction(0)
  elseif a:key == "l"
    call CycleJancok()
    call popup_settext(a:id, g:jancokTitle[1])
  else
    call FilterElse(a:id, a:key)
  endif
  return 1
endfunction

function! Filter2(id, key)
  if a:key ==# " "
    let g:jancokBool = 0
    call popup_close(a:id)
  elseif a:key == "h"
    if line('.') == 1
      normal! G
    else
      normal! gg
    endif
  elseif a:key == "j"
    normal! }
  elseif a:key == "k"
    normal! {
  elseif a:key == "l"
    call CycleJancok()
    call popup_settext(a:id, g:jancokTitle[0])
  else
    call FilterElse(a:id, a:key)
  endif
  "call CycleJancok()
  return 1
endfunction

function! FilterElse(id, key)
  if a:key =~# '^[0-9]$'
    let g:jancokNum = g:jancokNum * 10 + str2nr(a:key)
    if g:jancokNum > 71
      let g:jancokNum = str2nr(a:key)
    endif
    echo g:jancokNum
    return 1
  elseif a:key == "u"
    call Save()
  elseif a:key == "i"
    normal! gg=G''
  elseif a:key == "s"
    let x = input("?_? ")
    if x != ''
      let g:resultGetChar = x
      call popup_close(a:id)
      call SearchOnCurrentScreen()
    endif
    call popup_close(a:id)
  endif
  "let g:jancokBool = 0
  "call popup_close(a:id)
endfunction

function! JancokJump(id, nav)
  let current_line = getpos('.')[1]
  if a:nav
    call setpos('.', [0, current_line + g:jancokNum, 0, 0])
  else
    call setpos('.', [0, current_line - g:jancokNum, 0, 0])
  endif
  let g:jancokNum = 0
  call popup_close(a:id)
endfunction

"===============================================================================

function! Save()
  w
  if &filetype ==# 'typescript' || &filetype ==# 'javascript'
    write                         " Save file first
    execute '!prettier --write ' . shellescape(expand('%:p'))
  endif
endfunction

"===============================================================================

function! FuzzySearch()
  echo "FuzzySearch"
  let g:foo = popup_create("asas", {
        \ 'border': [],
        \ 'filter': 'FuzzySearchFilter',
        \ })
endfunction

let g:tempKeys = ""
function! FuzzySearchFilter(id, key)
  if a:key ==# " "
    call popup_close(a:id)
  elseif a:key ==# "\<BS>"
    let g:tempKeys = g:tempKeys[:-2]  " remove last char
    echo g:tempKeys
    return 1
  elseif a:key ==# "\<CR>"
    return 1
  elseif strdisplaywidth(a:key) > 0
    let g:tempKeys .= a:key
    echo g:tempKeys
  else
    " For debugging, show special key
    echo "Special key: " . string(a:key)
  endif
  return 1
endfunction
