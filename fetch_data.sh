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

FILES=urls/*
for f in $FILES
do
  for url in `cat $f`; do
    # --no-check-certificate added to deal with sites using https - not the
    #                        best solution!
    # --restrict-file-names=nocontrol ensures that UTF8 files get created
    #                                 properly
    # -U sets our custom user agent, which allows sites to keep track of which
    #    robots are accessing them
    wget --no-check-certificate --restrict-file-names=nocontrol -P  data/`basename $f`/ -U "IATI-Registry-Refresher" "$url"
    # Fetch the exitcode of the previous command
    exitcode=$?
    # If the exitcode is not zero (ie. there was an error), output to STDIN
    if [ $exitcode -ne 0 ]; then
      echo $exitcode $f $url
    fi
    # Delay of 1 second between requests, so as not to upset servers
    sleep 1s
  done
done
