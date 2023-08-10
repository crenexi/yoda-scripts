#!/bin/bash

dir=$(dirname "$0")
source "$dir/helpers/echo-utils.sh"
source "$dir/helpers/define-dest.sh"
source "$dir/helpers/define-src.sh"

##########
## Functions

function on_done() {
  echo_success "Completed upload!"
}

# Prepare the aws s3 command and do dry run
function exec_prerun() {
  # Command to run
  aws_cmd="aws s3 cp \"$src\" \"$dest\""

  # Add recursive if src is a directory
  if [ -d "$sel_src" ]; then
    aws_cmd+=" --recursive"
  fi

  echo_header "Simulating run..." "$cblue"
  eval "$aws_cmd --dryrun"
}

# Prompt the user to confirm before executing the command
function exec_confirm() {
  echo "Review command to be executed:"
  echo_header "$aws_cmd" "$cyellow"
  read -p "Ready to proceed? (y/n): " confirm

  if [[ "$confirm" == [yY] ]]; then
    eval "$aws_cmd"
    on_done
  fi
}

##########
## Main

define_src
define_dest "$src"
exec_prerun
exec_confirm
