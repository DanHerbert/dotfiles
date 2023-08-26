#!/bin/sh
# This script is intentionally idempotent so that it can safely "sync" new files
# when run repeatedly.
set -eu

# Ensure a few folders really exist so that stow doesn't mess things up by
# trying to make them symlinks.
if ! [ -d "$HOME/.config" ]; then
    mkdir -p "$HOME/.config"
fi
if ! [ -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi

if ! [ -d "$HOME/.local/lib" ]; then
    mkdir -p "$HOME/.local/lib"
fi

if ! [ -d "$HOME/.local/lib/bc.d" ]; then
    mkdir -p "$HOME/.local/lib/bc.d"
fi

if ! command -v stow 2> /dev/null; then
    echo 'GNU stow is not installed. All package managers call this "stow".'
    exit 1
fi

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

hook_origin="$SCRIPT_DIR/git-hook-post-checkout.sh"
hook_dest="$SCRIPT_DIR/.git/hooks/post-checkout"
if [ ! -e "$hook_dest" ] && [ ! -L "$hook_dest" ]; then
    ln -s "$hook_origin" "$hook_dest"
fi

set -v
stow --target="$HOME/.config" config
stow --target="$HOME/.local" local
stow --target="$HOME" home
