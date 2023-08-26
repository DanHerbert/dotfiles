#!/bin/sh

# This script can update itself while running (since it updates through git)
# All commands must happen within these curly brace blocks to ensure everything
# loads into memory before executing.
{
PROJECT_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

set -ux

cd "$PROJECT_ROOT" || exit 1

current_branch="$(git branch --show-current)"
git_failed=$?
if [ "$git_failed" != 0 ]; then
    echo "Bad git ownership detected. Doing nothing."
    echo 'Project user'
    stat -c '%U' "$PROJECT_ROOT"
    echo 'Script user'
    id -u -n
    echo 'Current safe directories'
    git --no-pager config --show-origin --get-all safe.directory
    exit 1
fi
if [ "$current_branch" != 'main' ]; then
    echo 'On a non-default branch. Doing nothing.'
    exit
fi
GIT_SSH_COMMAND="ssh -o BatchMode=yes" git pull --force --autostash
# A git hook will run any needed changes post-checkout so no other actions are
# needed here. See /git-hooks/post-checkout for full behavior.
}; exit
