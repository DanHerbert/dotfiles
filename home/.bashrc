#!/bin/bash

# I use zsh, but sometimes bash gets loaded (such as fresh OS installs) so this
# minimal rc file exists to give me some of my preferred defaults. This file is
# intentionally small & standalone with no references to any other files.

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

[[ $DISPLAY ]] && shopt -s checkwinsize

if command -v shopt > /dev/null 2>&1; then
    shopt -s histappend
fi

export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export HISTCONTROL=ignorespace:ignoredups:erasedups
export EDITOR='/usr/bin/vim'
export SUDO_EDITOR='/usr/bin/vim'
export VISUAL='/usr/bin/vim'

PATH="$HOME/.local/bin:$PATH"

# Generated using https://geoff.greer.fm/lscolors/
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

alias ls='ls --color=auto -p'

if [ -x "$HOME/.local/bin/codium" ]; then
    alias code='$HOME/.local/bin/codium'
else
    alias code='/usr/bin/codium'
fi
alias g='/usr/bin/git'

alias gs='echo "You never want to open ghostscript"'
alias ga='echo "Missing a space between g & a"'
alias cm='echo "Missing \"g\" prefix"'
alias gp='echo "Use \"g pl\" or \"g ps\" instead"'
alias gd='echo "Use \"g d\" instead."'
alias gdc='echo "Use \"g dc\" instead."'
alias subl='echo "Use code instead"'

# Reference I used to get these ANSI control sequences.
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
CYAN='\[\e[36m\]'
YELLOW='\[\e[33m\]'
GREEN='\[\e[32m\]'
WHITE='\[\e[39m\['
RED='\[\e[31m\['

if tput setaf 1 > /dev/null; then
    GREEN=$(tput setaf 22)
fi

BG_RED='\[\e[101m\]'

BOLD='\[\e[1m\]'
DIM='\[\e[2m\]'
RESET='\[\e[0m\]'

__is_dir_hg() {
  cwd="$(pwd -P)"
  while [ "$cwd" ] && [ ! -d "$cwd/.hg" ]; do
    cwd="${cwd%/*}"
  done
  test -d "$cwd/.hg"
}

__scm_dir_marker__() {
    SCM_STYLE="$(tput dim; tput setaf 94)"
    SCM_RESET="$(tput sgr0)"
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        current_rev=$(git symbolic-ref -q --short HEAD 2> /dev/null || git describe --tags --exact-match 2> /dev/null || git rev-parse --short HEAD)
        printf '%s⎇ %s%s' "$SCM_STYLE" "$current_rev" "$SCM_RESET"
    elif __is_dir_hg > /dev/null 2>&1; then
        printf '%s☿%s' "$SCM_STYLE" "$SCM_RESET"
    fi
}
export __scm_dir_marker__

if [ "$(id -u)" = 0 ]; then
    USER_STYLE=$BOLD$WHITE$BG_RED
else
    USER_STYLE=$DIM$CYAN
fi

HOST_STYLE=$DIM$RED
CWD_STYLE=$DIM$GREEN

# Documentation for Bash escape characters can be found here:
# https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
export PS1="$USER_STYLE\\u$RESET$DIM@$RESET$HOST_STYLE\\h$RESET $CWD_STYLE\\w$RESET \$(__scm_dir_marker__)\\n$YELLOW\\\$$RESET "
export PS2="$YELLOW>$RESET "
