#!/bin/bash
# This script assumes it's ran in a Git repo that follows Git Flow
set -e

dir=$(dirname "$0")
source "$dir/../utils/splash.sh"
source "$dir/../utils/echo-utils.sh"

## FUNCTIONS ##################################################################

function readVersion {
  version=$(cat package.json \
    | grep version \
    | head -1 \
    | awk -F: '{ print $2 }' \
    | sed 's/[",]//g' \
    | tr -d '[[:space:]]')
}

function confirmChecks {
  while true; do
    echo_info "Checks completed"
    read -p "Approve checks? [y/n] " yn
    case "$yn" in
        [Yy]* ) break;;
        [Nn]* )
          echo_info "Cancelled"
          exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

function confirmRelease {
  while true; do
    read -p "Are you sure to proceed? [y/n] " yn
    case "$yn" in
        [Yy]* ) break;;
        [Nn]* )
          echo_info "Cancelled release"
          exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

function approveRelease {
  # Lint and get version
  npm run lint
  readVersion

  # Approve checks
  confirmChecks

  # Release confirmation
  echo_success "READY TO RELEASE"
  echo_warn "YOU'RE ABOUT TO RELEASE v${version}"
  confirmRelease
}

function updateOrigin {
  # Update main
  git checkout main
  git push origin main
  git push origin main --tags

  # Update develop
  git checkout develop
  git push origin develop
  git push origin develop --tags
}

function finishRelease {
  # Finishes the release and tags
  export GIT_MERGE_AUTOEDIT=no
  git flow release finish -m 'Merge' v${version}
  unset GIT_MERGE_AUTOEDIT
  echo_success "RELEASED v${version} AND PUSHED TAGS!"

  # Push changes
  updateOrigin
  echo_success "RELEASE PUSHED TO ORIGIN"

  # List branches
  echo "Local branches:"
  git branch --list
}

## MAIN #######################################################################

# Check for unstaged commits
if [ -d ".git" ]; then
	changes=$(git status --porcelain)

	if [ -z "${changes}" ]; then
    splash
    echo_info "Confirming version..."
    approveRelease

    echo_info "Finishing release..."
    finishRelease
	else
		echo_warn "Please commit staged files prior to bumping"
	fi
fi
