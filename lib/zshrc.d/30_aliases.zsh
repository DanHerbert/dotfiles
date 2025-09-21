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

if command -v systemctl 2>&1 >/dev/null; then
    alias sctl='systemctl'
    alias uctl='systemctl --user'
fi
if command -v journalctl 2>&1 >/dev/null; then
    alias jctl='journalctl -o short-iso --no-hostname'
fi

# Environment variable LS_COLORS must also exist for this to work.
alias ls='ls --color=auto --group-directories-first -p'
alias lsa='ls --color=auto --group-directories-first -pA'
alias lst='ls --color=auto --group-directories-first -pt'

alias mv='mv -i'
alias cp='cp -i'

# Force diff to use color by default.
alias diff='diff --color'

alias ytd="$(command -v yt-dlp 2>/dev/null)"

alias dateutc='date -u +%Y-%m-%dT%H:%M:%S%z'

# On Linux, codium will report electron flags as unknown to codium on stderr
# On MacOS, electron will report Wayland flags as invalid on stderr
# In both cases, these messages are noise so I want them sent to a logfile
# instead. We should also make sure the "ts" command (part of moreutils package)
# exists so we can prepend timestamps to all logs.
if ! command -v code >/dev/null 2>&1 && command -v ts >/dev/null 2>&1; then
    alias code="codium 2> >(mkdir -p $XDG_STATE_HOME/codium; ts '[%Y-%m-%dT%H:%M:%S]' >> $XDG_STATE_HOME/codium/errors.log)"
fi

alias py3='python3'

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    batpath="$(command -v batcat)"
    alias bat="$batpath"
elif command -v bat >/dev/null 2>&1; then
    batpath="$(command -v bat)"
fi
if [[ -n "$batpath" ]]; then
    export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | $batpath -p -lman'"
fi
lesspath="$(command -v less)"
alias lessc="$batpath --plain --pager=\"$lesspath --RAW-CONTROL-CHARS\""

alias lessv="$VIMRUNTIME/macros/less.sh"

# --verbose Output all details for potential debugging
# --update Only copy the things that need it
# --partial Don't delete partial transfers (makes resuming easier)
# --info=flist2,progress2 Overall progress, not individual files
# --human-readable Use human units
alias rsync='rsync --verbose --update --partial --info=flist2,progress2 --human-readable --exclude="/.git" --filter=":- .gitignore"'
# Same as above, but respect git and .gitignore files.
alias grsync='--human-readable --exclude="/.git" --filter=":- .gitignore" rsync --verbose --update --partial --info=flist2,progress2'

# zsh seems to automatically map completions of this to git, but bash does not.
alias g="$(command -v git 2>/dev/null)"

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
