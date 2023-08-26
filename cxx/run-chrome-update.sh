#!/bin/bash

dir=$(dirname "$0")
source "$dir/../utils/echo-utils.sh"

sudo apt update

echo_info "Updating Chrome..."
sudo apt-get --only-upgrade install google-chrome-stable
sudo apt-get install libnss3

sudo pkill -15 -x "google-chrome" || true
sudo pkill -15 -x "chrome" || true

echo_success "Chrome update complete!"

exit
