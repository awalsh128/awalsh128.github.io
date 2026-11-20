"""Find and read a LinkedIn data export for update_recommendations.py.

LinkedIn has no public API for recommendations, so the resume page's recommendations come from the data export
you request from LinkedIn. This finds the newest export in ~/Downloads under LinkedIn's own file name
(Basic_LinkedInDataExport_MM-DD-YYYY.zip.zip, or Complete_..., zipped or unzipped), or takes a given path, and
reads only Recommendations_Received.csv from it.

With no export found, run from a terminal, it prints how to get one and waits: press any key to look again
once it's downloaded, or q to skip. Without a terminal (e.g. the pre-commit hook, where git gives hooks no
input), it prints a one-line note instead.
"""

import re
import sys
from pathlib import Path

from downloads import DOWNLOADS_DIR, newest_export, read_export_csv

try:
    import termios
    import tty
except ImportError:  # Not POSIX; fall back to waiting for Enter.
    termios = tty = None

DEFAULT_SEARCH_DIR = DOWNLOADS_DIR
CSV_NAME = "Recommendations_Received.csv"

# LinkedIn names the archive after the export date and downloads it as
# Basic_LinkedInDataExport_11-05-2026.zip.zip; unzipping that gives a folder named ...zip. Match any number of
# .zip suffixes, including none.
EXPORT_NAME = re.compile(
    r"^(?:Basic|Complete)_LinkedInDataExport_(?P<month>\d{2})-(?P<day>\d{2})-(?P<year>\d{4})(?:\.zip)*$",
    re.IGNORECASE,
)
EXPORT_URL = "https://www.linkedin.com/mypreferences/d/download-my-data"
INSTRUCTIONS = f"""\
No LinkedIn data export found in {DEFAULT_SEARCH_DIR}. To get one:
  1. Open {EXPORT_URL}
     (LinkedIn: Me > Settings & Privacy > Data privacy > Get a copy of your data).
  2. Choose "Want something in particular?", tick Recommendations, and click Request archive.
  3. When LinkedIn emails you (usually within minutes), download the zip into {DEFAULT_SEARCH_DIR}.
     It's named like Basic_LinkedInDataExport_MM-DD-YYYY.zip.zip; there's no need to unzip it."""


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
        export = newest_export(search_dir, EXPORT_NAME)
        if export:
            print(f"Found {export.name}.", file=sys.stderr)
            return export
        print(f"Still no export in {search_dir}.", file=sys.stderr)


def load_csv(export_arg: str | None) -> str | None:
    """Recommendations CSV text from the given export path, or from the newest export in ~/Downloads.

    None when there's nothing to read; the reason is printed, and the caller keeps its current data.
    """
    if export_arg:
        export = Path(export_arg).expanduser()
        if not export.exists():
            print(f"update_recommendations: {export} not found; keeping the current list.", file=sys.stderr)
            return None
    else:
        export = newest_export(DEFAULT_SEARCH_DIR, EXPORT_NAME)
        if not export and sys.stdin.isatty():
            export = wait_for_export(DEFAULT_SEARCH_DIR)
            if not export:
                print("update_recommendations: skipped; keeping the current list.", file=sys.stderr)
                return None
        if not export:
            print(
                "update_recommendations: no LinkedIn data export found; keeping the current list "
                "(run scripts/update_recommendations.py in a terminal for how to get one).",
                file=sys.stderr,
            )
            return None
    csv_text = read_export_csv(export, CSV_NAME)
    if csv_text is None:
        print(
            f"update_recommendations: {CSV_NAME} not found in {export}; keeping the current list.",
            file=sys.stderr,
        )
    return csv_text
