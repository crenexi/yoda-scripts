#!/bin/bash
# Checkup on some specific cron jobs

echo "#######################################"
echo "## LAST BACKUPS #######################"
echo "#######################################"
echo "HOME:               $(cat /etc/crenexi/crenexi@victory/bac-home_time)"
echo "MOST:               $(cat /etc/crenexi/crenexi@victory/bac-most_time)"
echo "GAMES:              $(cat /etc/crenexi/crenexi@victory/bac-games_time)"
echo
echo "#######################################"
echo "## SEE MORE ###########################"
echo "#######################################"
echo "LAST BACKUP LOG"
echo "  cat /etc/crenexi/crenexi@$(hostname)/bac-home.log | less -F"
echo "  cat /etc/crenexi/crenexi@$(hostname)/bac-most.log | less -F"
echo "  cat /etc/crenexi/crenexi@$(hostname)/bac-games.log | less -F"
echo "CRENEXI CRON LOG"
echo "  cat /etc/crenexi/cron.log | less -F"
echo "ROOT/USER CRONTABS"
echo "  sudo crontab -l"
echo "  chrontab -l"
echo "ALL/USER CHRON SYSLOG"
echo "  grep -E 'CRON.' /var/log/syslog | tail -n 300 | less -F"
echo "  grep -E 'CRON.*crenexi' /var/log/syslog | tail -n 300 | less -F"
echo
