#!/usr/bin/python
# Okta oauth client credentials flow with Workflow identity federation
import os
import json
import requests
import base64
import secrets


def get_okta_token():
    okta_az_server = os.environ["OKTA_AZ_SERVER"]
    client_id = os.environ["CLIENT_ID"]
    client_secret = os.environ["CLIENT_SECRET"]
    encodedData = base64.b64encode(bytes(f"{client_id}:{client_secret}", "ISO-8859-1")).decode("ascii")

    cookies = {
        'JSESSIONID': secrets.token_urlsafe(33),
    }

    headers = {
        'Accept': '*/*',
        'Authorization': 'Basic %s' % {encodedData},
        'Cache-Control': 'no-cache',
        'Content-Type': 'application/x-www-form-urlencoded',
    }

    data = {
        'grant_type': 'client_credentials'
    }

    response = requests.post(okta_az_server,
                             headers=headers, cookies=cookies, data=data)
    response.raise_for_status()
    print("Creating Okta token file")
    data = response.json()
    with open('/tmp/okta-token.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)


if __name__ == '__main__':
    print("Running main")
    get_okta_token()
