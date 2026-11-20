#!/usr/bin/env python3

"""Sync the resume page's LinkedIn recommendations from a LinkedIn data export.

Reads the export found by linkedin_export.py (the newest in ~/Downloads, or --export / $LINKEDIN_EXPORT), keeps the
recommendations marked visible, and writes them newest first to data/linkedin_recommendations.json, which
layouts/_default/resume.html shows on the resume page (but not in the PDF). With no export, it leaves the data file
alone and exits 0.
"""

import argparse
import csv
import io
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path

from linkedin_export import load_csv

ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT_DIR / "data" / "linkedin_recommendations.json"
DATE_FORMATS = (
    "%m/%d/%y, %I:%M %p",
    "%m/%d/%Y, %I:%M %p",
    "%m/%d/%y %I:%M %p",
    "%m/%d/%Y %I:%M %p",
    "%m/%d/%y",
    "%m/%d/%Y",
    "%b %d, %Y",
    "%Y-%m-%d",
)


def iso_date(value: str) -> str:
    value = value.strip()
    for date_format in DATE_FORMATS:
        try:
            return datetime.strptime(value, date_format).date().isoformat()
        except ValueError:
            continue
    return value


def parse(csv_text: str) -> list[dict]:
    """Visible recommendations, newest first, with only the fields the resume page shows."""
    recommendations = []
    for row in csv.DictReader(io.StringIO(csv_text)):
        row = {(key or "").strip().lower(): (value or "").strip() for key, value in row.items()}
        status = row.get("status", "")
        if status and status.upper() != "VISIBLE":
            continue
        text = row.get("text", "")
        if not text:
            continue
        name = " ".join(part for part in (row.get("first name", ""), row.get("last name", "")) if part)
        recommendations.append(
            {
                "name": name,
                "title": row.get("job title", ""),
                "company": row.get("company", ""),
                "date": iso_date(row.get("creation date", "")),
                "text": text,
            }
        )
    # Newest first; anything without a parseable date goes last.
    dated = re.compile(r"^\d{4}-\d{2}-\d{2}$")
    return sorted(
        recommendations, key=lambda rec: (bool(dated.match(rec["date"])), rec["date"]), reverse=True
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--export",
        default=os.environ.get("LINKEDIN_EXPORT"),
        help="export zip, extracted folder, or Recommendations_Received.csv (default: newest in ~/Downloads)",
    )
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT), help="JSON file to write, or - to print")
    args = parser.parse_args()

    csv_text = load_csv(args.export)
    if csv_text is None:
        return 0

    content = json.dumps(parse(csv_text), indent=2, ensure_ascii=False) + "\n"
    if args.output == "-":
        print(content, end="")
        return 0
    path = Path(args.output)
    if path.exists() and path.read_text() == content:
        return 0
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    print(f"update_recommendations: updated {path.relative_to(ROOT_DIR)}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
