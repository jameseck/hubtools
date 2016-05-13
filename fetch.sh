#!/bin/bash

curl -s https://api.github.com/orgs/1and1internet/repos\?per_page\=200 | perl -ne 'print "$1\n" if (/"ssh_url": "([^"]+)/)' | xargs -n 1 git clone"
