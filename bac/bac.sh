#!/bin/bash

function main() {
  catch_config_dne
  configure_vars

  if [ "$auto" = true ]; then
    info "Starting automatic backup"
    catch_recent_backup
    is_dry_run=false
    run_backup
    on_complete
  else
    confirm_dir_key
    run_backup_dry
    confirm_run
    run_backup
    on_complete
  fi
}

#################################################
#### VERIFICATION HELPERS #######################
#################################################

function catch_config_dne() {
  local variables=("id" "user" "auto" "interval" "sources" "dir_parent" "log_parent")
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
  echo "## ${1}"
}

function cancel() {
  if [ -n "$1" ]; then
    echo "## Backup cancelled! $1"
  else
    echo "## Backup cancelled!"
  fi
  exit 1
}

function notify() {
  # Ensure this is Ubuntu and notify-send exists
  if [[ "$(lsb_release -si)" == "Ubuntu" ]] && command -v notify-send >/dev/null 2>&1; then
    # Detect the name of the display in use and the user using the display
    local display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"
    local user=$(who | grep '('$display')' | awk '{print $1}' | head -n 1)
    local uid=$(id -u $user)

    # Crenexi-themed alert
    icon="/home/crenexi/Documents/System-Assets/Icons/crenexi_fav_main.png"
    su -c "DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send -u normal -t 5000 -i \"$icon\" \"$1\" \"$2\"" -s /bin/sh $user
  fi
}

function configure_vars() {
  # Destination
  host=$(hostname)
  dir_key="${user}@${host}"
  dest="$dir_parent/$dir_key"

  # Exclude and include files
  exclude_from="$dot/bac_exclude.txt"
  include_from="$dot/bac_include.txt"

  # Log files
  file_stamp="$log_parent/$dir_key/bac-${id}_time"
  file_log="$log_parent/$dir_key/bac-$id.log"
}

function on_complete() {
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  time_human=$(date +"%B %-d at %-I:%M%P")

  # Log the timestamp in the stamp file
  mkdir -p "$(dirname "$file_stamp")"
  echo "$timestamp" > "$file_stamp"

  # Log rsync output and cleanup
  echo "Backup for: $dir_key" > "$file_log"
  cat "$file_log_temp" >> "$file_log"
  rm "$file_log_temp"

  # Notification and standard log
  notify "Backup Complete" "Finished $id backup on $time_human!"
  info "Completed \"$id\" backup at $time_human!"
}

#################################################
## BACKUP PROCESS ###############################
#################################################

function backup_from() {
  local from="$1"
  local to="$dest$1"

  # Rsync params, suppress error logs, and pipe to pv for progress
  local params="-aAXv --delete --delete-excluded --exclude-from=\"$exclude_from\" --include-from=\"$include_from\" \"$from\" \"$to\" > \"$file_log_temp\" 2>&1"

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

  # Ensure destination, exclude file, and include file exist
  if ! [ -d $dest ]; then cancel "Destination does not exist!"; fi
  if ! [ -f $exclude_from ]; then cancel "Exclude file does not exist!"; fi
  if ! [ -f $include_from ]; then cancel "Include file does not exist!"; fi

  # Backup each source
  for src in "${sources[@]}"; do
    # Ensure directory exists at dest
    [ -d $dest$src ] || mkdir -p $dest$src

    # Execute backup
    info "Backing up \"${src}\"..."
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
