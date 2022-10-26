import json
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

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

REGISTRY_BASE_URL = "https://iatiregistry.org/api/3"

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
    with open(f"ckan/{publisher}_n", 'w', encoding='utf-8') as file:
        json.dump(publisher_meta, file)


def main():
    publishers = fetch_publishers()
    for publisher in publishers:
        publisher_meta = fetch_publisher(publisher)
        write_publisher(publisher, publisher_meta)

if __name__ == '__main__':
    main()
