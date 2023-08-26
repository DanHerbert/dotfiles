set nocompatible
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
inoremap jj <ESC>
nnoremap ; :
set whichwrap+=<,>,h,l
"Color names from /usr/share/vim/vim90/colors/
color evening
checktime
syntax on
filetype on
filetype plugin on

function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif

  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"

  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction

let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
