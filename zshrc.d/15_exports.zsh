#!/usr/bin/zsh

export HISTFILE=$HOME/.histfile
export HISTSIZE=10000
export SAVEHIST=10000
export EDITOR='/usr/bin/vim'

if [[ -n ${DISPLAY+x} ]] && [[ -x "/opt/vscodium-bin/bin/codium" ]]; then
    export VISUAL="$HOME/.local/bin/codium"
else
    export VISUAL="/usr/bin/vim"
fi
export TERM='xterm-256color'
# Generated using https://geoff.greer.fm/lscolors/
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
# Set a reasonable format for timestamps in ls command.
export TIME_STYLE='+%Y-%0m-%0dT%H:%M'

if [[ -d "$HOME/.local/lib/bc.d" ]]; then
    for file in "$HOME"/.local/lib/bc.d/*.bc; do
        BC_ENV_ARGS="$file $BC_ENV_ARGS "
    done
    export BC_ENV_ARGS
fi
