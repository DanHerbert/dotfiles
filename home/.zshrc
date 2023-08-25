#!/usr/bin/zsh

HISTFILE=$HOME/.histfile
HISTSIZE=10000
SAVEHIST=10000

# Emacs keybindings (-v would be vim keybindings)
bindkey -e

zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit -u

autoload edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey '^R' history-incremental-search-backward

setopt inc_append_history
setopt share_history
setopt prompt_subst
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_DUPS
setopt PROMPT_SUBST

export EDITOR='/usr/bin/vim'
export VISUAL="$HOME/.local/bin/codium"
export TERM='xterm-256color'
# Generated using https://geoff.greer.fm/lscolors/
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

typeset -U path PATH
path=("$HOME/.local/bin" "$path[@]")


if [ -d "$HOME/.local/lib/bc.d" ]; then
    for file in "$HOME/.local/lib/bc.d/*.bc"; do
        BC_ENV_ARGS="$file $BC_ENV_ARGS "
    done
    export BC_ENV_ARGS
fi

alias py3='python3'

# LS_COLORS must also be exported for this to work.
alias ls='ls --color=auto -p'
alias lsc='ls --color=auto --group-directories-first -Apv'
# Ensure diff defaults to using color.
alias diff='diff --color'

alias code="$HOME/.local/bin/codium"

alias g='/usr/bin/git'

alias gs='echo "You never want to open ghostscript"'
alias ga='echo "Missing a space between g & a"'
alias cm='echo "Missing \"g\" prefix"'
alias gp='echo "Use \"g pl\" or \"g ps\" instead"'
alias gd='echo "Use \"g d\" instead."'
alias gdc='echo "Use \"g dc\" instead."'
alias subl='echo "Use code instead"'

ACCOUNT_TYPE_STYLE='%{%F{221}%}' # Muted yellow
DIRECTORY_STYLE='%{%F{65}%}%' # Muted green
USER_STYLE='%{%F{66}%}' # Muted cyan
MACHINE_STYLE='%{%F{009}%}' # Muted light red

# Better desaturation if the terminal supports true 24-bit color support.
# if [[ $COLORTERM == 'truecolor' ]]; then
#     MACHINE_STYLE=$'%{\e[38;0;208;163;158%}' # Color #d0a39f
# fi

# root user styles.
if [[ $EUID == 0 ]]; then
    USER_STYLE='%{%B%F{255}%K{196}%}' # Bright red
    ACCOUNT_TYPE_STYLE='%{%B%F{200}%}%#' # Hot pink
    DIRECTORY_STYLE='%{%F{54}%}%' # Muted purple
fi

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_prompt() {
    psvar[1]=$'\%n'
}
precmd_functions+=( precmd_prompt precmd_vcs_info )

PS1=$USER_STYLE'%n%{%b%f%k%}%{%F{60}%}@%{%f%}'$MACHINE_STYLE'%m%{%f%} '"$DIRECTORY_STYLE"'0~%{%f%} ${vcs_info_msg_0_}'$'\n'"$ACCOUNT_TYPE_STYLE"'%#%{%b%f%} '
PS2="$ACCOUNT_TYPE_STYLE"'>%{%f%} '

zstyle ':vcs_info:git:*' formats '(%b)'
