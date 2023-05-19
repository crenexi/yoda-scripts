#!/bin/bash
# Supplies the main function for backups

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

function notify() {
  # Ensure this is Ubuntu and notify-send exists
  if [[ "$(lsb_release -si)" == "Ubuntu" ]] && command -v notify-send >/dev/null 2>&1; then
    # Detect the name of the display in use and the user using the display
    local display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"
    local user=$(who | grep '('$display')' | awk '{print $1}' | head -n 1)
    local uid=$(id -u $user)

    # Crenexi-themed alert
    icon="/home/crenexi/Documents/System-Assets/Icons/crenexi_fav_main.png"
    sudo -u $user DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send -u normal -t 5000 -i "$icon" "$1" "$2"
  fi
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
  echo "catch recent backup"

  # If no backup file, proceed
  if [[ -f "$file_stamp" ]]; then
    # Note: all units should be in seconds
    current_time=$(date +%s) # current time
    last_backup_time=$(stat -c %Y "$file_stamp") # backup time
    time_diff=$((current_time - last_backup_time)) # timeago

    # If recent backup, exit
    if ! [ $time_diff -gt $interval ]; then
      echo "gt interval"
      cancel "Recent backup performed. Skipping"
    fi
  fi
}

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

function configure_vars() {
  catch_config_dne

  # Destination
  host=$(hostname)
  dir_key="${user}@${host}"
  dest="$dir_parent/$dir_key"

  # Exclude and include files
  exclude_from="$dot/bac_exclude.txt"
  include_from="$dot/bac_include.txt"

  # Log files
  file_stamp="$log_parent/$dir_key/stamp_$id"
  file_log="$log_parent/$dir_key/log_$id"
}

function backup_from() {
  local from="$1"
  local to="$dest$1"

  # Rsync params, suppress error logs, and pipe to pv for progress
  local params="-aAXv --delete --delete-excluded --exclude-from=\"$exclude_from\" --include-from=\"$include_from\" \"$from\" \"$to\" > \"$file_log_temp\" 2>&1"

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
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  time_human=$(date +"%B %-d at %-I:%M%P")

  # Log the timestamp in the stamp file
  mkdir -p "$(dirname "$file_stamp")"
  echo "$timestamp" > "$file_stamp"

  # Log rsync output and cleanup
  echo "Backup for: $dir_key" > "$file_log"
  cat "$file_log_temp" >> "$file_log"
  rm "$file_log_temp"
  echo "-----------------------" >> "$file_log"

  # Notification
  notify "Backup Complete" "Finished $id backup on $time_human!"
}

function run_backup() {
  trap cancel INT

  # Temp rsync log
  file_log_temp=$(mktemp)

  # Preflight checks
  catch_dest_dne
  catch_exclude_dne
  catch_include_dne

  # Backup each source
  for src in "${sources[@]}"; do
    # Ensure directory exists at dest
    [ -d $dest$src ] || mkdir -p $dest$src

    # Execute backup
    info "Backing up \"${src}\"..."
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
  catch_recent_backup
  is_dry_run=false
  run_backup
  info "Backup complete!"
}

function start_manual() {
  confirm_dir_key
  run_backup_dry
  review_run
  confirm_run
}

function main() {
  configure_vars

  if [ "$auto" = true ]; then
    start_auto
  else
    start_manual
  fi
}
