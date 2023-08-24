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
  path="$1"

  # If path is ".", "*", or ends with "/*", set to an empty string
  if [[ "$path" == "." || "$path" == "*" || "${path: -2}" == "/*" ]]; then
    path=""
  fi

  # Remove leading and trailing "/" if present
  [[ "${path:0:1}" == "/" ]] && path="${path:1}"
  [[ "${path: -1}" == "/" ]] && path="${path:0:${#path}-1}"

  # Remove leading "./" or trailing "*"
  [[ "${path:0:2}" == "./" ]] && path="${path:2}"
  [[ "${path: -1}" == "*" ]] && path="${path:0:${#path}-1}"
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

  # Print the options vertically
  for i in "${!endpoints[@]}"; do
    echo "$((i+1))) ${endpoints[i]}"
  done

  # Read the user's choice
  while true; do
    read -p "Enter your choice (1-${#endpoints[@]}): " choice

    if ((choice >= 1 && choice <= ${#endpoints[@]})); then
      # Set the selected endpoint
      endpoint=${endpoints[$((choice-1))]}
      break
    else
      echo "Invalid choice, please try again."
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
  txt_accept="ACCEPT DESTINATION"
  txt_insert="Insert between base/path"
  txt_redo="Insert new path"

  echo_header "Edit path (1-3):"
  while true; do
    echo "1) $txt_accept (DEFAULT)"
    echo "2) $txt_insert"
    echo "3) $txt_redo"
    read -p "Choose an option (1-3): " REPLY

    # Use the default option if the user just presses Enter
    [[ -z "$REPLY" ]] && REPLY=1

    case $REPLY in
      1) new_path=""; break ;;
      2) edit_insert_between; break ;;
      3) edit_insert_new; break ;;
      *) echo "Invalid option. Please choose again." ;;
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
