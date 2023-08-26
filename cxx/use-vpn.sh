openvpn_dir="/etc/openvpn/ovpn_udp/"
server=${1:-"us5695"}
proto=${2:-"udp"}

credentials="$HOME/.nordvpn-config"

dir=$(dirname "$0")
source "$dir/../utils/echo-utils.sh"

## HELPERS ####################################################################

# Check if the credentials file exists
function check_credentials_dne() {
  if [[ ! -f $credentials ]]; then
    echo "NordVPN config file not found."
    exit 1
  fi
}

# Read username and password, and verify
function verify_credentials() {
  read -r username < "$credentials"
  read -r password < "$credentials"

  # Check if the username or password is empty
  if [[ -z $username ]] || [[ -z $password ]]; then
    echo "NordVPN username or password is missing."
    exit 1
  fi
}

# Temp file to store credentials
function store_credentials() {
  credentials_temp_file=$(mktemp)
  chmod 200 "$credentials_temp_file"
  printf "%s\n%s" "$username" "$password" > "$credentials_temp_file"
}

function open_vpn() {
  sudo openvpn --config "$openvpn_dir$server.nordvpn.com.$proto.ovpn" --auth-user-pass "$credentials_temp_file"

  # Clean up the temporary file
  rm "$credentials_temp_file"
  exit 0
}

## MAIN #######################################################################

check_credentials_dne
verify_credentials
store_credentials
open_vpn
