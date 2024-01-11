#!/bin/bash

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

# Full-width header
echo_header() {
  local message="$1" # required
  local do_clear="$2" # optional
  local term_width=$(tput cols)
  local hashes=""

  # Add hashes up to term_width, unless message is longer
  if [ $((${#message} + 4)) -lt $term_width ]; then
    total_hashes=$(($term_width - ${#message} - 4))
    hashes=$(printf '#%.0s' $(seq 1 $total_hashes))
  fi

  if [[ ! -z $do_clear ]]; then clear; fi # clear
  echo -e "## $message $hashes" # message
}

# Simple emphasis
echo_callout() {
  local header="$1" # required
  local message="$2" # required
  local color=$3 # optional

  echo "## $header"
  echo "##\\"

  if [[ -v $color ]]; then
    echo "$message"
  else
    echo -e "${color}${message}${cend}"
  fi

  echo "##/"
}


