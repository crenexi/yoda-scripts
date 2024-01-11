#!/bin/bash
# This script processes images in a given directory by creating two more
# images width 1920x and 1040x, and applying light compression. The input
# parameter is the dir where the images to be processed are located.
set -e

##########
## HELPERS

# Utility colors
cred="\e[1;31m"
cgreen="\e[1;32m"
cyellow="\e[1;33m"
cblue="\e[1;34m"
cmagenta="\e[1;35m"
ccyan="\e[1;36m"
cend="\e[0m"

# Utility echos
echo_info () { echo -e "${cblue}${1}${cend}"; }
echo_success() { echo -e "${cgreen}${1}${cend}"; }
echo_warn() { echo -e "/!\ ${cyellow}${1}${cend}"; }
echo_error() { echo -e "/!\ ${cred}${1}${cend}"; }

##########
## MAIN

function produce() {
  name="$1"
  width="$2"

  if [[ -z "$name" ]]; then
    echo_error "Name not specified. Exiting."
    exit;
  fi

  if [[ -z "$width" ]]; then
    echo_error "Width not specified. Exiting."
    exit;
  fi

  src="${name}_og.${ext}"
  file_og="${name}_${width}_og.$ext"
  file="${name}_${width}.$ext"

  convert "$src" -resize "${width}x" "$file_og"
  ffmpeg -i "$file_og" -compression_level 75 -y "$file"
}

function each_ext() {
  dir="$1"
  ext="$2"

  if [[ -z "$dir" ]]; then
    echo_error "Directory (first arg) not specified. Exiting."
    exit;
  fi

  if [[ -z "$ext" ]]; then
    echo_error "Extension (second arg) not specified. Exiting."
    exit;
  fi

  shopt -s nullglob
  files=("$dir"/*_og."$ext")

  # No files with original suffix
  if [ ${#files[@]} -eq 0 ]; then
    echo "No files with \"_og.${ext}\" exist in this directory"
  fi

  # For each image file
  for f in $files; do
    basename=$(basename "$f" ".$ext")
    name=$(echo "$basename" | sed -e "s/_og//g")
    width=$(identify -format "%w" "$f")

    # Compress the original
    ffmpeg -i "$f" -compression_level 85 -y "$name.$ext"

    # Produce size variations
    if [ "$width" -gt 1920 ]; then produce "$name" 1920; fi
    if [ "$width" -gt 1040 ]; then produce "$name" 1040; fi
  done
  shopt -u nullglob
}

each_ext "$1" "jpeg"
each_ext "$1" "jpg"
each_ext "$1" "png"
