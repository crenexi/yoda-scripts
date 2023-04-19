#!/bin/bash
set -e

colorRed=$'\e[1;31m'
colorGreen=$'\e[1;32m'
colorYellow=$'\e[1;33m'
colorBlue=$'\e[1;34m'
colorMagenta=$'\e[1;35m'
colorCyan=$'\e[1;36m'
colorEnd=$'\e[0m'

info () {
  printf "## ${1}\n"
}

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
    info "${colorBlue}Checks completed${colorEnd}"
    read -p "Approve checks? [Y/N] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* )
          info "${colorYellow}Cancelled${colorEnd}"
          exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

function confirmRelease {
  while true; do
    read -p "Are you sure to proceed? [Y/N] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* )
          info "${colorYellow}Cancelled release${colorEnd}"
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
  info "${colorGreen}READY TO RELEASE${colorEnd}"
  info "${colorYellow}YOU'RE ABOUT TO RELEASE v${version}${colorEnd}"
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
  info "${colorGreen}RELEASED v${version} AND PUSHED TAGS!${colorEnd}"

  # Push changes
  updateOrigin
  info "${colorGreen}RELEASE PUSHED TO ORIGIN${colorEnd}"

  # List branches
  info "Local branches:\n"
  git branch --list
}

# Check for unstaged commits
if [ -d ".git" ]; then
	changes=$(git status --porcelain)

	if [ -z "${changes}" ]; then
    info "##########"
    info "Confirming version..."
    approveRelease

    info "##########"
    info "Finishing release..."
    finishRelease
	else
		echo "/!\ ${colorYellow}Please commit staged files prior to bumping${colorEnd}"
	fi
fi
