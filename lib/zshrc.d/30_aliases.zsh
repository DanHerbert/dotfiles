#!/usr/bin/zsh

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias zgrep='egrep --color=auto'

# Handy cd shortcuts
alias     ..='cd ..'
alias    ...='cd ../..'
alias   ....='cd ../../..'
alias  .....='cd ../../../..'
alias ......='cd ../../../../..'

alias userctl='systemctl --user'
alias jctl='journalctl -o short-iso --no-hostname'

# Environment variable LS_COLORS must also exist for this to work.
alias ls='ls --color=auto --group-directories-first -p'
alias lsa='ls --color=auto --group-directories-first -pA'
alias lst='ls --color=auto --group-directories-first -pt'

# Force diff to use color by default.
alias diff='diff --color'

alias ytd='/usr/bin/yt-dlp'

alias dateutc='date -u +%Y-%m-%dT%H:%M:%S%z'

alias vless="$VIMRUNTIME/macros/less.sh"

alias code="$HOME/.local/bin/codium"

alias py3='python3'

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    alias bat="$(command -v batcat)"
fi
alias bless='bat --plain --pager="less --RAW-CONTROL-CHARS"'

if [[ ! -e $XDG_CONFIG_HOME/wget/wget-hsts.txt ]]; then
    mkdir -p $XDG_CONFIG_HOME/wget
    touch $XDG_CONFIG_HOME/wget/wget-hsts.txt
fi

alias wget='wget --hsts-file="$XDG_CONFIG_HOME/wget/wget-hsts.txt"'

# --verbose Output all details for potential debugging
# --update Only copy the things that need it
# --partial Don't delete partial transfers (makes resuming easier)
# --info=flist2,progress2 Overall progress, not individual files
# --human-readable Use human units
alias rsync='rsync --verbose --update --partial --info=flist2,progress2 --human-readable'

# zsh seems to automatically map completions of this to git, but bash does not.
alias g='/usr/bin/git'

alias sudo='nocorrect sudo '

alias adb='HOME="$XDG_DATA_HOME"/android adb'

# Aliases I've used in the past, but keep a reminder message for since I still
# use them out of habit sometimes.
alias gs='echo "You never want to open ghostscript"'
alias ga='echo "Missing a space between g & a"'
alias cm='echo "Missing \"g\" prefix"'
alias co='echo "Missing \"g\" prefix"'
alias gp='echo "Use \"g pl\" or \"g ps\" instead"'
alias gd='echo "Use \"g d\" instead."'
alias gdc='echo "Use \"g dc\" instead."'
alias subl='echo "Use code instead"'
