#!/bin/bash

function main() {
  sleep "$((60 + $delay))" # sleep a minimum of 1m
  catch_config_dne # validate configuration
  configure_vars # create script variables
  catch_recent_backup # skip if recent backup

  # If destination is pandora, ensure it's mounted
  if [[ $dest == "/pandora"* ]]; then await_pandora; fi

  # Complete backup
  info_stamped "Starting"
  run_backup
  on_complete
}

#################################################
#### VERIFICATION HELPERS #######################
#################################################

function catch_config_dne() {
  local variables=("id" "user" "is_dry_run" "interval" "delay" "sources" "dest_parent" "log_parent")
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

function catch_not_home() {
  home_network="192.168.0"
  device_interface="wlp0s20f3"
  current_ip=$(ip addr show dev $device_interface | grep -oP 'inet \K[\d.]+')

  if ! [[ $current_ip == $home_network* ]]; then
    cancel "Home network not detected. Exiting."
  fi
}

function catch_script_deps() {
  local scripts=("$mnt_pandora" "$cxx_notify")
  local missing_scripts=()

  for script in "${scripts[@]}"; do
    if ! [ -f "$script" ]; then
      missing_scripts+=("$script")
    fi
  done

  if [ ${#missing_scripts[@]} -gt 0 ]; then
    echo "Error: The following scripts are missing:"
    for script in "${missing_scripts[@]}"; do
      echo "$script"
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
  echo "## ${1}"
}

function info_stamped() {
  statused="$1" # verb indicating status
  more_info="$2" # for cancel message

  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  time_human=$(date +"%B %-d at %-I:%M%P")

  # Notification and standard log
  "$cxx_notify" "Backup $statused - $id" "$statused on $time_human! $more_info"
  info "$statused \"$id\" backup at $time_human! $more_info"
}

function cancel() {
  local exit_code=${2:-0}
  info_stamped "Cancelled" "$1"
  exit "$exit_code"
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
  file_stamp="$log_parent/bac-${id}_time"
  file_log="$log_parent/bac-$id.log"

  # Commands
  mnt_pandora=/home/crenexi/.cx/bin/cxx/mnt-pandora.sh
  cxx_notify=/home/crenexi/.cx/bin/cxx/cxx-notify.sh
}

function await_pandora() {
  mnt_point="/pandora/pandora_crenexi"

  # 0. Make sure we're home
  catch_not_home

  # 1. Wait until autofs service starts
  while ! systemctl is-active autofs >/dev/null 2>&1; do
    sleep 5
  done

  # 2. Trigger the mount
  source "$mnt_pandora"

  # Wait until specified destination parent is mounted
  while ! mountpoint -q "$mnt_point"; do
    sleep 5
  done
}

function on_complete() {
  action_text="Completed"
  if [ "$is_dry_run" = true ]; then
    action_text+=" dry"
  fi

  # Log and notify
  info_stamped "$action_text"

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
  local params="-aAXv --no-links --delete --delete-excluded --exclude-from=\"$exclude_from\" --include-from=\"$include_from\" \"$from\" \"$to\" >> \"$file_log_temp\" 2>&1"

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

  # Note if dry run
  if [ "$is_dry_run" = true ]; then
    info "Starting dry run..."
  fi

  # Temp rsync log
  file_log_temp=$(mktemp)

  # Ensure destination parent and folder exist
  if ! [ -d "$dest_parent" ]; then cancel "Destination parent does not exist!" 1; fi
  if ! [ -d "$dest" ]; then mkdir "$dest"; fi

  # Ensure exclude and include files exist
  if ! [ -f $exclude_from ]; then cancel "Exclude file does not exist!" 1; fi
  if ! [ -f $include_from ]; then cancel "Include file does not exist!" 1; fi

  # Backup each source
  for src in "${sources[@]}"; do
    # Ensure directory exists at dest
    [ -d $dest$src ] || mkdir -p $dest$src

    # Log each src backing up; for testing
    # info "Backing up \"${src}\"..."

    backup_from $src
  done
}
