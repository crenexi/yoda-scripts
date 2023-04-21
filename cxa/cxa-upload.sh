#!/bin/bash

color_red=$"\e[1;31m"
color_green=$"\e[1;32m"
color_yellow=$"\e[1;33m"
color_blue=$"\e[1;34m"
color_magenta=$"\e[1;35m"
color_cyan=$"\e[1;36m"
color_end=$"\e[0m"

info() {
  printf "## ${1}\n"
}

info_block() {
  message="$1"
  color="$2"
  echo "##########"
  printf "## ${color}${message}${color_end}\n"
}

# Define s3_dests array
s3_dests=(
  "s3://cx--www.crenexi.com/assets/test"
  "s3://mf--www.michelleflorero.com/assets/test"
)

# Prompt the user to select source to upload
function read_source() {
  info_block "Select source to upload [.]:"
  read -e source

  # Defaults to "./*"
  source="${source:-.}"

  # If the pattern appears to not specify base dir, make it relative
  [[ ! "$source" =~ [\.~/].* ]] && source="./$source"
}

# Prompt the user to select a destination
function read_dest_base() {
  info_block "Select destination base:"
  select sel_dest in "${s3_dests[@]}"; do
    if [[ -n $sel_dest ]]; then
      break
    fi
  done
}

# Prompt the user to select a path
function read_dest_path() {
  info_block "Select destination path [/]:"
  read -e dest_path

  # Ensure slash is first char
  if [[ ${dest_path:0:1} == "/" ]]; then
    dest_path=${dest_path:1}
  fi
}

# Prepare the aws s3 command and do dry run
function exec_prerun() {
  aws_cmd="aws s3 cp \"$source\" \"${sel_dest}/assets/${dest_path}\" --recursive"

  info_block "Simulating run..." $color_blue
  eval "$aws_cmd --dryrun"
}

# Prompt the user to confirm before executing the command
function exec_confirm() {
  echo "Review command to be executed:"
  info_block "$aws_cmd" $color_yellow
  read -p "Ready to proceed? (Y/N): " confirm

  if [[ $confirm == [yY] ]]; then
    eval $aws_cmd
  fi
}

read_source
read_dest_base
read_dest_path
exec_prerun
exec_confirm
