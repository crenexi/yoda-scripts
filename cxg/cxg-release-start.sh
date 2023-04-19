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

function approveBump {
  # Lint and get version
  npm run lint
  readVersion

  # Approve checks
  confirmChecks

  # No errors; proceed
  info "${colorGreen}READY TO START RELEASE${colorEnd}"
  info "Current Version: ${colorMagenta}v${version}${colorEnd}"
}

function confirmVersion {
  while true; do
    info "Version '${colorBlue}v${newVersion}${colorEnd}' will be created."
    read -p "Proceed to create release? [Y/N] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* )
          info "${colorYellow}Cancelled${colorEnd}"
          exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

function promptVersion {
  read -p "Enter new semantic version (exclude the v): " newVersion

  # Ensure something was entered
  if [ -z "$newVersion" ]; then
    info "${colorRed}/!\ NO VERSION SUPPLIED. EXITING.${colorEnd}"
    exit 1
  fi

  confirmVersion
}

function bumpPackageJson {
	npm version $newVersion --no-git-tag-version
  git add .
  git commit -m "Bumped version to v${newVersion}"

  info "${colorGreen}BUMPED VERSION TO v${newVersion}!${colorEnd}"
}

function startRelease {
  git checkout develop
  git pull origin develop
  git push origin develop
  git flow release start v${newVersion}
}

function main {
  info "##########"
  info "Affirming checks..."
  approveBump

  info "##########"
  info "Confirming version..."
  promptVersion

  info "##########"
  info "Starting release..."
  startRelease

  info "##########"
  info "Bumping version..."
  bumpPackageJson
}

# Check for unstaged commits
if [ -d ".git" ]; then
	changes=$(git status --porcelain)

	if [ -z "${changes}" ]; then
    main
	else
		echo "/!\ ${colorYellow}Please commit staged files prior to bumping${colorEnd}"
	fi
fi
