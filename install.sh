#!/bin/bash -e

# Before installing dependencies, this script will ensure that these packages:
#   a) Exist within the system's package manager
#   b) Are not already installed.
# Some package names listed here are intentional duplicates like 'pipx' and
# 'python-pipx' which exist under different names in different package managers.
dependencies=(bat bc build-essential cargo curl dash datamash dosfstools etckeeper fastfetch git glow go golang jq libssl-dev moreutils needrestart npm pipx pkg-config python-pip python-pipx python-virtualenv python3-pip python3-virtualenv ripgrep rsync shellcheck shfmt stow stress stress-ng tig tmux traceroute tree vim wget xkcdpass zsh zsh-completions)

export DEBIAN_FRONTEND=noninteractive

main() {
    local install_user="$USER"
    parent_dir=$(get_dotfiles_parent_dir "$install_user")
    if [[ -d "$parent_dir/dotfiles" ]]; then
        echo 'dotfiles appear to be installed. Doing nothing'
        exit 1
    fi
    local os_type starttime stoptime
    os_type="$(uname -o)"
    starttime="$(date +%s.%N)"

    do_ssh_setup "$install_user"

    if [ "$os_type" = 'Darwin' ]; then
        do_macos_install
    elif [ "$os_type" = 'GNU/Linux' ]; then
        do_gnulinux_install
    fi
    stoptime="$(date +%s.%N)"
    total_runtime=$(echo "$stoptime - $starttime" | bc)
    runtime_days=$(echo "$total_runtime/86400" | bc)
    total_runtime=$(echo "$total_runtime-86400*$runtime_days" | bc)
    runtime_hours=$(echo "$total_runtime/3600" | bc)
    total_runtime=$(echo "$total_runtime-3600*$runtime_hours" | bc)
    runtime_minutes=$(echo "$total_runtime/60" | bc)
    total_runtime=$(echo "$total_runtime-60*$runtime_minutes" | bc)
    runtime_seconds=$(echo "$total_runtime-60*$runtime_minutes" | bc)
    printf "runtime: %d:%02d:%02d:%06.3f\n" \
        "$runtime_days" "$runtime_hours" "$runtime_minutes" "$runtime_seconds"
}

do_ssh_setup() {
    local install_user="$1"
    local u_home
    u_home=$(eval echo "~${install_user}")
    if [[ ! -f "$u_home/.ssh/keys/id_main" ]]; then
        mkdir -p "$u_home/.ssh/keys/"
        (set -x; sudo -u "$install_user" ssh-keygen -t ssh-ed25519 -C "$install_user@$(hostname)" -P '' -f "$u_home/.ssh/keys/id_main")
        cat "$u_home/.ssh/keys/id_main.pub"
        read -srp "Copy SSH public key, then press Enter to continue."
    fi
    if [[ ! -e "$u_home/.ssh/config" ]]; then
        download_from_dotiles_repo 'home/.ssh/config' "$u_home/.ssh/config" "$install_user"
    fi
    ssh -NT git@github.com 2>&1 | grep -o 'successfully authenticated'
    ssh_files=( "keys/id_main" "keys/id_main.pub" "config" "known_hosts" )
    for ssh_file in "${ssh_files[@]}"; do
        user_file="$u_home/.ssh/$ssh_file"
        root_file="/root/.ssh/$ssh_file"
        has_root_file="$(sudo /bin/sh -c "test -f /root/.ssh/$ssh_file" || echo 1)"
        if [[ -f "$user_file" ]] && [[ $has_root_file -eq 1 ]]; then
            sudo mkdir -pv /root/.ssh/keys/
            (set -x; sudo cp "$user_file" "$root_file")
        fi
    done
    (set -x
    sudo chown -fR "$install_user:$(id -gn "$install_user")" "$u_home/.ssh"
    sudo chmod -f 600 "$u_home/.ssh/keys/id_main"
    sudo chmod -f 644 "$u_home/.ssh/keys/id_main.pub"
    sudo chown -fR root:root /root/.ssh
    sudo chmod -f 600 "$u_home/.ssh/keys/id_main"
    sudo chmod -f 644 "$u_home/.ssh/keys/id_main.pub"
    )
}

do_common_install() {
    do_dotfiles_install_for "$USER"
    do_dotfiles_install_for "root"
}

do_macos_install() {
    # Ensure XCode/Homebrew exists, then install.
    echo 'TODO'
}

