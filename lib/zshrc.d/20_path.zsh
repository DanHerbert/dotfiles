#!/usr/bin/zsh

# Make PATH only have unique values. Later entries are removed by earlier ones.
typeset -U path PATH

if [ -n "$HOMEBREW_PREFIX" ]; then
    path=("$HOMEBREW_PREFIX/opt/binutils/bin" "$path[@]")
    for bindir in "$HOMEBREW_PREFIX"/opt/*/libexec/gnubin; do
        if ls -1 "$bindir" | grep -vFf <(ls -1 /usr/local/bin) 2>&1 1>/dev/null; then
            path=("$bindir" "$path[@]")
        fi
    done
fi
path=("$RUSTUP_HOME/bin" "$path[@]")
path=("$CARGO_HOME/bin" "$path[@]")
path=("$GOPATH/bin" "$path[@]")
path=("$HOME/.local/bin" "$path[@]")
