#!/usr/bin/zsh

# Emacs keybindings
bindkey -e

autoload edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

bindkey '^R' history-incremental-search-backward

# These might be terminal emulator specific
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
