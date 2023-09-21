#!/bin/zsh

# How my psvar array is arranged.
# psvar[1]=system_parts
# psvar[9]=prompt newline

compute_psvars() {
    local PROMPT_WRAP_LIMIT
    PROMPT_WRAP_LIMIT=30
    local cwd
    cwd=$(cd "$PWD" && dirs -p | head -1)

    # zsh prompt expansions treat "empty" as false and all other values as true.
    psvar[9]=''
    local vcs_len
    local venv_len
    local prompt_len
    vcs_len=${#vcs_info_msg_0_}
    venv_len=${#VIRTUAL_ENV_PROMPT}
    prompt_len=$(( venv_len + ${#cwd} + vcs_len + ${#psvar[1]} ))
    if [[ $prompt_len -ge $PROMPT_WRAP_LIMIT ]]; then
        psvar[9]=true
    fi
}
compute_psvars
