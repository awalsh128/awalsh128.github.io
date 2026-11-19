#!/usr/bin/env python3

"""Sync data/popular_posts.json with Google Search Console clicks per page.

The homepage's Posts section (layouts/partials/recent-articles/main.html) shows pinned posts first, then the posts
with the most search clicks over the last LOOKBACK_DAYS, then the newest to fill any gaps.

Reads clicks for the domain property through the Search Console API as a service account. CI passes a short-lived
access token in $SEARCH_CONSOLE_TOKEN (from Workload Identity Federation, no stored key); locally it signs in with the
service account's JSON key, the file named by $SEARCH_CONSOLE_KEY, else DEFAULT_KEY. See docs/site.md for the setup.
With neither it leaves the data file alone and exits 0, so the pre-commit hook and CI skip it without access.
"""

from datetime import date, timedelta
from pathlib import Path
from urllib.parse import quote, urlparse
import argparse
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request

from google_auth import access_token

ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT_DIR / "data" / "popular_posts.json"
DEFAULT_KEY = Path.home() / ".config" / "awalsh128.com" / "search-console-key.json"
PROPERTY = "sc-domain:awalsh128.com"
SCOPE = "https://www.googleapis.com/auth/webmasters.readonly"
LOOKBACK_DAYS = 365
# Search Console data lags by about two days; end before that so totals don't shift between runs on the same day.
LAG_DAYS = 3


def query_clicks(token: str, start: date, end: date) -> dict[str, int]:
  """Clicks per site path (e.g. /safer-curl-bash/), merging http/https, www and #fragment variants."""
  url = f"https://www.googleapis.com/webmasters/v3/sites/{quote(PROPERTY, safe='')}/searchAnalytics/query"
  body = {"startDate": start.isoformat(), "endDate": end.isoformat(), "dimensions": ["page"], "rowLimit": 1000}
  request = urllib.request.Request(
      url,
      data=json.dumps(body).encode(),
      headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
  )
  with urllib.request.urlopen(request) as response:
    rows = json.loads(response.read()).get("rows", [])
  clicks: dict[str, int] = {}
  for row in rows:
    path = urlparse(row["keys"][0]).path.lower() or "/"
    clicks[path] = clicks.get(path, 0) + int(row["clicks"])
  return clicks


def render(clicks: dict[str, int], start: date, end: date) -> str:
  pages = [{"path": path, "clicks": n} for path, n in clicks.items() if n > 0]
  pages.sort(key=lambda page: (-page["clicks"], page["path"]))
  data = {"source": "Google Search Console", "start": start.isoformat(), "end": end.isoformat(), "pages": pages}
  return json.dumps(data, indent=2) + "\n"


def main() -> int:
  parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
  parser.add_argument("--output", default=str(DEFAULT_OUTPUT), help="JSON file to write, or - to print")
  args = parser.parse_args()

  token = os.environ.get("SEARCH_CONSOLE_TOKEN")
  key_file = Path(os.environ.get("SEARCH_CONSOLE_KEY") or DEFAULT_KEY).expanduser()
  if not token and not key_file.is_file():
    print(f"update_popular_posts: no Search Console key at {key_file}; keeping the current list.", file=sys.stderr)
    return 0

  end = date.today() - timedelta(days=LAG_DAYS)
  start = end - timedelta(days=LOOKBACK_DAYS)
  try:
    clicks = query_clicks(token or access_token(key_file, SCOPE), start, end)
  except (OSError, subprocess.CalledProcessError, KeyError, ValueError) as error:
    detail = error.read().decode(errors="replace") if isinstance(error, urllib.error.HTTPError) else error
    print(f"update_popular_posts: Search Console query failed: {detail}", file=sys.stderr)
    return 1

  content = render(clicks, start, end)
  if args.output == "-":
    print(content, end="")
    return 0
  path = Path(args.output)
  if path.exists() and json.loads(path.read_text())["pages"] == json.loads(content)["pages"]:
    return 0
  path.write_text(content)
  print(f"update_popular_posts: updated {path.relative_to(ROOT_DIR)}", file=sys.stderr)
  return 0


if __name__ == "__main__":
  sys.exit(main())
