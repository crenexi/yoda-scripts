# Utility colors
cred="\e[1;31m"
cgreen="\e[1;32m"
cyellow="\e[1;33m"
cblue="\e[1;34m"
cmagenta="\e[1;35m"
ccyan="\e[1;36m"
cend="\e[0m"

# Utility echos
echo_info () { echo -e "${cblue}${1}${cend}"; }
echo_success() { echo -e "${cgreen}${1}${cend}"; }
echo_warn() { echo -e "/!\ ${cyellow}${1}${cend}"; }
echo_error() { echo -e "/!\ ${cred}${1}${cend}"; }
echo_header() {
  message="$1"
  color="$2"
  echo "##########"
  echo -e "## ${color}${message}${cend}"
}
