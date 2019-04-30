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
from os.path import join
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


print('Fetching:')
api_root = 'https://iatiregistry.org/api/3/action'

# Pull all the group identifiers from the registry
# We store them in an array , $groups, for later use
organisation_names = request_with_backoff(
    'get',
    f'{api_root}/organization_list').json()['result']

# Loop through each organization and save the URL end-points of the data files
# You may need to set up an empty directory called "urls"
for organisation_name in organisation_names:
    print(organisation_name)
    filename = f'urls/{organisation_name}'

    response = request_with_backoff(
        'get', f'{api_root}/package_search',
        params={'fq': f'organization:{organisation_name}', 'rows': 1000000})

    with open(join('ckan', organisation_name), 'wb') as handler:
        # Save CKAN json from the API call to a file
        handler.write(response.content)
    result = response.json()['result']

    with open(filename, 'w') as handler:
        for package in result['results']:
            if len(package['resources']) > 0:
                url_string = '{name} {url}\n'.format(
                    name=package['name'],
                    url=package['resources'][0]['url'],
                )
                handler.write(url_string)
