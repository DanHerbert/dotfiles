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
P_HOME=$(bash -c "echo ~$P_USER")

# vim plugins are the 1 thing that should always be symlinked if possible and do
# not need a placeholder directory.
(cd home && find . -maxdepth 4 -type d -exec mkdir -p "$P_HOME/{}" \;)
(cd local && find . -maxdepth 4 -type d -exec mkdir -p "$P_HOME/.local/{}" \;)
(cd config && find . -maxdepth 4 -type d -exec mkdir -p "$P_HOME/.config/{}" \;)
echo 'Placeholder directories for stow targets have been created, if needed.'

set -x
stow --target="$P_HOME/.config" config
stow --target="$P_HOME/.local" local
stow --target="$P_HOME" home
