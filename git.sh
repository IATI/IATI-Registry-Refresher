#!/bin/bash
# These are the commands used to update a git repository each night. If you
# wish to use it yourself, you will need comment out, or change the gist
# commands and create a git repository in the data/ and urls/ directories.
# 
# Full details of how this is deployed on IATI servers can be found in this
# state file:
# https://github.com/IATI/IATI-Websites/blob/master/salt/dashboard.sls

# Ensure that the current working directory is the one containing this file
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Update the git repository in data/ but do not try to merge
# Any merges (or rebases) have to be done manaully
cd data/
# git checkout master # AKM If push isn't working, no point pulling 2022-08-17
# git pull --ff-only
git checkout automatic
# git pull --ff-only

# Remove all files from the data and urls directories, so that we can refetch
# them
git rm -r *
cd ..
cd urls
git rm -r *
cd ..

# Run grab_urls.php
php grab_urls.php

# Run /fetch_data.sh and capture both STDIN and STDERR.
# Both of these are uploaded to github gist
./fetch_data.sh 2> debug > errors
# Prevent empty gist that won't be uploaded
# *NJO 2021-11-04 this hasn't worked since 2017, commenting out
# echo "." >> errors
# gist errors -u 4f86dc7b36562c8b2b21
# gist debug -u 2fff388417fa0ca9509b

# Keep track of urls in a git repository also
cd urls/
git add .
git commit -a -m "Automatic data refresh"
# git push #NJO 2021-11-04 hasn't worked since 2016
cd ..

cd data/
# Ensure that we retain the README. Any other persistent files should be added
# here
# git checkout master # -- README.md - *NJO 2021-11-04 I accidentally deleted the readme so cutting this out
# AKM don't accidentally checkout master here 2022-08-17
git add .

# Make the commit and push it
git commit -a -m "Automatic data refresh"
# git push *NJO this doesn't work either




#### Post processing on our new data snapshot.
# Removing any lines below will not affect snapshot creation
# *NJO 2021-11-04 - don't use any of these gists
cd ..
GIST=false ./validate.sh

