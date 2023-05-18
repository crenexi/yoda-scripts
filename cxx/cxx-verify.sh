#!/bin/bash

numMissing=0

function missing() {
    ((numMissing++))
    printf "/!\ MISSING: $1\n"
}

function verify() {
    eval "which $1" || missing $1
}

printf "VERIFYING BIN\n"

verify "git"
verify "htop"
verify "cmatrix"
verify "curl"
verify "wmctrl"
verify "baobabz"
verify "chrome-gnome-shell"
verify "dropbox"
verify "spotify"
verify "code"

printf "MISSING: $numMissing\n"
printf "DONE VERIFYING\n"
