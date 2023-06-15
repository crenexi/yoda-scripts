#!/bin/bash
set -e

# Helpers
echo_heading() {
  local title=$1
  local title_length=${#title}
  local pad_length=$((56 - title_length))
  local pad=$(printf '%*s' "$pad_length" | tr ' ' '#')
  echo "## $title $pad"
}

# Basic update
function start_update() {
  echo_heading "Update"
  sudo apt update
}

# Prompt for upgrade
function prompt_upgrade() {
  echo_heading "Upgrade"
  read -p "Choose upgrade option (1. Routine / 2. Aggressive / 3. Skip): " upgrade_opt

  if [[ $upgrade_opt == "1" ]]; then
    echo "Starting routine upgrade..."
    sudo apt upgrade
    echo "Completed upgrade!"
  elif [[ $upgrade_opt == "2" ]]; then
    echo "Starting aggressive upgrade..."
    sudo apt dist-upgrade -y
    sudo apt autoremove --purge -y
    sudo apt clean
    echo "Completed upgrade!"
  elif [[ $upgrade_opt == "3" ]]; then
    echo "Skipping upgrade."
  else
    echo "Invalid option. Choose an upgrade option."
    prompt_upgrade
  fi
}

# Prompt to update Chrome
function prompt_chrome_update() {
  echo_heading "Chrome"
  read -p "Update Chrome? (y/n): " confirm_chrome
  if [[ $confirm_chrome == "y" || $confirm_chrome == "Y" ]]; then
    echo "Updating Chrome..."
    run-chrome-update.sh
  fi
}

# Prompt to update gnome extensions
function prompt_ext_update() {
  echo_heading "Extensions"
  list_can_update=$(gnome-extensions list --updates)

  if ! [[ -n "$list_can_update" ]]; then
    echo "All extensions up-to-date."
  else
    echo "##"
    echo "Extension updates available:"
    echo $list_can_update
    echo "##"
    echo "gnome-extensions install <uuid> (shown above)"
    echo "##"
    read -rp "Continue [ENTER]"
  fi
}

# Done
function finish_update() {
  echo "Update complete!"
  echo_heading "Reboot"
  read -p "Reboot the system? (y/n): " confirm_reboot
  if [[ $confirm_reboot == "y" || $confirm_reboot == "Y" ]]; then
    echo "Rebooting the system..."
    reboot
  fi
}

start_update
prompt_upgrade
prompt_chrome_update
prompt_ext_update
finish_update
exit 0
