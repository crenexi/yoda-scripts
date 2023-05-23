#!/bin/bash

###/!\ TEST SETUP ###############################
dir_test="/home/crenexi/Downloads/backup-test"

dir_test_src="$dir_test/src/"
mkdir -p "$dir_test_src"
echo "Test File" > "$dir_test_src/test.txt"

dir_test_dest="$dir_test/dest/"
mkdir -p "$dir_test_dest"

dir_test_log="$dir_test/log/"
mkdir -p "$dir_test_log"

###/!\ FINISH TEST SETUP ########################

dot="$(dirname "$0")"
days15=$((15 * 24 * 60 * 60))

#################################################
## CONFIG #######################################
#################################################

id="test"
user="crenexi"
auto=false
interval=$days15
delay=0

# Sources
sources=(
  "$dir_test_src"
)

# Backup parent (backup will be at "dest_parent/user@host")
dest_parent="$dir_test_dest"

# Log parent (logs will be at "log_parent/user@host")
log_parent="$dir_test_log"

#################################################
## RUN ##########################################
#################################################

source "$dot/../backup.sh"
main
