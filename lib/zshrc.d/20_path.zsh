#!/usr/bin/zsh

# Make PATH only have unique values. Later entries are removed by earlier ones.
typeset -U path PATH

path=("$HOME/.local/bin" "$path[@]")
path=("$GOPATH/bin" "$path[@]")
path=("$CARGO_HOME/bin" "$path[@]")
