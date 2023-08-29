#!/bin/bash
set -e

dir=$(dirname "$0")
source "$dir/helpers/helpers.sh"
source "$dir/../utils/splash.sh"
source "$dir/../utils/echo-utils.sh"

## FUNCTIONS ##################################################################

function preflight_checks {
  echo "Preflight checks..."
  check_git_flow
  check_unstaged_commits
  check_npm_lint
  read_version

  # Release confirmation
  echo_success "READY TO RELEASE!"
  echo_warn "YOU'RE ABOUT TO RELEASE v${version}"
}

function confirm_release {
  while true; do
    read -p "Proceed to release? [y/n] " yn
    case "$yn" in
      [Yy]* ) break;;
      [Nn]* ) cancel 0;;
      * ) echo "Yes or no.";;
    esac
  done
}

function update_origin {
  echo "Updating origin..."

  # Update main
  git checkout main
  git push origin main
  git push origin main --tags

  # Update develop
  git checkout develop
  git push origin develop
  git push origin develop --tags

  echo_info "Origin updated!"
}

function finish_release {
  echo_info "Finishing release..."

  # Finishes the release and tags
  export GIT_MERGE_AUTOEDIT=no
  git flow release finish -m 'Merge' v${version}
  unset GIT_MERGE_AUTOEDIT
  echo_success "RELEASED v${version} AND PUSHED TAGS!"

  # Push changes
  update_origin
  echo_success "RELEASE PUSHED TO ORIGIN"

  # List branches
  echo "Local branches:"
  git branch --list

}

## MAIN #######################################################################

splash
preflight_checks
confirm_release
finish_release
