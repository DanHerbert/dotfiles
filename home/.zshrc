#!/usr/bin/zsh

zshrc_file="$(print -P %N)"
dotfiles_root="$(realpath "${zshrc_file:P:h}/..")"
unset zshrc_file

for script in "$dotfiles_root"/{zshrc.d,untrackedrc.d}/*.{zsh,sh}(N); do
    if [[ -r "${script:P}" ]] && [[ -f "${script:P}" ]]; then
        real_script="${script:P}"
        source "$real_script"
        unset real_script
    fi
done;

unset script;
unset dotfiles_root;
