#!/bin/bash

for f in `find -maxdepth 1 -type d | grep -v ^\.$`; do
  echo $f
  [ -d "$f/.git" ] && git -C $f remote update
done
