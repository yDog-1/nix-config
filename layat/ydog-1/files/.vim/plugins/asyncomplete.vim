Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'

augroup asyncomplete_config
  autocmd!
  autocmd User asyncomplete_setup call asyncomplete#register_source(
        \ asyncomplete#sources#buffer#get_source_options({
        \   'name': 'buffer',
        \   'allowlist': ['*'],
        \   'completor': function('asyncomplete#sources#buffer#completor'),
        \ }))
augroup END
