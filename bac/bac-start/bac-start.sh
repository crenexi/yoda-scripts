#!/bin/bash

#################################################
## CONFIG #######################################
#################################################

nodry=true
user="crenexi"

# Destination
# "/nas/Panda-Private/Backup_Systems"
# "/media/crenexi/CH-Backups/Backups_Systems"
dest="/nas/Panda-Private/Backup_Systems"

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

# Exclude and include files
exclude_from="./bac_exclude.txt"
include_from="./bac_include.txt"

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
  host=$(hostname)
  dir_key="${user}@${host}"
  notice "DIRECTORY KEY" $dir_key

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
  # Build exclude options
  exclude=""
  for path in "${exclude_paths[@]}"; do
    exclude+="--exclude=\"${path}\" "
  done

  rsync_params="-aAXv --delete --delete-excluded --exclude-from=\"$exclude_from\" --include-from=\"$include_from\" \"$1\" \"$dest$1\""
  rsync_cmd_dry="sudo rsync --dry-run $rsync_params"
  rsync_cmd="sudo rsync $rsync_params"

  # Run backup, or dry run
  if [ "$is_dry_run" = true ]; then
    eval $rsync_cmd_dry

    notice "COMPLETED DRY RUN OF" "${rsync_cmd}"
  else
    eval $rsync_cmd
  fi
}

function run_backup() {
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
}

function run_backup_dry() {
  # Skip if --nodry is supplied
  if [ "$nodry" = true ]; then return; fi

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

confirm_dir_key
run_backup_dry
review_run
confirm_run
