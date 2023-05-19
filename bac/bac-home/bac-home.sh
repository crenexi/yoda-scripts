#!/bin/bash

#################################################
## CONFIG #######################################
#################################################

auto=true
user="crenexi"

# Sources
sources=(
  "/home/crenexi/" \
  "/hdd/" \
)

# Destination
# "/nas/Panda-Private/Backup_Systems"
# "/media/crenexi/CH-Backups/Backups_Systems"
host=$(hostname)
dir_key="${user}@${host}"
dir_parent="/nas/Panda-Private/Backup_Systems"
dest="$dir_parent/$dir_key"

# Exclude and include files
exclude_from="$(dirname "$0")/bac_exclude.txt"
include_from="$(dirname "$0")/bac_include.txt"
file_backup_time="/etc/crenexi/backup-time"

#################################################
#### HELPERS ####################################
#################################################

function info() {
  printf "## ${1}\n"
}

function notice() {
  printf "## ${1}:\n"
  printf "${2}\n"
}

function cancel() {
  if [ -n "$1" ]; then
    printf "## Backup cancelled! $1\n"
  else
    printf "## Backup cancelled!\n"
  fi
  exit 1
}

function echo_sources() {
  for src in "${sources[@]}"; do echo $src; done;
}

#################################################
## PROMPTS ######################################
#################################################

function confirm_dir_key() {
  info "DIRECTORY KEY: $dir_key"
  info "DESTINATION: $dest"

  PS3="## IS THIS THE RIGHT DIRECTORY KEY? "
  select sel in Yes Cancel; do
  case $sel in
    "Yes")
      info "Backing up ${dir_key}!"
      break;;
    "Cancel")
      cancel "Fix Directory Key!"
      break;;
    *)
      cancel
      break;;
    esac
  done
}

function confirm_run() {
  PS3="## PROCEED TO RUN BACKUP? "
  select sel in Proceed Cancel; do
  case $sel in
    "Proceed")
      info "Starting backup..."
      is_dry_run=false
      run_backup
      info "Backup complete!"
      break;;
    "Cancel")
      cancel
      break;;
    *)
      cancel
      break;;
    esac
  done
}

#################################################
#### PREFLIGHT CHECKS ###########################
#################################################

function catch_dest_dne() {
  if [ -d $dest ]; then
    info "Destination found!"
  else
    cancel "Destination does not exist!"
  fi
}

function catch_exclude_dne() {
  if [ -f $exclude_from ]; then
    info "Exclude file found!"
  else
    cancel "Exclude file does not exist!"
  fi
}

function catch_include_dne() {
  if [ -f $include_from ]; then
    info "Include file found!"
  else
    cancel "Include file does not exist!"
  fi
}

#################################################
## FUNCTIONS ####################################
#################################################

function backup_from() {
  local from="$1"
  local to="$dest$1"

  # Rsync params, suppress error logs, and pipe to pv for progress
  local params="-aAXv --delete --delete-excluded --exclude-from=\"$exclude_from\" --include-from=\"$include_from\" \"$from\" \"$to\" 2>/dev/null"

  # Rsync commands
  rsync_cmd_dry="sudo rsync --dry-run $params"
  rsync_cmd="sudo rsync $params"

  # Run backup, or dry run
  if [ "$is_dry_run" = true ]; then
    eval "$rsync_cmd_dry"
  else
    eval "$rsync_cmd"
  fi
}

function log_backup() {
  mkdir -p "$(dirname "$file_backup_time")"
  touch "$file_backup_time"
}

function run_backup() {
  trap cancel INT

  # Preflight checks
  catch_dest_dne
  catch_exclude_dne
  catch_include_dne

  # Backup each source
  for src in "${sources[@]}"; do
    # Ensure directory exists at dest
    [ -d $dest$src ] || mkdir -p $dest$src

    # Execute backup
    info "Backing up \"${src}\""
    backup_from $src
  done

  # Finished
  log_backup
}

function run_backup_dry() {
  info "Starting dry run..."
  is_dry_run=true
  run_backup
  info "Dry run complete!"
}

function review_run () {
  echo; info "SOURCES"; echo_sources
  echo; notice "DESTINATION" "${dest}"
  echo; info "EXCLUSIONS"; cat $exclude_from
  echo; info "INCLUSIONS"; cat $include_from
  echo;
}

#################################################
## MAIN #########################################
#################################################

function start_auto() {
  info "Auto enabled. Starting backup with no prompts"

  if [[ -f "$file_backup_time" && $(find "$file_backup_time" -mtime +1) ]]; then
    info "Skipping backup. Last backup performed within 24 hours."
  else
    info "Starting backup..."
    is_dry_run=false
    run_backup
    info "Backup complete!"
  fi
}

function start_manual() {
  confirm_dir_key
  run_backup_dry
  review_run
  confirm_run
}

if [ "$auto" = true ]; then
  start_auto
else
  start_manual
fi
