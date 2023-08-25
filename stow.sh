#!/bin/bash
# This script is intentionally idempotent so that it can safely "sync" new files
# when run repeatedly.
set -euv

stow --target="$HOME/.config" config
stow --target="$HOME/.local" local
stow --target="$HOME" home
