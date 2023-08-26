#!/bin/bash
# Installs all of these scripts at ~/.cx/bin

folders=(
  "./utils"
  "./cxa"
  "./cxg"
  "./cxi"
  "./cxr"
  "./cxx"
)

# Ensure bin exists
cx_bin="$HOME/.cx/bin"
mkdir -p "$cx_bin"

# Script copies
for folder in "${folders[@]}"
do
  folder_name=$(basename "$folder")
  rsync -av --delete "$folder/" "$cx_bin/$folder_name/"
  find $cx_bin/$folder -type f -name "*.sh" -exec chmod 755 -- {} +
done

source $HOME/.bashrc
