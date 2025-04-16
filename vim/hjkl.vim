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




let x = ListDynamicRanges()[1]


"execute '2match Comment /^\%>' . (x[0]-1) . 'l\%<' . (x[1]+1) . 'l.\+$/'
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
let x= Foo()
