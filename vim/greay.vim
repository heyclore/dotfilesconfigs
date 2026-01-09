"" Automatically source a Vimscript file when saved
augroup AutoSource
  autocmd!
  " Trigger on BufWritePost for Vimscript files (*.vim)
  autocmd BufWritePost *.vim source %
augroup END

set background=dark
hi clear
if exists('syntax_on') | syntax reset | endif
let g:colors_name='debug_red'

let x = [
      \ "Boolean",
      \ "Comment",
      \ "Conditional",
      \ "CursorLine",
      \ "CursorLineNr",
      \ "Delimiter",
      \ "Exception",   "here",
      \ "Function",
      \ "Identifier", 'heee',
      \ "Include",
      \ "Keyword",
      \ "Label",
      \ "LineNr",
      \ "Macro",
      \ "Normal",
      \ "NonText",
      \ "Number",
      \ "Operator",
      \ "Pmenu",
      \ "PmenuSbar",
      \ "PmenuSel",
      \ "PreCondit",
      \ "PreProc",
      \ "Repeat",
      \ "Special",
      \ "SpecialChar",
      \ "SpecialComment",
      \ "Statement",
      \ "StatusLine",
      \ "StatusLineNC",
      \ "StatusLineTerm",
      \ "StatusLineTermNC",
      \ "StorageClass",
      \ "String",
      \ "Structure",
      \ "TabLine",
      \ "TabLineFill",
      \ "TabLineSel",
      \ "Tag",
      \ "Title",
      \ "Todo",
      \ "Type",
      \ "VertSplit",
      \ "Visual",
      \ "WarningMsg",
      \ "WildMenu", 'aa'
      \ ]

for group in x
  "execute "hi! link " . group . " Merah"
  execute "hi! " . group . " cterm=NONE ctermfg=NONE  ctermbg=NONE "
endfor
