#!/bin/bash
# This script processes images in a given directory by creating two more
# images width 1920x and 1040x, and applying light compression. The input
# parameter is the dir where the images to be processed are located.

##########
## HELPERS

# Utility colors
cred="$\e[1;31m"
cgreen="$\e[1;32m"
cyellow="$\e[1;33m"
cblue="$\e[1;34m"
cmagenta="$\e[1;35m"
ccyan="$\e[1;36m"
cend="$\e[0m"

# Utility echos
echo_info () { printf "${cblue}${1}${cend}\n" }
echo_success() { printf "${cgreen}${1}${cend}\n" }
echo_warn() { printf "/!\ ${cyellow}${1}${cend}\n" }
echo_error() { printf "/!\ ${cred}${1}${cend}\n" }

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
  dir=$1
  ext=$2

  if [[ -z "$dir" || -z "$ext" ]]; then exit; fi

  shopt -s nullglob
  for f in "$dir"/*."$ext"; do
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

each_ext "$1" "png"
each_ext "$1" "jpg"
