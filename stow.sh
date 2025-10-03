#!/bin/bash
# This script is intentionally idempotent so that it can safely "sync" new files
# when run repeatedly without any negative side-effects.

# is_sourced borrowed from https://stackoverflow.com/a/28776166
is_sourced() {
    if [ -n "$NOT_SOURCED_OK" ]; then
        return 0
    fi
    if [ -n "$ZSH_VERSION" ]; then
        case $ZSH_EVAL_CONTEXT in *:file:*) return 0 ;; esac
    else # Add additional POSIX-compatible shell names here, if needed.
        case ${0##*/} in dash | -dash | bash | -bash | ksh | -ksh | sh | -sh) return 0 ;; esac
    fi
    return 1 # NOT sourced.
}

if ! is_sourced; then
    echo 'Script must be sourced'
    unset is_sourced
    exit 1
fi
unset is_sourced

if ! command -v stow >/dev/null 2>&1; then
    echo 'GNU stow is not installed. All package managers call this "stow".'
    return 1
fi

if ! command -v bc >/dev/null 2>&1; then
    echo 'GNU bc is not installed. All package managers call this "bc".'
    return 1
fi

if command -v gdate >/dev/null 2>&1; then
    date() { gdate "$@"; }
# Date on BSD-based systems (MacOS) does not have sub-second precision, which
# this script expects to do timing stuff. This seems to be the best way to
# detect proper support, at least for OSes that I use.
elif ! date --version | grep -q 'GNU coreutils' >/dev/null 2>&1; then
    if [ "$(uname -o)" = 'Darwin' ]; then
        echo 'GNU coretutils is not installed. Install "coreutils" from Homebrew.'
    else
        echo 'GNU coretutils package is not installed.'
    fi
    return 1
fi


timer_start() {
    if [ -n "$1" ]; then
        timer_start_var="$1"
        starttime="$(date +%s.%N)"
        eval export "$timer_start_var"=\$starttime
        unset starttime
    else
        __timer_starttime="$(date +%s.%N)"
        export __timer_starttime
    fi
}

timer_stop() {
    label_prefix="${1:-Segment}"
    starttime=$__timer_starttime
    if [ -n "$2" ]; then
        timer_start_var="$2"
        starttime=$(eval "echo \"\$$timer_start_var\"")
    fi
    stoptime="$(date +%s.%N)"
    total_runtime=$(echo "$stoptime - $starttime" | bc)
    runtime_days=$(echo "$total_runtime/86400" | bc)
    total_runtime=$(echo "$total_runtime-86400*$runtime_days" | bc)
    runtime_hours=$(echo "$total_runtime/3600" | bc)
    total_runtime=$(echo "$total_runtime-3600*$runtime_hours" | bc)
    runtime_minutes=$(echo "$total_runtime/60" | bc)
    total_runtime=$(echo "$total_runtime-60*$runtime_minutes" | bc)
    runtime_seconds=$(echo "$total_runtime-60*$runtime_minutes" | bc)
    printf "++ $label_prefix runtime: %04.2fs\n" "$runtime_seconds"
    # printf "%s runtime: %d:%02d:%02d:%06.3f\n" "$label_prefix" \
    #     "$runtime_days" "$runtime_hours" "$runtime_minutes" "$runtime_seconds"
    unset __timer_starttime
    unset label_prefix
    unset starttime
    unset stoptime
    unset total_runtime
    unset runtime_days
    unset runtime_hours
    unset runtime_minutes
    unset runtime_seconds
    if [ -n "$2" ]; then
        eval "unset \"\$timer_start_var\""
    fi
    unset timer_start_var
}
timer_start '__script_runtime'

PROJECT_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

timer_start
uninitialized_submodules="$(cd "$PROJECT_ROOT"; git submodule status | grep -cE '^-')"
if [ "$uninitialized_submodules" -gt 0 ]; then
    timer_stop 'submodule check'
    timer_stop "Total" '__script_runtime'
    echo 'dotfiles repo has uninitialized submodules.'
    echo 'Fix this by running "git submodule update --init --recursive"'
    unset uninitialized_submodules
    unset date
    unset timer_start
    unset timer_stop
    unset PROJECT_ROOT
    return 1
fi
unset uninitialized_submodules
timer_stop 'submodule check'

