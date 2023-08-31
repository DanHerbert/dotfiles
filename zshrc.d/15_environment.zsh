#!/usr/bin/zsh

export HISTFILE=$HOME/.histfile
export HISTSIZE=10000
export SAVEHIST=10000
export EDITOR='/usr/bin/vim'

if [[ -n ${DISPLAY+x} ]] && [[ -x "/opt/vscodium-bin/bin/codium" ]]; then
    export VISUAL="$HOME/.local/bin/codium"
else
    export VISUAL='/usr/bin/vim'
fi

# A surprising amount of modern apps misbehave without this specific value.
export TERM='xterm-256color'

# This is the "simplest" way to get this that I've been able to find...
# https://stackoverflow.com/a/43704557
export VIMRUNTIME=$(/usr/bin/vim -e -T dumb --cmd 'exe "set t_cm=\<C-M>"|echo $VIMRUNTIME|q' 2>&1 | tr -d '\015' | sed -E 's/(\s|\n|\r)+$//g')

# Generated using https://geoff.greer.fm/lscolors/
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Set a reasonable format for timestamps in ls command.
export TIME_STYLE='+%Y-%0m-%0dT%H:%M'

if [[ -d "$HOME/.local/lib/bc.d" ]]; then
    for file in "$HOME"/.local/lib/bc.d/*.bc; do
        BC_ENV_ARGS="$file $BC_ENV_ARGS "
    done
    unset file
    export BC_ENV_ARGS
fi

ZSH_COMMAND_TIME_COLOR="250"  # Gray
ZSH_COMMAND_TIME_EXCLUDE=(vim journalctl tig less "tail -f" "dmesg -w" "dmesg -W")
ZSH_COMMAND_TIME_MSG="[%%*] Runtime: %s"
