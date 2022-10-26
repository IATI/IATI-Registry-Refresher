import os
import json
import argparse
from time import sleep
from urllib.error import HTTPError
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import logging, sys

loggers = {}

REGISTRY_BASE_URL = "https://iatiregistry.org/api/3"
PUBLISHER_META_DIR = 'ckan'
URL_DIR = 'urls'
DATA_DIR = 'data'

def getLogger(name="dashboard-refresh"):
    global loggers

    if loggers.get(name):
        return loggers.get(name)
    else:
        logger = logging.getLogger('refresh')
        logger.handlers.clear()
        logger.setLevel(logging.INFO)
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(logging.INFO)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        loggers[name] = logger

    return logger

log = getLogger()

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
    log.error("Could not fetch publisher %s from %s: HTTP %s", publisher, url,response.status_code )
    return None

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

def parse_urls(file_path):
    """Parse urls saved in file and return in list of tuples.

    return - [( name, url ),...]
    """
    urls = []
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file.read().splitlines():
            urls.append((line.split(' ')[0], line.split(' ')[1]))
    return urls

def download_file(download_url, file_destination):
    """Download file from url and save in destination."""
    with requests_retry_session(retries=3).get(url=download_url, timeout=5, stream=True, headers={ 'User-Agent': 'iati-registry-refresher-py/1.0.0'}) as req:
        req.raise_for_status()
        with open(file_destination, 'wb') as file:
            for chunk in req.iter_content(chunk_size=8192):
                if chunk:
                    file.write(chunk)
        return file_destination

def refresh():
    """Gets publisher metadata and package urls from the IATI Registry API."""
    log.info('Starting refresh...')
    publishers = fetch_publishers()
    for publisher in publishers:
        log.info("Fetching %s", publisher)
        publisher_meta = fetch_publisher(publisher)
        if publisher_meta is not None:
            write_publisher(publisher, publisher_meta)
            url_string = ''
            for package in publisher_meta['result']['results']:
                try:
                    url_string += f"{package['name']} {package['resources'][0]['url']}\n"
                except Exception as error:
                    log.error("Caught exception for url_string %s: %s", publisher, error)
            write_urls(publisher, url_string)

def reload():
    """Download files from previously saved URLs"""
    log.info('Starting reload...')
    with os.scandir(f"{URL_DIR}/") as entries:
        for entry in entries:
            publisher = entry.name
            log.info("Downloading files for %s", publisher)
            urls = parse_urls(f"{URL_DIR}/{publisher}")
            if len(urls) > 0:
                try:
                    os.mkdir(f"{DATA_DIR}/{publisher}")
                except FileExistsError:
                    continue
                for file_name, file_url in urls:
                    try:
                        download_file(file_url, file_destination=f"{DATA_DIR}/{publisher}/{file_name}")
                        sleep(1)
                    except Exception as error:
                        log.error("Error Downloading file: %s url: %s error: %s", file_name, file_url, error)
                    

def main(args):
    """Main entrypoint to run the refresh and reload"""
    try:
        if args.type == "refresh":
            refresh()
        if args.type == "reload":
            reload()
    except Exception as error:
        log.error('%s Failed. %s',args.type, str(error).strip())

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Refresh from IATI Registry')
    parser.add_argument('-t', '--type', dest='type',
                        default="refresh", help="Trigger 'refresh' or 'validate'")
    args = parser.parse_args()
    main(args)
