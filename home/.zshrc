#!/usr/bin/zsh

zshrc_file="$(print -P %N)"
dotfiles_root="$(realpath "${zshrc_file:P:h}/..")"

for script in "$dotfiles_root"/{zshrc.d,untrackedrc.d}/*.{zsh,sh}(N); do
    source "$script"
done;

unset zshrc_file
unset dotfiles_root
unset script
