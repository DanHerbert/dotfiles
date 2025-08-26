#!/bin/sh

# This script can update itself while running (since it updates through git)
# All commands must happen within these curly brace blocks to ensure everything
# loads into memory before executing.
{
    PROJECT_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
    OWNER=$(stat -c "%U" "$PROJECT_ROOT")
    # Wrapper that ensures all git operations run as the correct user, while
    # also ensuring the correct SSH mode for any remote operations.
    u_git() {
        git_args="$*"
        sudo -u "$OWNER" sh -c "GIT_SSH_COMMAND='ssh -o BatchMode=yes'; git $git_args"
    }

    set -e

    cd "$PROJECT_ROOT" || exit 1

    current_branch="$(u_git branch --show-current)"
    git_failed=$?
    if [ "$git_failed" != 0 ]; then
        echo "Bad git ownership detected. Doing nothing."
        echo 'Project user'
        stat -c '%U' "$PROJECT_ROOT"
        echo 'Script user'
        id -u -n
        echo 'Current safe directories'
        u_git --no-pager config --show-origin --get-all safe.directory
        exit 1
    fi
    if [ "$current_branch" != 'main' ]; then
        echo 'On a non-default branch. Doing nothing.'
        exit
    fi
    if ! u_git ls-remote >/dev/null 2>&1; then
        echo 'Unable to connect to github.com to perform operations. Aborting...'
        exit 1
    fi
    old_version=$(u_git rev-parse HEAD)
    old_submodule_version=$(u_git submodule status --recursive | sha1sum | awk '{ print $1 }')
    has_stash=false
    if [ "$(u_git status --porcelain | wc -l)" -gt 0 ]; then
        has_stash=true
        u_git stash --include-untracked
    fi
    u_git pull --force --recurse-submodules
    u_git submodule update --init --recursive

    new_version=$(u_git rev-parse HEAD)
    new_submodule_version=$(u_git submodule status --recursive | sha1sum | awk '{ print $1 }')
    if $has_stash; then
        u_git stash pop
    fi
    if [ "$new_version" != "$old_version" ] || [ "$old_submodule_version" != "$new_submodule_version" ]; then
        # Stow expects to be sourced, but that is not needed inside update.sh
        # and can make things behave strangely if we do source the script.
        sudo -u "$OWNER" sh -c 'INSIDE_UPDATE_SCRIPT=1; export INSIDE_UPDATE_SCRIPT; '"$PROJECT_ROOT/stow.sh"
    fi
}
exit
