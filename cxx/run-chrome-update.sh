#!/bin/bash

sudo apt update
sudo apt-get --only-upgrade install google-chrome-stable
sudo apt-get install libnss3

sudo pkill -15 -x "google-chrome" || true
sudo pkill -15 -x "chrome" || true

echo "CHROME UPDATE COMPLETE!"

exit
