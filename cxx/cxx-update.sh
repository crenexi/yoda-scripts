#!/bin/bash
set -e

dir=$(dirname "$0")
source "$dir/../utils/echo-utils.sh"

# Basic update
function start_update() {
  echo_header "UPDATE" "clear"
  sudo apt update
}

# Prompt for upgrade
function prompt_upgrade() {
  echo_header "UPGRADE"
  read -p "Choose upgrade option (1. Routine / 2. Aggressive / 3. Skip): " upgrade_opt

  if [[ $upgrade_opt == "1" ]]; then
    echo_info "Starting routine upgrade..."
    sudo apt upgrade
    echo_success "Completed upgrade!"
  elif [[ $upgrade_opt == "2" ]]; then
    echo_info "Starting aggressive upgrade..."
    sudo apt dist-upgrade -y
    sudo apt autoremove --purge -y
    sudo apt clean
    echo_success "Completed upgrade!"
  elif [[ $upgrade_opt == "3" ]]; then
    echo "Skipping upgrade."
  else
    echo_warn "Invalid option. Choose an upgrade option."
    prompt_upgrade
  fi
}

# Prompt to update Chrome
function prompt_chrome_update() {
  echo_header "CHROME"
  read -p "Update Chrome? (y/n): " confirm_chrome
  if [[ $confirm_chrome == "y" || $confirm_chrome == "Y" ]]; then
    echo_info "Updating Chrome..."
    run-chrome-update.sh
  fi
}

# Prompt to update gnome extensions
function prompt_ext_update() {
  echo_header "EXTENSIONS"
  list_can_update=$(gnome-extensions list --updates)

  if ! [[ -n "$list_can_update" ]]; then
    echo_success "All extensions up-to-date."
  else
    echo "##"
    echo_info "Extension updates available:"
    echo $list_can_update
    echo "##"
    echo "gnome-extensions install <uuid> (shown above)"
    echo "##"
    read -rp "Continue [ENTER]"
  fi
}

# Done
function finish_update() {
  echo_success "Update complete!"
  echo_header "Reboot"

  read -p "Reboot the system? (y/n): " confirm_reboot

  if [[ $confirm_reboot == "y" || $confirm_reboot == "Y" ]]; then
    echo_info "Rebooting the system..."
    reboot
  else
    echo_success "Updates completed!"
  fi
}

start_update
prompt_upgrade
prompt_chrome_update
prompt_ext_update
finish_update
exit 0
