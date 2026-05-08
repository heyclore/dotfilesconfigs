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

function! NavMenu()
  echo "NavMenu"
  :unmap <leader>j
  let s:nav_menu = popup_create("/_?", {
        \ 'border': [],
        \ 'filter': 'NavMenuFilter',
        \ 'callback': 'Navcallback',
        \ })
endfunction

function! NavMenuFilter(id, key)
  if !exists('s:nav_num')
    let s:nav_num = 0
  endif
  if a:key ==# " "
    call popup_close(a:id)
    nnoremap <leader>j :call NavMenu()<CR>
  elseif a:key ==# "J"
    call JumpToScreenFraction(1)
  elseif a:key ==# "j"
    if s:nav_num
      call NavJump(a:id, 1)
    else
      normal! }
    endif
  elseif a:key ==# "k"
    if s:nav_num
      call NavJump(a:id, 0)
    else
      normal! {
    endif
  elseif a:key ==# "K"
    call JumpToScreenFraction(0)
  elseif a:key =~# '^[0-9]$'
    let s:nav_num = s:nav_num * 10 + str2nr(a:key)
    if s:nav_num > 71
      let s:nav_num = str2nr(a:key)
    endif
    echo s:nav_num
  elseif a:key ==# "h"
    let s:search_direction = '/'
    let s:direction_reverse = '?'
    call popup_close(a:id)
    :unmap <leader>j
    let s:fuzzy_search = popup_create("/", {
          \ 'border': [],
          \ 'filter': 'IncrementalSearchFilterInit',
          \ 'callback': 'Navcallback',
          \ })
  elseif a:key ==# "l"
    let s:search_direction = '?'
    let s:direction_reverse = '/'
    call popup_close(a:id)
    :unmap <leader>j
    let s:fuzzy_search = popup_create("?", {
          \ 'border': [],
          \ 'filter': 'IncrementalSearchFilterInit',
          \ 'callback': 'Navcallback',
          \ })
  elseif a:key ==# "v"
    normal! V
  elseif a:key ==# "d"
    normal! d
  elseif a:key ==# "o"
    normal! o
  elseif a:key ==# "O"
    normal! O
  elseif a:key ==# "u"
    normal! u
  elseif a:key ==# "g"
    normal! =G
  endif
  return 1
endfunction

function! Navcallback(id, key)
  nnoremap <leader>j :call NavMenu()<CR>
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

let s:has_prettier = executable('prettier')

function! FileMenu()
  echo "FileMenu"
  ":unmap hl
  let s:file_menu = popup_create("q w q! gG", {
        \ 'border': [],
        \ 'filter': 'FileMenuFilter',
        \ })
endfunction

function! FileMenuFilter(id, key)
  if a:key ==# " "
  elseif a:key == "h"
    quit
  elseif a:key == "j"
    if &filetype ==# 'typescript' || &filetype ==# 'javascript'
      "execute '!prettier --write ' . shellescape(expand('%:p'))
      "silent %!prettier --stdin-filepath %
      if s:has_prettier
        normal! ma
        silent %!prettier --stdin-filepath % --no-config
        normal! 'a
      endif
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

let s:state_keys = ""
let s:search_direction = ""
let s:direction_reverse = ""
let s:is_result = 0

function! IncrementalSearchFilterInit(id, key)
  if s:is_result
    call IncrementalSearchFilterResult(a:id, a:key)
    return 1
  endif
  if a:key ==# " " || a:key ==# "\<CR>"
    if s:state_keys == ""
      let s:state_keys = ""
      let s:search_direction = ""
      let s:direction_reverse = ""
      call popup_close(a:id)
      return 1
    endif
    call popup_settext(a:id, "@_@")
    let s:is_result =! s:is_result
    "call popup_close(a:id)
    return 1
  elseif a:key ==# "\<BS>"
    let s:state_keys = s:state_keys[:-2]
    if s:state_keys == ""
      return 1
    endif
    silent! execute 'normal!' . s:direction_reverse . "\<CR>"
    echo s:state_keys
  "elseif a:key ==# "\<CR>"
  "  return 1
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
  elseif a:key == "z"
    normal! zz
  endif
  return1
endfunction

"===============================================================================

function! RandomBuffer()
  let visible_buf = []
  for x in split(execute('ls'), '\n')
    let y =  split(x, '')
    if match(y[1], '%') >= 0
      continue
    elseif y[1] == 'h'
      execute 'bdelete!' y[0]
    else
      call add(visible_buf, str2nr(y[0]))
    endif
  endfor

  only
  let counter = 1
  for x in visible_buf
    execute 'vert sb ' . x
    if counter == 2
      execute 'wincmd J'
    endif
    let counter += 1
  endfor
  wincmd w
endfunction

"===============================================================================

let s:isCaps = v:true

function! CapsToggle()
  call system(s:isCaps
        \ ? 'setxkbmap -option caps:escape'
        \ : 'setxkbmap -option')
  let s:isCaps = !s:isCaps
  echo "CAPSLOCK is " . s:isCaps
endfunction

"===============================================================================

function! CloseBuffersSmart()
  let l:has_modified = 0

  for buf in range(1, bufnr('$'))
    if bufexists(buf) && buflisted(buf) && getbufvar(buf, '&modified')
      let l:has_modified = 1
      break
    endif
  endfor

  if !l:has_modified
    qa
    return
  endif

  for buf in range(1, bufnr('$'))
    if bufexists(buf) && buflisted(buf) && !getbufvar(buf, '&modified')
      execute 'bdelete' buf
    endif
  endfor
endfunction

"===============================================================================

function! ConsolePrint()

  exec 'w'

  if &filetype == 'python'
    exec 'bel term python %'
    "exec 'bel term ++shell git log --oneline --graph --all --decorate'
  endif

  if &filetype == 'ruby'
    "exec 'bel term'
    if getline(0,1)[0][0:1] == '##'
      exec 'bel term ++shell ruby %'
    else
      exec 'bel term ++shell bundle exec ruby %'
    endif
  endif

  if &filetype == 'java'
    exec 'bel term ++shell javac % && java %:t:r'
  endif

  if &filetype == 'typescript'
    "npx ts-node foo.ts
    exec 'bel term npx ts-node %'
  endif
  if &filetype == 'javascript'
    exec 'bel term node %'
  endif

  if &filetype == 'c'
    if getline(1) !~ '^#/\*'
      call append(0, '#/*')
      call append(1, 'gcc ' . expand('%') . ' && ./a.out; exit 0; */')
      call append(2, '')
      silent! exec 'chmod +x %'
      return ConsolePrint()
    endif
    "exec 'bel term ++shell gcc -o "%:t:r" % && ./%:t:r'
    "exec 'bel term ++shell gcc -o "%:t:r" -lX11 -lXpm -lXrandr -lm % && ./%:t:r'
    exec 'bel term ./%'
  endif

  if &filetype == 'dart'
    if getline(0,1)[0][0:1] == '//'
      :bel term bash -c "dart %"
    else
      silent exec '!kill -s USR1 "$(pgrep -f flutter_tools.snapshot\ run)" &> /dev/null'
      redraw!
    endif
    "silent exec '!kill -s USR1 "$(pgrep -f flutter_tools.snapshot\ run)" &> /dev/null'
    "redraw!
    ":bel term bash -c "dart %"
  endif
endfunction

"===============================================================================

let s:use_vertical_split = v:true
let s:last_opened_bufnr = 0

function! OpenAlternateBufferWithSmartSplit() abort
  let l:alt_bufnr = bufnr('#')
  if l:alt_bufnr == -1
    return
  endif

  if s:last_opened_bufnr != bufnr('%')
    if winwidth(0) * 8 > winheight(0) * 14
      execute 'vsplit | buffer ' . l:alt_bufnr
      let s:use_vertical_split = v:false
    else
      execute 'split | buffer ' . l:alt_bufnr
    endif
    let s:last_opened_bufnr = l:alt_bufnr
  else
    if winnr('$') > 1
      close
    endif

    if s:use_vertical_split
      execute 'vsplit | buffer ' . s:last_opened_bufnr
    else
      execute 'split | buffer ' . s:last_opened_bufnr
    endif
    let s:use_vertical_split = !s:use_vertical_split
  endif

endfunction

"===============================================================================

function! CopyToClipboard(text)
    call system('xclip -selection clipboard', a:text)
endfunction

"===============================================================================

"nnoremap hl :call HJKLmenu()<CR>
let mapleader = " "
nnoremap <leader>h :call FileMenu()<CR>
nnoremap <leader>j :call NavMenu()<CR>
nnoremap <leader>k :echo 'kkk'<CR>
nnoremap <leader>l :echo 'lll'<CR>
nnoremap <Tab><Tab> :EditVifm<CR>
nnoremap <Tab>q :call OpenAlternateBufferWithSmartSplit()<CR>
nnoremap <Home> <C-w>w
nnoremap <F1> :q!<CR>
nnoremap <F2> <Cmd>w<CR>
nnoremap <F3> :call CloseBuffersSmart()<CR>
nnoremap <F4> :call ConsolePrint()<CR>
nnoremap <F5> <Cmd>silent write !xclip -selection clipboard > /dev/null 2>&1<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap ; :
nnoremap : ;
"nnoremap <Esc><Esc> :
"nnoremap W :call RandomBuffer()<CR>

"inoremap jk <CR>
"inoremap hl <ESC>:call HJKLmenu()<CR>
inoremap jj <ESC>
inoremap <C-h> <C-x><C-o>
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>
inoremap <C-l> .
nnoremap yy yy:call CopyToClipboard(getreg('"'))<CR>
vnoremap y y:call CopyToClipboard(getreg('"'))<CR>
nnoremap <Esc>h :echo "ALT-h"<CR>
nnoremap <Esc>j :echo "ALT-j"<CR>
nnoremap <Esc>k :echo "ALT-k"<CR>
nnoremap <Esc>l :echo "ALT-l"<CR>
"inoremap <F2> <Cmd>w<CR>
"inoremap <F3> <ESC>:call ConsolePrint()<CR>

"autocmd VimEnter * call system('setxkbmap -option caps:escape')
"autocmd VimLeave * call system('setxkbmap -option')

