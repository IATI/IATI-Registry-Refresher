#!/bin/bash
cd "$( dirname "${BASH_SOURCE[0]}" )"
cd data/
git checkout master
git pull --ff-only
git checkout automatic
git pull --ff-only
git rm -r *
cd ..
rm urls/*
php grab_urls.php
./fetch_data.sh
cd data/
git checkout master -- README.md
git add .
git commit -a -m "Automatic data refresh"
git push

