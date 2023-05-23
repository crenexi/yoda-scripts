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
delay=600 # 10m delay

# Sources
sources=(
  "/home/crenexi/" \
  "/etc/" \
  "/usr/local/" \
  "/opt/" \
  "/srv/" \
  "/var/" \
)

# If victory, add /hdd
if [[ "$(hostname)" == "victory" ]]; then
  sources+=("/hdd/")
fi

# Backup parent (backup will be at "dest_parent/user@host")
dest_parent="/nas/Panda-Private/Backup_Systems"

# Log parent (logs will be at "log_parent/user@host")
log_parent="/etc/crenexi"

#################################################
## RUN ##########################################
#################################################

source "$dot/../backup.sh"
main
