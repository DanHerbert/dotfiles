#!/bin/bash

set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
GIT_WORK_TREE=$(cd "$SCRIPT_DIR"; git rev-parse --show-toplevel)

hooks=(post-checkout post-merge post-rewrite)

for hook_name in "${hooks[@]}"; do
    hook_origin="$SCRIPT_DIR/$hook_name"
    hook_dest="$GIT_WORK_TREE/.git/hooks/$hook_name"
    if [ ! -e "$hook_dest" ]; then
        ln -s "$hook_origin" "$hook_dest"
        echo "Created $hook_name hook"
    elif [ -e "$hook_dest" ] && [ ! -L "$hook_dest" ] &&
            [ "$(realpath "$hook_dest")" -ne "$hook_origin" ]; then
        echo "$hook_name exists and does not point to this project's hook."
    fi
done;
