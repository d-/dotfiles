:imap <M-s> <Esc>:silent w<kEnter>i 
set foldmethod=indent
set shiftwidth=4
map z1  :set foldlevel=0<CR><Esc>
map z2  :set foldlevel=1<CR><Esc>
map z3  :set foldlevel=2<CR><Esc>
map z4  :set foldlevel=3<CR><Esc>
map z5  :set foldlevel=4<CR><Esc>
map z6  :set foldlevel=5<CR><Esc>
map z7  :set foldlevel=6<CR><Esc>
map z8  :set foldlevel=7<CR><Esc>
map z9  :set foldlevel=8<CR><Esc>
set foldlevel=99
set numberwidth=1
set rnu!
set scl=no 
hi Normal ctermbg=16 guibg=#000000 
hi LineNr ctermbg=16 guibg=#000000

augroup black_on_save
  autocmd!
  autocmd BufWritePre *.py Black
augroup end

imap <F5> <Esc>:w<CR>:!clear;python %<CR>
nnoremap <F9> :Black<CR>
