#!/bin/bash

dot="$(dirname "$0")"
days2=$((2 * 24 * 60 * 60))

#################################################
## CONFIG #######################################
#################################################

id="home"
user="crenexi"
auto=false
interval=$days2
delay=0

# Sources
sources=(
  "/home/crenexi/"
)

# If victory, add /hdd
if [[ "$(hostname)" == "victory" ]]; then
  sources+=("/hdd/")
fi

# Backup parent (backup will be at "dest_parent/user@host")
dest_parent="/pandora/pandora_crenexi/Backup_Systems"

# Log parent (logs will be at "log_parent/user@host")
log_parent="/.cx/logs/bac"

#################################################
## RUN ##########################################
#################################################

source "$dot/../backup.sh"
main
