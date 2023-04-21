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

function approve_bump {
  # Lint and get version
  npm run lint
  read_version

  # Approve checks
  confirm_checks

  # No errors; proceed
  info "${color_green}READY TO START RELEASE${color_end}"
  info "Current Version: ${color_magenta}v${version}${color_end}"
}

function confirm_version {
  while true; do
    info "Version '${color_blue}v${new_version}${color_end}' will be created."
    read -p "Proceed to create release? [Y/N] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* )
          info "${color_yellow}Cancelled${color_end}"
          exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

function prompt_version {
  read -p "Enter new semantic version (exclude the v): " new_version

  # Ensure something was entered
  if [ -z "$new_version" ]; then
    info "${colorRed}/!\ NO VERSION SUPPLIED. EXITING.${color_end}"
    exit 1
  fi

  confirm_version
}

function bump_packagejson {
	npm version $new_version --no-git-tag-version
  git add .
  git commit -m "Bumped version to v${new_version}"

  info "${color_green}BUMPED VERSION TO v${new_version}!${color_end}"
}

function start_release {
  git checkout develop
  git pull origin develop
  git push origin develop
  git flow release start v${new_version}
}

function main {
  echo "##########"
  info "Affirming checks..."
  approve_bump

  echo "##########"
  info "Confirming version..."
  prompt_version

  echo "##########"
  info "Starting release..."
  start_release

  echo "##########"
  info "Bumping version..."
  bump_packagejson
}

# Check for unstaged commits
if [ -d ".git" ]; then
	changes=$(git status --porcelain)

	if [ -z "${changes}" ]; then
    main
	else
		echo "/!\ ${color_yellow}Please commit staged files prior to bumping${color_end}"
	fi
fi
