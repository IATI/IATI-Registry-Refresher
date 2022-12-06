#!/bin/bash
# These are the commands used to update a git repository each night. If you
# wish to use it yourself, you will need to create a git 
# repository in the data/ and urls/ directories.
# 
# Full details of how this used to be deployed on IATI servers can be found in this
# state file, this is no longer used in practice:
# https://github.com/IATI/IATI-Websites/blob/master/salt/dashboard.sls

# Ensure that the current working directory is the one containing this file
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Update the git repository in data/ but do not try to merge
# Any merges (or rebases) have to be done manaully
# Remove all files from the data and urls directories, so that we can
# refetch them

cd data
git checkout automatic
git rm -r *
cd ..

cd urls
rm -r *
cd ..

# Run refresh
# use -l <int> to set limit to a few publishers for testing
python main.py -t refresh -l 10 &> logs/$(date +\%Y\%m\%d)-refresh.log

# Run reload and capture both STDIN and STDERR.
python main.py -t reload &> logs/$(date +\%Y\%m\%d)-reload.log

# Commit data
cd data/
git add .
git commit -a -m "Automatic data refresh"
cd ..

#### Post processing on our new data snapshot.
# Removing any lines below will not affect snapshot creation
# GIST=false ./validate.sh
