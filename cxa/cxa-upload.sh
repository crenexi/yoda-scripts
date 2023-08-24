#!/bin/bash

dir=$(dirname "$0")
source "$dir/../cxx/helpers/splash.sh"
source "$dir/../cxx/helpers/echo-utils.sh"
source "$dir/helpers/define-dest.sh"
source "$dir/helpers/define-src.sh"

# Exit function to print a message and terminate
exit_script() {
  echo "Cancelled and exited."
  exit 1
}

## Functions ##################################################################

# Prompt the user to confirm the inputs
function confirm_defs() {
  echo_header "REVIEW CP ARGS" "clear"
  echo -e "## Src: ${cmagenta}${src}${cend}"
  echo -e "## Dest: ${cyellow}${dest}${cend}"

  read -p "Looks good? (Y/n): " confirm
  if [[ "$confirm" != "" && "$confirm" != [yY] ]]; then
    exit_script
  fi
}

function exec_cp() {
  local opts=""
  local items=($src)

  # Add dry run if so
  if [[ $is_dry_run == "true" ]]; then
    opts+=" --dryrun"
  fi

  # Perform cp for each src
  for item in "${items[@]}"; do
    local item_opts="$opts"
    local item_dest="$dest"

    # Add recursive if item is a directory
    if [ -d "$item" ]; then
      item_opts+=" --recursive"

      # Append directory name to destination
      local dir_name=$(basename "$item")
      item_dest="${dest}${dir_name}/"
    fi

    aws s3 cp $item "$item_dest" $item_opts
  done
}

# Start dry run
function prerun_exec() {
  echo_header "DESTINATION" "clear"
  echo -e "${cyellow}${dest}${cend}"

  # Dry run
  echo_info "Simulating run..." "$cblue"
  is_dry_run="true"
  exec_cp
}

# Prompt the user to confirm before executing the command
function confirm_exec() {
  echo -e "${cred}Confirm to continue:${cend}"
  read -p "Execute uploads? (y/n): " confirm
  if [[ "$confirm" == [yY] ]]; then
    is_dry_run="false"
    exec_cp

    echo; echo_success "Completed upload!"
  fi
}

## Main #######################################################################

# splash
define_src
define_dest "$src"
confirm_defs
prerun_exec
confirm_exec
