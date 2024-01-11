#!/bin/bash

dir=$(dirname "$0")
source "$dir/../utils/echo-utils.sh"

function service_status() {
  name=$1
  active_state=$(systemctl is-active "$name")
  enabled_state=$(systemctl is-enabled "$name")

  echo
  echo_header "$name"
  echo "$name is $active_state and $enabled_state"
  eval "systemctl status --no-pager $name"
}

function service_count() {
  count=$(sudo systemctl list-units --type=service --state=running | grep -c "\.service")
  echo
  echo_header "SUMMARY"
  echo_info "$count total services running"
}

# Main
service_status "autofs"
service_status "postgresql"

# Crenexi
service_status "cx-backup.service"

# Summary
service_count
