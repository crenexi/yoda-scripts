#!/bin/bash

dir=$(dirname "$0")
dir_content="$HOME/.cx/bin/utils/content"
source "$dir/helpers/helpers.sh"
source "$dir/../utils/splash.sh"
source "$dir/../utils/echo-utils.sh"

url_notion_projects="https://www.notion.so/crenexi/9e7a6fc2be4b42499e5141ae44c250a0"
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

# Prompt to update Notion
function prompt_notion() {
  echo "##"
  echo_callout "Update Notion" "$url_notion_projects"
  echo_info "Update Notion version..."
  read -p "Continue: (ENTER): "
}

# Prompt to perform invalidation
function prompt_invalidation() {
  echo "##"
  echo_callout "Invalidation" "$url_cloudfront_home"
  echo_info "Consider CloudFront invalidation..."
  read -p "Continue: (ENTER): "
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

  # Update staging (optional)
  prompt_update_stage

  # Cleanup
  git checkout develop
  git_editor "reset"
}

function on_complete() {
  cat "$dir_content/art_nyan.txt"
  echo "\\"; echo "#\\"; echo "##\\"
  echo_success "✨ FINISHED RELEASE!";
  prompt_notion
  prompt_invalidation
  echo_success "ALL DONE!"
  list_branches
}

## MAIN #######################################################################

splash
preflight_checks
confirm_release
finish_release
on_complete
