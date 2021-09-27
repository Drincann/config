" key
" normal mod
imap jk <Esc>
" command mod
nmap <space> :
" 文件树
map  <C-f> :NERDTreeToggle<CR>
" 括号补全
imap ( ()<Left>
" 终端
tmap <Esc> <C-\><C-n>
" 唤出终端
nmap <C-t> :Ttoggle<CR><C-w>ji
tmap <C-t> <Esc>:Ttoggle<CR>

" plug
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'joshdick/onedark.vim'
Plug 'pangloss/vim-javascript'
Plug 'valloric/youcompleteme'
Plug 'kassio/neoterm'
call plug#end()

" theme
colorscheme onedark

" 变量
let g:neoterm_default_mod = 'belowright'
let g:neoterm_size = '15' 
