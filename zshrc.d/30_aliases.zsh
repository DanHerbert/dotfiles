#!/usr/bin/zsh

# Environment variable LS_COLORS must also exist for this to work.
alias ls='ls --color=auto -p'
alias lsc='ls --color=auto --group-directories-first -Apv'
# Force diff to use color by default.
alias diff='diff --color'

alias code="$HOME/.local/bin/codium"

alias py3='python3'

# zsh seems to automatically map completions of this to git, but bash does not.
alias g='/usr/bin/git'

# Aliases I've used in the past, but keep a reminder message for since I still
# use them out of habit sometimes.
alias gs='echo "You never want to open ghostscript"'
alias ga='echo "Missing a space between g & a"'
alias cm='echo "Missing \"g\" prefix"'
alias gp='echo "Use \"g pl\" or \"g ps\" instead"'
alias gd='echo "Use \"g d\" instead."'
alias gdc='echo "Use \"g dc\" instead."'
alias subl='echo "Use code instead"'
