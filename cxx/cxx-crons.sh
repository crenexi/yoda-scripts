#!/bin/bash
# Checkup on some specific cron jobs

echo "#######################################"
echo "## CRONS | ROOT #######################"
echo "#######################################"
su -c "crontab -l" root

echo "#######################################"
echo "## CRONS | ROOT | LOG TAIL ############"
echo "#######################################"
grep -E 'CRON.*root' /var/log/syslog | tail -n 100

echo "#######################################"
echo "## CRONS | CRENEXI ####################"
echo "#######################################"
crontab -l

echo "#######################################"
echo "## CRONS | CRENEXI | LOG TAIL #########"
echo "#######################################"
grep -E 'CRON.*crenexi' /var/log/syslog | tail -n 100
