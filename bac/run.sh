#!/bin/bash
# This runs all backup scripts
source /home/crenexi/.bashrc

bac="/home/crenexi/.cx/bin/bac"
logs="/home/crenexi/.cx/logs"

# Log file
bac_log="$logs/bac.log"
if [ ! -f "$bac_log" ]; then
  touch "$bac_log"
fi

# Backups
"$bac/bac-home.sh" >> "$logs/bac.log" 2>&1
"$bac/bac-most.sh" >> "$logs/bac.log" 2>&1
"$bac/bac-games.sh" >> "$logs/bac.log" 2>&1
