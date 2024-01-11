#!/bin/bash

# Error if jq not installed
function ensure_jq_installed() {
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it and try again."
    exit 1
  fi
}

# Read JSON into comma-delimited string
function init_template_keys() {
  local group="$1"

  if [[ -z "$group" ]]; then
    echo "Error: Template group is not provided."
    exit 1
  fi

  template_keys=$(jq -r ".${group} | join(\",\")" "$dir/templates/templates.json")
}
