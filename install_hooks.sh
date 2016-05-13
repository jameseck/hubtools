#!/bin/bash

[ "$1" == "" ] && echo "You must provide a path (either relative to the repo .git dir or absolute path) to the hook" && exit 1

for f in `find -maxdepth 1 -type d | grep -v ^\.$`; do
  [ ! -d "$f/.git" ] && continue
  [ -e "$f/.git/hooks/pre-commit" ] && continue
  ln -s $1 $f/.git/hooks/pre-commit
done
