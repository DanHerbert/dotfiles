#!/bin/sh

# This script can update itself while running (since it updates through git)
# All commands must happen within these curly brace blocks to ensure everything
# loads into memory before executing.
{
PROJECT_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

set -euv

cd "$PROJECT_ROOT"
if [ "$(git branch --show-current)" != 'main' ]; then
    echo 'On a non-default branch. Doing nothing.'
    exit
fi
git pull --force --autostash
# A git hook will run any needed changes post-checkout so no other actions are
# needed here. See /git-hooks/post-checkout for full behavior.
}; exit
