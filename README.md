# Dan Herbert's dotfiles

A collection of my shell scripts and config files that get copied around to
multiple machines.

At the moment, I'm currently only using Linux based OSes so these are very
Linux-centric. Probably 95% of these scripts should also work fine on macOS but
since some core utilities there are using BSD variants they might not work there
unless you've installed GNU coreutils via homebrew (or other) and set it up to
work without the "g" prefixes.

# Installation

To "install" this repo, you will need
[gnu stow](https://www.gnu.org/software/stow/) to be available on your device.
It is available on most \*nix package managers as simply `stow`.

Clone this repo, then run the `stow.sh` script to set up symlinks to the
necessary locations. Stow will not create a symlink if a file already exists so
running this command is mostly harmless on a new device. It is also idempotent
so it can be run repeatedly without any troubles.
