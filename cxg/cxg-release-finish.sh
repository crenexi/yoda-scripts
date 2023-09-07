#!/bin/bash

dir=$(dirname "$0")
source "$dir/helpers/helpers.sh"
source "$dir/../utils/splash.sh"
source "$dir/../utils/echo-utils.sh"

url_cloudfront_home="https://us-east-1.console.aws.amazon.com/cloudfront/v3/home"

## HELPERS ####################################################################

function git_editor() {
  case "$1" in
    "disable" )
      og_git_editor=$GIT_EDITOR
      export GIT_EDITOR=true ;;
    "reset" )
      export GIT_EDITOR=$og_git_editor ;;
  esac
}

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
  git_editor "disable"

  # Finish the git flow release
  git flow release finish -m "Release version ${version}" "v${version}" || {
     git_editor "reset"
    cancel 1 "Failed to perform 'git flow release finish'!"
  }

  # Push changes
  git push origin develop main
  git push origin --tags

  # Updated staging
  checkout_stage
  update_stage

  # Cleanup
  git_editor "reset"

  # List branches
  echo "Local branches:"
  git branch --list
}

function on_complete() {
  echo "###/"
  echo "##/"
  echo "#/"
  echo_success "✨ FINISHED RELEASE!"
  echo "#\\"
  echo_header "NEXT STEPS"

  prompt_notion
  prompt_invalidation
}

## MAIN #######################################################################

splash
preflight_checks
confirm_release
finish_release
on_complete
