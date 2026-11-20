"""Find and read data exports downloaded from websites, shared by the sync scripts that read them.

An export is a zip, the folder it unzips to, or a single CSV, named with the date it was made. The newest is
chosen by that date, then by modification time.
"""

import re
import zipfile
from pathlib import Path

DOWNLOADS_DIR = Path.home() / "Downloads"


def newest_export(search_dir: Path, name_pattern: re.Pattern) -> Path | None:
    """Newest zip or folder in search_dir whose name matches name_pattern (with year, month and day
    groups).
    """
    if not search_dir.is_dir():
        return None
    candidates = []
    for path in search_dir.iterdir():
        match = name_pattern.match(path.name)
        if match and (path.is_dir() or zipfile.is_zipfile(path)):
            made = (match.group("year"), match.group("month"), match.group("day"), path.stat().st_mtime)
            candidates.append((made, path))
    return max(candidates, default=(None, None))[1]


def read_export_csv(export: Path, csv_name: str) -> str | None:
    """Contents of csv_name from an export zip or folder, or of export itself when it's a CSV; None if
    missing.
    """
    if export.is_file() and export.suffix.lower() == ".csv":
        return export.read_text(encoding="utf-8-sig")
    if export.is_dir():
        found = next(export.rglob(csv_name), None)
        return found.read_text(encoding="utf-8-sig") if found else None
    if zipfile.is_zipfile(export):
        with zipfile.ZipFile(export) as archive:
            name = next((n for n in archive.namelist() if Path(n).name == csv_name), None)
            return archive.read(name).decode("utf-8-sig") if name else None
    return None
