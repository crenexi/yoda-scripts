#!/bin/bash
# Accessing the mount point will implicitly trigger autofs to mount the NAS

verify_mount() {
  local mnt_point=$1

  if ! ls "$mnt_point" >/dev/null 2>&1; then
    echo "## Failed to mount $mnt_point"
    exit 1
  fi
}

# Ensure autofs is active and enabled; exit otherwise
if ! systemctl is-active --quiet autofs && ! systemctl is-enabled --quiet autofs; then
  echo "## Autofs service is not active or enabled. Cannot mount pandora."
  exit 1
fi

# Mount pandora_crenexi
mnt_crenexi="/pandora/pandora_crenexi"
if ! ls "$mnt_crenexi" >/dev/null 2>&1; then
  verify_mount "$mnt_crenexi"
fi

# Mount pandora_public
mnt_public="/pandora/pandora_public"
if ! ls "$mnt_public" >/dev/null 2>&1; then
  verify_mount "$mnt_public"
fi
