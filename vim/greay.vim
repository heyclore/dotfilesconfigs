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
function! OpenAlternateBufferWithSmartSplit(x)
  if x
  else
    let xx = {}
  endif
endfunction
let x = [
      \ "Boolean",          "true,false,null",
      \ "Comment",          "comment",
      \ "Conditional",      "if,else,switch,case,break,default",
      \ "CursorLine",       "set-cursorline",
      \ "CursorLineNr",     "set-number",
      \ "Delimiter",        "()-[]-{}",
      \ "Exception",        ";-try-catch-throw",
      \ "Function",         "Point{xy}-version-new-constructor-fetch-#privateField-exist",
      \ "Identifier",       "Point-Result-true-false-Array-ID-Promise-T-Error-args-any-obj-User-%-g:",
      \ "Include",          "#include",
      \ "Keyword",          "export-interface-const-type-class-async-public-protected-await-extends",
      \ "Label",            "x-y-ok-value-${}-case-default",
      \ "LineNr",           "set-number",
      \ "Macro",            "#define-MAX",
      \ "Normal",           "all-text",
      \ "NonText",          "set-number*",
      \ "Number",           "1-2-3-4-999",
      \ "Operator",         "new-,-typeof-in",
      \ "PreCondit",        "#if-#endif",
      \ "PreProc",          "name-a-b-id?-data-err-resolve-ms-ok-value-n-obj",
      \ "Repeat",           "for-while-do",
      \ "Special",          "value-@sealed-as",
      \ "SpecialChar",      "%d=%s-%c-%.2f",
      \ "SpecialComment",   "@",
      \ "Statement",        "let-for-in-execute-endfor-return-break-hi-vim*",
      \ "StatusLine",       "NORMAL-foo.vim-[vim]-utf8[unix]-22/33-col:11-bot",
      \ "StatusLineNC",     "[vim]-[c]-[typescript]",
      \ "StatusLineTerm",   ":terminal",
      \ "StatusLineTermNC", ":terminal",
      \ "StorageClass",     "const-readonly-static",
      \ "String",           "string-termasuk-quote",
      \ "Structure",        "name-Error-this-Object-Promise-console-setTimeout",
      \ "TabLine",          "tabe",
      \ "TabLineFill",      "tabe",
      \ "TabLineSel",       "tabe",
      \ "Title",            "tabe",
      \ "Todo",             "TODOOS",
      \ "Type",             "number-string-null-void-=>-",
      \ "VertSplit",        "vsplit-separator",
      \ "Visual",           "VISUAL-V-LINE",
      \ ]

for group in x
  execute "hi! " . group . " cterm=NONE ctermfg=NONE  ctermbg=NONE "
endfor

hi WildMenu       cterm=NONE ctermfg=196 ctermbg=NONE
