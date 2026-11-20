#!/usr/bin/env python3

"""Sync data/popular_posts.json with the search clicks per page in a Google Search Console export.

The homepage's Posts section (layouts/partials/recent-articles/main.html) shows pinned posts first, then the
posts with the most search clicks, then the newest to fill any gaps.

Reads Pages.csv from the newest Search Console export for awalsh128.com in ~/Downloads (Search Console >
Performance > Pages > Export > Download CSV, which saves a zip named like
awalsh128.com-Performance-on-Search-YYYY-MM-DD.zip), or from the path given with --export or
$SEARCH_CONSOLE_EXPORT. With no export it leaves the data file alone and exits 0, so the pre-commit hook skips
it until you download one.
"""

import argparse
import csv
import io
import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import urlparse

from downloads import DOWNLOADS_DIR, newest_export, read_export_csv
from generated_markdown import ROOT_DIR, write_if_changed

DEFAULT_OUTPUT = ROOT_DIR / "data" / "popular_posts.json"
CSV_NAME = "Pages.csv"
# Search Console names the zip after the property and the export date; a repeat download adds " (1)" and so
# on.
EXPORT_NAME = re.compile(
    r"^.*awalsh128\.com.*-Performance-on-Search-(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})"
    r"(?: \(\d+\))?(?:\.zip)?$",
    re.IGNORECASE,
)


def parse(csv_text: str) -> list[dict]:
    """Clicks per site path (e.g. /safer-curl-bash/), most first, merging http/https, www and #fragment
    variants.
    """
    rows = csv.reader(io.StringIO(csv_text))
    header = [name.strip().lower() for name in next(rows, [])]
    clicks_column = header.index("clicks")
    clicks: dict[str, int] = {}
    for row in rows:
        if not row or not row[0].strip():
            continue
        path = urlparse(row[0].strip()).path.lower() or "/"
        clicks[path] = clicks.get(path, 0) + int(row[clicks_column].replace(",", "") or 0)

    pages = [{"path": path, "clicks": n} for path, n in clicks.items() if n > 0]
    return sorted(pages, key=lambda page: (-page["clicks"], page["path"]))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--export",
        default=os.environ.get("SEARCH_CONSOLE_EXPORT"),
        help="export zip, extracted folder, or Pages.csv (default: newest in ~/Downloads)",
    )
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT), help="JSON file to write, or - to print")
    args = parser.parse_args()

    export = Path(args.export).expanduser() if args.export else newest_export(DOWNLOADS_DIR, EXPORT_NAME)
    if not export or not export.exists():
        print(
            "update_popular_posts: no Search Console export found; keeping the current list.", file=sys.stderr
        )
        return 0
    csv_text = read_export_csv(export, CSV_NAME)
    if csv_text is None:
        print(
            f"update_popular_posts: {CSV_NAME} not found in {export}; keeping the current list.",
            file=sys.stderr,
        )
        return 0
    try:
        pages = parse(csv_text)
    except ValueError as error:
        print(f"update_popular_posts: can't read {CSV_NAME} in {export}: {error}", file=sys.stderr)
        return 1

    content = json.dumps({"source": export.name, "pages": pages}, indent=2) + "\n"
    if args.output == "-":
        print(content, end="")
        return 0
    write_if_changed(Path(args.output), content, "update_popular_posts")
    return 0


if __name__ == "__main__":
    sys.exit(main())
