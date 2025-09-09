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

    local system_parts
    local uid_primary=-1
    local uid_max=60000
    local user_count
    # Getting system user info on MacOS is very slow and the values never change
    # once the system is set up, so storing them in a file allows things to
    # speed up
    local user_stats_file="$XDG_STATE_HOME/dotfiles/users.stats"

    if [[ -f "$users_stats_file" ]]; then
        uid_primary=$(grep -m 1 uid_primary "$users_stats_file" | cut -d ' ' -f 2)
        uid_max=$(grep -m 1 uid_max "$users_stats_file" | cut -d ' ' -f 2)
        user_count=$(grep -m 1 user_count "$users_stats_file" | cut -d ' ' -f 2)
    elif [[ -f '/etc/login.defs' ]]; then
        uid_primary=$(grep -m 1 -E '^UID_MIN\s' /etc/login.defs | awk '{ print $2 }')
        uid_max=$(grep -m 1 -E '^UID_MAX\s' /etc/login.defs | awk '{ print $2 }')
        user_count=$(getent passwd | awk -F ':' "{ if (\$3 >= $uid_primary && \$3 <= $uid_max) { print \$3 } }" | wc -l)
        mkdir -p "$XDG_STATE_HOME/dotfiles"
        echo "uid_primary $uid_primary" > "$XDG_STATE_HOME/dotfiles/users.stats"
        echo "uid_max $uid_max" >> "$XDG_STATE_HOME/dotfiles/users.stats"
        echo "user_count $user_count" >> "$XDG_STATE_HOME/dotfiles/users.stats"
    # MacOS and BSD systems don't use the same login conventions as Linux.
    elif command -v dscl >/dev/null 2>&1; then
        real_user_list=$(dscl . list /Users | grep -v '^_' | xargs  -I % sh -c '[ -d /Users/% ] && echo %')
        uid_primary="$(id -u $(echo "$real_user_list" | head -1))"
        user_count=$(echo "$real_user_list" | wc -l)
        mkdir -p "$XDG_STATE_HOME/dotfiles"
        echo "uid_primary $uid_primary" > "$XDG_STATE_HOME/dotfiles/users.stats"
        echo "uid_max $uid_max" >> "$XDG_STATE_HOME/dotfiles/users.stats"
        echo "user_count $user_count" >> "$XDG_STATE_HOME/dotfiles/users.stats"
    fi

    # root user styles. Intentionally meant to call attention to remind me to avoid
    # lingering in this state for too long.
    if [[ $EUID == 0 ]] && [[ $user_count > 0 ]]; then
        user_style='%{%B%F{255}%K{196}%}' # Bright red
        # Note the extra # inserted at the end to make it more "annoying"
        access_style='%{%B%F{200}%}%#' # Hot pink
        cwd_style='%{%F{54}%}' # Muted purple
        if [[ $COLORTERM =~ ^(truecolor|24bit)$ ]]; then
            cwd_style='%{%F{#443f46}%}' # Desaturated purple
        fi
    fi

    # Only show the user name in the prompt if not currently signed in as the
    # primary (first) user on the system.
    if [[ $(id -u) != $uid_primary ]]; then
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
