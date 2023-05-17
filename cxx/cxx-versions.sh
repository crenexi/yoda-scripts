#!/bin/bash

function version() {
	echo "##/ VERSION OF $1:"
	eval $2
  echo
}

version "UBUNTU" "lsb_release -a"
version "GIT" "git --version"
version "NODE" "node --version"
version "NPM" "npm --version"
version "POSTGRESQL" "pg_lsclusters"
