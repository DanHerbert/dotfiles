#!/bin/sh
# This script is intentionally idempotent so that it can safely "sync" new files
# when run repeatedly.
set -eu

if ! command -v stow >/dev/null 2>&1; then
    echo 'GNU stow is not installed. All package managers call this "stow".'
    exit 1
fi

# Within the non-login shell triggered through a git hook via a python service
# the usual $HOME doesn't exist. It also will not point to the correct home
# since this same situation also means the current user would always be root.
PROJECT_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
P_USER=$(stat -c "%U" "$PROJECT_ROOT")
# Stow internally expects a HOME env var.
HOME="$(bash -c "echo ~$P_USER")"
export HOME

# Setup destination directories for everything in the repo. This will make it
# easier to add machine-specific files without being tracked as part of this
# dotfiles repo. vim needs extra depth to ensure that the plugins directory is a
# real directory and not a symlink, hence the difference in home/
(cd home && find . -maxdepth 4 -type d -exec sudo -u "$P_USER" mkdir -p "$HOME/{}" \;)
(cd local && find . -maxdepth 2 -type d -exec sudo -u "$P_USER" mkdir -p "$HOME/.local/{}" \;)
(cd config && find . -maxdepth 2 -type d -exec sudo -u "$P_USER" mkdir -p "$HOME/.config/{}" \;)
echo 'Placeholder directories for stow targets have been created, if needed.'

set -x
sudo -u "$P_USER" stow --verbose=1 --target="$HOME/.config" config
sudo -u "$P_USER" stow --verbose=1 --target="$HOME/.local" local
sudo -u "$P_USER" stow --verbose=1 --target="$HOME" home
