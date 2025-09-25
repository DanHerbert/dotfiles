#!/bin/bash -e

# Before installing dependencies, this script will ensure that these packages:
#   a) Exist within the system's package manager
#   b) Are not already installed.
# Some package names listed here are intentional duplicates like 'pipx' and
# 'python-pipx' which exist under different names in different package managers.
dependencies=(bat bc build-essential cargo curl dash datamash dosfstools etckeeper fastfetch git glow go golang jq libssl-dev moreutils needrestart npm pipx pkg-config python-pip python-pipx python-virtualenv python3-pip python3-virtualenv ripgrep rsync shellcheck shfmt stow stress stress-ng tig tmux traceroute tree vim wget xkcdpass zsh zsh-completions)

export DEBIAN_FRONTEND=noninteractive

main() {
    parent_dir=$(get_dotfiles_parent_dir "$USER")
    if [[ -d "$parent_dir/dotfiles" ]]; then
        echo 'dotfiles appear to be installed. Doing nothing'
        exit 1
    fi
    local os_type starttime stoptime
    os_type="$(uname -o)"
    starttime="$(date +%s.%N)"

    do_ssh_setup
    ssh -NT git@github.com

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
    if [[ ! -f "$HOME/.ssh/keys/id_main" ]] && [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        mkdir -p "$HOME/.ssh/keys/"
        (set -x; ssh-keygen -t ssh-ed25519 -C "$USER@$(hostname)" -P '' -f "$HOME/.ssh/keys/id_main")
        cat "$HOME/.ssh/keys/id_main.pub"
        read -srp "Copy SSH public key, then press Enter to continue."
        if [[ ! -e "$HOME/.ssh/config" ]]; then
            download_from_dotiles_repo 'home/.ssh/config' "$HOME/.ssh/config"
        fi
    fi
    has_root_key=$(sudo /bin/sh -c 'test -e /root/.ssh/keys/id_main' || echo 1)
    if ! $has_root_key; then
        (set -x
        sudo mkdir -p /root/.ssh/keys/
        sudo cp "$HOME/.ssh/keys/id_main" "$HOME/.ssh/keys/id_main.pub" /root/.ssh/keys/
        sudo cp "$HOME"/.ssh/config /root/.ssh/
        sudo cp "$HOME"/.ssh/known_hosts /root/.ssh/
        sudo chown -fR root:root /root/.ssh
        sudo chmod -f 600 "$HOME/.ssh/keys/id_main"
        sudo chmod -f 644 "$HOME/.ssh/keys/id_main.pub"
        )
    fi
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
    set -x
    sudo etckeeper init
    sudo /bin/sh -c "set -x; cd /etc && git config user.name '$USER' && git config user.email '$USER@$(hostname)'"
    sudo etckeeper commit 'Configure etckeeper repo authorship'

    sudo chsh -s '/usr/bin/zsh' "$USER"
    sudo chsh -s '/usr/bin/zsh' 'root'

    set +x

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
    mkdir -p "$dotfiles_parent_dir"

    sudo -u "$install_user" /bin/sh -c "set -x; cd $dotfiles_parent_dir; git clone --recurse-submodules git@github.com:DanHerbert/dotfiles.git"
    sudo -u "$install_user" /bin/sh -c "set -x; cd $dotfiles_parent_dir/dotfiles; git pull --force --recurse-submodules"
    sudo -u "$install_user" /bin/sh -c "set -x; cd $dotfiles_parent_dir/dotfiles; git submodule update --init --recursive"
    sudo -u "$install_user" /bin/sh -c "set -x; INSIDE_UPDATE_SCRIPT=1 $dotfiles_parent_dir/dotfiles/stow.sh"

    echo "dotfiles have been installed for $install_user"
}

download_from_dotiles_repo() {
    rel_path="$1"
    out_path="$2"
    dl_url="https://raw.githubusercontent.com/DanHerbert/dotfiles/refs/heads/main/$rel_path"
    if command -v curl >/dev/null 2>&1; then
        curl -o "$out_path" "$dl_url" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$out_path" "$dl_url" 2>/dev/null
    fi
    chmod +x "$out_path"
}

main
