#!/bin/bash

if [ "$1" == "fetch" ]; then
  [ "$2" == "" ] && par=8 || par=$2
  find -maxdepth 1 -type d | grep -v ^\.$ | xargs -P $par -I{} bash -c '[ -d {}/.git ] && echo "Fetching {}" && git -C {} fetch'
  echo
fi

for f in `find -maxdepth 1 -type d | grep -v ^\.$`; do
  if [ -d "$f/.git" ]; then
    behind=$(git -C $f log --oneline HEAD..origin | wc -l)
    ahead=$( git -C $f log --oneline origin..HEAD | wc -l)
    [ $behind -gt 0 ] && echo -e "\e[33m$f - Behind remote by ${behind} commit(s)\e[0m"
    [ $ahead -gt 0 ]  && echo -e "\e[34m$f - Ahead of remote by ${ahead} commit(s)\e[0m"
  fi
done
