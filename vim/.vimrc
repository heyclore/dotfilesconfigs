" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

let bash_variable = system('echo $JANCOK')
call vundle#begin()
Plugin 'chrisbra/csv.vim'
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'Jorengarenar/vim-darkness'
Plugin 'jreybert/vimagit'
if bash_variable == 1
  Plugin 'dart-lang/dart-vim-plugin'
  Plugin 'prabirshrestha/vim-lsp'
  Plugin 'mattn/vim-lsp-settings'
endif
"Plugin 'natebosch/vim-lsc'
"Plugin 'natebosch/vim-lsc-dart'
"Plugin 'ryanpcmcquen/true-monochrome_vim'
call vundle#end()            " required

filetype plugin indent on    " required
filetype plugin on
filetype off                 " required

"set t_Co=256
set nocompatible             " be iMproved, required
set number
set relativenumber
set encoding=utf-8
set listchars=eol:¶,space:·
"set autochdir
set path+=**
set wildmenu
set showcmd
set noshowmode
set nobackup
set nowritebackup
set noswapfile
set cursorline
set cursorcolumn
set colorcolumn=80
set mouse=a
set completeopt-=preview
set ts=2 sw=2 expandtab
set shell=bash\ -l
set signcolumn=no
"set nowrap
"set incsearch

let g:airline_theme = 'base16_grayscale'
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_preview = 1
let airline#extensions#whitespace#enabled = 0
let g:magit_update_mode = 'fast'

nnoremap <C-1> 1gt <CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
inoremap jj <ESC>
inoremap jk <CR>
nnoremap ZZ :q<CR>
nnoremap Zz :q!<CR>

" Swap [ with Shift+[ (i.e., {)
"nnoremap [ {
"nnoremap { [
"vnoremap [ {
"vnoremap { [
"inoremap [ {
"inoremap { [

" Swap ] with Shift+] (i.e., })
"nnoremap ] }
"nnoremap } ]
"vnoremap ] }
"vnoremap } ]
"inoremap ] }
"inoremap } ]

"hi Directory ctermfg=243
hi Normal guibg=NONE ctermbg=NONE

colorscheme darkness
syntax enable

"##### FUCNTION ##### <CR>
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

  if &filetype == 'javascript'
    exec 'bel term node %'
  endif

  if &filetype == 'c'
    "exec 'bel term ++shell gcc -o "%:t:r" % && ./%:t:r'
    exec 'bel term ++shell gcc -o "%:t:r" -lX11 -lXpm -lXrandr % && ./%:t:r'
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

function! SearchMultipleValues()
  " Clear previous search highlights
  silent! :nohlsearch

  " Search for multiple values
  vimgrep /4495685\|5430625/ %
  copen  " Open the quickfix window to navigate through matches
endfunction

"nmap <F4> :LSClientShowHover<CR>
"nmap <F3> :copen <CR>
nmap <F2> :call ConsolePrint()<CR>
nmap <F1> :call SearchMultipleValues()<CR>
nnoremap Q :bd<CR>
""##### END FUCNTION #####
"let g:lsc_dart_sdk_path = '~/AUR/flutter/bin/cache/dart-sdk/'
"let g:lsc_auto_map = {
"    \ 'GoToDefinitionSplit': '<C-]>',
"    \ 'FindReferences': 'gr',
"    \ 'NextReference': '<C-n>',
"    \ 'PreviousReference': '<C-p>',
"    \ 'FindImplementations': 'gI',
"    \ 'FindCodeActions': 'ga',
"    \ 'Rename': 'gR',
"    \ 'ShowHover': v:false,
"    \ 'DocumentSymbol': 'go',
"    \ 'WorkspaceSymbol': 'gS',
"    \ 'SignatureHelp': 'gm',
"    \ 'Completion': 'completefunc',
"    \}

function! s:on_lsp_buffer_enabled() abort
  "setlocal omnifunc=lsp#complete
  "setlocal signcolumn=yes
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  nmap <buffer> ga <plug>(lsp-code-action-float)
  nmap <buffer> gs <plug>(lsp-document-symbol-search)
  nmap <buffer> [\ <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]\ <plug>(lsp-next-diagnostic)
  nmap <buffer> K <plug>(lsp-hover)
  "nmap <buffer> gd <plug>(lsp-definition)
  "nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
  "nmap <buffer> gr <plug>(lsp-references)
  "nmap <buffer> gi <plug>(lsp-implementation)
  "nmap <buffer> gt <plug>(lsp-type-definition)
  "nmap <buffer> <leader>rn <plug>(lsp-rename)
  "nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
  "nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

  "let g:lsp_format_sync_timeout = 1000
  "autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

  " refer to doc to add more commands
endfunction

augroup lsp_install
  au!
  " call s:on_lsp_buffer_enabled only for languages that has the server registered.
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
let g:csv_delim=','
let g:csv_default_delim=','

function! Asu()
  exec 'source /home/noodle/apps/git/dotfilesconfigs/vim/copen.vim'
endfunction

nmap <F3> :call Asu()<CR>
noremap hl :call JancokMenu()<CR>
