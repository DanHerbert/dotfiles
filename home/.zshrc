#!/usr/bin/zsh

# Don't do anything if not running an interactive shell.
if [[ ! -o interactive ]]; then
    exit
fi

zshrc_file="$(print -P %N)"
dotfiles_root="$(realpath "${zshrc_file:P:h}/..")"

for script in "$dotfiles_root"{/lib/zshrc.d,/lib/plugins/*,/untrackedrc.d}/*.{zsh,sh}(N); do
    source "$script"
done;

unset zshrc_file
unset dotfiles_root
unset script
