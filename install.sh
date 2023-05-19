#!/bin/bash
# Installs all of these scripts at ~/bin

folders=(
  "./cxa"
  "./cxg"
  "./cxi"
  "./cxr"
  "./cxx"
)

# Ensure bin exists
mkdir -p "$HOME/bin"

# Script copies
for folder in "${folders[@]}"
do
  folder_name=$(basename "$folder")
  rsync -av --delete "$folder/" "$HOME/bin/$folder_name/"
  find $HOME/bin/$folder -type f -name "*.sh" -exec chmod 755 -- {} +
done

source $HOME/.bashrc
