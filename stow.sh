#!/bin/sh
# This script is intentionally idempotent so that it can safely "sync" new files
# when run repeatedly without any negative side-effects.
set -e

if ! command -v stow >/dev/null 2>&1; then
    echo 'GNU stow is not installed. All package managers call this "stow".'
    exit 1
fi

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

# Within the non-login shell triggered through a git hook via a python service
# the usual $HOME doesn't exist. It also will not point to the correct home
# since this same situation also means the current user would always be root.
PROJECT_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
P_USER=$(stat -c "%U" "$PROJECT_ROOT")
# Stow internally expects a HOME env var.
U_HOME="$(getent passwd "$P_USER" | cut -d: -f6)"

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
    echo 'ZDOTDIR=$U_HOME/.config/zsh' > "$U_HOME/.zshenv"
    echo "Created [$U_HOME/.zshenv] to ensure ZSH runs correctly."
fi

set -x
sudo -u "$P_USER" stow --verbose=1 --target="$U_HOME/.config" config
sudo -u "$P_USER" stow --verbose=1 --target="$U_HOME/.local" local
sudo -u "$P_USER" stow --verbose=1 --target="$U_HOME" home
set +x

unset is_sourced
unset PROJECT_ROOT
unset P_USER
unset U_HOME

hash -r
