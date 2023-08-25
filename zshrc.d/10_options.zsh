#!/usr/bin/zsh

zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit -u

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
