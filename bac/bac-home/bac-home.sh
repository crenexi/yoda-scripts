#!/bin/bash

dot="$(dirname "$0")"
days2=$((2 * 24 * 60 * 60))

#################################################
## CONFIG #######################################
#################################################

id="home"
user="crenexi"
auto=true
interval=$days2

# Sources
sources=(
  "/home/crenexi/" \
  "/hdd/" \
)

# Backup parent (backup will be at "dest_parent/user@host")
dir_parent="/nas/Panda-Private/Backup_Systems"

# Log parent (logs will be at "log_parent/user@host")
log_parent="/etc/crenexi"

#################################################
## RUN ##########################################
#################################################

source "$dot/../bac.sh"
main
