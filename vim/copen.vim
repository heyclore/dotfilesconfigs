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

let g:resultGetChar = ""
let g:jancokBool = 1
let g:jancokTitle = ["H:Indent J:Search K:Save L:Quit","H: J:Down K:Up L:L"]

function! JancokMenu()
  let g:gg = popup_create(g:jancokTitle[0], {
        "\ 'line': 'cursor',
        "\ 'col': 'cursor+13',
        \ 'pos': 'center',
        \ 'border': [],
        \ 'filter': 'JancokFilter'
        \ })
endfunction
function! JancokFilter(id, key)
  if g:jancokBool
    if a:key == "h"
      normal! gg=G''
    elseif a:key == "j"
      let x = input("?_? ")
      if x != ''
        let g:resultGetChar = x
      endif
      return 1
    elseif a:key == "k"
      w
    elseif a:key == "l"
      q
    elseif a:key ==# " "
      let g:jancokBool = !g:jancokBool
      call popup_settext(a:id, g:jancokTitle[1])
      return 1
    endif
    call popup_close(a:id)
    return 1
  else
    if a:key == "h"
      return 1
    elseif a:key == "j"
      call JumpToScreenFraction(1)
      return 1
    elseif a:key == "k"
      call JumpToScreenFraction(0)
      return 1
    elseif a:key == "l"
      return 1
    elseif a:key ==# " "
      let g:jancokBool = !g:jancokBool
      call popup_settext(a:id, g:jancokTitle[0])
      return 1
    endif
    let g:jancokBool = !g:jancokBool
    call popup_close(a:id)
    return 1
  endif
endfunction
