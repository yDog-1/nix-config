let mapleader = ' '
nnoremap <Space> <Nop>
xnoremap <Space> <Nop>

inoremap <silent> jj <Esc>

function! s:JumpToNextClosingPair() abort
  call search("[])}\"'`]", 'W')
endfunction

if !has('gui_running')
  execute "set <M-m>=\em"
endif
inoremap <silent> <M-m> <C-r>=lexima#insmode#escape()<CR><Esc>:call <SID>JumpToNextClosingPair()<CR>a

nnoremap <silent> <expr> <M-j>
      \ line('.') < line('$') ? "\<Cmd>move .+1\<CR>" : ''
nnoremap <silent> <expr> <M-k>
      \ line('.') > 1 ? "\<Cmd>move .-2\<CR>" : ''

nnoremap <silent> <Leader>n <Cmd>nohlsearch<CR>
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
xnoremap <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
xnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <Leader><CR> i<CR><Esc>

nnoremap x "_x
xnoremap x "_x
nnoremap X "_d
xnoremap X "_d

nnoremap <silent> <Leader>q <Cmd>copen<CR>

function! s:UppercasePreviousWord() abort
  let l:before_cursor = strpart(getline('.'), 0, col('.') - 1)
  let l:word = matchstr(l:before_cursor, '\v<(\k(<)@!)*$')
  return "\<C-W>" . toupper(l:word)
endfunction

inoremap <expr> <C-k> <SID>UppercasePreviousWord()
tnoremap <C-]><C-]> <C-W>N

" Neovim defaults that are not mapped by Vim.
nnoremap Y y$
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>
nnoremap <silent> <C-L> <Cmd>nohlsearch<Bar>diffupdate<Bar>redraw!<CR>
nnoremap & :&&<CR>

function! s:VisualSearch(forward) abort
  let l:cursor = getpos('.')
  let l:anchor = getpos('v')
  let l:visual_mode = mode()
  let l:lines = getregion(l:cursor, l:anchor, {'type': l:visual_mode})
  let l:pattern = join(map(l:lines, {_, value -> escape(value, '\')}), '\n')
  if empty(l:pattern)
    return "\<Esc>"
  endif

  let l:pattern = '\V' . l:pattern
  call setreg('/', l:pattern)
  call histadd('/', l:pattern)
  let v:searchforward = a:forward

  let l:count = v:count1
  if !a:forward && (l:cursor[1] > l:anchor[1]
        \ || (l:cursor[1] == l:anchor[1] && l:cursor[2] > l:anchor[2]))
    let l:count += 1
  endif
  return "\<Esc>" . l:count . 'n'
endfunction

xnoremap <expr> * <SID>VisualSearch(1)
xnoremap <expr> # <SID>VisualSearch(0)

function! s:VisualMacro() abort
  if mode() !=# 'V'
    return '@'
  endif
  return ':normal! @' . getcharstr() . "\<CR>"
endfunction

xnoremap <silent> <expr> @ <SID>VisualMacro()
xnoremap <silent> Q :normal! @@<CR>

nnoremap <silent> [q <Cmd>execute v:count1 . 'cprevious'<CR>
nnoremap <silent> ]q <Cmd>execute v:count1 . 'cnext'<CR>
nnoremap <silent> [Q <Cmd>execute v:count ? v:count . 'cc' : 'cfirst'<CR>
nnoremap <silent> ]Q <Cmd>execute v:count ? v:count . 'cc' : 'clast'<CR>
nnoremap <silent> [<C-Q> <Cmd>execute v:count1 . 'cpfile'<CR>
nnoremap <silent> ]<C-Q> <Cmd>execute v:count1 . 'cnfile'<CR>

nnoremap <silent> [l <Cmd>execute v:count1 . 'lprevious'<CR>
nnoremap <silent> ]l <Cmd>execute v:count1 . 'lnext'<CR>
nnoremap <silent> [L <Cmd>execute v:count ? v:count . 'll' : 'lfirst'<CR>
nnoremap <silent> ]L <Cmd>execute v:count ? v:count . 'll' : 'llast'<CR>
nnoremap <silent> [<C-L> <Cmd>execute v:count1 . 'lpfile'<CR>
nnoremap <silent> ]<C-L> <Cmd>execute v:count1 . 'lnfile'<CR>

nnoremap <silent> [a <Cmd>execute v:count1 . 'previous'<CR>
nnoremap <silent> ]a <Cmd>execute v:count1 . 'next'<CR>
nnoremap <silent> [A <Cmd>execute v:count ? v:count . 'argument' : 'rewind'<CR>
nnoremap <silent> ]A <Cmd>execute v:count ? v:count . 'argument' : 'last'<CR>

nnoremap <silent> [b <Cmd>execute v:count1 . 'bprevious'<CR>
nnoremap <silent> ]b <Cmd>execute v:count1 . 'bnext'<CR>
nnoremap <silent> [B <Cmd>execute v:count ? v:count . 'buffer' : 'brewind'<CR>
nnoremap <silent> ]B <Cmd>execute v:count ? v:count . 'buffer' : 'blast'<CR>

nnoremap <silent> [t <Cmd>execute v:count1 . 'tprevious'<CR>
nnoremap <silent> ]t <Cmd>execute v:count1 . 'tnext'<CR>
nnoremap <silent> [T <Cmd>execute v:count ? v:count . 'trewind' : 'tfirst'<CR>
nnoremap <silent> ]T <Cmd>execute v:count ? v:count . 'trewind' : 'tlast'<CR>
nnoremap <silent> [<C-T> <Cmd>execute v:count1 . 'ptprevious'<CR>
nnoremap <silent> ]<C-T> <Cmd>execute v:count1 . 'ptnext'<CR>

function! s:AddBlankLine(above) abort
  let l:line = a:above ? line('.') - 1 : line('.')
  call append(l:line, repeat([''], v:count1))
endfunction

nnoremap <silent> [<Space> <Cmd>call <SID>AddBlankLine(1)<CR>
nnoremap <silent> ]<Space> <Cmd>call <SID>AddBlankLine(0)<CR>
