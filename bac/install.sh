#!/bin/bash

# Ensure directories exist
mkdir -p "$HOME/bin/bac/"

# Backup most
cp -r ./bac-most.sh $HOME/bin/bac/
cp -r ./bac-most/ $HOME/bin/bac/
chmod 755 $HOME/bin/bac/bac-most.sh

# Backup home
cp -r ./bac-home.sh $HOME/bin/bac/
cp -r ./bac-home/ $HOME/bin/bac/
chmod 755 $HOME/bin/bac/bac-home.sh

# Make sh executable
find ~/bin/bac/**/* -type f -name "*.sh" -exec chmod 755 -- {} +

source $HOME/.bashrc
