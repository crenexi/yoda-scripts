#!/bin/bash

dir=$(dirname "$0")
source "$dir/../utils/splash.sh"
source "$dir/../utils/echo-utils.sh"

function sync_origin() {
  echo_info "Pruning and fetching origin..."
  git remote prune origin
  git fetch
}

function sync_deleted_branches() {
  read -p "Delete local branches that have been deleted on the remote? [y/n]: " -n 1 -r

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Delete local branches that have been deleted on the remote
    git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | while read branch; do git branch -D "$branch"; done
  fi
}

function echo_local_branches() {
  echo "Local branches:"
  echo 'FEATURES:'
  git branch -a | grep 'feature/'

  echo 'BUGFIXES:'
  git branch -a | grep 'bugfix/'

  echo 'HOTFIXES:'
  git branch -a | grep 'hotfix/'

  echo 'RELEASES:'
  git branch -a | grep 'release/'
}

sync_origin
sync_deleted_branches
echo_local_branches
echo_random_quote
