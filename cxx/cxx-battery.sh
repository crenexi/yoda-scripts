#!/bin/bash

sudo tlp-stat -s

printf "+++ Battery\n"
sudo tlp-stat -b | grep -E 'Charge|Capacity|_threshold' --color=none

printf "\n+++ Devices\n"
sudo tlp-stat -d | grep -E 'Devices' --color=none

printf "\n+++ Processor\n"
sudo tlp-stat -p | grep -E 'CPU model' --color=none
