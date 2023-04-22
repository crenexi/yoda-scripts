#!/bin/bash
# The script assumes that the template_dir directory exists and has some
# specific files with placeholders for NAME.

##########
## HELPERS

# Utility colors
cred="$\e[1;31m"
cgreen="$\e[1;32m"
cblue="$\e[1;34m"
cend="$\e[0m"

# Utility echos
echo_info () { printf "${cblue}${1}${cend}\n" }
echo_success() { printf "${cgreen}${1}${cend}\n" }
echo_error() { printf "/!\ ${cred}${1}${cend}\n" }

# Ensure args are provided
if [[ -z "$comp_dest" ]] || [[ -z "$comp_name" ]]; then
  echo_error "MUST INCLUDE DIRECTORY AND NAME ARGUMENTS"
  echo "Example: cxr-container ./src/shared/components/ui"
  exit 1
fi

##########
## CONFIG

template_dir="./templates/react-container"

##########
## MAIN

comp_dest=${1%/}
comp_name=$2
comp_dir="$comp_dest/$comp_name"

# Component folder
echo_info "Creating $comp_dir component-with-container"
mkdir -p "$comp_dir"

# Component files
sed -e "s/NAME/$comp_name/g" "$template_dir/template_index.js" > "$comp_dir/index.js"
sed -e "s/NAME/$comp_name/g" "$template_dir/template_NAMEContainer.jsx" > "$comp_dir/${comp_name}Container.jsx"
sed -e "s/NAME/$comp_name/g" "$template_dir/template_NAME.jsx" > "$comp_dir/$comp_name.jsx"
sed -e "s/NAME/$comp_name/g" "$template_dir/template_NAME.scss" > "$comp_dir/$comp_name.scss"

# Done
echo_success "$comp_name component-with-container ready"
