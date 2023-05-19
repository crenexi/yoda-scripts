#!/bin/bash
# Checkup on some specific cron jobs

echo "#######################################"
echo "## RECENT CRENEXI CRONS ###############"
echo "#######################################"
grep -E 'CRON.*crenexi' /var/log/syslog | tail -n 100

echo "#######################################"
echo "## CRENEXI CRONS ######################"
echo "#######################################"
crontab -l
