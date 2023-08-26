#!/bin/bash
set -e

dir=$(dirname "$0")
source "$dir/helpers/helpers.sh"

name="$1"
dest="$2"

## MAIN #######################################################################

template_group="component"

ensure_jq_installed
init_template_keys "$template_group"
eval "$dir/helpers/cp-template.sh \"$name\" \"$dest\" \"$template_keys\""
