IATI Registry Refresher
=======================

This small aplication allows you to query the CKAN implementation at iatiregistry.org
to find all 'end point' urls of data recorded on the registry, and to then download that data.

The registry holds records about where data can be found on the interent.

The application is basically 2 scripts that you run one after the other.

`grab_urls.php` 
queries the registry and creates a text file for each group on the registry of all url end points of IATI data files

`fetch_data.sh`
uses wget to pull all the data from those url text files and deposit them in their own directory.



Requirements
------------
IATI Registry Refresher requires PHP version 5.2.0 or later.

It also requires curl.
on Ubuntu 
```
sudo apt-get install curl
sudo apt-get install php5-curl
```


Installation and usage
----------------------

Place all files in the same directory.
Create an empty directories called `urls` and `data`, e.g.
```
mkdir urls data ckan
```

From a terminal, use php-cli to run:
```
php grab_urls.php
```
(if you want to set up your own paths, copy this file to e.g. ` grab_my_urls.php` and edit the paths.)
This gives the data endpoints for all the files in the IATI registry (see 
http://iatiregistry.org/)

Run fetch_data.sh to get all the data.
(In a terminal type `./fetch_data.sh`) 
(if you want to set up your own paths, copy this file to e.g. `fetch_my_urls.sh` and edit the paths.)


Wget Caveats
------------

If your copy of wget is compiled against an old version of gnutls, then some https downloads will fail. Please make sure your system has the latest version of gnutls installed.


Bugs, issues and feature requests
--------------------------------

If you find any bugs, note any issues or have any feature requests, please
report them at https://github.com/caprenter/IATI-Registry-Refresher

Licence
-------

``` 
Copyright 2012 caprenter <caprenter@gmail.com>
     
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
