#!/bin/bash
# Checkup on some specific cron jobs

# Cron logs over the past week
grep -E 'CRON.*crenexi' /var/log/syslog | grep "$(date -d '1 week ago' '+%b %e')"
