#!/bin/bash
set -e

color_red=$"\e[1;31"
color_green=$"\e[1;32"
color_yellow=$"\e[1;33"
color_blue=$"\e[1;34"
color_magenta=$"\e[1;35"
color_cyan=$"\e[1;36"
color_end=$"\e[0"

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
    info "${color_blue}Checks completed${color_end}"
    read -p "Approve checks? [Y/N] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* )
          info "${color_yellow}Cancelled${color_end}"
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
          info "${color_yellow}Cancelled release${color_end}"
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
  info "${color_green}READY TO RELEASE${color_end}"
  info "${color_yellow}YOU'RE ABOUT TO RELEASE v${version}${color_end}"
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
  info "${color_green}RELEASED v${version} AND PUSHED TAGS!${color_end}"

  # Push changes
  updateOrigin
  info "${color_green}RELEASE PUSHED TO ORIGIN${color_end}"

  # List branches
  info "Local branches:\n"
  git branch --list
}

# Check for unstaged commits
if [ -d ".git" ]; then
	changes=$(git status --porcelain)

	if [ -z "${changes}" ]; then
    echo "##########"
    info "Confirming version..."
    approveRelease

    echo "##########"
    info "Finishing release..."
    finishRelease
	else
		echo "/!\ ${color_yellow}Please commit staged files prior to bumping${color_end}"
	fi
fi
