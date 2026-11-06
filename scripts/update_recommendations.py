#!/usr/bin/env python3

"""Sync the resume page's LinkedIn recommendations from a LinkedIn data export.

LinkedIn has no public API for recommendations, so this reads the data export
you request from LinkedIn (Settings > Data privacy > Get a copy of your data).
It looks in ~/Downloads for the newest export under LinkedIn's own file name
(Basic_LinkedInDataExport_MM-DD-YYYY.zip.zip, or Complete_..., zipped or unzipped),
or uses the path given with --export or $LINKEDIN_EXPORT. It reads only
Recommendations_Received.csv from it, keeps the recommendations marked visible,
and writes them newest first to data/linkedin_recommendations.json, which
layouts/_default/resume.html shows on the resume page (but not in the PDF).

Nothing else in the export is read. With no export found, it leaves the data
file alone and exits 0. Run from a terminal, it first prints how to get an
export and waits: press any key to look again once it's downloaded, or q to
skip. Without a terminal (e.g. the pre-commit hook, where git gives hooks no
input), it prints a one-line note instead.
"""

from datetime import datetime
from pathlib import Path
import argparse
import csv
import io
import json
import os
import re
import sys
import zipfile

try:
    import termios
    import tty
except ImportError:  # Not POSIX; fall back to waiting for Enter.
    termios = tty = None

ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT_DIR / "data" / "linkedin_recommendations.json"
DEFAULT_SEARCH_DIR = Path.home() / "Downloads"
CSV_NAME = "Recommendations_Received.csv"

# LinkedIn names the archive after the export date and downloads it as Basic_LinkedInDataExport_11-05-2026.zip.zip;
# unzipping that gives a folder named ...zip. Match any number of .zip suffixes, including none.
EXPORT_NAME = re.compile(r"^(?:Basic|Complete)_LinkedInDataExport_(\d{2})-(\d{2})-(\d{4})(?:\.zip)*$", re.I)
EXPORT_URL = "https://www.linkedin.com/mypreferences/d/download-my-data"
INSTRUCTIONS = f"""\
No LinkedIn data export found in {DEFAULT_SEARCH_DIR}. To get one:
  1. Open {EXPORT_URL}
     (LinkedIn: Me > Settings & Privacy > Data privacy > Get a copy of your data).
  2. Choose "Want something in particular?", tick Recommendations, and click Request archive.
  3. When LinkedIn emails you (usually within minutes), download the zip into {DEFAULT_SEARCH_DIR}.
     It's named like Basic_LinkedInDataExport_MM-DD-YYYY.zip.zip; there's no need to unzip it."""

DATE_FORMATS = (
    "%m/%d/%y, %I:%M %p", "%m/%d/%Y, %I:%M %p", "%m/%d/%y %I:%M %p", "%m/%d/%Y %I:%M %p",
    "%m/%d/%y", "%m/%d/%Y", "%b %d, %Y", "%Y-%m-%d",
)


def find_export(search_dir: Path) -> Path | None:
    """Newest LinkedIn export in search_dir by the date in its name (then by modification time)."""
    if not search_dir.is_dir():
        return None
    candidates = []
    for path in search_dir.iterdir():
        match = EXPORT_NAME.match(path.name)
        if match and (path.is_dir() or zipfile.is_zipfile(path)):
            month, day, year = match.groups()
            candidates.append(((year, month, day, path.stat().st_mtime), path))
    return max(candidates, default=(None, None))[1]


def read_key() -> str:
    """One key press from the terminal, without needing Enter where the platform allows it."""
    if termios is None:
        return sys.stdin.readline()[:1]
    fd = sys.stdin.fileno()
    saved = termios.tcgetattr(fd)
    try:
        tty.setcbreak(fd)
        return sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, saved)


def wait_for_export(search_dir: Path) -> Path | None:
    """Print how to get an export, then check again on each key press until one appears or the user quits."""
    print(INSTRUCTIONS, file=sys.stderr)
    while True:
        print("\nPress any key to check again, or q to skip: ", end="", file=sys.stderr, flush=True)
        key = read_key()
        print(file=sys.stderr)
        if key.lower() == "q":
            return None
        export = find_export(search_dir)
        if export:
            print(f"Found {export.name}.", file=sys.stderr)
            return export
        print(f"Still no export in {search_dir}.", file=sys.stderr)


def read_csv_text(export: Path) -> str | None:
    """Contents of Recommendations_Received.csv from an export zip, folder, or the CSV itself."""
    if export.is_file() and export.suffix.lower() == ".csv":
        return export.read_text(encoding="utf-8-sig")
    if export.is_dir():
        found = next(export.rglob(CSV_NAME), None)
        return found.read_text(encoding="utf-8-sig") if found else None
    if zipfile.is_zipfile(export):
        with zipfile.ZipFile(export) as archive:
            name = next((n for n in archive.namelist() if Path(n).name == CSV_NAME), None)
            return archive.read(name).decode("utf-8-sig") if name else None
    return None


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
        recommendations.append({
            "name": name,
            "title": row.get("job title", ""),
            "company": row.get("company", ""),
            "date": iso_date(row.get("creation date", "")),
            "text": text,
        })
    # Newest first; anything without a parseable date goes last.
    dated = re.compile(r"^\d{4}-\d{2}-\d{2}$")
    return sorted(recommendations, key=lambda rec: (bool(dated.match(rec["date"])), rec["date"]), reverse=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--export",
        default=os.environ.get("LINKEDIN_EXPORT"),
        help="export zip, extracted folder, or Recommendations_Received.csv (default: newest in ~/Downloads)",
    )
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT), help="JSON file to write, or - to print")
    args = parser.parse_args()

    if args.export:
        export = Path(args.export).expanduser()
        if not export.exists():
            print(f"update_recommendations: {export} not found; keeping the current list.", file=sys.stderr)
            return 0
    else:
        export = find_export(DEFAULT_SEARCH_DIR)
        if not export and sys.stdin.isatty():
            export = wait_for_export(DEFAULT_SEARCH_DIR)
            if not export:
                print("update_recommendations: skipped; keeping the current list.", file=sys.stderr)
                return 0
        if not export:
            print(
                "update_recommendations: no LinkedIn data export found; keeping the current list "
                f"(run {Path(__file__).relative_to(ROOT_DIR)} in a terminal for how to get one).",
                file=sys.stderr,
            )
            return 0
    csv_text = read_csv_text(export)
    if csv_text is None:
        print(f"update_recommendations: {CSV_NAME} not found in {export}; keeping the current list.", file=sys.stderr)
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
    print(f"update_recommendations: updated {path.relative_to(ROOT_DIR)} from {export.name}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
