#!/bin/bash
# This script assists in uploading assets to S3. The script assumes that
# the user has rw permissions to the S3 buckets specified in s3_dests.

##########
## HELPERS

# Utility colors
cred="\e[1;31m"
cgreen="\e[1;32m"
cyellow="\e[1;33m"
cblue="\e[1;34m"
cmagenta="\e[1;35m"
ccyan="\e[1;36m"
cend="\e[0m"

# Utility echos
echo_info () { echo -e "${cblue}${1}${cend}"; }
echo_success() { echo -e "${cgreen}${1}${cend}"; }
echo_warn() { echo -e "/!\ ${cyellow}${1}${cend}"; }
echo_error() { echo -e "/!\ ${cred}${1}${cend}"; }
echo_header() {
  message="$1"
  color="$2"
  echo "##########"
  echo -e "## ${color}${message}${cend}"
}

##########
## CONFIG

# Define s3_dests array
s3_dests=(
  "s3://cx--www.crenexi.com/assets/test"
  "s3://mf--www.michelleflorero.com/assets/test"
)

##########
## MAIN

# Prompt the user to select source to upload
function read_source() {
  echo_header "Select source to upload [.]:"
  read -e sel_src

  # Defaults to "./*"
  sel_src="${sel_src:-.}"

  # If the pattern appears to not specify base dir, make it relative
  [[ ! $sel_src =~ [\.~/].* ]] && sel_src="./$sel_src"
}

# Prompt the user to select a destination
function read_dest_base() {
  echo_header "Select destination base:"
  select sel_dest in "${s3_dests[@]}"; do
    if [[ -n "$sel_dest" ]]; then
      break
    fi
  done
}

# Prompt the user to select a path
function read_dest_path() {
  echo_header "Select destination path [/]:"
  read -e dest_path
}

# Prepare the aws s3 command and do dry run
function exec_prerun() {
  aws_cmd="aws s3 cp \"$sel_src\" \"${sel_dest}/assets/${dest_path}/\""

  # Remove dup slashes
  aws_cmd="${aws_cmd//\/\//\/}"

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
  read -p "Ready to proceed? (Y/N): " confirm

  if [[ "$confirm" == [yY] ]]; then
    eval "$aws_cmd"
  fi
}

read_source
read_dest_base
read_dest_path
exec_prerun
exec_confirm
