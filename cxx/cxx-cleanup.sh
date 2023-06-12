#!/bin/bash
# Ensure deborphan and gio packages are available

function cleanup_packages() {
  echo "## Packages cleanup #########################################"

  # APT cleanup
  echo "Autoclean and autoremove..."
  sudo apt autoclean
  sudo apt autoremove -y

  # Remove orphaned packages not needed by any other package
  echo "Removing orphaned packages..."
  orphan_packages=$(deborphan)
  if [ -n "$orphan_packages" ]; then
    echo "$orphan_packages" | xargs sudo apt-get -y remove --purge
  fi

  # Removes old config files left behind by removed packages
  echo "Removing orphaned configs..."
  orphan_configs=$(dpkg -l | grep '^rc' | awk '{print $2}')
  if [ -n "$orphan_configs" ]; then
    echo "$orphan_configs" | sudo xargs dpkg --purge
  fi
}

function cleanup_caches() {
  echo "## Cache cleanup ############################################"

  # Remove cached lists of available packages; helps with indexing/refreshing
  echo "Removing cached lists..."
  sudo rm -rf /var/lib/apt/lists/*
}

function cleanup_trash() {
  echo "## Trash cleanup ############################################"

  trash_files="$HOME/.local/share/Trash/files"

  # Ensure trash dir exists
  if [ ! -d "$trash_files" ]; then
    echo "Trash directory does not exist."
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
    read -p "Delete all $trash_count files in trash? (y/n): " deleteTrash
    if [[ "$deleteTrash" == [yY] ]]; then
      gio trash --empty
      echo "Deleted Trash files"
    fi
  fi
}

#################################################
## Main #########################################
#################################################

cleanup_packages
cleanup_caches
cleanup_trash
echo
echo "Finished cleanup operations!"
