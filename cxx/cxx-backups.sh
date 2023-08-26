#!/bin/bash
# Checkup on some specific cron jobs

dir=$(dirname "$0")
host=$(hostname)
logs="$HOME/.cx/logs"
source "$dir/../utils/echo-utils.sh"

function echo_last_backups() {
  dirs=("bac-home" "bac-most" "bac-games")

  for dir in "${dirs[@]}"; do
    filepath="$logs/bac/${dir}_time"

    if [ -f "$filepath" ]; then
      echo_info "$dir: $(cat "$filepath")"
    fi
  done
}

function echo_last_backups_less() {
  dirs=("bac-home" "bac-most" "bac-games")

  for dir in "${dirs[@]}"; do
    filepath="$logs/bac/$dir\.log"

    if [ -f "$filepath" ]; then
      echo "  $(cat "$filepath") | less -F"
    fi
  done
}

echo_header "LAST BACKUPS" "clear"
echo_last_backups
echo_header "SEE MORE"
echo "LAST BACKUP LOG"
echo_last_backups_less
echo "CRENEXI BACKUP LOG"
echo "  cat $logs/bac.log | less -F"
echo "ROOT/USER CRONTABS"
echo "  sudo crontab -l"
echo "  chrontab -l"
echo "ALL/USER CHRON SYSLOG"
echo "  grep -E 'CRON.' /var/log/syslog | tail -n 300 | less -F"
echo "  grep -E 'CRON.*crenexi' /var/log/syslog | tail -n 300 | less -F"
