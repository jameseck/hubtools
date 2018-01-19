#!/bin/sh

USER=jameseck
NEW=0

for repo in $(curl -s "https://api.github.com/users/${USER}/repos?per_page=100" | grep -o 'git@[^"]*'); do
  dir=$(echo $repo | sed -e "s/^git@github.com:${USER}\///" -e 's/\.git$//')
  if [ ! -d $dir ]; then
    NEW=1
    mkdir $dir
  fi
  if [ "${NEW}" == "1" ]; then
    echo "Cloning repo: $repo"
    git clone $repo $dir
  else
    echo "Updating repo: $repo"
    pushd . > /dev/null
    cd $dir
    git remote update
    git pull --all
    popd > /dev/null
  fi
done


#for d in `find -maxdepth 1 -type d -not -iname '.'`; do
#  if [ -d "$d/.git" ]; then
#    echo "Processing $d"
#    pushd . > /dev/null
#    cd $d
#    git pull
#    popd
#  fi
#done
