set helplang=ja,en
set clipboard=unnamedplus
set noswapfile
set ttimeout
set ttimeoutlen=100

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent

set cursorline
set ruler
set number
set relativenumber
set showmatch

set completeopt=menu,menuone,noselect

set hlsearch
set incsearch
set ignorecase
set smartcase

set laststatus=3
set splitbelow
set splitright

set wrap
set linebreak
set showbreak=

set foldmethod=syntax
set foldlevel=99
set autoread

augroup vim_config
  autocmd!
  autocmd WinEnter * checktime
  autocmd FileType qf nnoremap <buffer> <silent> q <Cmd>cclose<CR>
augroup END
