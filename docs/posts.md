# Writing posts

Authoring conventions for `content/posts/`. For tone, use the `site-voice` skill (`.claude/skills/site-voice/SKILL.md`).

## Front matter

Use Hugo and Blowfish keys only: `title`, `summary`, `tags`, and `lastmod` for the last meaningful update. The date comes
from the file or folder name, so a `date` key is optional and doesn't override it. Leave out keys from the old Jekyll
and Blogger site (`author`, `toc`, `toc_icon`, `thumbnail`, `modified_time`, `last_modified_at`, `blogger_*`);
nothing reads them. The table of contents is on for every post via `showTableOfContents` in `hugo.toml`.

## Page bundles

A post with its own images is a page bundle instead of a single file: `content/posts/YYYY-MM-DD-slug/index.md` with the
images beside it, referenced by bare filename (e.g. `![alt](diagram.svg)`). The folder name sets the date and URL the
same way, and the images also render in the VSCode Markdown preview.

## Linking to another post

Link by content path with empty link text, e.g. `[](/posts/2026-11-04-safer-curl-bash)` (the file or folder name under
`content/`, with the date and without `.md`; add `#heading` for a section).
`layouts/_default/_markup/render-link.html` fills in the post's title and published URL, so the link survives title
changes. Give link text to override the title. An empty link that isn't a page fails the build.

## Source files and code blocks

To show a whole source file, put it in the page bundle and use `{{< code-include source="script.sh" >}}` instead of
pasting it into a fenced block. The language defaults to the file extension; override it with `language="bash"`, and
pass Hugo highlight options with `options="linenos=table"`. Add `collapse="true"` to hide a long file behind a
clickable header (or `collapse="open"` to start expanded), with `title="..."` to change the header from the file name.
The file is also published beside the post, so readers can download it.

To collapse a long fenced code block that isn't a bundle file, add attributes to its opening fence, e.g.
```` ```yaml {collapse="true" title=".github/workflows/publish.yml"} ````. It renders as the same card as `code-include`
(`layouts/partials/code-card.html`, via `layouts/_default/_markup/render-codeblock.html`); blocks without `collapse`
render as before.

## Download archives

To let readers download several bundle files at once, keep them in a folder in the bundle (e.g. `scaffold/`) and run
`scripts/pack_bundle_archives.sh <bundle>/scaffold/` once to create `scaffold.tar.gz` beside it. After that the
pre-commit hook rebuilds the archive whenever files in the folder are staged; don't edit the archive by hand. Don't
start file names in the folder with a dot, since Hugo doesn't publish dotfiles.

## Math

Math uses LaTeX: `$...$` inline and `$$...$$` on their own lines for display. Hugo renders it to KaTeX at build time
(no shortcode or JavaScript needed). Escape a literal dollar sign in prose as `\$`. Units use siunitx-style macros
defined in `layouts/_default/_markup/render-passthrough.html`: `\qty{43.2}{min}`, `\unit{km/h}`, `\num{43200}`,
`\percent` (`\SI` and `\si` also work).

## Callouts

Use GitHub alert syntax (`> [!NOTE]`, `> [!WARNING]`), not shortcodes.

## Tags

Tags use a fixed vocabulary; reuse an existing tag before adding a new one, and give each post 1-4 tags. Pick the
language(s) shown in code, then the platform, then the topic:

- Languages: `C`, `C#`, `C++`, `Java`, `PowerShell`, `Python`, `TypeScript`.
- Platforms: `.NET`, `Android`, `Entity Framework`, `GitHub`, `VS Code`.
- Topics: `Algorithms`, `Build Systems`, `Career`, `Compression`, `Computer Science`, `Concurrency`,
  `Data Acquisition`, `Databases`, `Logging`, `Open Source` (project releases), `Performance`, `Reliability`,
  `Security`, `Software Design`, `Static Analysis`, `System Administration`, `Testing`.
- Cross-posting: `Article` marks a post to republish on lykotek.com. Hugo exports these posts to
  `/tags/article/lykotek.json` (`layouts/_default/term.lykotekexport.json`), and lykotek.com's sync script copies them
  from the live site. It doesn't count toward the 1-4 tags. Everything in a tagged post also becomes public on the
  Lykotek business site, so use it only for posts that belong there.

Spell tags exactly as listed; Hugo merges tags case-insensitively into one URL, so `vscode` and `VSCode` would collide.
Add a new topic only when it is the main subject of the post.
