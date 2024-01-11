#!/bin/bash

function focusSpotify {
  wmctrl -a "Spotify Premium"
}

# check if spotify is already running
if pgrep -x "spotify" > /dev/null; then
  focusSpotify
else
	spotify &
  sleep 1s && focusSpotify
fi

exit
