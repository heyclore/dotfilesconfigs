vim9script

def SetupPlugins(): void
  var plugins = {
    start: [
      'https://github.com/vim-airline/vim-airline',
      'https://github.com/vim-airline/vim-airline-themes',
      'https://github.com/Jorengarenar/vim-darkness',
      'https://github.com/mcchrish/nnn.vim',
    ],
    opt: [
      'https://github.com/prabirshrestha/vim-lsp',
      'https://github.com/mattn/vim-lsp-settings',
    ]
  }

  if !executable('git')
    echo 'Git not found!'
    return
  endif

  var base = expand('~/.vim/pack/git_plugins')
  mkdir(base .. '/start', 'p')
  mkdir(base .. '/opt', 'p')

  def RepoName(url: string): string
    return substitute(substitute(url, '.*/', '', ''), '\.git$', '', '')
  enddef

  # ---- build set of wanted plugins ----
  var wanted = {}
  for type in ['start', 'opt']
    for url in plugins[type]
      wanted[type .. '/' .. RepoName(url)] = true
    endfor
  endfor

  # ---- clone missing plugins ----
  for type in ['start', 'opt']
    var dirBase = base .. '/' .. type
    for url in plugins[type]
      var name = RepoName(url)
      var dir = dirBase .. '/' .. name
      if !isdirectory(dir)
        echo 'Cloning ' .. type .. ': ' .. url
        system('git clone --depth 1 ' .. url .. ' ' .. dir)
      endif
    endfor
  endfor

  # ---- remove unused plugins ----
  for type in ['start', 'opt']
    var dirBase = base .. '/' .. type
    for dir in glob(dirBase .. '/*', false, true)
      var key = type .. '/' .. fnamemodify(dir, ':t')
      if !has_key(wanted, key)
        echo 'Removing unused plugin: ' .. dir
        delete(dir, 'rf')
      endif
    endfor
  endfor

  echo 'Plugins synced!'
enddef
command! LL call SetupPlugins()


filetype plugin indent on
hi Normal guibg=NONE ctermbg=NONE
syntax enable
colorscheme darkness

setlocal autoread
set number
set relativenumber
set listchars=eol:¶,space:·
#set cursorcolumn
set cursorline
set colorcolumn=80
set mouse=a
set noshowmode
set path+=**
set wildmenu
set completeopt-=preview
set ts=2 sw=2 expandtab
set nobackup
set nowritebackup
set noswapfile
set shell=/bin/bash
set signcolumn=no
set splitright
set splitbelow
set hidden

g:airline_theme = 'base16_grayscale'
g:netrw_banner = 0
g:netrw_liststyle = 3
g:netrw_preview = 1
g:airline#extensions#whitespace#enabled = 0


if exists('$JANCOK')
  packadd vim-lsp
  packadd vim-lsp-settings

  #setlocal omnifunc=lsp#complete
  #if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  #nmap <buffer> ga <plug>(lsp-code-action-float)
  #nmap <buffer> gs <plug>(lsp-document-symbol-search)
  #nmap <buffer> [\ <plug>(lsp-previous-diagnostic)
  #nmap <buffer> ]\ <plug>(lsp-next-diagnostic)
  #nmap <buffer> K <plug>(lsp-hover)
  #nmap <buffer> gd <plug>(lsp-definition)
  #nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
  #nmap <buffer> gr <plug>(lsp-references)
  #nmap <buffer> gi <plug>(lsp-implementation)
  #nmap <buffer> gt <plug>(lsp-type-definition)
  #nnoremap <buffer> gt :split<CR><plug>(lsp-type-definition)
  #nmap <buffer> <leader>rn <plug>(lsp-rename)
  #nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
  #nnoremap <buffer> <expr><c-d> lsp#scroll(-4)
  #inoremap <buffer> <C-x><C-x> <C-x><C-o>

  augroup OptionalLSP
    autocmd!
    autocmd FileType * {
      setlocal omnifunc=lsp#complete
      if exists('+tagfunc')
        setlocal tagfunc=lsp#tagfunc
      endif
      nnoremap <buffer> ga <plug>(lsp-code-action-float)
      nnoremap <buffer> gs <plug>(lsp-document-symbol-search)
      nnoremap <buffer> [\ <plug>(lsp-previous-diagnostic)
      nnoremap <buffer> ]\ <plug>(lsp-next-diagnostic)
      nnoremap <buffer> K <plug>(lsp-hover)
      nnoremap <buffer> gt :split<CR><plug>(lsp-type-definition)
      inoremap <buffer> <C-x><C-x> <C-x><C-o>
    }
  augroup END
endif

source /home/noodle/apps/git/dotfilesconfigs/vim/hjkl.vim
