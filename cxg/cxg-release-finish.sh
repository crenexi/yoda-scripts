#!/bin/bash

dir=$(dirname "$0")
source "$dir/helpers/helpers.sh"
source "$dir/../utils/splash.sh"
source "$dir/../utils/echo-utils.sh"

url_cloudfront_home="https://us-east-1.console.aws.amazon.com/cloudfront/v3/home"

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

# Prompt to perform invalidation
function prompt_invalidation() {
  echo_callout "Invalidation" "$url_cloudfront_home"
  read -p "Consider CloudFront invalidation for immediate updates. Done: (ENTER): "
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

function finish_release {
  echo_info "Finishing release..."

  # Sync release
  git checkout release
  git pull origin release

  # release->main
  git checkout main
  git merge release

  # Tag release
  git tag -a "v${version}" -m "Release version ${version}"

  # Sync main
  git push origin main
  git push origin main --tags
  echo_success "RELEASED v${version} AND PUSHED TAGS!"

  # Backmerge into develop
  git checkout develop
  git merge release

  # Sync develop
  git push origin develop
  git push origin develop --tags

  # Remove release
  # Note: keep release on remote for keeping pipeline source-detection intact
  git branch -d release

  # Push changes
  echo_success "✨ FINISHED RELEASE!"

  # List branches
  echo "Local branches:"
  git branch --list
}

## MAIN #######################################################################

splash
preflight_checks
confirm_release
finish_release
prompt_notion
prompt_invalidation
