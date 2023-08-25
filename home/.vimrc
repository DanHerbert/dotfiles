set noswapfile
set nowb
set expandtab
set autoindent
set nobackup
set autoread
set number
set ttyfast
set showcmd
set showmode
set visualbell
set background=dark
set colorcolumn=80
set mouse=a
set shiftwidth=2
set tabstop=2
set backspace=eol,start,indent
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
inoremap jj <ESC>
nnoremap ; :
set whichwrap+=<,>,h,l
"Color names from /usr/share/vim/vim90/colors/
color evening
checktime
syntax on
filetype on
filetype plugin on
