#!/usr/bin/zsh

lanip() {
    /usr/bin/ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4}'
}
export lanip

lanips() {
    /usr/bin/ip -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4}'
}
export lanips

wanip() {
    curl --write-out '\n' --silent 'https://ipv4.dan.herbert.io/remote_addr'
}
export wanip

wanip6() {
    curl --write-out '\n' --silent 'https://ipv6.dan.herbert.io/remote_addr'
}
export wanip6

wanips() {
    wanip
    wanip6
}
export wanip6
