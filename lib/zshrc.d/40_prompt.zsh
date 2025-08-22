#!/usr/bin/zsh
# Prompt colors follow the spirit of Debian's default prompt guidance: Prompt
# should not distract the user. Focus should be on the output of commands, not
# the prompt. For me, that means using a dimmed color palette that deemphasizes
# the prompt data, but still has a touch of color to make it readable at a
# glance. See https://sources.debian.org/src/bash/5.2.37-2/debian/skel.bashrc#L43

# For documentation of zsh prompt expansion sequences, see:
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }

___LIB_DIR=$(cd "${0:a:h}/.." || exit 1; pwd)

compute_prompt_psvars() {
    for script in "$___LIB_DIR"/zshprompt.d/*.zsh; do
        source "$script"
    done
}

precmd_functions+=( precmd_vcs_info compute_prompt_psvars )

compute_initial_prompt() {
    local access_style='%{%F{226}%}' # Bright yellow
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
        psvar[1]+="$(id -un)"
    fi
    if [[ -n $SSH_CLIENT ]]; then
        if [[ -n $system_parts ]]; then
            system_parts+='%{%F{60}%}@%{%f%}'
            psvar[1]+='@'
        fi
        ssh_client_ip=$(echo $SSH_CLIENT | awk '{ print $1 }')
        if [[ -f "$XDG_CONFIG_HOME/hostname-public.txt" ]] && [[ "$ssh_client_ip" == "$(gatewayip)" ]]; then
            public_host=$(cat "$XDG_CONFIG_HOME/hostname-public.txt")
            system_parts+=$host_style$public_host'%{%f%}'
            psvar[1]+="$public_host"
        else
            system_parts+=$host_style"$(hostname --long)"'%{%f%}'
            psvar[1]+="$(hostname --long)"
        fi
    fi
    if [[ -n $system_parts ]]; then
        psvar[1]+=' '
        system_parts+=' '
    fi

    PS1="$system_parts$cwd_style"'%~%{%f%} '"$vcs_style"'${vcs_info_msg_0_}%{%f%}'%9(V.$'\n'.)"$access_style"'%#%{%b%f%} '
    PS2="$access_style"'⟩%{%f%} '

    export PS1
    export PS2
}
compute_initial_prompt
unset -f compute_initial_prompt

zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '⎇ %b%a %u%c%m'
