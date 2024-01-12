#!/bin/bash

# Function to reset npm registry to default
reset_npm_registry() {
  echo "Resetting npm registry to the default public registry..."
  npm config set registry https://registry.npmjs.org
  echo "Npm registry has been reset to the default public registry."
}

# Check for command-line argument and use a switch case for future expansion
case "$1" in
  reset-registry)
    reset_npm_registry
    ;;
  *)
    echo "Usage: $0 [reset-registry]"
    exit 1
    ;;
esac
