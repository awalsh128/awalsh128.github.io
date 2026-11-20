"""Helpers for writing generated files and page sections, shared by the sync scripts."""

import re
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[1]


def first_sentence(text: str) -> str:
    """First sentence of text with whitespace collapsed, ending in punctuation ("" for no text)."""
    text = " ".join((text or "").split())
    match = re.match(r"(.+?[.!?])(\s|$)", text)
    sentence = match.group(1) if match else text
    return sentence if not sentence or sentence[-1] in ".!?" else sentence + "."


def replace_between(content: str, start: str, end: str, body: str) -> str:
    """Replace everything between the start and end marker lines with body; ValueError if the markers are
    missing.
    """
    pattern = re.compile(re.escape(start) + r".*?" + re.escape(end), re.DOTALL)
    if not pattern.search(content):
        raise ValueError(f"markers not found; expected {start!r} ... {end!r}")
    return pattern.sub(lambda _: f"{start}\n\n{body}\n\n{end}", content)


def write_if_changed(path: Path, content: str, tag: str) -> None:
    """Write content to path unless it is already there, and say so on stderr as "<tag>: updated <path>"."""
    if path.exists() and path.read_text() == content:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    shown = path.resolve().relative_to(ROOT_DIR) if path.resolve().is_relative_to(ROOT_DIR) else path
    print(f"{tag}: updated {shown}", file=sys.stderr)


def update_between(path: Path, start: str, end: str, body: str, tag: str) -> None:
    """Rewrite the section of the page at path between the start and end markers; ValueError if missing."""
    write_if_changed(path, replace_between(path.read_text(), start, end, body), tag)
