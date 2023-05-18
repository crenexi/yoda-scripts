#!/bin/bash

# Ensure directories exist
mkdir -p "$HOME/bin/bac/"

# Start entry
cp -r ./bac-start.sh $HOME/bin/bac/
find ~/bin/bac/**/* -type f -name "*.sh" -exec chmod 755 -- {} +

# Start folder
cp -r ./bac-start/ $HOME/bin/bac/

chmod 755 $HOME/bin/bac/bac-start.sh

source $HOME/.bashrc
