let s:vim_home = has('win32') ? expand('~/vimfiles') : expand('~/.vim')
let s:vim_plug = s:vim_home . '/autoload/plug.vim'
if !filereadable(s:vim_plug)
  call mkdir(fnamemodify(s:vim_plug, ':h'), 'p')
  let s:download_attempted = 0

  if has('win32')
    if !executable('powershell')
      echoerr 'vim-plug requires PowerShell for its initial installation on Windows'
    else
      let s:download_attempted = 1
      call system(
            \ 'powershell -NoProfile -Command "iwr -useb '
            \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim '
            \ . '| ni $HOME/vimfiles/autoload/plug.vim -Force"'
            \ )
    endif
  elseif !executable('curl')
    echoerr 'vim-plug requires curl for its initial installation'
  else
    let s:download_attempted = 1
    call system([
          \ 'curl',
          \ '-fLo',
          \ s:vim_plug,
          \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
          \ ])
  endif

  if s:download_attempted
    if v:shell_error
      echoerr 'Failed to install vim-plug'
    else
      augroup vim_plug_bootstrap
        autocmd!
        autocmd VimEnter * ++once PlugInstall --sync | source $MYVIMRC
      augroup END
    endif
  endif
endif

if filereadable(s:vim_plug)
  call plug#begin(s:vim_home . '/plugged')

  let s:plugins_dir = fnamemodify(expand('<sfile>:p'), ':h:h') . '/plugins'
  for s:plugin_config in sort(glob(s:plugins_dir . '/*.vim', 0, 1))
    execute 'source' fnameescape(s:plugin_config)
  endfor

  call plug#end()
endif
