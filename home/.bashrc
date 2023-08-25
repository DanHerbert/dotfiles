#!/bin/bash

# I use zsh, but sometimes bash gets loaded (such as fresh OS installs) so this
# minimal rc file exists to give me some of my preferred defaults. This file is
# intentionally small & standalone with no references to any other files.

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export HISTCONTROL=ignorespace:ignoredups:erasedups
export EDITOR='/usr/bin/vim'
export VISUAL="$HOME/.local/bin/codium"

alias ls='ls --color=auto -p'

alias code='/usr/bin/codium'
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
CYAN='\[\e[0;36m\]'
YELLOW='\[\e[0;33m\]'
GREEN='\[\e[0;32m\]'
WHITE='\[\e[39m\['

BG_RED='\[\e[101m\]'

BOLD='\[\e[1m\]'
DIM='\[\e[2m\]'
RESET='\[\e[0m\]'

if [[ $EUID == 0 ]]; then
    USER_STYLE=$BOLD$WHITE$BG_RED
else
    USER_STYLE=$DIM$CYAN
fi

# Documentation for Bash escape characters can be found here:
# https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
export PS1="$USER_STYLE"'\u'"$RESET$DIM@$RESET\\h $DIM$GREEN\\w$RESET\\n$DIM$YELLOW\\\$$RESET "
export PS2="$YELLOW>$RESET "
