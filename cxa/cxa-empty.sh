#!/bin/bash

dir=$(dirname "$0")
source "$dir/helpers/echo-utils.sh"
source "$dir/helpers/define-dest.sh"

##########
## Helpers

function clean_dest() {
  dest="${dest%/}" # remove trailing slash
  dest="${dest//\/\//\/}" # handle // to /
  dest="${dest/s3:\//s3:\/\/}" # handle s3:/ to s3://
}

function clean_pattern() {
  pattern="${pattern#/}" # remove leading slash
  pattern="${pattern//\"}" # remove double quotes
  pattern="${pattern//\'}" # remove single quotes
}

function echo_dest_pattern() {
  local warn="$1"
  clear

  # Warn if needed
  if [[ -n "$warn" ]]; then
    echo_warn "$warn"
    echo
  fi

  # Echo destination
  echo_header "Destination:"
  echo -e "$dest/${cmagenta}${pattern}${cend}"
}

##########
## Interactions

# Selects the type of remove intended
function select_cmd_type() {
  local txt_rm_file="Single File: Remove Specific Object"
  local txt_rm_pattern="Prefix Pattern: Remove Objects by Pattern"
  local txt_rm_prefix="Prefix Sweep: Remove Objects (Including Prefixes)"

  clear
  echo_header "Command Type:"
  while true; do
    echo "1) $txt_rm_file"
    echo "2) $txt_rm_pattern"
    echo "3) $txt_rm_prefix"
    read -p "Choose (1-4): " REPLY

    case $REPLY in
      1) cmd_type="file"; break ;;
      2) cmd_type="pattern"; break ;;
      3) cmd_type="prefix"; break ;;
      *) echo "Invalid option. Please choose again." ;;
    esac
  done
}

# Prompt to set the recursive option
function prompt_recursive() {
  clear
  echo_header "Recursive?"

  while true; do
    read -p "Remove recursively? (y/N): " input
    case $input in
      [yY]* )
        is_recursive="true"
        break ;;
      [nN]* | "" )
        is_recursive="false"
        break ;;
      * )
        echo "Invalid input. (yY, nN, Enter)"
        ;;
    esac
  done
}


function prompt_pattern() {
  clear
  echo_header "Pattern"

  while true; do
    # Show the warning message if the last iteration had an invalid pattern
    if [[ "$invalid_pattern" == "true" ]]; then
      echo_dest_pattern "Must be a valid pattern!"
      invalid_pattern="false" # Reset the flag
    fi

    read -e -p "Enter pattern: " new_pattern

    # No new input, but an existing pattern is present
    if [[ -z "$new_pattern" && ! -z "$pattern" ]]; then
      break
    fi

    # If the new pattern is not a valid pattern
    if [[ "$new_pattern" != *[*?[]* || "$new_pattern" == */* ]]; then
      invalid_pattern="true"
      continue
    else
      pattern="$new_pattern"
      break
    fi
  done

  clean_pattern
}

verify_cmd() {
  echo_header "Verify"
  echo -e "${cred}${aws_cmd}${cend}"

  if [[ $is_recursive == "true" ]]; then
    echo_error "THIS IS A RECURSIVE OPERATION"
  fi

  read -p "Approve command? (Y/n): " confirm

  if [[ "$confirm" != [yY] ]]; then
    exit 1
  fi
}

##########
## Functions

function exec_cmd() {
  clear
  verify_cmd

  # Complete a dry run
  clear
  echo_header "Simulating run..." "$cblue"
  eval "$aws_cmd --dryrun"

  # Final confirmation
  echo_header "Remove?"
  echo -e "${cred}${aws_cmd}${cend}"
  read -p "Ready to proceed? (y/n): " confirm

  if [[ "$confirm" == [yY] ]]; then
    eval "$aws_cmd"
    echo; echo_success "Completed removals!"
  fi
}

# Remove for a single object
function proceed_rm_single() {
  define_dest

  if [[ "$dest" == */ ]]; then
    echo "Destination ends in a slash but should be a file!"
    exit 1
  fi

  aws_cmd="aws s3 rm $dest"
  exec_cmd
}

function build_pattern_cmd() {
  aws_cmd="aws s3 ls"
  if [[ $is_recursive == "true" ]]; then
    aws_cmd+=" --recursive"
  fi

  aws_cmd+=" $dest/ | grep '.$pattern$' | awk '{print \$4}' | xargs -I {} aws s3 rm $dest/{}"
}

function build_prefix_cmd() {
  aws_cmd="aws s3 rm"
  if [[ $is_recursive == "true" ]]; then
    aws_cmd+=" --recursive"
  fi

  aws_cmd+=" $dest/"
}

# Remove for multiple objects
function proceed_rm_many() {
  echo "#1 proceed_md_many: $dest"

  # Define the destination
  define_dest
  clean_dest

  echo "#2 proceed_md_many: $dest"

  # Enter pattern
  if [[ $cmd_type == "pattern" ]]; then
    prompt_pattern
  fi

  # Recursive choice
  prompt_recursive

  case "$cmd_type" in
    pattern)
      build_pattern_cmd
      exec_cmd
      ;;
    prefix)
      build_prefix_cmd
      exec_cmd
      ;;
    *)
      echo "Invalid command type: $cmd_type" ;;
  esac
}

##########
## Main

select_cmd_type
if [[ $cmd_type == "file" ]]; then
  proceed_rm_single
else
  proceed_rm_many
fi
