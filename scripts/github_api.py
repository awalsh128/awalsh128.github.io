"""GitHub API calls through the GitHub CLI (`gh`), shared by the sync scripts.

Both raise FileNotFoundError when `gh` is missing and subprocess.CalledProcessError when the call fails.
"""

import json
import subprocess


def gh_api(path: str, raw: bool = False) -> bytes:
  """Response body of `gh api <path>`; raw=True returns a file's contents instead of its JSON metadata."""
  command = ["gh", "api", path]
  if raw:
    command += ["-H", "Accept: application/vnd.github.raw"]
  return subprocess.run(command, capture_output=True, check=True).stdout


def gh_json(path: str, paginate: bool = False):
  """Parsed JSON of `gh api <path>`; paginate=True returns a list with one entry per page."""
  command = ["gh", "api", path] + (["--paginate", "--slurp"] if paginate else [])
  return json.loads(subprocess.run(command, capture_output=True, check=True).stdout)
