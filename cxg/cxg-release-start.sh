#!/bin/bash

dir=$(dirname "$0")
source "$dir/helpers/helpers.sh"
source "$dir/../utils/splash.sh"
source "$dir/../utils/echo-utils.sh"

## FUNCTIONS ##################################################################

function preflight_checks {
  check_git_flow
  check_unstaged_commits
  check_npm_lint
  read_version

  clear; echo_success "Ready to start release"
  echo -e "Current Version: ${cmagenta}v${version}${cend}"
}

function prompt_version {
  read -p "Enter new semantic version (exclude the v): " new_version
  validate_version

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

function start_flow_release {
  echo "Starting release..."
  git checkout develop
  git pull origin develop
  git push origin develop
  git flow release start v${new_version}
}

function bump_packagejson {
  echo "Bumping version..."
	npm version "$new_version" --no-git-tag-version
  git add .
  git commit -m "Bumped version to v${new_version}"
  echo_success "Bumped version to v${new_version}!"
}

## MAIN #######################################################################

splash
preflight_checks
prompt_version
start_flow_release
bump_packagejson
