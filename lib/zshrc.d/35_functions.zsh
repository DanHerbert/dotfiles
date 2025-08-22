#!/usr/bin/zsh

if command -v ip 2>&1 >/dev/null; then
    lanip() {
        ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4}'
    }
    export lanip
fi

lanips() {
    if command -v ip 2>&1 >/dev/null; then
        ip -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4}'
    else
        ifconfig -l inet | xargs -n1 ipconfig getifaddr
    fi
}
export lanips

if command -v ip 2>&1 >/dev/null; then
    gatewayip() {
        ip route | head -n1 | awk '{ print $3 }'
    }
fi

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

if command -v lscpu 2>&1 >/dev/null; then
    # Count the number of cores, minus efficiency cores iff on an Alder Lake system.
    # Prior generations of Intel CPUs will return the total core count.
    cpu_perf_cores() {
        lscpu --all --extended | tail -n +2 | awk '{ print $4 }' | uniq -c | awk '{ print $1 }' | uniq -c | head -n1 | awk '{ print $1 }'
    }
    export cpu_perf_cores

    cpu_total_cores() {
        lscpu --all --extended | tail -n +2 | awk '{ print $4 }' | uniq | wc -l
    }
    export cpu_total_cores
fi
