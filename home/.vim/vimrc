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
set pastetoggle=<F11>
set history=1000
set mouse=a
set shiftwidth=2
set tabstop=2
set backspace=eol,start,indent
inoremap jj <ESC>
nnoremap ; :
set whichwrap+=<,>,h,l
" Vim regexp escaping style
set magic

checktime
syntax on
filetype on
filetype plugin on

set viminfo+=n~/.vim/viminfo

set background=dark
"Color scheme names from $(vim --cmd 'echo $VIMRUNTIME|q')/colors/
"  colorscheme evening

colorscheme desert
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set t_Co=256
set termguicolors

set colorcolumn=80
set cursorline
set cursorcolumn
highlight ColorColumn ctermbg=237 guibg=#393939
highlight CursorColumn ctermbg=235 guibg=#373737
highlight CursorLine cterm=NONE ctermbg=235 guibg=#373737
highlight LineNr ctermfg=94 guifg=#7d6426

autocmd FileType gitcommit setlocal colorcolumn=72

set listchars=tab:␉-,trail:·,nbsp:⎵,space:·
set list

highlight TypingTrailingWhitespace ctermfg=234
highlight WhitespaceMol ctermfg=24
highlight WhitespaceBol ctermfg=24
highlight CustomTabWhitespace ctermfg=24
highlight CustomTrailingWhitespace ctermfg=white ctermbg=196

call matchadd('WhitespaceMol', ' ', 10)
call matchadd('WhitespaceBol', '^\s\+', 20)
call matchadd('CustomTabWhitespace', '\t\+', 20)
call matchadd('CustomTrailingWhitespace', '\s\+$', 20)

function DetectTabsOrSpaces()
    " Determines whether to use spaces or tabs on the current buffer.
    if getfsize(bufname("%")) > 256000
        " File is very large, just use the default.
        return
    endif

    let numTabs=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^\\t"'))
    let numSpaces=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^ "'))

    if numTabs > numSpaces
        setlocal noexpandtab
        setlocal shiftwidth=4
        setlocal tabstop=4
    endif
endfunction
autocmd BufReadPost * call DetectTabsOrSpaces()

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
