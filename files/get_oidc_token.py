#!/usr/bin/python
# Okta oauth client credentials flow with Workflow identity federation
import google.auth
import os
import json
from google.auth import identity_pool
import requests
import http.client
from pprint import pprint
import requests
import json

def get_okta_token():
    cookies = {
        'JSESSIONID': 'C4178E6BB95095E2E6652D69CC3B716A',
    }

    headers = {
        'Accept': '*/*',
        'Authorization': 'Basic <Base64enc clientid:clientsecret>',
        'Cache-Control': 'no-cache',
        'Content-Type': 'application/x-www-form-urlencoded',
    }

    data = {
        'grant_type': 'client_credentials'
    }

    response = requests.post('<okta_az_server>/v1/token',
                             headers=headers, cookies=cookies, data=data)
    response.raise_for_status()
    print("Creating Okta token file")
    data = response.json()
    with open('/tmp/okta-token.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)


if __name__ == '__main__':
    print("Running main")
    get_okta_token()
    # For service account credentials
    file = open('client-config.json')
    json_config_info = json.loads(file.read())
    scopes = ['https://www.googleapis.com/auth/devstorage.full_control',
              'https://www.googleapis.com/auth/devstorage.read_only', 'https://www.googleapis.com/auth/devstorage.read_write']
    #credentials  = google.auth.default(scopes=scopes)
    credentials = identity_pool.Credentials.from_info(json_config_info)
    scoped_credentials = credentials.with_scopes(scopes)
    print("Removing Okta token file")
    os.remove('/tmp/okta-token.json')