"""Helpers for writing generated Markdown into site pages, shared by the sync scripts."""

import re


def first_sentence(text: str) -> str:
  """First sentence of text with whitespace collapsed, ending in punctuation ("" for no text)."""
  text = " ".join((text or "").split())
  match = re.match(r"(.+?[.!?])(\s|$)", text)
  sentence = match.group(1) if match else text
  return sentence if not sentence or sentence[-1] in ".!?" else sentence + "."


def replace_between(content: str, start: str, end: str, body: str) -> str:
  """Replace everything between the start and end marker lines with body; ValueError if the markers are missing."""
  pattern = re.compile(re.escape(start) + r".*?" + re.escape(end), re.S)
  if not pattern.search(content):
    raise ValueError(f"markers not found; expected {start!r} ... {end!r}")
  return pattern.sub(lambda _: f"{start}\n\n{body}\n\n{end}", content)
