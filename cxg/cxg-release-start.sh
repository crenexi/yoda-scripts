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

function check_release_commits() {
  git fetch origin develop release # fetch latest
  local develop_commit=$(git rev-parse origin/develop) # develop hash
  local release_commit=$(git rev-parse origin/release) # release hash

  # Compare the latest commits
  if [[ "${develop_commit}" != "${release_commit}" ]]; then
    cancel 1 "Release branch exists with new commits!"
  fi
}

function create_release_branch() {
  # Check if a local 'release' branch exists
  local local_exists=$(git show-ref --quiet --verify refs/heads/release && echo "exists" || echo "notexists")

  # Check if a remote 'release' branch exists
  local remote_exists=$(git ls-remote --exit-code --heads origin release > /dev/null 2>&1 && echo "exists" || echo "notexists")

  # If either local or remote 'release' branch exists
  if [[ "${local_exists}" == "exists" || "${remote_exists}" == "exists" ]]; then
    check_release_commits
  fi

  # Create new local release
  git checkout -b release

  # Force push to remote
  if [[ "${remote_exists}" == "exists" ]]; then
    git push -f origin release
  else
    git push origin release
  fi
}

function start_release() {
  echo "Starting release..."

  # Sync develop
  git checkout develop
  git pull origin develop

  # Create release
  create_release_branch
}

function bump_packagejson() {
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
start_release
bump_packagejson
