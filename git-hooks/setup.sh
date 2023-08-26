#!/bin/sh

set -e

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
GIT_WORK_TREE=$(cd "$SCRIPT_DIR"; git rev-parse --show-toplevel)

hook_origin="$SCRIPT_DIR/post-checkout"
hook_dest="$GIT_WORK_TREE/.git/hooks/post-checkout"
if [ ! -e "$hook_dest" ] && [ ! -L "$hook_dest" ]; then
    ln -s "$hook_origin" "$hook_dest"
fi
