#!/bin/bash

dot="$(dirname "$0")"
days15=$((15 * 24 * 60 * 60))

#################################################
## CONFIG #######################################
#################################################

id="games"
user="crenexi"
auto=false
interval=$days15
delay=1200 # 20m delay

# Sources
sources=(
  "/home/crenexi/.steam/" \
  "/home/crenexi/.minecraft/" \
  "/home/crenexi/Games/" \
  "/hdd/SteamLibrary/" \
)

# Backup parent (backup will be at "dest_parent/user@host")
dest_parent="/nas/Panda-Private/Backup_Games"

# Log parent (logs will be at "log_parent/user@host")
log_parent="/etc/crenexi"

#################################################
## RUN ##########################################
#################################################

source "$dot/../backup.sh"
main
