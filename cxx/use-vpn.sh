#!/bin/bash

dir=$(dirname "$0")
source "$dir/../utils/echo-utils.sh"

## CONFIG #####################################################################

credentials="$HOME/.nordvpn-config"
openvpn_dir="/etc/openvpn/ovpn_udp/"
server=${1:-"us9680"}
proto=${2:-"udp"}

## HELPERS ####################################################################

# Error cleanup
function error() {
  message=${1:-"Unknown error."}
  echo_error "$message"
  exit 1
}

# Graceful cleanup
function cleanup() {
  echo "System going to sleep, disconnecting VPN..."
  exit 0
}
trap cleanup SIGTERM SIGHUP

## FUNCTIONS ##################################################################

function verify_credentials() {
  # Ensure file exists
  if [[ ! -f $credentials ]]; then
    error "NordVPN config file not found."
    echo "Create file at \'\$HOME/.nordvpn-config\'"
  fi

  # Get and verify credentials
  username=$(grep -oP 'username=\K.*' "$credentials")
  password=$(grep -oP 'password=\K.*' "$credentials")
  if [[ -z $username ]] || [[ -z $password ]]; then
    error "NordVPN username or password is missing."
  fi
}

# Temp file to store credentials
function store_credentials() {
  credentials_temp_file=$(mktemp)
  chmod 600 "$credentials_temp_file"
  printf "%s\n%s" "$username" "$password" > "$credentials_temp_file"
}

# Start the VPN
function open_vpn() {
  config_file="$openvpn_dir$server.nordvpn.com.$proto.ovpn"

  if [[ ! -f $config_file ]]; then
    error "Config file $config_file not found."
  fi

  sudo openvpn --config "$config_file" --auth-user-pass "$credentials_temp_file"
}

## MAIN #######################################################################

# Cleanup in case of an error
trap '[[ -n $credentials_temp_file ]] && rm -f "$credentials_temp_file"' EXIT

verify_credentials
store_credentials
open_vpn

# 1m before tmp credentials file is deleted
sleep 60
