"" Automatically source a Vimscript file when saved
augroup AutoSource
  autocmd!
  " Trigger on BufWritePost for Vimscript files (*.vim)
  autocmd BufWritePost *.vim source %
augroup END

set background=dark
if exists('syntax_on') | syntax reset | endif
hi! clear
let g:colors_name='debug_red'

"for group in getcompletion('', 'highlight')
"  execute "hi! " . group . " cterm=NONE ctermfg=196 ctermbg=NONE"
"  if group != "Normal"
"    execute "hi! link" . group . " cterm=NONE ctermfg=196 ctermbg=NONE"
"  endif
"endfor

"execute "hi! Normal cterm=NONE ctermfg=196 ctermbg=NONE"

let x = [
      \ "Boolean",          
      \ "Comment",          
      \ "Conditional",      
      \ "CursorLine",       
      \ "CursorLineNr",     
      \ "Delimiter",        
      \ "Exception",        
      \ "Function",         
      \ "Identifier",       
      \ "Include",          
      \ "Keyword",          
      \ "Label",            
      \ "LineNr",           
      \ "Macro",            
      \ "NonText",          
      \ "Number",           
      \ "Operator",         
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
      \ "Title",            
      \ "Todo",             
      \ "Type",             
      \ "VertSplit",        
      \ "Visual",
      \ "typescriptVariableDeclaration",
      \ "typescriptClassName",
      \ "typescriptAssign",
      "\ "Normal",          
      \ ]
"for group in x
"  "for group in getcompletion('', 'highlight')
"  "execute "hi! " . group . " cterm=NONE ctermfg=22 ctermbg=NONE"
"endfor

execute "hi! Normal cterm=NONE ctermfg=238 ctermbg=NONE"
hi!  Comment cterm=NONE ctermfg=242 ctermbg=NONE
hi!  CursorLine cterm=NONE ctermfg=NONE ctermbg=235
hi!  CursorLineNr cterm=NONE ctermfg=246 ctermbg=NONE
hi!  Keyword cterm=NONE ctermfg=239 ctermbg=NONE
hi!  LineNr cterm=NONE ctermfg=236 ctermbg=NONE
hi!  NonText cterm=NONE ctermfg=235 ctermbg=NONE
hi!  Number cterm=NONE ctermfg=254 ctermbg=NONE
hi!  String cterm=NONE ctermfg=254 ctermbg=NONE
hi!  StatusLine cterm=NONE ctermfg=232 ctermbg=240
hi!  StatusLineNC cterm=NONE ctermfg=248 ctermbg=234
hi!  StatusLineTerm cterm=NONE ctermfg=232 ctermbg=240
hi!  StatusLineTermNC cterm=NONE ctermfg=248 ctermbg=234
hi!  TabLine cterm=NONE ctermfg=248 ctermbg=234
hi!  TabLineFill cterm=NONE ctermfg=332 ctermbg=240
hi!  TabLineSel cterm=NONE ctermfg=332 ctermbg=240
hi!  Title cterm=NONE ctermfg=232 ctermbg=NONE
hi!  Todo cterm=BOLD ctermfg=255 ctermbg=NONE
hi!  VertSplit cterm=NONE ctermfg=242 ctermbg=NONE
"hi!  Delimiter cterm=NONE ctermfg=21 ctermbg=22
"hi!  Include cterm=NONE ctermfg=236 ctermbg=222
"hi!  Macro cterm=NONE ctermfg=244 ctermbg=22
"hi!  PreCondit cterm=NONE ctermfg=22 ctermbg=22
"hi!  SpecialChar cterm=NONE ctermfg=248 ctermbg=255
"hi!  SpecialComment cterm=NONE ctermfg=248 ctermbg=33
hi!  Boolean cterm=NONE ctermfg=255 ctermbg=NONE
hi!  Conditional cterm=NONE ctermfg=242 ctermbg=NONE
hi!  Exception cterm=NONE ctermfg=244 ctermbg=NONE
hi!  Function cterm=NONE ctermfg=248 ctermbg=NONE
hi!  Identifier cterm=NONE ctermfg=234 ctermbg=NONE
hi!  Label cterm=NONE ctermfg=244 ctermbg=NONE
hi!  Operator cterm=NONE ctermfg=250 ctermbg=NONE
hi!  PreProc cterm=NONE ctermfg=240 ctermbg=NONE
hi!  Repeat cterm=NONE ctermfg=244 ctermbg=NONE
hi!  Special cterm=NONE ctermfg=248 ctermbg=NONE
hi!  Statement cterm=NONE ctermfg=236 ctermbg=NONE
hi!  StorageClass cterm=NONE ctermfg=255 ctermbg=NONE
hi!  Structure cterm=NONE ctermfg=245 ctermbg=NONE
hi!  Type cterm=NONE ctermfg=240 ctermbg=NONE
hi!  Visual cterm=NONE ctermfg=NONE ctermbg=245
hi!  typescriptVariableDeclaration cterm=NONE ctermfg=246 ctermbg=NONE
hi!  typescriptClassName cterm=NONE ctermfg=246 ctermbg=NONE
hi!  typescriptAssign cterm=NONE ctermfg=242 ctermbg=NONE
hi!  typescriptBraces cterm=NONE ctermfg=242 ctermbg=NONE
"
"for group in getcompletion('', 'highlight')
"execute "hi! " . group . " cterm=NONE ctermfg=33 ctermbg=NONE"
"endfor"
"{ = typescriptBraces (highlight: typescriptBraces)
