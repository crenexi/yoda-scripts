#!/bin/bash
# This runs all backup scripts
source /home/crenexi/.bashrc

bin="/home/crenexi/.cx/bin/bac"
log="/home/crenexi/.cx/logs/bac.log"

function trim_log() {
  local max_lines=100
  local line_count=$(wc -l < "$log")

  if [ "$line_count" -gt "$max_lines" ]; then
    remove_count=$((line_count - max_lines)) # lines to remove
    tail -n "$max_lines" "$log" > "$log.tmp" # trimmed file
    mv "$log.tmp" "$log"
  fi
}

# Trim or create log
if [ -f "$log" ]; then
  trim_log
else
  touch "$log"
fi

# Backups
"$bin/bac-home.sh" >> "$log" 2>&1
"$bin/bac-most.sh" >> "$log" 2>&1
"$bin/bac-games.sh" >> "$log" 2>&1
