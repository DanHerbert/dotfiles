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
export wanips

# Count the number of cores, minus efficiency cores iff on an Alder Lake system.
# Prior generations of Intel CPUs will return the total core count.
perf_cores() {
    lscpu --all --extended | tail -n +2 | awk '{ print $4 }' | uniq -c | awk '{ print $1 }' | uniq -c | head -n1 | awk '{ print $1 }'
}

totalcores() {
    grep -E '^cpu\scores' /proc/cpuinfo | uniq |  awk '{print $4}'
}
