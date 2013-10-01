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
./fetch_data.sh 2> debug > errors
gist errors -u 6726204
gist debug -u 6726200
cd data/
git checkout master -- README.md
git add .
git commit -a -m "Automatic data refresh"
git push

cd ..
xmllint data/*/* > /dev/null 2> xmlerrors
gist xmlerrors -u 6726333

for f in data/*/*; do echo "`xmllint --xpath "name(/*)" "$f"` $f"; done > topelements
cat topelements | grep -v iati-activities | grep -v iati-organisations > nonstandardroots
gist -u 6728773 nonstandardroots 

for f in data/*/*; do echo "`xmllint --xpath "string(/*/@version)" "$f"` $f"; done > versions
awk -F '[ ]' '{print $1}' versions | sort | uniq -c > 0_versions-summary
gist -u 6729360 0_versions-summary versions

