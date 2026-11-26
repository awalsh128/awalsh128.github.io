"""Download homepage project logos into assets/img/projects/, used by update_projects.py.

A project's logo is the first image in its README that points at a file in the repository itself (badges and
other external images are skipped), or the file named in the overrides. It's saved as <repo>.<ext>, and logos
of repositories no longer listed are removed. A repository without a logo gets the `project-icon` shortcode's
fallback.
"""

import base64
import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path, PurePosixPath
from urllib.parse import urljoin, urlparse

from github_api import gh_api

ROOT_DIR = Path(__file__).resolve().parents[1]
LOGO_DIR = ROOT_DIR / "assets" / "img" / "projects"
LOGO_EXTENSIONS = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg"}

# Image references in a README: <img ... src="logo.png"> (any attribute order or spacing), and Markdown
# ![alt](logo.png), ![alt](<logo with spaces.png>) or ![alt](logo.png "Title").
IMAGE_PATTERN = re.compile(
    r"""<img\b[^>]*?\bsrc\s*=\s*["']([^"']+)["']"""
    r"""|!\[[^\]]*\]\(\s*<?([^)\s>]+)>?(?:\s+["'][^"']*["'])?\s*\)""",
    re.IGNORECASE,
)


def readme_logo_download_url(readme: str, readme_download_url: str) -> str | None:
    """Download URL of the first image in the README that's served from the repository, if any."""
    for match in IMAGE_PATTERN.finditer(readme):
        src = (match.group(1) or match.group(2)).split("#")[0].split("?")[0]
        if not src or PurePosixPath(src).suffix.lower() not in LOGO_EXTENSIONS:
            continue

        if re.match(r"^[a-z][a-z0-9+.-]*:|^//", src, re.IGNORECASE):
            # Absolute URL: accept only files served from this repository.
            repo_prefix = readme_download_url.rsplit("/", 2)[0]
            if src.startswith(repo_prefix):
                return src
            continue

        # Relative path: resolve it next to the README.
        base = readme_download_url.rsplit("/", 1)[0] + "/"
        return urljoin(base, src)

    return None


def fetch_logo(slug: str, override: str | None) -> tuple[bytes, str] | None:
    """The logo's bytes and file extension: the override file if given, else the README's first image."""
    if override:
        return gh_api(f"repos/{slug}/contents/{override}", raw=True), PurePosixPath(override).suffix.lower()
    info = json.loads(gh_api(f"repos/{slug}/readme"))
    readme = base64.b64decode(info["content"]).decode("utf-8", "replace")
    url = readme_logo_download_url(readme, info["download_url"])
    if not url:
        return None
    return urllib.request.urlopen(url).read(), PurePosixPath(urlparse(url).path).suffix.lower()


def sync_logos(repos: list[dict], overrides: dict[str, str], logo_dir: Path = LOGO_DIR) -> None:
    """Download each repository's logo into logo_dir and remove logos of unlisted repositories.

    overrides maps a repository name to the path of its logo file in the repository, used instead of the
    README image.
    """
    logo_dir.mkdir(parents=True, exist_ok=True)
    keep = set()
    for repo in repos:
        name, slug = repo["name"], repo["nameWithOwner"]
        try:
            logo = fetch_logo(slug, overrides.get(name))
        except (subprocess.CalledProcessError, KeyError, ValueError, OSError) as e:
            print(f"update_projects: no logo for {slug}: {e}", file=sys.stderr)
            # A failed fetch (offline, rate limit) keeps the logo already here instead of removing it as stale.
            keep.update(path.name for path in logo_dir.glob(f"{name}.*"))
            continue
        if not logo:
            continue

        data, ext = logo
        target = logo_dir / f"{name}{ext}"
        keep.add(target.name)
        if not target.exists() or target.read_bytes() != data:
            target.write_bytes(data)
            print(f"update_projects: updated {target.relative_to(ROOT_DIR)}", file=sys.stderr)

    for stale in logo_dir.iterdir():
        if stale.is_file() and stale.name not in keep:
            stale.unlink()
            print(f"update_projects: removed {stale.relative_to(ROOT_DIR)}", file=sys.stderr)
