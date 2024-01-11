#!/bin/bash

dir=$(dirname "$0")
source "$dir/../utils/echo-utils.sh"

if ! command -v tlp-stat &> /dev/null; then
  echo_error "Package 'tlp-stat' is not installed. Exiting."
  exit 1
fi

sudo tlp-stat -s

printf "+++ Battery\n"
sudo tlp-stat -b | grep -E 'Charge|Capacity|_threshold' --color=none

printf "\n+++ Devices\n"
sudo tlp-stat -d | grep -E 'Devices' --color=none

printf "\n+++ Processor\n"
sudo tlp-stat -p | grep -E 'CPU model' --color=none
