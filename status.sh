#!/bin/bash

for f in `find -maxdepth 1 -type d | grep -v ^\.$`; do
  if [ -d "$f/.git" ]; then
    cd $f
    if [ "$?" != "0" ]; then
      echo "Unable to cd to $f"
      next
    fi
    [ "$1" == "fetch" ] && git fetch
    behind=$(git log --oneline HEAD..origin | wc -l)
    ahead=$( git log --oneline origin..HEAD | wc -l)
    [ $behind -gt 0 ] && echo "$f - Behind remote by ${behind} commit(s)"
    [ $ahead -gt 0 ] && echo "$f - Ahead of remote by ${ahead} commit(s)"
    cd ..
  fi
done
