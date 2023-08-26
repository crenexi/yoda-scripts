#!/bin/bash

splash_duration=2
dir_content="$HOME/.cx/bin/utils/content"

# Prints centered random quote from quotes.txt
function echo_random_quote() {
  quote_count=$(grep -cve '^\s*$' $dir_content/quotes.txt)

  if [[ $quote_count != 0 ]]; then
    quote_line=$((RANDOM % quote_count + 1))
    quote=$(sed "${quote_line}q;d" $dir_content/quotes.txt)

    echo "##/"
    echo "#/  $quote"
    echo "/"
  fi
}

function splash() {
  # Crenexi splash
  clear
  cat "$dir_content/art_crenexi.txt"
  cat "$dir_content/art_stitch.txt"
  sleep $splash_duration
  clear

  # Quote and ready
  echo_random_quote
  echo
}
