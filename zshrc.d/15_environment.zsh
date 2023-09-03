#!/usr/bin/zsh

if [[ -n ${DISPLAY+x} ]] && [[ -x "/opt/vscodium-bin/bin/codium" ]]; then
    export VISUAL="$HOME/.local/bin/codium"
fi

# A surprising amount of modern apps misbehave without this specific value.
export TERM='xterm-256color'

# This is the "simplest" way to get this that I've been able to find...
# https://stackoverflow.com/a/43704557
export VIMRUNTIME=$(/usr/bin/vim -e -T dumb --cmd 'exe "set t_cm=\<C-M>"|echo $VIMRUNTIME|q' 2>&1 | tr -d '\015' | sed -E 's/(\s|\n|\r)+$//g')

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
