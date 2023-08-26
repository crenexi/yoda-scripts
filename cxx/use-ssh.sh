#!/bin/bash

locations=()

## HELPERS ####################################################################

add_location() {
  local name=$1
  local pem_path=$2
  local ssh_url=$3

  locations+=("$name:$pem_path:$ssh_url")
}

## CONFIG #####################################################################
## Define SSH locations: add_location <name> <pem-path> <ssh-url>

add_location "crenexi-api" \
  "~/.ssh/ec2/ec2crenexicom.pem" \
  "ubuntu@ec2-34-201-224-176.compute-1.amazonaws.com"

## Main #######################################################################

PS3="Select the location: "
select location in "${locations[@]}"; do
  case $location in
    *)
      # Split the location location using ':' as the delimiter
      IFS=':' read -r -a location <<< "$location"

      # Retrieve the specific location from the array
      name=${location[0]}
      pem_path=${location[1]}
      ssh_url=${location[2]}

      # SSH into the selected location
      ssh -i "$pem_path" "$ssh_url"
      break;;
  esac
done
