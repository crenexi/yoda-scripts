#!/bin/bash

dot="$(dirname "$0")"

#################################################
## CONFIG #######################################
#################################################

auto=true
user="crenexi"

# Sources
sources=(
  "/home/crenexi/" \
  "/hdd/" \
  "/etc/" \
  "/usr/local/" \
  "/opt/" \
  "/srv/" \
  "/var/" \
)

# Destination
# "/nas/Panda-Private/Backup_Systems"
# "/media/crenexi/CH-Backups/Backups_Systems"
host=$(hostname)
dir_key="${user}@${host}"
dir_parent="/nas/Panda-Private/Backup_Systems"
dest="$dir_parent/$dir_key"

# Exclude and include files
exclude_from="$dot/bac_exclude.txt"
include_from="$dot/bac_include.txt"

# Log files
file_stamp="/etc/crenexi/$dir_key/stamp"
file_log="/etc/crenexi/$dir_key/log"

#################################################
## RUN ##########################################
#################################################

source "$dot/../bac.sh"
main
