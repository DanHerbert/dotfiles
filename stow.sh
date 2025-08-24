#!/bin/sh
# This script is intentionally idempotent so that it can safely "sync" new files
# when run repeatedly without any negative side-effects.

# is_sourced borrowed from https://stackoverflow.com/a/28776166
is_sourced() {
    if [ -n "$INSIDE_UPDATE_SCRIPT" ]; then
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

uninitialized_submodules="$(cd "$PROJECT_ROOT"; git submodule status | grep -cE '^-')"
if [ "$uninitialized_submodules" -gt 0 ]; then
    echo 'dotfiles repo has uninitialized submodules.'
    echo 'Fix this by running "git submodule update --init --recursive"'
    unset uninitialized_submodules
    return 1
fi
unset uninitialized_submodules

# Because this script must be sourced, the set -e flag would kill the entire
# terminal if this script has an error. Running in a subshell prevents that from
# happening while still allowing failed commands to stop the script (except for
# the final `hash -r` command at the end of the script which always runs).
(set -e

# Within the non-login shell triggered through a git hook via a python service
# the usual $HOME doesn't exist. It also will not point to the correct home
# since this same situation also means the current user would always be root.
PROJECT_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
P_USER=$(stat -c "%U" "$PROJECT_ROOT")
# Stow internally expects a HOME env var.
U_HOME="$(eval echo "~${P_USER}")"

# Setup destination directories for everything in the repo. This will make it
# easier to add machine-specific files without being tracked as part of this
# dotfiles repo. vim needs extra depth to ensure that the plugins directory is a
# real directory and not a symlink, hence the difference in home/
(cd home && find . -maxdepth 4 -type d -exec sudo -u "$P_USER" mkdir -vp "$U_HOME/{}" \;)
(cd local && find . -maxdepth 2 -type d -exec sudo -u "$P_USER" mkdir -vp "$U_HOME/.local/{}" \;)
(cd config && find . -maxdepth 2 -type d -exec sudo -u "$P_USER" mkdir -vp "$U_HOME/.config/{}" \;)
echo 'Placeholder directories for stow targets have been created, if needed.'

# Not all contexts will automatically load ~/.config/environment.d/ configs
# Creating this file ensures environment variables always get loaded within
# my default zsh shell.
if [ -z "$XDG_CONFIG_HOME" ] && [ ! -f "$U_HOME/.zshenv" ]; then
    # Linter: I really want the shell variable to be written to the disk file.
    # shellcheck disable=SC2016
    echo 'ZDOTDIR=$HOME/.config/zsh' > "$U_HOME/.zshenv"
    echo "Created [$U_HOME/.zshenv] to ensure ZSH runs correctly."
fi

( export PS4=''; set -xe
sudo -u "$P_USER" stow --verbose=1 --target="$U_HOME/.config" config
sudo -u "$P_USER" stow --verbose=1 --target="$U_HOME/.local" local
sudo -u "$P_USER" stow --verbose=1 --target="$U_HOME" home
)

cleanup_start="$(date +%s.%N)"
# The pruned directory option lines below are technically not required, but will
# speed up this command quite a bit if the lines included.
has_shown_header=0
find "$U_HOME" \
        -path "$PROJECT_ROOT" -type d -prune -o \
        -path "$U_HOME/code" -type d -prune -o \
        -path "$U_HOME/Downloads" -type d -prune -o \
        -path "$U_HOME/Documents" -type d -prune -o \
        -path "$U_HOME/Desktop" -type d -prune -o \
        -path "$U_HOME/Music" -type d -prune -o \
        -path "$U_HOME/Pictures" -type d -prune -o \
        -path "$U_HOME/Videos" -type d -prune -o \
        -path "$U_HOME/Public" -type d -prune -o \
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
cleanup_stop="$(date +%s.%N)"
cleanup_total=$(echo "$cleanup_stop - $cleanup_start" | bc)
cleanup_days=$(echo "$cleanup_total/86400" | bc)
cleanup_total=$(echo "$cleanup_total-86400*$cleanup_days" | bc)
cleanup_hours=$(echo "$cleanup_total/3600" | bc)
cleanup_total=$(echo "$cleanup_total-3600*$cleanup_hours" | bc)
cleanup_minutes=$(echo "$cleanup_total/60" | bc)
cleanup_total=$(echo "$cleanup_total-60*$cleanup_minutes" | bc)
cleanup_seconds=$(echo "$cleanup_total-60*$cleanup_minutes" | bc)
printf "Cleanup runtime: %07.4f\n" "$cleanup_seconds"
# printf "Cleanup runtime: %d:%02d:%02d:%07.4f\n" \
#     "$cleanup_days" "$cleanup_hours" "$cleanup_minutes" "$cleanup_seconds"

) # End outermost subshell

hash -r
