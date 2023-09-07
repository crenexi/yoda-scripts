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

# Checkout/create stage
function checkout_stage() {
  git rev-parse --verify stage > /dev/null 2>&1
  [ $? -eq 0 ] && git checkout stage || git checkout -b stage
}

# Complete merge
function update_stage() {
  git merge develop --no-edit
  git push origin stage
  echo_success "Merged changes from 'develop' to 'stage' and pushed to remote."
}

sync_develop
confirm_stage
checkout_stage
update_stage
