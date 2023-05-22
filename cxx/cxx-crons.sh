#!/bin/bash
# Checkup on some specific cron jobs

echo "#######################################"
echo "## CRONS | ROOT #######################"
echo "#######################################"
sudo crontab -l

echo "#######################################"
echo "## CRONS | CRENEXI ####################"
echo "#######################################"
crontab -l

echo "#######################################"
echo "## CRONS | LOG TAIL ###################"
echo "#######################################"
grep -E 'CRON.*crenexi' /var/log/syslog | tail -n 300 | less -F
