#!/usr/bin/env python3

"""Normalize an exported Google Doc resume into content/resume.md for Hugo.

Google's markdown export represents headings as bold paragraphs (unless the
doc uses heading styles), uses `*` bullets with blank lines between them,
aligns dates with tabs, and backslash-escapes punctuation. This script turns
that into the semantic dialect read by markdown_to_html.py:

  ## Section, ### Employer or role, #### Team, and tight `-` lists.

When writing to a file, the existing Hugo front matter is kept and the `# Name`
heading is dropped, because the page title in the front matter is the heading.
"""

from pathlib import Path
import argparse
import re
import sys

ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT_DIR / "content" / "resume.md"

SECTIONS = {
    "summary", "professional summary", "core skills", "skills",
    "technical skills", "professional experience", "experience",
    "open source", "projects", "education", "certifications",
    "publications", "awards",
}
EXPERIENCE_SECTIONS = {"professional experience", "experience"}


def fetch(doc_path: str) -> str:
    with open(doc_path, "r") as file:
        content = file.read()
    return content


def clean(text: str) -> str:
    text = re.sub(r"\\([!#.+()|>~_-])", r"\1", text)
    return re.sub(r"[ \t]{2,}|\t", " ", text).strip()


def normalize(markdown: str) -> str:
    lines: list[str] = []
    seen_title = seen_section = in_experience = False

    def emit_block(*block: str) -> None:
        lines.extend(["", *block, ""])

    for raw_line in markdown.replace("\r\n", "\n").split("\n"):
        line = raw_line.rstrip()
        stripped = line.strip()
        if not stripped or stripped == "---":
            lines.append("")
            continue

        heading = re.match(r"^(#{1,6})\s+(.*)$", stripped)
        if heading:
            title = clean(re.sub(r"^\*\*(.*)\*\*$", r"\1",
                          heading.group(2).strip()))
            level = min(len(heading.group(1)), 4)
            if level == 1:
                seen_title = True
            else:
                seen_section = True
            if level == 2:
                in_experience = title.lower() in EXPERIENCE_SECTIONS
            emit_block(f"{'#' * level} {title}")
            continue

        bold_line = re.match(r"^\*\*([^*]+)\*\*([ \t]*)(.*)$", stripped)
        if bold_line and (not bold_line.group(3) or "\t" in bold_line.group(2)):
            title = clean(bold_line.group(1)).rstrip(":")
            meta = clean(bold_line.group(3))
            if not seen_title:
                seen_title = True
                emit_block(f"# {title}")
            elif meta:
                level = 4 if in_experience and "|" not in meta else 3
                emit_block(f"{'#' * level} {title}", "", meta)
            elif title.lower() in SECTIONS:
                seen_section = True
                in_experience = title.lower() in EXPERIENCE_SECTIONS
                emit_block(f"## {title}")
            elif not seen_section:
                emit_block(f"**{title}**")
            else:
                emit_block(f"{'####' if in_experience else '###'} {title}")
            continue

        bullet = re.match(r"^[*+-]\s+(.*)$", stripped)
        if bullet:
            lines.append(f"- {clean(bullet.group(1))}")
            continue

        # A trailing two-space hard break becomes a paragraph break.
        lines.append(clean(stripped))
        if raw_line.endswith("  "):
            lines.append("")

    # Make lists tight and collapse runs of blank lines.
    result: list[str] = []
    for index, line in enumerate(lines):
        if not line:
            following = next((l for l in lines[index + 1:] if l), "")
            if not result or not result[-1] or (
                    result[-1].startswith("- ") and following.startswith("- ")):
                continue
        result.append(line)
    while result and not result[-1]:
        result.pop()
    return "\n".join(result) + "\n"


def front_matter(path: Path) -> str:
    """Return the file's existing `---` front matter block plus a blank line."""
    if not path.exists():
        return ""
    match = re.match(r"\A---\n.*?\n---\n", path.read_text(encoding="utf-8"), re.S)
    return match.group(0) + "\n" if match else ""


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "mddoc_path", nargs="?",
        help="Local file path to markdown file")
    parser.add_argument(
        "--input", type=Path,
        help="normalize an already-exported markdown file instead of fetching")
    parser.add_argument(
        "--output", default=str(DEFAULT_OUTPUT),
        help="output path, or - for stdout (default: content/resume.md)")
    args = parser.parse_args()

    if args.input:
        markdown = args.input.read_text(encoding="utf-8")
    elif args.mddoc_path:
        markdown = fetch(args.mddoc_path)
    else:
        parser.error(
            "pass a local markdown file path or use --input")

    output = re.sub(r"\A# [^\n]*\n+", "", normalize(markdown))
    if args.output == "-":
        sys.stdout.write(output)
    else:
        path = Path(args.output)
        path.write_text(front_matter(path) + output, encoding="utf-8")
        print(f"Wrote {args.output}")


if __name__ == "__main__":
    main()
