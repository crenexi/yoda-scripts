#!/bin/bash
# Checkup on some specific cron jobs

function echo_last_backups() {
  dirs=("bac-home" "bac-most" "bac-games")

  for dir in "${dirs[@]}"; do
    filepath="/etc/crenexi/crenexi@$(hostname)/${dir}_time"

    if [ -f "$filepath" ]; then
      echo "$dir: $(cat "$filepath")"
    fi
  done
}

function echo_last_backups_less() {
  dirs=("bac-home" "bac-most" "bac-games")

  for dir in "${dirs[@]}"; do
    filepath="/etc/crenexi/crenexi@$(hostname)/$dir\.log"

    if [ -f "$filepath" ]; then
      echo "  $(cat "$filepath") | less -F"
    fi
  done
}

echo "#######################################"
echo "## LAST BACKUPS #######################"
echo "#######################################"
echo_last_backups
echo
echo "#######################################"
echo "## SEE MORE ###########################"
echo "#######################################"
echo "LAST BACKUP LOG"
echo_last_backups_less
echo "CRENEXI CRON LOG"
echo "  cat /etc/crenexi/cron.log | less -F"
echo "ROOT/USER CRONTABS"
echo "  sudo crontab -l"
echo "  chrontab -l"
echo "ALL/USER CHRON SYSLOG"
echo "  grep -E 'CRON.' /var/log/syslog | tail -n 300 | less -F"
echo "  grep -E 'CRON.*crenexi' /var/log/syslog | tail -n 300 | less -F"
echo
