import json
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

REGISTRY_BASE_URL = "https://iatiregistry.org/api/3"
PUBLISHER_META_DIR = 'ckan'
URL_DIR = 'urls'

def requests_retry_session(
    retries=10,
    backoff_factor=0.3,
    status_forcelist=(),
    session=None,
):
    """Retry for requests"""
    session = session or requests.Session()
    retry = Retry(
        total=retries,
        read=retries,
        connect=retries,
        backoff_factor=backoff_factor,
        status_forcelist=status_forcelist,
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    return session

def fetch_publishers():
    """Fetch list of publishers from registry."""
    url= f"{REGISTRY_BASE_URL}/action/organization_list"
    response = requests_retry_session().get(url=url, timeout=30)
    if response.status_code == 200:
        json_response = json.loads(response.content)
        return json_response['result']
    raise Exception(f"Could not fetch publisher list from {url}: HTTP {response.status_code}")

def fetch_publisher(publisher):
    """Fetch an individual publisher's metadata from registry."""
    url= f"{REGISTRY_BASE_URL}/action/package_search?fq=organization:{publisher}&rows=1000000"
    response = requests_retry_session().get(url=url, timeout=30)
    if response.status_code == 200:
        json_response = json.loads(response.content)
        return json_response
    raise Exception(f"Could not fetch publisher {publisher} from {url}: HTTP {response.status_code}")

def write_publisher(publisher, publisher_meta):
    """Write an individual publisher's metadata to file."""
    file_path = f"{PUBLISHER_META_DIR}/{publisher}"
    with open(file_path, 'w', encoding='utf-8') as file:
        json.dump(publisher_meta, file)

def write_urls(publisher, url_string):
    """Write a publishers urls to file."""
    file_path = f"{URL_DIR}/{publisher}_n"
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(url_string)

def main():
    """Gets publisher metadata and package urls from the IATI Registry API."""
    publishers = fetch_publishers()
    for publisher in publishers:
        print(f"{publisher}")
        publisher_meta = fetch_publisher(publisher)
        write_publisher(publisher, publisher_meta)
        url_string = ''
        for package in publisher_meta['result']['results']:
            try:
                url_string += f"{package['name']} {package['resources'][0]['url']}\n"
            except Exception as error:
                print(f"Caught exception for url_string {publisher}: {error} ")
        write_urls(publisher, url_string)

if __name__ == '__main__':
    main()
