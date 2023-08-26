#!/bin/sh
# This script is intentionally idempotent so that it can safely "sync" new files
# when run repeatedly.
set -eu

if ! command -v stow > /dev/null 2>&1; then
    echo 'GNU stow is not installed. All package managers call this "stow".'
    exit 1
fi

# vim plugins are the 1 thing that should always be symlinked if possible and do
# not need a placeholder directory.
(cd home && find . -maxdepth 4 -type d -exec mkdir -p "$HOME/{}" \;)
(cd local && find . -maxdepth 4 -type d -exec mkdir -p "$HOME/.local/{}" \;)
(cd config && find . -maxdepth 4 -type d -exec mkdir -p "$HOME/.config/{}" \;)
echo 'Placeholder directories for stow targets have been created, if needed.'

set -x
stow --target="$HOME/.config" config
stow --target="$HOME/.local" local
stow --target="$HOME" home
