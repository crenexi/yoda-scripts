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

sync_develop
prompt_update_stage
