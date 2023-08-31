#!/bin/sh

# This script can update itself while running (since it updates through git)
# All commands must happen within these curly brace blocks to ensure everything
# loads into memory before executing.
{
    PROJECT_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

    set -eux

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
    OWNER=$(stat -c "%U" "$PROJECT_ROOT")
    GROUP=$(stat -c "%G" "$PROJECT_ROOT")
    old_version=$(git rev-parse HEAD)
    old_submodule_version=$(git submodule status --recursive | sha1sum | awk '{ print $1 }')
    GIT_SSH_COMMAND="ssh -o BatchMode=yes" git pull --force --autostash --recurse-submodules
    GIT_SSH_COMMAND="ssh -o BatchMode=yes" git submodule update --init --recursive
    # When this update happens through systemd (root), ownership can get wonky.
    chown -R "$OWNER":"$GROUP" "$PROJECT_ROOT"

    new_version=$(git rev-parse HEAD)
    new_submodule_version=$(git submodule status --recursive | sha1sum | awk '{ print $1 }')
    if [ "$new_version" != "$old_version" ] || [ "$old_submodule_version" != "$new_submodule_version" ]; then
        "$PROJECT_ROOT/stow.sh"
    fi
}
exit
