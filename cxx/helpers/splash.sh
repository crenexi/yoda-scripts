#!/bin/bash

# Prints centered random quote from quotes.txt
function echo_random_quote() {
  quote_count=$(grep -cve '^\s*$' ./content/quotes.txt)
  quote_line=$((RANDOM % quote_count + 1))
  quote=$(sed "${quote_line}q;d" ./content/quotes.txt)

  echo "##/"
  echo "#/  $quote"
  echo "/"
}

# Crenexi splash
clear
cat './content/art_crenexi.txt'
cat './content/art_stitch.txt'
sleep 1
clear

# Quote and ready
echo_random_quote
echo
