#!/usr/bin/zsh
ACCOUNT_TYPE_STYLE='%{%F{221}%}' # Muted yellow
DIRECTORY_STYLE='%{%F{65}%}%' # Muted green
USER_STYLE='%{%F{66}%}' # Muted cyan
MACHINE_STYLE='%{%F{009}%}' # Muted light red

# Better desaturation if the terminal supports true 24-bit color support.
# if [[ $COLORTERM == 'truecolor' ]]; then
#     MACHINE_STYLE=$'%{\e[38;0;208;163;158%}' # Color #d0a39f
# fi

# root user styles.
if [[ $EUID == 0 ]]; then
    USER_STYLE='%{%B%F{255}%K{196}%}' # Bright red
    ACCOUNT_TYPE_STYLE='%{%B%F{200}%}%#' # Hot pink
    DIRECTORY_STYLE='%{%F{54}%}%' # Muted purple
fi

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_prompt() {
    psvar[1]=$'\%n'
}
precmd_functions+=( precmd_prompt precmd_vcs_info )

PS1=$USER_STYLE'%n%{%b%f%k%}%{%F{60}%}@%{%f%}'$MACHINE_STYLE'%m%{%f%} '"$DIRECTORY_STYLE"'0~%{%f%} ${vcs_info_msg_0_}'$'\n'"$ACCOUNT_TYPE_STYLE"'%#%{%b%f%} '
PS2="$ACCOUNT_TYPE_STYLE"'>%{%f%} '

zstyle ':vcs_info:git:*' formats '(%b)'
