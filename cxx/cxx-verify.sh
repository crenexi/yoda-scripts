#!/bin/bash

numMissing=0

function missing() {
    ((numMissing++))
    echo "/!\ MISSING: $1"
}

function verify() {
    eval "which $1" || missing $1
}

verify "git"
verify "htop"
verify "trash"
verify "cmatrix"
verify "curl"
verify "wmctrl"
verify "baobab"
verify "chrome-gnome-shell"
verify "spotify"
verify "code"

printf "\nMISSING: $numMissing\n"
echo "DONE VERIFYING"
