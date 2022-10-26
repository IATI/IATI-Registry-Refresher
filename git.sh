#!/bin/bash
# These are the commands used to update a git repository each night. If you
# wish to use it yourself, you will need to create a git 
# repository in the data/ and urls/ directories.
# 
# Full details of how this is deployed on IATI servers can be found in this
# state file:
# https://github.com/IATI/IATI-Websites/blob/master/salt/dashboard.sls

# Ensure that the current working directory is the one containing this file
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Update the git repository in data/ but do not try to merge
# Any merges (or rebases) have to be done manaully
# Remove all files from the data and urls directories, so that we can
# refetch them

cd data
git checkout main
git rm -r *
cd ..

cd urls
git checkout main
git rm -r *
cd ..

# Run refresh
# use -l 10 to set limit to 10 publishers for testing
python main.py -t refresh &> logs/$(date +\%Y\%m\%d)-refresh.log

# Commit url changes
cd urls/
git add .
git commit -a -m "Automatic data refresh"
cd ..

# Run reload and capture both STDIN and STDERR.
python main.py -t reload &> logs/$(date +\%Y\%m\%d)-reload.log

cd data/
git add .

# Make the commit 
git commit -a -m "Automatic data refresh"
cd ..

#### Post processing on our new data snapshot.
# Removing any lines below will not affect snapshot creation
# GIST=false ./validate.sh
