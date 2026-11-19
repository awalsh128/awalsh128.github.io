"""Google API access tokens for a service account, used by update_popular_posts.py.

Signs the OAuth JWT with `openssl` instead of a Google client library, so the scripts need no Python packages. Raises
subprocess.CalledProcessError when signing fails and urllib.error.URLError when Google rejects the request.
"""

from pathlib import Path
import base64
import json
import subprocess
import tempfile
import time
import urllib.parse
import urllib.request

TOKEN_URL = "https://oauth2.googleapis.com/token"


def b64url(data: bytes) -> str:
  return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def sign_rs256(message: bytes, private_key_pem: str) -> bytes:
  with tempfile.TemporaryDirectory() as work:
    key = Path(work) / "key.pem"
    key.write_text(private_key_pem)
    key.chmod(0o600)
    return subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", str(key)], input=message, capture_output=True, check=True
    ).stdout


def access_token(key_file: Path, scope: str) -> str:
  """Access token for the service account in key_file (its downloaded JSON key), limited to scope."""
  key = json.loads(key_file.read_text())
  now = int(time.time())
  header = b64url(json.dumps({"alg": "RS256", "typ": "JWT"}).encode())
  claims = b64url(
      json.dumps(
          {"iss": key["client_email"], "scope": scope, "aud": TOKEN_URL, "iat": now, "exp": now + 3600}
      ).encode()
  )
  unsigned = f"{header}.{claims}"
  assertion = f"{unsigned}.{b64url(sign_rs256(unsigned.encode(), key['private_key']))}"
  body = urllib.parse.urlencode(
      {"grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer", "assertion": assertion}
  ).encode()
  with urllib.request.urlopen(urllib.request.Request(TOKEN_URL, data=body)) as response:
    return json.loads(response.read())["access_token"]
