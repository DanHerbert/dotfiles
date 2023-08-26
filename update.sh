#!/bin/sh

# This script can update itself while running (since it updates through git)
# All commands must happen within these curly brace blocks to ensure everything
# loads into memory before executing.
{
PROJECT_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

set -euv

cd "$PROJECT_ROOT"
current_branch="$(git branch --show-current)"
git_failed=$?
if [ $git_failed ]; then
    echo "Bad git ownership detected. Doing nothing."
    # Git project user
    stat -c '%U' "$PROJECT_ROOT"
    echo "Script user: $USER"
    git config --show-origin --get-all safe.directory
    exit 1
fi
if [ "$current_branch" != 'main' ]; then
    echo 'On a non-default branch. Doing nothing.'
    exit
fi
git pull --force --autostash
# A git hook will run any needed changes post-checkout so no other actions are
# needed here. See /git-hooks/post-checkout for full behavior.
}; exit
