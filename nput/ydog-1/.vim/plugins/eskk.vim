let g:eskk#no_default_mappings = 1
let g:eskk#enable_completion = 0
let g:eskk#show_candidates_count = 2
let g:eskk#marker_henkan = ''
let g:eskk#marker_henkan_select = ''

if exists('$SKK_DICT_PATH') && !empty($SKK_DICT_PATH)
  let g:eskk#directory = $SKK_DICT_PATH . '/eskk'
  let g:eskk#dictionary = {
        \ 'path': $SKK_DICT_PATH . '/SKK-JISYO.user',
        \ 'sorted': 0,
        \ 'encoding': 'utf-8',
        \ }
endif

if exists('$SKK_DICT_PATHS') && !empty($SKK_DICT_PATHS)
  let g:eskk#large_dictionary = {
        \ 'path': split($SKK_DICT_PATHS, ',')[0],
        \ 'sorted': 1,
        \ 'encoding': 'euc-jp',
        \ }
endif

Plug 'vim-skk/eskk.vim'

imap <C-f> <Plug>(eskk:toggle)
cmap <C-f> <Plug>(eskk:toggle)
