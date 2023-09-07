#!/bin/bash

dir=$(dirname "$0")
source "$dir/../utils/splash.sh"
source "$dir/../utils/echo-utils.sh"

ssh_locations_file="$dir/config/ssh-locations.json"

## FUNCTIONS ##################################################################

# Exit script
function error() {
  message=${1:-"Unknown error."}
  echo_error "$message"
  exit 1
}

# Validate JSON locations
function validate_locations_json() {
  # Ensure file exists
  if [[ ! -f $ssh_locations_file ]]; then
    error "SSH locations JSON file not found."
  fi

  # Ensure it's parseable
  if ! jq empty "$ssh_locations_file" >/dev/null 2>&1; then
    error "Invalid JSON file format."
  fi
}

function read_locations() {
  validate_locations_json
  IFS=$'\n' read -rd '' -a ssh_locations < <(jq -r 'map(.name + ":" + .pem_path + ":" + .ssh_url) | .[]' "$ssh_locations_file")
}

function validate_pem_path() {
  if [[ ! -f $1 ]]; then
    error "PEM file $1 not found."
  fi
}

function echo_locations() {
  locations_count=1
  echo "#/"

  for location in "${ssh_locations[@]}"; do
    IFS=':' read -r -a location_arr <<< "$location"
    name=${location_arr[0]}
    pem_path=${location_arr[1]}
    ssh_url=${location_arr[2]}

    echo "$locations_count) $name"
    echo "## SSH: $ssh_url"
    echo "## PEM: $pem_path"
    echo "#/"

    ((locations_count++))
  done

  # Range of locations like "1-3"
  locations_range="1-$((locations_count - 1))"
  [[ $locations_count -eq 2 ]] && locations_range="1"
}

function open_ssh_session() {
  local debug="true"

  echo_header "SSH" "clear"
  echo_callout "Location:" "$name"

  # SSH command
  ssh_cmd="ssh"
  if [ $debug == "true" ]; then ssh_cmd+=" -vvv"; fi
  ssh_cmd+=" -i \"$pem_path\" \"$ssh_url\""
  eval "$ssh_cmd"
}

function prompt_location() {
  while true; do
    clear
    echo_header "SSH TO"
    echo_locations

    read -p "Enter your choice [$locations_range]: " input

    # Validate choice
    if [[ $input -ge 1 && $input -lt $locations_count ]]; then
      location=${ssh_locations[$((input-1))]}
      IFS=':' read -r -a location_arr <<< "$location"

      name=${location_arr[0]}
      pem_path=${location_arr[1]}
      ssh_url=${location_arr[2]}

      validate_pem_path "$pem_path"
      open_ssh_session
      break
    fi
  done
}

## MAIN #######################################################################

read_locations
prompt_location
