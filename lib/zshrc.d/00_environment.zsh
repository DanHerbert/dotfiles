#!/usr/bin/zsh
# Most environment variables should be placed in config/environment.d/
# This file is only for:
# vars that require some computation to evaluate
# vars that are specific to interactive shells

# This env var check is used as a proxy to figure out if the current environment
# has not loaded ~/.config/environment.d/ which my dotfiles depend on.
if [[ -z $XDG_CONFIG_HOME ]]; then
    for conf in "$HOME"/.config/environment.d/*.conf; do
        set -a; source <(grep -vE '^#' "$conf"); set +a;
    done
fi

if [[ -n ${DISPLAY} ]] && [[ -n ${WAYLAND_DISPLAY} ]] && [[ -x "/opt/vscodium-bin/bin/codium" ]]; then
    export VISUAL="$HOME/.local/bin/codium --wait"
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

# Yikes to this command, but this is what it takes to allow environment
# variables defined with ~/.config/environment.d/*.conf within SSH sessions
# without any shell RC hacks.
SSH_TMUX_CMD="/usr/bin/systemd-run --user -E SSH_CLIENT=\"\$SSH_CLIENT\" -E SSH_CONNECTION=\"\$SSH_CONNECTION\" -E SSH_TTY=\"\$SSH_TTY\" --pty --same-dir --wait --collect --service-type=exec /usr/bin/dash -c '/usr/bin/systemd-run --scope --user /usr/bin/tmux new -As work'"

ZSH_COMMAND_TIME_COLOR="250"  # Gray
ZSH_COMMAND_TIME_EXCLUDE=(vim journalctl tig less "tail -f" "dmesg -w" "dmesg -W")
ZSH_COMMAND_TIME_MSG="[%%*] Runtime: %s"
