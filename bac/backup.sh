#!/bin/bash

function main() {
  # Sleep a minimum of 1m
  sleep "$((60 + delay))"

  # Init config and vars
  catch_config_dne
  configure_vars

  if [ "$auto" = true ]; then
    info_stamped "Starting"
    catch_recent_backup
    is_dry_run=false
    on_start
    run_backup
    on_complete
  else
    confirm_dir_key
    run_backup_dry
    confirm_run
    on_start
    run_backup
    on_complete
  fi
}

#################################################
#### VERIFICATION HELPERS #######################
#################################################

function catch_config_dne() {
  local variables=("id" "user" "auto" "interval" "delay" "sources" "dest_parent" "log_parent")
  local missing_variables=()

  for var in "${variables[@]}"; do
    if [[ -z ${!var} ]]; then
      missing_variables+=("$var")
    fi
  done

  if [[ ${#missing_variables[@]} -gt 0 ]]; then
    echo "Error: The following variables are not defined or empty:"
    for var in "${missing_variables[@]}"; do
      echo "$var"
    done
    exit 1
  fi
}

function catch_recent_backup() {
  # If no backup file, proceed
  if [[ -f "$file_stamp" ]]; then
    # Note: all units should be in seconds
    current_time=$(date +%s) # current time
    last_backup_time=$(stat -c %Y "$file_stamp") # backup time
    time_diff=$((current_time - last_backup_time)) # timeago

    # If recent backup, exit
    if ! [ $time_diff -gt $interval ]; then
      cancel "Recent backup performed. Skipping"
    fi
  fi
}

#################################################
#### MISC HELPERS ###############################
#################################################

function info() {
  if [ "${auto}" = "true" ]; then
    echo "## ${1}"
  fi
}

function info_stamped() {
  statused="$1" # verb indicating status
  more_info="$2" # for cancel message

  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  time_human=$(date +"%B %-d at %-I:%M%P")

  # Notification and standard log
  "$cxx_notify" "Backup $statused" "$statused $id backup on $time_human! $more_info"
  info "$statused \"$id\" backup at $time_human! $more_info"
}

function cancel() {
  if [ "${auto}" = "true" ]; then
    info_stamped "Cancelled" "$1"
  fi
  exit 1
}

function configure_vars() {
  # Destination
  host=$(hostname)
  dir_key="${user}@${host}"
  dest="$dest_parent/$dir_key"

  # Exclude and include files
  exclude_from="$dot/../exclude.txt" # same for all backups
  include_from="$dot/include.txt" # backup-specific

  # Log files
  file_stamp="$log_parent/$dir_key/bac-${id}_time"
  file_log="$log_parent/$dir_key/bac-$id.log"

  # Commands
  mnt_pandora=/home/crenexi/.cx/bin/cxx/mnt-pandora.sh
  cxx_notify=/home/crenexi/.cx/bin/cxx/cxx-notify.sh
}

function await_pandora() {
  mnt_point="/pandora/pandora_crenexi"

  # 1. Wait until autofs service starts
  while ! systemctl is-active autofs >/dev/null 2>&1; do
    info "Pending autofs start..."
    sleep 5
  done

  # 2. Trigger the mount
  source "$mnt_pandora"

  # Wait until specified destination parent is mounted
  while ! mountpoint -q "$mnt_point"; do
    info "Pending $mnt_point mount..."
    sleep 5
  done

  info "Mounted $mnt_point"
}

function on_start() {
  time_human=$(date +"%B %-d at %-I:%M%P")
  "$cxx_notify" "Backup Started" "Starting $id backup on $time_human!"
}

function on_complete() {
  info_stamped "Completed"

  # Log the timestamp in the stamp file
  mkdir -p "$(dirname "$file_stamp")"
  echo "$timestamp" > "$file_stamp"

  # Log rsync output and cleanup
  echo "Backup for: $dir_key" > "$file_log"
  cat "$file_log_temp" >> "$file_log"
  rm "$file_log_temp"
}

#################################################
## BACKUP PROCESS ###############################
#################################################

function backup_from() {
  local from="$1"
  local to="$dest$1"

  # Rsync params, suppress error logs, and pipe to pv for progress
  local params="-aAXv --no-links --delete --delete-excluded --exclude-from=\"$exclude_from\" --include-from=\"$include_from\" \"$from\" \"$to\""

  # Log to both if manual, or else just log to file
  if [ "$auto" != true ]; then
    params+=" 2>&1 | tee \"$file_log_temp\""
  else
    params+=" > \"$file_log_temp\" 2>&1"
  fi

  # Rsync commands
  rsync_cmd_dry="rsync --dry-run $params"
  rsync_cmd="rsync $params"

  # Run backup, or dry run
  if [ "$is_dry_run" = true ]; then
    eval "$rsync_cmd_dry"
  else
    eval "$rsync_cmd"
  fi
}

function run_backup() {
  trap cancel INT

  # Temp rsync log
  file_log_temp=$(mktemp)

  # If destination is pandora, ensure it's mounted
  if [[ $dest == "/pandora"* ]]; then await_pandora; fi

  # Ensure destination parent and folder exist
  if ! [ -d "$dest_parent" ]; then cancel "Destination parent does not exist!"; fi
  if ! [ -d "$dest" ]; then mkdir "$dest"; fi

  # Ensure exclude and include files exist
  if ! [ -f $exclude_from ]; then cancel "Exclude file does not exist!"; fi
  if ! [ -f $include_from ]; then cancel "Include file does not exist!"; fi

  # Backup each source
  for src in "${sources[@]}"; do
    # Ensure directory exists at dest
    [ -d $dest$src ] || mkdir -p $dest$src

    # Execute backup
    if ! [ "$auto" = true ]; then
      info "Backing up \"${src}\"..."
    fi

    backup_from $src
  done
}

#################################################
## MANUAL BACKUP PROCESS ########################
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

function run_backup_dry() {
  info "Starting dry run..."
  is_dry_run=true
  run_backup
  info "Dry run complete!"
}

function confirm_run() {
  # Echo summary of backup parameters
  info "SOURCES"; for src in "${sources[@]}"; do echo $src; done;
  info "DESTINATION"; echo "${dest}"
  info "EXCLUSIONS"; cat $exclude_from
  info "INCLUSIONS"; cat $include_from

  PS3="## PROCEED TO RUN BACKUP? "
  select sel in Proceed Cancel; do
  case $sel in
    "Proceed")
      is_dry_run=false
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
