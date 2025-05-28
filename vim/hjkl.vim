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

function! HJKLmenu()
  echo "HJKLmenu"
  :unmap hl
  :unmap lh
  let s:hjkl_menu = popup_create("/ jk % @_@", {
        \ 'border': [],
        \ 'filter': 'HJKLfilter',
        \ 'callback': 'HJKLcallback',
        \ })
endfunction

noremap hl :call HJKLmenu()<CR>

function! HJKLfilter(id, key)
  if a:key ==# " "
    call popup_close(a:id)
  elseif a:key == "h"
    call popup_close(a:id)
    call IncrementalSearch()
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
    if &filetype ==# 'typescript' || &filetype ==# 'javascript'
      "execute '!prettier --write ' . shellescape(expand('%:p'))
      normal! ma
      silent %!prettier --stdin-filepath %
      normal! 'a
    endif
    write
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

function! IncrementalSearch()
  echo "IncrementalSearch"
  normal! 0
  :unmap hl
  :unmap lh
  let s:fuzzy_search = popup_create("$ j? k? @_@", {
        \ 'border': [],
        \ 'filter': 'IncrementalSearchFilter',
        \ 'callback': 'HJKLcallback'
        \ })
endfunction

let s:state_keys = ""
let s:search_direction = ""
let s:direction_reverse = ""
let s:is_result = 0

function! IncrementalSearchFilter(id, key)
  if s:search_direction == '/' || s:search_direction == '?'
    call IncrementalSearchFilterInit(a:id, a:key)
    return 1
  endif
  if a:key ==# " "
    call popup_close(a:id)
  elseif a:key == "h"
    let s:is_result =! s:is_result
    let s:search_direction = '?'
    call IncrementalSearchFilterInit(a:id, a:key)
  elseif a:key == "j"
    let s:search_direction = '/'
    let s:direction_reverse = '?'
  call popup_settext(a:id, s:search_direction)
  elseif a:key == "k"
    let s:search_direction = '?'
    let s:direction_reverse = '/'
  call popup_settext(a:id, s:search_direction)
  elseif a:key == "l"
    echo 4
  endif
  return 1
endfunction

function! IncrementalSearchFilterInit(id, key)
  if s:is_result
    call IncrementalSearchFilterResult(a:id, a:key)
    return 1
  endif
  if a:key ==# " "
    if s:state_keys == ""
      let s:state_keys = ""
      let s:search_direction = ""
      let s:direction_reverse = ""
      call popup_close(a:id)
      return 1
    endif
  call popup_settext(a:id, "@_@")
    let s:is_result =! s:is_result
    return 1
  elseif a:key ==# "\<BS>"
    let s:state_keys = s:state_keys[:-2]
    if s:state_keys == ""
      return 1
    endif
    silent! execute 'normal!' . s:direction_reverse . "\<CR>"
    echo s:state_keys
  elseif a:key ==# "\<CR>"
    return 1
  elseif a:key =~# '^[A-Za-z0-9]$'
    let s:state_keys .= a:key
    call setreg("/", s:state_keys)
    silent! execute 'normal!'. s:search_direction . "\<CR>"
    echo s:state_keys
  else
    echo "Special key: " . string(a:key)
  endif
  return 1
endfunction

function! IncrementalSearchFilterResult(id, key)
  if a:key ==# " "
    let s:state_keys = ""
    let s:search_direction = ""
    let s:direction_reverse = ""
    let s:is_result =! s:is_result
    call popup_close(a:id)
  elseif a:key == "j"
    normal! n
  elseif a:key == "k"
    normal! N
  endif
  return1
endfunction

"===============================================================================