# Because this script must be sourced, the set -e flag would kill the entire
# terminal if this script has an error. Running in a subshell prevents that from
# happening while still allowing failed commands to stop the script (except for
# the final `hash -r` command at the end of the script which always runs).
(set -e

# This script can sometimes be executed by a user different than the one who
# actually owns the directory. Ensure all operations use the environment vars
# that this script's owner would have. MacOS/BSD have different stat options
# than GNU/Linux, so we fallback if the Linux version fails.
P_USER=$(stat -c "%U" "$PROJECT_ROOT" 2>/dev/null || stat -f "%Su" "$PROJECT_ROOT")
# Stow internally expects a HOME env var.
U_HOME="$(eval echo "~${P_USER}")"
timer_start
# Setup destination directories for everything in the repo. This will make it
# easier to add machine-specific files without being tracked as part of this
# dotfiles repo. vim needs extra depth to ensure that the plugins directory is a
# real directory and not a symlink, hence the difference in home/
(cd "$PROJECT_ROOT/home" && find . -maxdepth 4 -type d -exec mkdir -vp "$U_HOME/{}" \;)
(cd "$PROJECT_ROOT/local" && find . -maxdepth 2 -type d -exec mkdir -vp "$U_HOME/.local/{}" \;)
(cd "$PROJECT_ROOT/config" && find . -maxdepth 2 -type d -exec mkdir -vp "$U_HOME/.config/{}" \;)
echo 'Placeholder directories for stow targets have been created, if needed.'
timer_stop "mkdirs"

# Not all contexts will automatically load ~/.config/environment.d/ configs
# Creating this file ensures environment variables always get loaded within
# my default zsh shell.
if [ -z "$XDG_CONFIG_HOME" ] && [ ! -f "$U_HOME/.zshenv" ]; then
    # Linter: I really want the shell variable to be written to the disk file.
    # shellcheck disable=SC2016
    echo 'ZDOTDIR=$HOME/.config/zsh' > "$U_HOME/.zshenv"
    echo "Created [$U_HOME/.zshenv] to ensure ZSH runs correctly."
fi

# Although this script should only ever stow files and not touch real files,
# these 2 specific files are treated as special simply to make installing
# dotfiles easier.
if [ -f "$HOME/.ssh/config" ] && [ ! -L "$HOME/.ssh/config" ]; then
    mv "$HOME/.ssh/config" "$HOME/ssh_config_$(date -u +%Y-%m-%d)"
fi
if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
    mv "$HOME/.bashrc" "$HOME/original_$(date -u +%Y-%m-%d).bashrc"
fi

timer_start
( export PS4=''; set -xe
cd "$PROJECT_ROOT"
stow --verbose=1 --target="$U_HOME/.config" config
stow --verbose=1 --target="$U_HOME/.local" local
stow --verbose=1 --target="$U_HOME" home
)
timer_stop "stows"

timer_start
# The pruned directory option lines below are technically not required, but will
# speed up this command quite a bit if the lines included.
has_shown_header=0
find "$U_HOME"/.* \
        -path "$U_HOME/.cache" -type d -prune -o \
        -path "$U_HOME/.local/state/cargo" -type d -prune -o \
        -path "$U_HOME/.local/state/rustup" -type d -prune -o \
        -path "$U_HOME/.local/state/golang" -type d -prune -o \
        -path "$U_HOME/.local/share/Steam" -type d -prune -o \
        -type l -print 2>/dev/null | while read -r symlink; do
    true_path=$(realpath -q "$symlink" || true)
    case $true_path in
        "$PROJECT_ROOT"*)
            if [ -L "$symlink" ] && [ ! -e "$true_path" ]; then
                if [ $has_shown_header = 0 ]; then
                    echo 'Cleaning up broken symlinks owned by stow.sh ...'
                    has_shown_header=1
                fi
                rel_target=$(printf '%s' "$symlink" | sed "s|$U_HOME|~|")
                rel_source=$(readlink "$symlink")
                rm "$symlink"
                echo "UNLINK: $rel_target => $rel_source"
            fi
            ;;
    esac
done
timer_stop "cleanup"

) # End outermost subshell

hash -r
timer_stop "Total" '__script_runtime'

unset timer_start
unset timer_stop
unset __script_runtime
unset date
