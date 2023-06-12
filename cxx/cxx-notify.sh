#!/bin/bash
# format: cxx-notify.sh [title] [message]

# Ensure notify-send exists
if ! command -v "notify-send" >/dev/null 2>&1; then
  echo "Package 'notify-send' is not found. Exiting."
  exit 1
fi

function notify() {
  # Ensure this is Ubuntu and notify-send exists
  if [[ "$(lsb_release -si)" == "Ubuntu" ]] && command -v notify-send >/dev/null 2>&1; then
    # Detect the name of the display in use and the user using the display
    local display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"
    local user=$(who | grep '('$display')' | awk '{print $1}' | head -n 1)
    local uid=$(id -u $user)

    # Crenexi-themed alert
    icon="/home/crenexi/Documents/System-Assets/Icons/crenexi_fav_main.png"
    su -c "DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send -u normal -t 5000 -i \"$icon\" \"$1\" \"$2\"" -s /bin/sh $user
  fi
}

notify "$@"
