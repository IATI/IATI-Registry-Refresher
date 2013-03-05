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
FILES=urls/*
for f in $FILES
do
  
  echo "Processing $f file..."
  # --no-check-certificate added to deal with sites using https - not the best solution!
  wget --no-check-certificate -P  data/`basename $f`/ -i "$f"  
  # take action on each file. $f store current file name
  #cat $f
done
