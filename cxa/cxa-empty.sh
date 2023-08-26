#!/bin/bash

# Script for managing AWS S3 object removals

dir=$(dirname "$0")
source "$dir/../utils/echo-utils.sh"
source "$dir/helpers/define-dest.sh"

# Exit function to print a message and terminate
exit_cancelled() {
  echo "Cancelled and exited."
  exit 1
}

## Helper Functions ###########################################################

sanitize_destination() {
  dest="${dest%/}"
  dest="${dest//\/\//\/}"
  dest="${dest/s3:\//s3:\/\/}"
}

sanitize_pattern() {
  pattern="${pattern#/}"
  pattern="${pattern//\"}"
  pattern="${pattern//\'}"
}

# Display destination with optional warning
echo_destination() {
  local warning="$1"
  [[ -n "$warning" ]] && echo_warn "$warning" && echo
  echo_info "Destination:"
  echo -e "$dest/${cmagenta}${pattern}${cend}"
}

## User Interaction ###########################################################

# User-defined removal type selection
choose_removal_type() {
  echo_header "COMMAND TYPE" "clear"
  options=("Single File" "Prefix Pattern" "Prefix Sweep")
  select opt in "${options[@]}"; do
    case $REPLY in
      1) removal_type="file"; break ;;
      2) removal_type="pattern"; break ;;
      3) removal_type="prefix"; break ;;
      *) echo "Invalid option."; exit_cancelled ;;
    esac
  done
}

# Recursive removal prompt
ask_for_recursive_removal() {
  echo_info "Recursive?"
  read -p "Remove recursively? (y/N): " input
  if [[ "$input" == "y" || "$input" == "Y" ]]; then
    recursive_flag="true"
  else
    recursive_flag="false"
  fi
}

# Get user pattern input
get_pattern_from_user() {
  echo_header "PATTERN" "clear"
  echo_callout "Destination" "$dest"
  while true; do
    [[ "$pattern_invalid" == "true" ]] && echo_destination "Invalid pattern!" && pattern_invalid="false"
    read -e -p "Enter pattern: " input_pattern
    if [[ -z "$input_pattern" && -n "$pattern" ]]; then return; fi
    [[ "$input_pattern" != *[*?[]* || "$input_pattern" == */* ]] && pattern_invalid="true" || pattern="$input_pattern" && return
  done
}

# Confirm before execution
confirm_execution() {
  echo_header "VERIFY" "clear"
  echo -e "${cred}${s3_cmd}${cend}"
  [[ $recursive_flag == "true" ]] && echo_warn "RECURSIVE OPERATION"
  read -p "Approve command? (Y/n): " approval
  if [[ "$approval" == [nN] || -z "$approval" ]]; then
    exit_cancelled
  fi
}

## AWS Command Execution ######################################################

execute_s3_command() {
  confirm_execution
  echo_info "Simulating run..."
  eval "$s3_cmd --dryrun"
  echo_error "Confirm Removal?"
  read -p "Ready to proceed? (y/n): " proceed_confirmation
  if [[ "$proceed_confirmation" != [yY] ]]; then
    exit_cancelled
  fi
  eval "$s3_cmd"
  echo_success "Removal complete!"
}

construct_pattern_cmd() {
  s3_cmd="aws s3 ls"
  [[ $recursive_flag == "true" ]] && s3_cmd+=" --recursive"
  s3_cmd+=" $dest/ | grep '.$pattern$' | awk '{print \$4}' | xargs -I {} aws s3 rm $dest/{}"
}

construct_prefix_cmd() {
  s3_cmd="aws s3 rm"
  [[ $recursive_flag == "true" ]] && s3_cmd+=" --recursive"
  s3_cmd+=" $dest/"
}

## Main Execution #############################################################

remove_single_object() {
  define_dest
  [[ "$dest" == */ ]] && echo "Destination should point to a file!" && exit 1
  s3_cmd="aws s3 rm $dest"
  execute_s3_command
}

remove_multiple_objects() {
  define_dest
  sanitize_destination
  [[ $removal_type == "pattern" ]] && get_pattern_from_user
  ask_for_recursive_removal
  case "$removal_type" in
    pattern) construct_pattern_cmd ;;
    prefix) construct_prefix_cmd ;;
    *) echo "Invalid removal type: $removal_type" ;;
  esac
  execute_s3_command
}

# Script entry point
choose_removal_type
[[ $removal_type == "file" ]] && remove_single_object || remove_multiple_objects
