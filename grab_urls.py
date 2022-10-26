import requests
import json
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

def requests_retry_session(
    retries=10,
    backoff_factor=0.3,
    status_forcelist=(),
    session=None,
):
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
    url= f"{REGISTRY_BASE_URL}/action/organization_list"
    response = requests_retry_session().get(url=url, timeout=30)
    if response.status_code == 200:
        json_response = json.loads(response.content)
        return json_response['result']
    else:
        raise Exception(f"Could not fetch publisher list from {url}: HTTP {response.status_code}")

def main():
    publishers = fetch_publishers()
    print(publishers)

if __name__ == '__main__':
    main()