#!/bin/bash

function service_status() {
  name=$1
  active_state=$(systemctl is-active "$name")
  enabled_state=$(systemctl is-enabled "$name")

  echo "#############################################################"
  echo "## $name is $active_state and $enabled_state"
  echo
  eval "systemctl status --no-pager $name"
  echo
}

function service_count() {
  count=$(sudo systemctl list-units --type=service --state=running | grep -c "\.service")
  echo "$count total services running"
  echo
}

service_count

# Main
service_status "autofs"
service_status "postgresql"

# Crenexi
service_status "cx-backup.service"
