let g:fuzzbox_mappings = 0
let g:fuzzbox_devicons = 0

Plug 'vim-fuzzbox/fuzzbox.vim'

nnoremap <silent> <Leader>ff <Cmd>FuzzyFiles<CR>
nnoremap <silent> <Leader>fb <Cmd>FuzzyBuffers<CR>
nnoremap <silent> <Leader>fg <Cmd>FuzzyGrep<CR>
nnoremap <silent> <Leader>fr <Cmd>FuzzyMru<CR>
nnoremap <silent> <Leader>fh <Cmd>FuzzyHelp<CR>
