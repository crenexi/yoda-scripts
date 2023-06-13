#!/bin/bash

dot="$(dirname "$0")"
days10=$((10 * 24 * 60 * 60))

#################################################
## CONFIG #######################################
#################################################

id="games"
user="crenexi"
auto=false
interval=$days10
delay=900 # 15m delay

# Sources
sources=(
  "/home/crenexi/.steam/" \
  "/home/crenexi/.minecraft/" \
  "/home/crenexi/Games/" \
  "/hdd/SteamLibrary/" \
)

# Backup parent (backup will be at "dest_parent/user@host")
dest_parent="/pandora/pandora_crenexi/Backup_Games"

# Log parent (logs will be at "log_parent/user@host")
log_parent="/home/crenexi/.cx/logs/bac"

#################################################
## RUN ##########################################
#################################################

source "$dot/../backup.sh"
main
