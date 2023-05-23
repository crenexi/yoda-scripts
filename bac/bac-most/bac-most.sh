#!/bin/bash

dot="$(dirname "$0")"
days5=$((5 * 24 * 60 * 60))

#################################################
## CONFIG #######################################
#################################################

id="most"
user="crenexi"
auto=false
interval=$days5

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

# Backup parent (backup will be at "dest_parent/user@host")
dir_parent="/nas/Panda-Private/Backup_Systems"

# Log parent (logs will be at "log_parent/user@host")
log_parent="/etc/crenexi"

#################################################
## RUN ##########################################
#################################################

sleep 600 # delay for 10 minutes
source "$dot/../bac.sh"
main
