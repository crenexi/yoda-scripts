#!/bin/bash

# Exit script
function cancel() {
  code=${1:-1}
  message=${2:-"Operation cancelled."}

  if [ "$code" -eq 1 ]; then
    echo_error "$message"
  else
    echo "$message"
  fi

  exit $code
}

# Validate Git Flow
function check_git_flow() {
  # Check installation
  if ! git flow version > /dev/null 2>&1; then
    cancel 1 "Git Flow is not installed. Install it before proceeding."
  fi

  # Check Git Flow initialization in repository
  if [ ! -f ".git/config" ] || ! grep -q '\[gitflow' ".git/config"; then
    cancel 1 "Git Flow is not initialized in this repository. Initialize it before proceeding."
  fi
}

# Check for unstaged commits
function check_unstaged_commits() {
  # Exit if not a Git repo
  if [ ! -d ".git" ]; then
    cancel 1 "This directory is not a Git repository. EXITING."
  fi

  # Exit if there's unstaged commits
  changes=$(git status --porcelain)
  if [ -n "${changes}" ]; then
    cancel 1 "Please commit staged files prior to bumping"
  fi

  return 0 # No unstaged commits
}

# Linting validation
function check_npm_lint() {
  if ! grep -q '"lint":' package.json; then
    echo "Skipping lint. No such command in package."
    return 0
  fi

  npm run lint > /dev/null 2>&1

  # Has lint output
  if [ $? -ne 0 ]; then
    echo_warn "Linting issues detected."

    while true; do
      read -p "Proceed regardless? (y/n) " input
      case "$input" in
        [Yy]* ) break;;
        [Nn]* ) cancel 0;;
        * ) echo "Yes or no.";;
      esac
    done
  fi
}

# Retrieve the version
function read_version() {
  version=$(cat package.json \
    | grep version \
    | head -1 \
    | awk -F: '{ print $2 }' \
    | sed 's/[",]//g' \
    | tr -d '[[:space:]]')

  # Check version exists
  if [[ -z "${version}" ]]; then
    cancel 1 "Version is not defined."
  fi

  # Check version format
  if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    cancel 1 "Version ${version} is not in the format X.Y.Z"
  fi
}
