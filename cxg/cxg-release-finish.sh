#!/bin/bash
# This script assumes it's ran in a Git repo that follows Git Flow
set -e

##########
## HELPERS

# Utility colors
cred="\e[1;31m"
cgreen="\e[1;32m"
cyellow="\e[1;33m"
cblue="\e[1;34m"
cmagenta="\e[1;35m"
ccyan="\e[1;36m"
cend="\e[0m"

# Utility echos
echo_info () { echo -e "${cblue}${1}${cend}"; }
echo_success() { echo -e "${cgreen}${1}${cend}"; }
echo_warn() { echo -e "/!\ ${cyellow}${1}${cend}"; }
echo_error() { echo -e "/!\ ${cred}${1}${cend}"; }
echo_header() {
  message="$1"
  color="$2"
  echo "##########"
  echo -e "## ${color}${message}${cend}"
}

##########
## MAIN

function readVersion {
  version=$(cat package.json \
    | grep version \
    | head -1 \
    | awk -F: '{ print "$2" }' \
    | sed 's/[",]//g' \
    | tr -d '[[:space:]]')
}

function confirmChecks {
  while true; do
    echo_info "Checks completed"
    read -p "Approve checks? [Y/N] " yn
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
    read -p "Are you sure to proceed? [Y/N] " yn
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
  info "Local branches:\n"
  git branch --list
}

# Check for unstaged commits
if [ -d ".git" ]; then
	changes=$(git status --porcelain)

	if [ -z "${changes}" ]; then
    echo_header "Confirming version..."
    approveRelease

    echo_header "Finishing release..."
    finishRelease
	else
		echo_warn "Please commit staged files prior to bumping"
	fi
fi
