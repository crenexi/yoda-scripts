#!/bin/bash

dot="$(dirname "$0")"
days7=$((5 * 24 * 60 * 60))

#################################################
## CONFIG #######################################
#################################################

id="most"
user="crenexi"
is_dry_run=true
interval=$days7
delay=450 # 7m delay

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
dest_parent="/pandora/pandora_crenexi/Backup_Systems"

# Log parent (logs will be at "log_parent/user@host")
log_parent="/home/crenexi/.cx/logs/bac"

#################################################
## RUN ##########################################
#################################################

source "$dot/../backup.sh"
main
