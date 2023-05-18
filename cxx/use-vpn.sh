openvpn_dir="/etc/openvpn/ovpn_udp/"
server=${1:-"us5695"}
proto=${2:-"udp"}

credentials="$HOME/.nordvpn-config"

# Check if the credentials file exists
if [[ ! -f $credentials ]]; then
  echo "NordVPN config file not found."
  exit 1
fi

# Read the username and password from the config file
read -r username < "$credentials"
read -r password < "$credentials"

# Check if the username or password is empty
if [[ -z $username ]] || [[ -z $password ]]; then
  echo "NordVPN username or password is missing."
  exit 1
fi

# Create a temporary file to store credentials
credentials_temp_file=$(mktemp)
chmod 200 "$credentials_temp_file"
printf "%s\n%s" "$username" "$password" > "$credentials_temp_file"

sudo openvpn --config "$openvpn_dir$server.nordvpn.com.$proto.ovpn" --auth-user-pass "$credentials_temp_file"

# Clean up the temporary file
rm "$credentials_temp_file"
exit
