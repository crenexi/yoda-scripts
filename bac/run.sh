# This runs all backup scripts
source /home/crenexi/.bashrc

/home/crenexi/bin/bac/bac-home.sh >> /etc/crenexi/cron.log 2>&1
/home/crenexi/bin/bac/bac-most.sh >> /etc/crenexi/cron.log 2>&1
/home/crenexi/bin/bac/bac-games.sh >> /etc/crenexi/cron.log 2>&1
