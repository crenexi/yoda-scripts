#!/bin/bash

dir=$(dirname "$0")
source "$dir/helpers/echo-utils.sh"

##########
## Helpers

function init_endpoints() {

  endpoints=()
  while IFS= read -r line; do
    endpoints+=("$line")
  done < "$dir/s3-endpoints"
}

function set_path() {
  # Trim leading/trailing spaces and slashes
  path=$(echo "$1" | sed -e 's/^[\/ ]*//' -e 's/[\/ ]*$//')

  # If the path is "./*", set it to an empty string
  if [[ "${path:0:2}" == "./*" ]]; then
    path=""
  # Remove leading "/" or "./"
  elif [[ "${path:0:1}" == "/" ]]; then
    path="${path#/}"
  elif [[ "${path:0:2}" == "./" ]]; then
    path="${path#./}"
  fi
}


function echo_dest() {
  clear
  echo_header "Destination:"
  echo -e "$base_uri/${cmagenta}${path}${cend}"
}

##########
## Functions

function read_endpoint() {
  clear
  echo_header "Select S3 destination:"
  select endpoint in "${endpoints[@]}"; do
    if [[ -n "$endpoint" ]]; then
      break
    fi
  done
}

function edit_insert_between() {
  echo_info "INSERT BETWEEN"
  read -e -p "Insert: " input
  input=$(echo "$input" | sed -e 's/^[\/ ]*//' -e 's/[\/ ]*$//') # trim

  new_path="${input}/${path}"
  set_path "$new_path"
}

function edit_insert_new() {
  echo_info "REDWRITE PATH"
  read -e -p "New path: " input
  input=$(echo "$input" | sed -e 's/^[\/ ]*//' -e 's/[\/ ]*$//') # trim

  new_path="$input"
  set_path "$new_path"
}

function select_edit_path() {
  txt_accept="Accept destination"
  txt_insert="Insert between base/path"
  txt_redo="Insert new path"

  echo_header "Edit path:"
  select option in "$txt_accept" "$txt_insert" "$txt_redo"; do
    case $REPLY in
      1) # Accept destination
        echo "You chose to accept this destination."
        new_path="" # No new path
        break
        ;;
      2) # Insert between
        edit_insert_between
        break
        ;;
      3) # Redo path
        edit_insert_new
        break
        ;;
      *) # Invalid
        echo "Invalid option. Please choose again."
        new_path="TEST"
        ;;
    esac
  done
}

function read_dest() {
  base_uri="$endpoint/assets"

  while true; do
    dest="$base_uri/$path"
    echo_dest
    select_edit_path

    if [[ -z "$new_path" ]]; then
      break
    fi
  done
}

##########
## Main

function define_dest() {
  src="$1"

  init_endpoints

  # Default path is the provided src
  set_path "$src"

  # Confirm or specify destination
  read_endpoint
  read_dest

  export dest
}
