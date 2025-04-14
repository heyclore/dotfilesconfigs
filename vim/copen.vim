let g:copen_list = []
let g:copen_selected = 0

function! ShowCopenPopup(arg)
  if a:arg == ''
    if empty(g:copen_list)
      return 1
    endif
  else
    execute 'silent! vimgrep /' . a:arg . '/ %'
    let g:copen_list = map(getqflist(), 'bufname(v:val.bufnr) . ":" . v:val.lnum . "|" . v:val.text')
    if empty(g:copen_list)
      return 1
    endif
    let g:foo = a:arg
  endif

  let content = copy(g:copen_list)
  let g:copen_selected = 0
  let g:copen_popup_id = popup_create(g:foo, {
        \ 'line': 'cursor',
        \ 'col': 'cursor+13',
        \ 'border': [],
        \ 'filter': 'CopenPopupFilter'
        \ })
endfunction

function! CopenPopupFilter(id, key)
  if a:key == "\<Esc>"
    call popup_close(a:id)
    return 1
  elseif a:key == "\<CR>" || a:key == "l"
    call popup_close(a:id)
    return 1
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
  call popup_move(a:id, {'line': 'cursor', 'col': 'cursor+13'})
  return 1
endfunction

command! -nargs=? C call ShowCopenPopup(<q-args>)
