#!/bin/bash

# Accessing the mount point will implicitly trigger autofs to mount the NAS
mnt_private="/nas/Panda-Private"
if ! ls "$mnt_private" >/dev/null 2>&1; then
  echo "Mounting Panda-Private..."

  if ! ls "$mnt_private" >/dev/null 2>&1; then
    echo "Failed to mount Panda-Private"
    exit 1
  fi
fi

# Shared
mnt_shared="/nas/Panda-Shared"
if ! ls "$mnt_shared" >/dev/null 2>&1; then
  echo "Mounting Panda-Shared..."

  if ! ls "$mnt_shared" >/dev/null 2>&1; then
    echo "Failed to mount Panda-Shared"
    exit 1
  fi
fi
