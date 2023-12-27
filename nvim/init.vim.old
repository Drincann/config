" key
" normal mod
imap jk <Esc>
" command mod
nmap <space> :
" 文件树
map  <C-f> :NERDTreeToggle<CR>
" 括号补全
" imap ( ()<Left>
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
" Plug 'valloric/youcompleteme'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'kassio/neoterm'
call plug#end()

" theme
colorscheme onedark

" 变量
let g:neoterm_default_mod = 'belowright'
let g:neoterm_size = '15' 

" line numbers
" turn hybrid line numbers on
set number relativenumber
set nu rnu

" turn hybrid line numbers off
set nonumber norelativenumber
set nonu nornu

" toggle hybrid line numbers
set number! relativenumber!
set nu! rnu!


set number

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" color
highlight LineNr ctermfg=white


" coc
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

