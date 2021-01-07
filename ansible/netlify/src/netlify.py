import os
import base64
import requests
from kubernetes import client, config

API = os.environ.get("NETLIFY_API")
TOKEN = os.environ.get("NETLIFY_TOKEN")
SITE_ID = os.environ.get("NETLIFY_SITE_ID")
SECRET_NAME = os.environ.get("K8S_SECRET_NAME")
NAMESPACE = os.environ.get("K8S_NAMESPACE")

def get_cert():
    config.load_kube_config()
    v1 = client.CoreV1Api()
    ret = v1.read_namespaced_secret(SECRET_NAME, NAMESPACE)
    return (
        base64.b64decode(ret.data['tls.crt']).decode('ascii'),
        base64.b64decode(ret.data['tls.key']).decode('ascii')
    )

def update_cert(ssl_cert, ssl_key):
    try:
        result = requests.post(
            f"{API}/sites/{SITE_ID}/ssl",
            headers= {
                "Authorization": f"Bearer {TOKEN}"
            },
            json={
                "certificate": ssl_cert,
                "key": ssl_key,
                "ca_certificates": ssl_cert,
            }
        )
        result.raise_for_status()
        print(result.json())
    except requests.exceptions.HTTPError as e:
        print(e)

ssl_cert, ssl_key = get_cert()
update_cert(ssl_cert, ssl_key)
