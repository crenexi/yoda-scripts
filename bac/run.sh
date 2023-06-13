#!/bin/bash
# This runs all backup scripts
source /home/crenexi/.bashrc

bac="/home/crenexi/.cx/bin/bac"
logs="/home/crenexi/.cx/logs"

"$bac/bac-home.sh" >> "$logs/bac.log" 2>&1
"$bac/bac-most.sh" >> "$logs/bac.log" 2>&1
"$bac/bac-games.sh" >> "$logs/bac.log" 2>&1
