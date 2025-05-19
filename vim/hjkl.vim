let sloc = line('$')
let topline = line('w0')
let botline = line('w$')

function! ListDynamicRanges()
  let start_line = line('w0')
  let end_line = line('w$')

  let total_lines = end_line - start_line + 1
  let range_size = total_lines / 4

  let ranges = []
  for i in range(0, 3)
    let subrange_start = start_line + i * range_size
    let subrange_end = start_line + (i + 1) * range_size - 1
    if i == 3
      let subrange_end = end_line
    endif
    call add(ranges, [subrange_start, subrange_end])
  endfor

  return ranges
endfunction



function! SelectWithKeys()
  "let options = ['Option 1', 'Option 2', 'Option 3']
  let options = ListDynamicRanges()
  let index = 0  " Start with the first option

  while 1
    let key = getchar()
    if key == 106
      let index = (index + 1) % len(options)
    elseif key == 107
      let index = (index - 1 + len(options)) % len(options)
    elseif key == 13 || key == 108
      "echo 'Final selection: ' . options[index]
      break
    endif
    "echo options[index]
    "echo options[index][0] options[index][1]
    execute '2match Comment /^\%>' . (options[index][0]-1) . 'l\%<' . (options[index][1]+1) . 'l.\+$/'
    echo key
  endwhile
endfunction

"call SelectWithKeys()

function! Foo()
  let current_line = getpos('.')[1]
  let matches = []
  let search = 'te'
  for lnum in range(line('w0'), line('w$'))
    let line_text = getline(lnum)
    let start_col = 0
    while 1
      let col = match(line_text, search, start_col)
      if col == -1
        break
      endif
      call add(matches, [lnum, col + 1])
      let start_col = col + 1
    endwhile
  endfor
  let less = filter(copy(matches), {i, v -> v[0] < current_line})
  let more = filter(copy(matches), {i, v -> v[0] >= current_line})
  echo less current_line more
endfunction

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

nnoremap K :call JumpToScreenFraction(0)<CR>
nnoremap J :call JumpToScreenFraction(1)<CR>



function! SetLangInfo() abort
  if exists('g:lang_info')
    return
  endif
  let g:lang_info = {
        \ 'filetype': '',
        \ 'keywords': [],
        \ 'symbols': []
        \ }
  if &filetype ==# 'javascript' || &filetype ==# 'typescript'
    let g:lang_info.filetype = 'javascript'
    let g:lang_info.keywords = ['if', 'else', 'for', 'while', 'function',
          \'const', 'let', 'var', 'return', 'switch', 'case', 'break', 'try',
          \'catch', 'finally', 'typeof', 'new', 'class', 'interface',
          \'extends', 'implements']
  elseif &filetype ==# 'python'
    let g:lang_info.filetype = 'python'
    let g:lang_info.keywords = ['if', 'else', 'elif', 'for', 'while', 'def',
          \'class', 'import', 'from', 'return', 'try', 'except', 'finally',
          \'with', 'as', 'pass', 'break', 'continue', 'lambda', 'global',
          \'nonlocal']
  elseif &filetype ==# 'c'
    let g:lang_info.filetype = 'c'
    let g:lang_info.keywords = ['if', 'else', 'for', 'while', 'do', 'switch',
          \'case', 'break', 'continue', 'return', 'int', 'float', 'char',
          \'double', 'void', 'struct', 'union', 'typedef', 'enum', 'const',
          \'static', 'extern']
  else
    let g:lang_info.filetype = 'unsupported'
    let g:lang_info.keywords = []
  endif
  let g:lang_info.symbols = ['+', '-', '*', '/', '=', '==', '!=', '<', '>',
        \'<=', '>=', '++', '--', '->', '.', ',', ';', '@', '&&', '||',
        \'===', '!==', '?', ':', '&', '|', '^', '~', '%', '!']
endfunction


function! LexWithCoords()
  let current_line = line('.')
  let line_text = getline(current_line)
  let result = []
  let s = line_text
  let col = 1
  let pattern = '\v\w+|[[:punct:]]'
  while len(s) > 0
    let match = matchstr(s, pattern)
    if match == ''
      break
    endif
    let idx = match(line_text[col - 1:], '\V' . escape(match, '\'))
    if idx >= 0
      let real_col = col + idx
      let type = 0
      if match =~ '^\d\+$' || match =~ '^\d*\.\d\+$'
        let type = 1
      elseif match =~ '^\w\+$'
        let type = 2
      endif
      call add(result, [current_line, real_col, match, type])
      let col = real_col + len(match)
    else
      break
    endif
    "let s = a:str[col - 1:]
    let s = line_text[col - 1:]
    let s = substitute(s, '^\s*', '', '')
    let col = col + strlen(line_text[col - 1:]) - strlen(s)
  endwhile
  let g:matches = result
  let g:bar = popup_create(g:resultGetChar, {
        \ 'border': [],
        \ 'filter': 'BarFilter'
        \ })
endfunction


function! LexWithCoords()
  let current_line = line('.')
  let line_text = getline(current_line)
  let result = []
  let s = line_text
  let col = 1
  let pattern = '\v\w+'  " Match only words

  while len(s) > 0
    let match = matchstr(s, pattern)
    if match == ''
      break
    endif

    let idx = match(line_text[col - 1:], '\V' . escape(match, '\'))
    if idx >= 0
      let real_col = col + idx
      call add(result, [current_line, real_col, match])
      let col = real_col + len(match)
    else
      break
    endif

    let s = line_text[col - 1:]
    let s = substitute(s, '^\s*', '', '')
    let col = col + strlen(line_text[col - 1:]) - strlen(s)
  endwhile

  let g:matches = result
  let g:bar = popup_create(g:resultGetChar, {
        \ 'border': [],
        \ 'filter': 'BarFilter'
        \ })
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

"noremap hl :call JancokMenu()<CR>
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

