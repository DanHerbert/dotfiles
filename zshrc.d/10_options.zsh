#!/usr/bin/zsh

[[ -d $ZSH_COMPDUMP ]] || mkdir -p $ZSH_COMPDUMP
_comp_files=($ZSH_COMPDUMP/zcompdump(Nm-20))

zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path $ZSH_COMPDUMP/zcompdump-${ZSH_VERSION}

if (( $#_comp_files )); then
    autoload -Uz compinit -C -d "$ZSH_COMPDUMP/zcompdump-${ZSH_VERSION}"
else
    autoload -Uz compinit -d "$ZSH_COMPDUMP/zcompdump-${ZSH_VERSION}"
fi

compinit -u -d "$ZSH_COMPDUMP/zcompdump-${ZSH_VERSION}"

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
