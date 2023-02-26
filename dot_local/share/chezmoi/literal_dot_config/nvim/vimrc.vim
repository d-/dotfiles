:imap <M-s> <Esc>:silent w<kEnter>i 
autocmd BufWritePost *.py execute ':silent Black'


set foldmethod=indent
set shiftwidth=4
nnoremap <space> za
vnoremap <space> zf
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

