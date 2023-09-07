#!/bin/bash

# Source the helper and utility functions
dir=$(dirname "$0")
source "$dir/helpers/helpers.sh"
source "$dir/../utils/echo-utils.sh"

# Sync develop
function sync_develop() {
  echo_header "STAGE" "clear"
  git checkout develop
  git pull origin develop
  read_version
  echo_callout "Version:" "v$version"
}

# Prompt user to proceed to stage
function confirm_stage() {
  while true; do
    read -p "Stage v$version? [y/n]: " input
    case "$input" in
      [Yy]* ) break;;
      [Nn]* ) exit 0;;
    esac
  done
}

sync_develop
confirm_stage
checkout_stage
update_stage
