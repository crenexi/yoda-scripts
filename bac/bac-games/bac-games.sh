#!/bin/bash

dot="$(dirname "$0")"

#################################################
## CONFIG #######################################
#################################################

id="games"
user="crenexi"
auto=true

# Sources
sources=(
  "/home/crenexi/.steam/" \
  "/home/crenexi/.minecraft/" \
  "/home/crenexi/Games/" \
  "/hdd/SteamLibrary/" \
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
