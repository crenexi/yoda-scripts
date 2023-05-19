#!/bin/bash
# Installs all of these scripts at ~/bin/bac

# Ensure bin/bac exists
dir="$HOME/bin/bac"
mkdir -p "$dir"

rsync -av --delete "." "$dir/"
find "$dir/" -type f -name "*.sh" -exec chmod 755 -- {} +

source $HOME/.bashrc
