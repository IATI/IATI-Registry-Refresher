IATI Registry Refresher
=======================

[![License: MIT](https://img.shields.io/badge/license-GPLv3-blue.svg)](https://github.com/IATI/IATI-Registry-Refresher#licence)

Introduction
------------

This small application allows you to query the CKAN implementation at iatiregistry.org
to find all 'end point' urls of data recorded on the registry, and to then download that data.

The registry holds records about where data can be found on the internet.

The application is basically 2 scripts that you run one after the other.

`python main.py -t refresh` 
queries the registry and creates a text file for each group on the registry of all url end points of IATI data files

`python main.py -t reload` 
pulls all the data from those url text files and deposit them in their own directory.


Requirements
------------
IATI Registry Refresher requires Python 3.10 or later

It also requires curl.
on Ubuntu 
```
sudo apt-get install curl
```


Installation and usage
----------------------

Place all files in the same directory.
Create an empty directories called `urls`, `data` and `ckan`
```
mkdir urls data ckan
```

From a terminal

```
# Create a virtual environment (recommended)
virtualenv pyenv
source pyenv/bin/activate
# Install python dependencies
pip install -r requirements.txt
```

```
# Run the applications
python main.py -t refresh 
python main.py -t reload
```


(if you want to set up your own paths edit the paths set in PUBLISHER_META_DIR, URL_DIR.)
This gives the data endpoints for all the files in the IATI registry (see 
http://iatiregistry.org/)

Run reload to get all the data.
(In a terminal type `python main.py -t reload`) 
(if you want to set up your own paths edit the paths set in PUBLISHER_META_DIR, URL_DIR, and DATA_DIR.)


Creating a git data snapshot
----------------------------

The code in `git.sh` can be used to update a git repository (in the data directory) with a new commit each time it is run. The IATI Tech Team maintains a git repository with nightly snapshot commits, but it is not public, see https://github.com/IATI/IATI-Stats#getting-some-data-to-run-stats-on


Bugs, issues and feature requests
--------------------------------

If you find any bugs, note any issues or have any feature requests, please
report them at https://github.com/IATI/IATI-Registry-Refresher

License
-------

``` 
Copyright 2012 caprenter <caprenter@gmail.com>
Copyright 2022 nosvalds <nik@nikolaso.com>

This file is part of IATI Registry Refresher.
     
IATI Registry Refresher is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
    
IATI Registry Refresher is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
    
You should have received a copy of the GNU General Public License
along with IATI Registry Refresher.  If not, see <http://www.gnu.org/licenses/>.
```
