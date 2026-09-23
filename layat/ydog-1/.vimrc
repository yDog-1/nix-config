set nocompatible
scriptencoding utf-8

if has('win32')
  let s:vim_config_root = expand('~/vimfiles')
else
  let s:vim_config_root = expand('<sfile>:p:h') . '/.vim'
endif

execute 'source' fnameescape(s:vim_config_root . '/options.vim')
execute 'source' fnameescape(s:vim_config_root . '/keymaps.vim')
execute 'source' fnameescape(s:vim_config_root . '/config/vim-plug.vim')
