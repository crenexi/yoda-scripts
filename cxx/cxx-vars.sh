#!/bin/bash

function var_is() {
  printf "%-20s %s\n" "$1:" "$2"
}

var_is "USER" $USER
var_is "HOME" $HOME
var_is "SHELL" $SHELL
var_is "XDG_SESSION_TYPE" $XDG_SESSION_TYPE
