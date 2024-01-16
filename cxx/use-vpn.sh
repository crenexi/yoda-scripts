#!/bin/bash

dir=$(dirname "$0")
source "$dir/../utils/echo-utils.sh"

## CONFIG #####################################################################

credentials="$HOME/.nordvpn-config"
openvpn_dir="/etc/openvpn/ovpn_udp/"
server="us9680"
proto="udp"

## HELPERS ####################################################################

# Error cleanup
function error() {
  message=${1:-"Unknown error."}
  echo_error "$message"
  exit 1
}

# Function to disconnect VPN
function disconnect_vpn() {
  echo "Disconnecting VPN..."
  sudo killall openvpn
  sleep 2
  exit 0
}

function cleanup_on_exit() {
  # Your cleanup code here, like removing temp files
  [[ -n $credentials_temp_file ]] && rm -f "$credentials_temp_file"
  exit 0
}

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
  openvpn_pid=$!
  wait $openvpn_pid
}

## MAIN #######################################################################

trap cleanup_on_exit SIGINT

case "$1" in
  stop)
    disconnect_vpn
    exit 0
    ;;
  *)
    verify_credentials
    store_credentials
    open_vpn

    # 2s before tmp credentials file is deleted
    sleep 2
    ;;
esac
