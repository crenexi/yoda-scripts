#!/bin/bash
# Ensure deborphan and gio packages are available

dir=$(dirname "$0")
source "$dir/../utils/echo-utils.sh"

## HELPERS ####################################################################

function ensure_deps() {
  for dep in deborphan gio; do
    if ! command -v $dep &>/dev/null; then
      echo_error "Error: $dep is not installed."
      exit 1
    else
      echo "$dep is installed."
    fi
  done
}

## FUNCTIONS ##################################################################

function cleanup_packages() {
  echo_header "PACKAGES CLEANUP"

  # APT cleanup
  echo -e "${cyellow}Autoclean and autoremove...${cend}"
  sudo apt autoclean
  sudo apt autoremove -y

  # Remove orphaned packages not needed by any other package
  echo -e "${cyellow}Removing orphaned packages...${cend}"
  orphan_packages=$(deborphan)
  if [ -n "$orphan_packages" ]; then
    echo "$orphan_packages" | xargs sudo apt-get -y remove --purge
  fi

  # Removes old config files left behind by removed packages
  echo -e "${cyellow}Removing orphaned configs...${cend}"
  orphan_configs=$(dpkg -l | grep '^rc' | awk '{print $2}')
  if [ -n "$orphan_configs" ]; then
    echo "$orphan_configs" | sudo xargs dpkg --purge
  fi
}

function cleanup_caches() {
  echo_header "CACHE CLEANUP"

  # Remove cached lists of available packages; helps with indexing/refreshing
  echo -e "${cyellow}Removing cached lists...${cend}"
  sudo rm -rf /var/lib/apt/lists/*
}

function cleanup_trash() {
  echo_header "TRASH CLEANUP"

  trash_files="$HOME/.local/share/Trash/files"

  # Ensure trash dir exists
  if [ ! -d "$trash_files" ]; then
    echo_error "Trash directory does not exist."
    exit 1
  fi

  trash_count=$(find "$trash_files" -type f | wc -l)

  if [ "$trash_count" -eq 0 ]; then
    echo "Trash is already empty"
  else
    # Review trash quickly
    read -p "Proceed to review Trash [ENTER]: "
    ls -la "$trash_files" | less -F

    # Prompt to delete trash
    read -p "Trash reviewed [ENTER]: "
    echo_error "Delete all $trash_count files in trash? (y/n): "
    read deleteTrash
    if [[ "$deleteTrash" == [yY] ]]; then
      gio trash --empty
      echo "Deleted Trash files"
    fi
  fi
}

## Main #######################################################################

ensure_deps
cleanup_packages
cleanup_caches
cleanup_trash
echo_success "Finished cleanup operations!"
