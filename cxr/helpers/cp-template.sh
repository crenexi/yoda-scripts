#!/bin/bash
set -e

dir=$(dirname "$0")
source "$dir/../../utils/echo-utils.sh"

## HELPERS ####################################################################

# Ensure args are provided
function ensure_args() {
  comp_name="$1"
  comp_dest="${2%/}"
  template_keys="$3"

  # Ensure template keys supplied
  if [[ -z "$template_keys" ]]; then
    echo_error "TEMPLATE KEYS NOT SUPPLIED!"
    exit 1
  else
    # Convert from string to array
    IFS=',' read -ra template_keys <<< "$template_keys"
  fi

  # Ensure user-provided component name and destination
  if [[ -z "$comp_dest" ]] || [[ -z "$comp_name" ]]; then
    echo_error "MUST INCLUDE COMPONENT NAME AND DIRECTORY!"
    echo "Usage: cxr-<type> <name> <destination>"
    exit 1
  fi
}

# Verify again if comp_dir exists
function verify_overwrite() {
  if [[ -d "$comp_dir" ]]; then
    echo_warn "## Directory $comp_dir already exists!"
    read -p "Overwrite? (Y/n) " input
    case "$input" in
      [nN])
        echo "Exiting without overwriting."
        exit 0 ;;
    esac
  fi
}

function ensure_template_dir() {
  if [[ ! -d "$template_dir" ]]; then
    echo_error "The template directory '$template_dir' does not exist!"
    exit 1
  fi
}

# List templates
function list_template_keys() {
  local index=1
  for key in "${template_keys[@]}"; do
    echo "$index) $key"
    index=$((index + 1))
  done
}

## FUNCTIONS ##################################################################

# Get the template key from user
function select_template_key() {
  while true; do
    echo_header "TEMPLATE" "clear"
    list_template_keys

    # Template choice index
    read -p "Choose: " input
    local index=$((input - 1))

    # Check if the choice is valid
    if (( index >= 0 )) && (( index < ${#template_keys[@]} )); then
      sel_template="${template_keys[$index]}"
      templates_dir="$(cd "$dir/.." && pwd)/templates"
      template_dir="$templates_dir/$sel_template"

      # Make sure template exists
      ensure_template_dir
      break
    else
      echo_error "Invalid choice! Try again."
    fi
  done
}

# Verify the action
function verify_action() {
  echo_header "CONFIRM" "clear"
  echo -e "## Template: $templates_dir/${cmagenta}${sel_template}${cend}"
  echo -e "## Component: $comp_dest/${cmagenta}${comp_name}${cend}"
  read -p "Continue? (Y/n) " choice

  case "$choice" in
    n|N ) exit 0;;
    * ) ;;
  esac
}

# Create component files
function create_component() {
  # Create base directory
  comp_dir="$comp_dest/$comp_name"
  verify_overwrite
  mkdir -p "$comp_dir"

  # Copy all template files (*.tlp.*) to destination
  find "$template_dir" -type f -name "*.tpl.*" | while read -r file; do
    relative_path="${file#$template_dir/}" # relative path
    dest_file="$comp_dir/${relative_path/.tpl./.}" # dest file
    dest_file="${dest_file/NAME/$comp_name}" # replace NAME placeholder
    mkdir -p "$(dirname "$dest_file")" # ensure dest dir exists
    sed -e "s/NAME/$comp_name/g" "$file" > "$dest_file" # placeholder edit
  done
}

function on_complete() {
  clear
  echo_success "Created $comp_name component"
  echo "## from '$sel_template' template"
  echo "## at '$(realpath $comp_dir)'"
  echo "##\\"
  ls -AF1 --color=auto --group-directories-first "$comp_dir";
  echo "##/"
  echo "#/"
  echo "/"
}

## MAIN #######################################################################

ensure_args "$1" "$2" "$3"
select_template_key
verify_action
create_component
on_complete
