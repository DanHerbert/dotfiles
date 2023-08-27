#!/usr/bin/zsh

autoload -Uz compinit
compinit -u

zstyle :compinstall filename "$HOME/.zshrc"
# Case insensitive completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

setopt extendedglob
setopt histexpiredupsfirst
setopt histfindnodups
setopt histignorealldups
setopt histignoredups
setopt histignorespace
setopt histnostore
setopt histreduceblanks
setopt histsavenodups
setopt incappendhistory
setopt promptsubst
setopt sharehistory
