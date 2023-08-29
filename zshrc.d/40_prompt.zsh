#!/usr/bin/zsh
# Prompt colors follow the spirit of Debian's default prompt guidance: Prompt
# should not distract the user. Focus should be on the output of commands, not
# the prompt. For me, that means using a dimmed color palete that deemphasizes
# the prompt data, but still has a touch of color to make it readable at a
# glance. See https://sources.debian.org/src/bash/4.3-11/debian/skel.bashrc/#L43


ACCESS_LEVEL_STYLE='%{%F{226}%}' # Bright yellow
USER_STYLE='%{%F{66}%}' # Muted cyan
MACHINE_STYLE='%{%F{009}%}' # Muted light red
DIRECTORY_STYLE='%{%F{65}%}' # Muted green
VSC_STYLE='%{%F{94}%}' # Muted orange

if [[ $COLORTERM =~ ^(truecolor|24bit)$ ]]; then
    USER_STYLE='%{%F{#466767}%}' # Desaturated cyan
    MACHINE_STYLE='%{%F{#886763}%}' # Desaturated red
    DIRECTORY_STYLE='%{%F{#505544}%}' # Desaturated green
    VSC_STYLE='%{%F{#6d5840}%}' # Desaturated orange
fi

# root user styles. Intentionally meant to call attention to remind me to avoid
# lingering in this state for too long.
if [[ $EUID == 0 ]]; then
    USER_STYLE='%{%B%F{255}%K{196}%}' # Bright red
    # Note the extra # inserted at the end to make it more "annoying"
    ACCESS_LEVEL_STYLE='%{%B%F{200}%}%#' # Hot pink
    DIRECTORY_STYLE='%{%F{54}%}%' # Muted purple
    if [[ $COLORTERM =~ ^(truecolor|24bit)$ ]]; then
        DIRECTORY_STYLE='%{%F{#443f46}%}' # Desaturated purple
    fi
fi

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_prompt() {
    psvar[1]=$'\%n'
}
precmd_functions+=( precmd_prompt precmd_vcs_info )

PS1=$USER_STYLE'%n%{%b%f%k%}%{%F{60}%}@%{%f%}'$MACHINE_STYLE'%m%{%f%} '"$DIRECTORY_STYLE"'%~%{%f%} '"$VSC_STYLE"'${vcs_info_msg_0_}'"%{%f%}"$'\n'"$ACCESS_LEVEL_STYLE"'%#%{%b%f%} '
PS2="$ACCOUNT_TYPE_STYLE"'>%{%f%} '

zstyle ':vcs_info:git:*' formats '(%b)'
