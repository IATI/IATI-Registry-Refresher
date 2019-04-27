"""
grab_urls.py

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

IATI Registry Refresher relies on other free software products. See the README.md file
for more details.
"""
from os import mkdir
from os.path import exists
from shutil import rmtree
from time import sleep

import requests


def request_with_backoff(*args, attempts=5, backoff=0.5, **kwargs):
    for attempt in range(1, attempts + 1):
        try:
            result = requests.request(*args, **kwargs)
            return result
        except requests.exceptions.ConnectionError:
            wait = attempt * backoff
            print(f'Rate limited! Retrying after {wait} seconds')
            sleep(wait)
    raise Exception(f'Failed after {attempts} attempts. Giving up.')


# Remove `urls` files
rmtree('urls', ignore_errors=True)
mkdir('urls')

# Loop through each page and save the URL end-points of the data files
print('Fetching:')
api_root = 'https://iatiregistry.org/api/3/action'
page = 1
page_size = 1000
while True:
    start = page_size * (page - 1)
    result = request_with_backoff(
        'get',
        f'{api_root}/package_search',
        params={'start': start, 'rows': page_size}).json()['result']
    if result['results'] == []:
        break

    for package in result['results']:
        organization = package['organization']
        if len(package['resources']) > 0 and organization:
            file = f'urls/{organization["name"]}'
            if not exists(file):
                print(organization['name'])
            url_string = '{name} {url}\n'.format(
                name=package['name'],
                url=package['resources'][0]['url'],
            )
            with open(file, 'a') as f:
                f.write(url_string)
    page += 1
