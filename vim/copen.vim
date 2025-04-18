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

function! ShowCopenPopup(arg)
  let g:current_line = getpos('.')
  if a:arg == ''
    if empty(g:copen_list)
      echo "?_?"
      return 1
    endif
  else
    execute 'silent! vimgrep /' . a:arg . '/ %'
    let g:copen_list = map(getqflist(), 'bufname(v:val.bufnr) . ":" . v:val.lnum . "|" . v:val.text')
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
        \ 'filter': 'CopenPopupFilter'
        \ })
endfunction

function! CopenPopupFilter(id, key)
  if a:key == "\<Esc>" || a:key == "\<CR>" || a:key == "l"
    call popup_close(a:id)
  elseif a:key == "k" || a:key == "\<Up>"
    let g:copen_selected = (g:copen_selected - 1 + len(g:copen_list)) % len(g:copen_list)
    execute 'silent! cc ' . (g:copen_selected + 1)
  elseif a:key == "j" || a:key == "\<Down>"
    let g:copen_selected = (g:copen_selected + 1) % len(g:copen_list)
    execute 'silent! cc ' . (g:copen_selected + 1)
  else
    return 0
  endif
  call popup_settext(g:copen_popup_id, 1 + g:copen_selected . "/" . len(g:copen_list))
  call popup_move(a:id, {'line': 'cursor+1', 'col': 'cursor+13'})
  return 1
endfunction

command! -nargs=? C call ShowCopenPopup(<q-args>)

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

function! Foo()
  let current_line = getpos('.')[1]
  let g:matches = []
  for lnum in range(line('w0'), line('w$'))
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
  "let less = filter(copy(matches), {i, v -> v[0] < current_line})
  "let more = filter(copy(matches), {i, v -> v[0] >= current_line})
  "echo less current_line more
  "echo matches getpos('.')
  let g:bar = popup_create("baz", {
        \ 'border': [],
        \ 'filter': 'BarFilter'
        \ })
endfunction
function! BarFilter(id, key)
  let curline = line('.')
  let target = []
  if a:key ==# " "
    echo 123
  elseif a:key == "h"
    normal! b
    return 1
  elseif a:key == "j"
    for loc in g:matches
      if loc[0] > curline
        let target = loc
        break
      endif
    endfor
  elseif a:key == "k"
    for loc in reverse(copy(g:matches))
      if loc[0] < curline
        let target = loc
        break
      endif
    endfor
  elseif a:key == "l"
    let current_word = expand("<cword>")
    let start_pos = searchpos(current_word, 'n')
    let end_pos = [start_pos[0], start_pos[1] + strlen(current_word) - 1]
    echo start_pos end_pos
    return 1
  else
    call popup_close(a:id)
  endif
  if !empty(target)
    call setpos('.', [0, target[0], target[1], 0])
  endif
  return 1
endfunction

"===============================================================================

let g:resultGetChar = ""
let g:jancokBool = 1
let g:jancokTitle = [
      \["Search Down Up Save", "H Indent K L"],
      \["h j k l", "H Switch K L"]
      \]

function! JancokMenu()
  let g:gg = popup_create(g:jancokTitle[0], {
        \ 'border': [],
        \ 'filter': 'JancokFilter'
        \ })
endfunction
function! JancokFilter(id, key)
  if g:jancokBool
    if a:key ==# " "
      let g:jancokBool = !g:jancokBool
      call popup_settext(a:id, g:jancokTitle[1])
      return 1
    elseif a:key == "h"
      let x = input("?_? ")
      if x != ''
        let g:resultGetChar = x
        call popup_close(a:id)
        call Foo()
      endif
    elseif a:key == "j"
      call JumpToScreenFraction(1)
      return 1
    elseif a:key == "k"
      call JumpToScreenFraction(0)
      return 1
    elseif a:key == "l"
      w
    elseif a:key == "H"
      return 1
    elseif a:key == "J"
      normal! gg=G''zz
    elseif a:key == "K"
      return 1
    elseif a:key == "L"
      return 1
    endif
    call popup_close(a:id)
    return 1
  else
    if a:key ==# " "
      let g:jancokBool = !g:jancokBool
      call popup_settext(a:id, g:jancokTitle[0])
      return 1
    elseif a:key == "h"
      return 1
    elseif a:key == "j"
      return 1
    elseif a:key == "k"
      return 1
    elseif a:key == "l"
      return 1
    elseif a:key == "H"
      return 1
    elseif a:key == "J"
      execute "normal! \<C-w>w"
      call popup_move(a:id, {'line': 'cursor+1', 'col': 'cursor+13'})
      return 1
    elseif a:key == "K"
      return 1
    elseif a:key == "L"
      return 1
    endif
    let g:jancokBool = !g:jancokBool
    call popup_close(a:id)
    return 1
  endif
endfunction
