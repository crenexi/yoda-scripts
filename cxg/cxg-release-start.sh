#!/bin/bash

dir=$(dirname "$0")
source "$dir/helpers/helpers.sh"
source "$dir/../utils/splash.sh"
source "$dir/../utils/echo-utils.sh"

## FUNCTIONS ##################################################################

function preflight_checks() {
  echo "Preflight checks..."
  check_git_flow
  check_unstaged_commits
  check_npm_lint
  read_version

  echo_success "Ready to start release"
  echo -e "Current Version: ${cmagenta}v${version}${cend}"
}

function prompt_version() {
  # Enter valid version
  while true; do
    read -p "Enter new semantic version (exclude the v): " new_version

    # Invalid version
    if [[ ! "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo_error "Invalid version. Must be in '0.0.0' format!"
    else
      break
    fi
  done

  # Confirmation to proceed
  while true; do
    echo -e "Version '${cblue}v${new_version}${cend}' will be created."
    read -p "Proceed to create release? [y/n] " yn
    case "$yn" in
      [Yy]* ) break;;
      [Nn]* ) cancel 0;;
      * ) echo "Yes or no.";;
    esac
  done
}

function start_release() {
  echo "Starting release..."

  # Sync develop
  git checkout develop
  git pull origin develop

  # Create release
  git flow release start "v${new_version}" || {
    cancel 1 "Failed to perform 'git flow release start'!"
  }
}

function bump_packagejson() {
  echo "Bumping version..."
	npm version "$new_version" --no-git-tag-version
  git add .
  git commit -m "Bumped version to v${new_version}"
  echo_success "Bumped version to v${new_version}!"
}

function on_complete() {
  git checkout "release/v${new_version}"
  echo_success "ALL DONE!"
  list_branches
}

## MAIN #######################################################################

splash
preflight_checks
prompt_version
start_release
bump_packagejson
prompt_update_stage "release/v$new_version"
on_complete
