#!/bin/bash

uptime_text=$(uptime | awk -F, '{print $1}' | awk '{$1=$1};1')
cpu_usage=$(top -bn1 | awk '/Cpu\(s\):/ {print $2 + $4}')
memory_usage=$(free -g | awk '/Mem:/ {print $3}')
uname_text=$(uname -a | awk '{print $1, $2, $3, $4}')
ip_text=$(ip addr show | awk '/inet / && $2 !~ /^127\.0\.0\.1/ {split($2, a, "/"); print a[1]}')

du_root=$(df -h --output=pcent / | awk 'NR==2{print $1}')
du_home=$(df -h --output=pcent "$HOME" | awk 'NR==2{print $1}')

function echo_du_dir() {
  dir=$1

  if [ -d "$dir" ]; then
    du=$(df -h --output=pcent $dir | awk 'NR==2{print $1}')
    echo "Disk Usage for $dir: $du"
  fi
}

echo "## UPTIME & USAGE #############################################"
echo "Uptime: $uptime_text"
echo "CPU Usage: $cpu_usage%"
echo "Memory Usage: $memory_usage GB"

echo "## STORAGE ####################################################"
echo "Disk Usage for /: $du_root"
echo "Disk Usage for $HOME/: $du_home"
echo_du_dir "/hdd"
echo_du_dir "/pandora/crenexi"

echo "## MISC #######################################################"
echo "IP Address: $ip_text"
echo "Info: $uname_text"
