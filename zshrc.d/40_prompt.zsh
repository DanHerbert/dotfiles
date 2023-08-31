#!/usr/bin/zsh
# Prompt colors follow the spirit of Debian's default prompt guidance: Prompt
# should not distract the user. Focus should be on the output of commands, not
# the prompt. For me, that means using a dimmed color palete that deemphasizes
# the prompt data, but still has a touch of color to make it readable at a
# glance. See https://sources.debian.org/src/bash/4.3-11/debian/skel.bashrc/#L43

# For documentation of zsh prompt expansion sequences, see:
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
compute_needs_newline() {
    # zsh prompt expansions treat "empty" as false and all other values as true.
    psvar[1]=''
    cwd=$(cd "$PWD" && dirs -p | head -1)
    cwd_length=${#cwd}
    vcs_length=${#vcs_info_msg_0_}
    sys_length="${#__prompt_system_parts}"
    venv_length=${#VIRTUAL_ENV_PROMPT}
    if [[ $(( venv_length + cwd_length + vcs_length + sys_length )) -ge 32 ]]; then
        psvar[1]=true
    fi
}
precmd_functions+=( precmd_vcs_info compute_needs_newline )

compute_initial_prompt() {
    local access_style='%{%F{11}%}' # Bright yellow
    local user_style='%{%F{66}%}' # Muted cyan
    local host_style='%{%F{95}%}' # Muted light red
    local cwd_style='%{%F{65}%}' # Muted green
    local vcs_style='%{%F{94}%}' # Muted orange

    if [[ $COLORTERM =~ ^(truecolor|24bit)$ ]]; then
        user_style='%{%F{#466767}%}' # Desaturated cyan
        host_style='%{%F{#886763}%}' # Desaturated red
        cwd_style='%{%F{#505544}%}' # Desaturated green
        vcs_style='%{%F{#6d5840}%}' # Desaturated orange
    fi

    # root user styles. Intentionally meant to call attention to remind me to avoid
    # lingering in this state for too long.
    if [[ $EUID == 0 ]]; then
        user_style='%{%B%F{255}%K{196}%}' # Bright red
        # Note the extra # inserted at the end to make it more "annoying"
        access_style='%{%B%F{200}%}%#' # Hot pink
        cwd_style='%{%F{54}%}' # Muted purple
        if [[ $COLORTERM =~ ^(truecolor|24bit)$ ]]; then
            cwd_style='%{%F{#443f46}%}' # Desaturated purple
        fi
    fi

    local system_parts
    if [[ $(id -u) -ne 1000 ]]; then
        system_parts=$user_style'%n%{%b%f%k%}'
    fi
    if [[ -n $SSH_CLIENT ]]; then
        if [[ -n $system_parts ]]; then
            system_parts+='%{%F{60}%}@%{%f%}'
        fi
        system_parts+=$host_style'%m%{%f%}'
    fi
    if [[ -n $system_parts ]]; then
        system_parts+=' '
    fi

    PS1="$system_parts$cwd_style"'%~%{%f%} '"$vcs_style"'${vcs_info_msg_0_}%{%f%}'%1(V.$'\n'.)"$access_style"'%#%{%b%f%} '
    PS2="$access_style"'>%{%f%} '
    __prompt_system_parts="$system_parts"

    export PS1
    export PS2
    export __prompt_system_parts
}
compute_initial_prompt
unset -f compute_initial_prompt

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '⎇ %b%a %u%c%m'
