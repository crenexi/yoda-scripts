#!/bin/bash

dir=$(dirname "$0")
source "$dir/helpers/echo-utils.sh"

# Default source
default_src="./*"

##########
## Helpers

function echo_curr_dir() {
  echo_header "Current directory:"
  pwd
  echo
  ls -AF1 --group-directories-first .
  echo
}


function echo_src() {
  local warn="$1"
  clear

  # List current directory contents
  echo_curr_dir

  # Warn if needed
  if [[ -n "$warn" ]]; then
    echo_warn "$warn"
    echo
  fi

  # Echo source
  echo_header "Source:"
  echo_info ${cmagenta}${src}${cend}
}

function set_src() {
  local _src=$1

  # If the pattern appears to not specify base dir, make it relative
  [[ ! $_src =~ [\.~/].* ]] && _src="./$_src"

  src="$_src"
}

##########
## Functions

function read_src() {
  src="$default_src"
  echo_src

  while true; do
    read -e -p "Confirm (ENTER) or specify source dir/file: " new_src

    if [[ -z "$new_src" ]]; then
      break
    elif [[ "$new_src" == *[*?[]* ]]; then
      echo_src "Cannot be pattern. Only a directory or folder!"
    else
      set_src "$new_src"
      echo_src
    fi
  done
}

##########
## Main

function define_src() {
  read_src
  export src
}
