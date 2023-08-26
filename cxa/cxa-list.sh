#!/bin/bash

dir=$(dirname "$0")
source "$dir/../utils/echo-utils.sh"
source "$dir/helpers/define-dest.sh"

## Functions ##################################################################

function select_cmd_type() {
  local txt_list="Contents: List Dirs/Files"
  local txt_dirs="Dirs Only: List Directories"
  local txt_by_size="Largest: List Files By Size"
  local txt_images="Images: List Image Files"
  local txt_media="Media: List All Media"

  echo_header "COMMAND TYPE:" "clear"
  while true; do
    echo "1) $txt_list (DEFAULT)"
    echo "2) $txt_dirs"
    echo "3) $txt_by_size"
    echo "4) $txt_images"
    echo "5) $txt_media"
    read -p "Choose (1-5): " REPLY

    # Use the default option if the user just presses Enter
    [[ -z "$REPLY" ]] && REPLY=1

    case $REPLY in
      1) cmd_type="list"; break ;;
      2) cmd_type="dirs"; break ;;
      3) cmd_type="size"; break ;;
      4) cmd_type="images"; break ;;
      5) cmd_type="media"; break ;;
      *) echo "Invalid option. Please choose again." ;;
    esac
  done
}

function prompt_recursive() {
  if [[ $cmd_type != "dirs" ]]; then
    echo_header "RECURSIVE?" "clear"

    while true; do
      read -p "List recursively? (y/N): " input
      case $input in
        [yY]* )
          is_recursive="true"
          break ;;
        [nN]* | "" )
          is_recursive="false"
          break ;;
        * )
          echo "Invalid input. (yY, nN, Enter)"
          ;;
      esac
    done
  fi
}

function define_command() {
  aws_cmd="aws s3 ls"

  # Fail if command type or dest are undefined
  if [[ -z $cmd_type ]] || [[ -z $dest ]]; then
    echo "Error: cmd_type or dest are not defined."
    exit 1
  fi

  # Recursive option
  if [[ $is_recursive == "true" ]]; then
    aws_cmd+=" --recursive"
  fi

  case $cmd_type in
    "list")
      # List all files
      cmd_header="DIRS/FILES"
      aws_cmd+=" --human-readable $dest"
      ;;
    "dirs")
      # List directories only
      cmd_header="DIRECTORIES ONLY"
      aws_cmd+=" --human-readable $dest | grep 'PRE' | awk '{print $2}'"
      ;;
    "size")
      local human_readable="numfmt --field=3 --to=iec-i --suffix=B --padding=7"

      # List files by size
      cmd_header="FILES - SIZE DESCENDING"
      aws_cmd+=" $dest | sort -rhk 3 | $human_readable"
      ;;
    "images")
      local image_exts="jpg jpeg png webp svg gif"
      local image_regex="\.\("$(echo "$image_exts" | tr ' ' '|')"\)$"

      # List image filetypes only
      cmd_header="IMAGES ONLY"
      aws_cmd+=" --human-readable $dest | grep -iE '$image_regex'"
      ;;
    "media")
      # List all media types - images, audio, video, etc
      local media_exts="jpg jpeg png bmp tiff webp ico svg gif"
      media_exts+=" mp4 mkv flv avi mov webm ogg wmv mp3 wav m4a aac flac"

      local media_regex="\.\("$(echo "$media_exts" | tr ' ' '|')"\)$"

      # List media filetypes only
      cmd_header="MEDIA ONLY - IMAGES, VIDEO, AUDIO, ETC"
      aws_cmd+=" --human-readable $dest | grep -iE '$media_regex'"
      ;;
    *)
      echo_error "Invalid command type"
      exit 1
  esac
}

function exec_confirm() {
  echo "Review command to be executed:"
  echo_warn "$aws_cmd"
  read -p "Ready to proceed? (Y/n): " confirm

  if [[ -z "$confirm" || "$confirm" == [yY] ]]; then
    echo_header "$cmd_header" "clear"
    echo_info "## Reading: $dest"
    eval "$aws_cmd"
    echo_success "Listing complete"
  fi
}

## Main #######################################################################

define_dest
select_cmd_type
prompt_recursive
define_command
exec_confirm
