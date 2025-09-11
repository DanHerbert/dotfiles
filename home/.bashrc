#!/bin/bash

# I use zsh, but sometimes bash gets loaded (such as fresh OS installs) so this
# minimal rc file exists to give me some of my preferred defaults. This file is
# intentionally small & standalone with no references to any other files.

# Ensure environment vars are loaded if XDG has not done it already. This
# intentionally happens even in a non-interactive shell.
if [[ -d "$HOME"/.config/environment.d/ ]] && [[ -z $XDG_CONFIG_HOME ]]; then
    for conf in "$HOME"/.config/environment.d/*.conf; do
        if [[ -f "$conf" ]] || [[ -L "$conf" && -e "$conf" ]]; then
            set -a
            # shellcheck source=/dev/null
            source <(grep -vE '^#' "$conf")
            set +a
        elif [[ -L "$conf" && ! -e "$conf" ]]; then
            echo "WARNING: environment conf symlink is broken [$conf]" >&2
        fi
    done
fi

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

if command -v shopt > /dev/null 2>&1; then
    shopt -s histappend
    [[ -n $DISPLAY ]] && shopt -s checkwinsize
fi

export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export HISTCONTROL=ignorespace:ignoredups:erasedups
export HISTSIZE=1000
export HISTFILESIZE=2000
export EDITOR='/usr/bin/vim'
export SUDO_EDITOR='/usr/bin/vim'

PATH="$HOME/.local/bin:$PATH"

# Generated using https://geoff.greer.fm/lscolors/
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

if ! shopt -oq posix; then
    # One or either of these exist in Debian-based systems by default.
    # Arch Linux only has these files if the 'bash-completions' package is
    # installed.
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        # shellcheck disable=SC1091
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        # shellcheck disable=SC1091
        . /etc/bash_completion
    fi
fi

alias ls='ls --color=auto -p'
alias grep='grep --color=auto'

alias g='/usr/bin/git'

# Reference I used to get these ANSI control sequences.
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
__CYAN='\[\e[36m\]'
__YELLOW='\[\e[33m\]'
__GREEN='\[\e[32m\]'
__WHITE='\[\e[39m\['
__RED='\[\e[31m\['

if tput setaf 1 > /dev/null; then
    __GREEN=$(tput setaf 22)
fi

__BG_RED='\[\e[101m\]'

__BOLD='\[\e[1m\]'
__DIM='\[\e[2m\]'
__RESET='\[\e[0m\]'

__is_dir_hg() {
  local cwd
  cwd="$(pwd -P)"
  while [ "$cwd" ] && [ ! -d "$cwd/.hg" ]; do
    cwd="${cwd%/*}"
  done
  test -d "$cwd/.hg"
}

__scm_dir_marker__() {
    local SCM_STYLE
    local SCM_RESET
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
    USER_STYLE=$__BOLD$__WHITE$__BG_RED
else
    USER_STYLE=$__DIM$__CYAN
fi

__HOST_STYLE=$__DIM$__RED
__CWD_STYLE=$__DIM$__GREEN

# Documentation for Bash escape characters can be found here:
# https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
export PS1="$USER_STYLE\\u$__RESET$__DIM@$__RESET$__HOST_STYLE\\h$__RESET $__CWD_STYLE\\w$__RESET \$(__scm_dir_marker__)\\n$__YELLOW\\\$$__RESET "
export PS2="$__YELLOW>$__RESET "
