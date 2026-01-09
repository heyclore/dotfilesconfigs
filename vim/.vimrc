vim9script

g:netrw_banner = 0
g:netrw_liststyle = 3
g:netrw_dirhistmax = 0
g:netrw_hide = 1
g:netrw_keepdir = 0
g:netrw_disable_netrwPlugin = 1
g:nnn#set_default_mappings = 0

filetype plugin indent on
syntax on
colorscheme darkness
hi Normal guibg=NONE ctermbg=NONE

set autoread
set number
set relativenumber
set wildmenu
set signcolumn=no
set noshowmode
set splitright
set splitbelow
set hidden
set mouse=a
set ts=2 sw=2 expandtab
set shell=/bin/bash
set path=.,,
set completeopt=menuone,noselect
set laststatus=2
set nobackup
set nowritebackup
set noswapfile
set lazyredraw
set ttyfast
set updatetime=300
set cursorline

####################################################################

def SetupPlugins(): void
  var plugins = {
    start: [
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

####################################################################

const mode_map = {
  n:  '  NORMAL ',
  i:  '  INSERT ',
  v:  '  VISUAL ',
  V:  '  V-LINE ',
  "\<C-V>": '  V-BLOCK ',
  c:  '  COMMAND ',
  R:  '  REPLACE ',
  s:  '  SELECT ',
  t:  '  TERMINAL ',
}

def g:GetMode(): string
  return get(mode_map, mode(), mode())
enddef

set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{%g:GetMode()%}
set statusline+=%#StatusLine#
set statusline+=\ %f%m%r%h%w
set statusline+=%=
set statusline+=%#StatusLineNC#
set statusline+=\ %y
set statusline+=%#PmenuSel#
set statusline+=\ %{(&fenc!=''?&fenc:&enc)}[%{&ff}]
set statusline+=%#StatusLine#
set statusline+=\ %l/%L\ col:%c\ %P

####################################################################

if exists('$JANCOK')
  packadd vim-lsp
  packadd vim-lsp-settings

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