do_gnulinux_install() {
    local distro_type
    distro_type="$(lsb_release --short --id)"
    case "$distro_type" in
        "Arch")
        # Use pacman and/or AUR helper to install.
        ;;
        "Debian" | "Ubuntu")
        # Use apt to install.
        do_debian_install "$distro_type"
        ;;
    esac
    do_common_linux_install
}

do_common_linux_install() {
    (set -x
    sudo etckeeper init
    sudo /bin/sh -c "set -x; cd /etc && git config user.name '$USER' && git config user.email '$USER@$(hostname)'"
    sudo etckeeper commit 'Configure etckeeper repo authorship'

    sudo chsh -s '/usr/bin/zsh' "$USER"
    sudo chsh -s '/usr/bin/zsh' 'root'
    )

    do_common_install
    do_os_config
}

do_debian_install() {
    sudo apt update
    sudo apt upgrade --assume-yes
    # shellcheck disable=SC2046
    sudo apt install --assume-yes $(get_debian_packages)
}

do_os_config() {
    cd "$(get_dotfiles_parent_dir "$USER")/dotfiles"
    if ! grep 'SUDO_EDITOR' /etc/environment; then
        (set -x; cat ./root/etc/environment | sudo tee -a /etc/environment)
    fi
    if [[ -d '/etc/etckeeper' ]]; then
        (set -x; sudo cp ./root/etc/etckeeper/commit.d/50vcs-commit /etc/etckeeper/commit.d/)
        (set -x; sudo sed -i "s/GIT_COMMIT_OPTIONS=\"\"/GIT_COMMIT_OPTIONS='--author=\"etckeeper <etckeeper@$(hostname)>\"'/" /etc/etckeeper/etckeeper.conf)
    fi
}

get_debian_packages() {
    local pkgs_to_install=()
    local pkg_exists pkg_installed
    for pkg in "${dependencies[@]}"; do
        pkg_exists="$(apt-cache search --names-only "^$pkg\$" | wc -l)"
        pkg_installed="$(dpkg -l "$pkg" 2>/dev/null | grep -c 'ii')"
        if [[ $pkg_exists -gt 0 ]] && [[ $pkg_installed -eq 0 ]]; then
            pkgs_to_install+=( "$pkg" )
        fi
    done
    set -x
    echo "${pkgs_to_install[*]}"
}

get_dotfiles_parent_dir() {
    if [ "$#" -ne 1 ]; then
        echo 'Missing username param for get_dotfiles_parent_dir'
        exit 1
    fi
    local install_user="$1"
    local u_home
    u_home=$(eval echo "~${install_user}")
    local dotfiles_location="$u_home"
    primary_uid=$(grep -m 1 -E '^UID_MIN\s' /etc/login.defs | awk '{ print $2 }')

    if [[ $(id -u "$install_user") == "$primary_uid" ]]; then
        if [[ -d "$u_home/Documents" ]]; then
            dotfiles_location="$u_home/Documents/code"
        else
            dotfiles_location="$u_home/code"
        fi
    fi
    echo "$dotfiles_location"
}

do_dotfiles_install_for() {
    local install_user="$1"
    local u_home
    u_home=$(eval echo "~${install_user}")

    dotfiles_parent_dir=$(get_dotfiles_parent_dir "$install_user")
    sudo -u "$install_user" mkdir -p "$dotfiles_parent_dir"

    sudo -u "$install_user" /bin/sh -c "set -x; cd $dotfiles_parent_dir; git clone --recurse-submodules git@github.com:DanHerbert/dotfiles.git"
    if [[ ! -d "$dotfiles_parent_dir/dotfiles/.git" ]]; then
        echo "git clone failed for $install_user"
        exit 1
    fi
    sudo -u "$install_user" /bin/sh -c "set -x; cd $dotfiles_parent_dir/dotfiles; git pull --rebase --force --recurse-submodules"
    sudo -u "$install_user" /bin/sh -c "set -x; cd $dotfiles_parent_dir/dotfiles; git submodule update --init --recursive"
    sudo -u "$install_user" /bin/sh -c "set -x; NOT_SOURCED_OK=1 $dotfiles_parent_dir/dotfiles/stow.sh"

    echo "dotfiles have been installed for $install_user"
}

download_from_dotiles_repo() {
    local rel_path="$1"
    local out_path="$2"
    local install_user="$3"
    dl_url="https://raw.githubusercontent.com/DanHerbert/dotfiles/refs/heads/main/$rel_path"
    if command -v curl >/dev/null 2>&1; then
        sudo -u "$install_user" curl -o "$out_path" "$dl_url" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        sudo -u "$install_user" wget -O "$out_path" "$dl_url" 2>/dev/null
    fi
}

main
