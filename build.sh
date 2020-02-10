#!/usr/bin/env bash

until cd /src
do
    echo "Waiting for volume mount..."
done
rm -rf urls data ckan
mkdir urls data ckan
php grab_urls.php
./fetch_data.sh
