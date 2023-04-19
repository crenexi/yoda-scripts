template_dir="./templates/react-container"

comp_dest=${1%/}
comp_name=$2

info () {
  printf "## ${1}\n"
}

# Ensure args are provided
if [[ -z "$comp_dest" ]] || [[ -z "$comp_name" ]]; then
  info "MUST INCLUDE DIRECTORY AND NAME ARGUMENTS"
  info "Example: cxr-container ./src/shared/components/ui"
  exit 1
fi

# Ensure dest has end slash


# Start
comp_dir="$comp_dest/$comp_name"
info "Creating $comp_dir component-with-container"

# Component folder
mkdir -p $comp_dir

# Component files
sed -e "s/NAME/$comp_name/g" $template_dir/template_index.js > $comp_dir/index.js
sed -e "s/NAME/$comp_name/g" $template_dir/template_NAMEContainer.jsx > $comp_dir/${comp_name}Container.jsx
sed -e "s/NAME/$comp_name/g" $template_dir/template_NAME.jsx > $comp_dir/$comp_name.jsx
sed -e "s/NAME/$comp_name/g" $template_dir/template_NAME.scss > $comp_dir/$comp_name.scss

# Done
info "$comp_name component-with-container ready"
