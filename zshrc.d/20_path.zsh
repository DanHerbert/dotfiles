#!/usr/bin/zsh

# Make PATH only have unique values. Later entries are removed by earlier ones.
typeset -U path PATH

path=("$HOME/.local/bin" "$path[@]")
path=("$HOME/.golang/bin" "$path[@]")
path=("$HOME/.cargo/bin" "$path[@]")
path=("$HOME/.npm-packages/bin" "$path[@]")

if [[ -d "$HOME/.npm-packages/bin" ]]; then
    export NODE_PATH="$HOME/.npm-packages/bin"
fi

if command -v go 2>&1 >/dev/null && [[ -d "$HOME/golang/bin" ]]; then
    export GOPATH="$HOME/.golang"
fi
