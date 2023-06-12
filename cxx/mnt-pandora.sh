#!/bin/bash

# Accessing the mount point will implicitly trigger autofs to mount the NAS
mnt_crenexi="/pandora/pandora_crenexi"
if ! ls "$mnt_crenexi" >/dev/null 2>&1; then
  echo "Mounting pandora_crenexi..."

  if ! ls "$mnt_crenexi" >/dev/null 2>&1; then
    echo "Failed to mount pandora_crenexi"
    exit 1
  fi
fi

# Shared
mnt_public="/pandora/pandora_public"
if ! ls "$mnt_public" >/dev/null 2>&1; then
  echo "Mounting pandora_public..."

  if ! ls "$mnt_public" >/dev/null 2>&1; then
    echo "Failed to mount pandora_public"
    exit 1
  fi
fi
