#!/bin/bash
#
#      fetch_data.sh
#
#      Copyright 2012 caprenter <caprenter@gmail.com>
#
#      This file is part of IATI Registry Refresher.
#
#      IATI Registry Refresher is free software: you can redistribute it and/or modify
#      it under the terms of the GNU General Public License as published by
#      the Free Software Foundation, either version 3 of the License, or
#      (at your option) any later version.
#
#      IATI Registry Refresher is distributed in the hope that it will be useful,
#      but WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#      GNU General Public License for more details.
#
#      You should have received a copy of the GNU General Public License
#      along with IATI Registry Refresher.  If not, see <http://www.gnu.org/licenses/>.
#
#      IATI Registry Refresher relies on other free software products. See the README.txt file
#      for more details.
#

# Set the internal field seperator to newline, so that we can loop over newline
# seperated url lists correctly.
IFS=$'\n'

# Make Commands
FILES=urls/*
for f in $FILES
do
  for url_line in `cat $f`; do
    url=`echo $url_line | sed 's/^[^ ]* //'`
    package_name=`echo $url_line | sed 's/ .*$//'`
    mkdir -p data/`basename $f`/

    # --restrict-file-names=nocontrol ensures that UTF8 files get created
    #                                 properly
    # -U sets our custom user agent, which allows sites to keep track of which
    #    robots are accessing them
    # --read-timeout=30 times out if no data is sent for more than 30 seconds
    # --dns-timeout=10 times out if DNS information takes longer than 10 seconds
    # --connect-timeout=10 times out if establishing a connection takes longer
    #                      than 10 seconds
    # --tries=3 means a download is tried at most 3 times
    # --retry-connrefused  means that connection refused errors will be treated
    #                      as transient errors and retried
    echo "wget --header \"Accept: application/xhtml+xml,application/xml,*/*;q=0.9\" --restrict-file-names=nocontrol --tries=3 --read-timeout=30 --dns-timeout=10 --connect-timeout=10 -U \"IATI-Data-Snappshotter\" --retry-connrefused \"$url\" -O data/`basename $f`/$package_name; test \"\$?\" != 0 && echo \$? `basename $f` $url_line " >> tmp_download_commands
  done
done

# Run commands in parallel
(cat tmp_download_commands | sort -R | parallel -j5) || true

# Delete tmp command file
rm tmp_download_commands
