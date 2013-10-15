#!/bin/bash
# These are the commands used to update
# https://github.com/Bjwebb/IATI-Data-Snapshot each night. If you wish to use
# it yourself, you will need comment out, or change the gist commands and
# create a git repository in the data/ directory.

# Ensure that the current working directory is the one containing this file
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Update the git repository in data/ but do not try to merge
# Any merges have to be done manaully
cd data/
git checkout master
git pull --ff-only
git checkout automatic
git pull --ff-only

# Remove all files from the data and urls directories, so that we can refetch
# them
git rm -r *
cd ..
rm urls/*

# Run grab_urls.php
php grab_urls.php

# Run /fetch_data.sh and capture both STDIN and STDERR.
# Both of these are uploaded to github gist
./fetch_data.sh 2> debug > errors
# Prevent empty gist that won't be uploaded
echo "." >> errors
gist errors -u 6726204
gist debug -u 6726200

cd data/
# Ensure that we retain the README. Any other persistent files should be added
# here
git checkout master -- README.md
git add .

# Make the commit and push it
git commit -a -m "Automatic data refresh"
git push




#### Post processing on our new data snapshot.
# Removing any lines below will not affect snapshot creation

cd ..
GIST=true ./validate.sh
