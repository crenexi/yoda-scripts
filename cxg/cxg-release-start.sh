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

function read_version {
  version=$(cat package.json \
    | grep version \
    | head -1 \
    | awk -F: '{ print $2 }' \
    | sed 's/[",]//g' \
    | tr -d '[[:space:]]')
}

function confirm_checks {
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

function approve_bump {
  # Lint and get version
  npm run lint
  read_version

  # Approve checks
  confirm_checks

  # No errors; proceed
  echo_success "READY TO START RELEASE"
  echo -e "Current Version: ${cmagenta}v${version}${cend}"
}

function confirm_version {
  while true; do
    echo -e "Version '${cblue}v${new_version}${cend}' will be created."
    read -p "Proceed to create release? [Y/N] " yn
    case "$yn" in
        [Yy]* ) break;;
        [Nn]* )
          echo_info "Cancelled"
          exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

function prompt_version {
  read -p "Enter new semantic version (exclude the v): " new_version

  # Ensure something was entered
  if [ -z "$new_version" ]; then
    echo_error "NO VERSION SUPPLIED. EXITING."
    exit 1
  fi

  confirm_version
}

function bump_packagejson {
	npm version "$new_version" --no-git-tag-version
  git add .
  git commit -m "Bumped version to v${new_version}"

  echo_success "BUMPED VERSION TO v${new_version}!"
}

function start_release {
  git checkout develop
  git pull origin develop
  git push origin develop
  git flow release start v${new_version}
}

function main {
  echo_header "Affirming checks..."
  approve_bump

  echo_header "Confirming version..."
  prompt_version

  echo_header "Starting release..."
  start_release

  echo_header "Bumping version..."
  bump_packagejson
}

# Check for unstaged commits
if [ -d ".git" ]; then
	changes=$(git status --porcelain)

	if [ -z "${changes}" ]; then
    main
	else
		echo_warn "Please commit staged files prior to bumping"
	fi
fi
