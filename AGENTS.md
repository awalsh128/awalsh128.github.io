# Agent Instructions

Instructions for AI agents (Claude Code, Codex, Copilot, Cursor, ...) working in this repository. See
[README.md](README.md) for the site layout, local preview, and deployment.

## Repository conventions

- Hugo site with the Blowfish theme. On a fresh clone run `scripts/setup_dev.sh`, then build with
  `.tools/hugo --gc` and preview with `.tools/hugo server`.
- Posts are `content/posts/YYYY-MM-DD-slug.md`; the filename sets the date and the `/slug/` URL. Don't rename
  existing posts, since that breaks published URLs and Disqus threads.
- Post images go in a page bundle (`content/posts/YYYY-MM-DD-slug/index.md`), never under `static/`.
- Generated files are never edited by hand: the project list in `content/_index.md`, the library list in
  `content/api.md`, `content/resume.pdf`, `data/linkedin_recommendations.json`, `data/popular_posts.json`, and
  `.tar.gz` bundle archives. `content/resume.md` is the single source of the resume and stays in this repo.
- Wrap Markdown at 110 columns; Prettier does it (`proseWrap: always`), width comes from `.editorconfig`.

## Scripts

- Keep each script in `scripts/` small and readable: one job per script, short enough to read in one sitting
  (aim for under 150 lines). When a script outgrows that, split a self-contained part into its own script.
- Shell scripts and git hooks source `scripts/common.sh` for the repo root and the `info` / `fail` helpers,
  and new shared shell functions go there instead of being copied between scripts. Keep it POSIX `sh`, since
  Husky runs hooks with `sh`.

## Pinned posts

The homepage Posts section shows pinned posts first. A post is pinned by `pinned: YYYY-MM-DD` (the day it was
pinned) in its front matter, and unpinned by removing that line.

Whenever you publish a post or pin or unpin one, review the pins: list them with
`grep -l '^pinned:' -r content/posts`, then ask Andrew whether to unpin any pinned more than three months ago
or superseded by a newer post. Change pins only on his answer.

## Drafts stay private

This repo is public, so unpublished posts never go in it, not even as `draft: true`, untracked files, or a
stash.

- Write drafts in the private repo `awalsh128/awalsh128.github.io.private` (cloned at
  `../awalsh128.github.io.private`), under `posts/` with the same name a post would get here
  (`posts/YYYY-MM-DD-slug/index.md` for a bundle). Commit them there.
- Preview drafts with the local-only `hugo.local.toml` (listed in `.git/info/exclude`, never committed), which
  mounts the private repo's `posts/` onto `content/posts`:
  `.tools/hugo server -D --config hugo.toml,hugo.local.toml`. If the file is missing, recreate it: re-declare
  Hugo's default mounts (archetypes, assets, content, data, i18n, layouts, static) and add
  `source = "../awalsh128.github.io.private/posts"`, `target = "content/posts"`, `files = ["! **.html"]`.
  Production builds don't use it, so drafts can't be published by accident.
- If you find a draft in this repo, move it to the private repo and remove it here.
- Publish with `scripts/publish_draft.sh`. A draft is ready when Andrew says so: set `draft: false` in its front
  matter in the private repo, then run the script (`-n` lists what it would publish). It finds every draft marked
  `draft: false`, skips one that still has a `TODO(andrew):` or a same-named post in `content/posts/`, copies the
  rest without agent prompt files (such as `agent.md`), drops the `draft: false` line, builds the site as a check,
  and removes the drafts from the private repo. It commits nothing: commit the deletions in the private repo, then
  commit the new posts here on a branch and open a PR. Drafts with no `draft` key or `draft: true` are never
  published.

## Read before you start

- Writing or editing a post (bundles, links to other posts, code blocks, math, callouts, tags):
  [docs/posts.md](docs/posts.md).
- Any prose for the site or on Andrew's behalf (posts, page copy, reading list, release notes): never invent
  his experiences or opinions; leave a `TODO(andrew):` placeholder for what's needed.
- The resume, homepage projects or Posts section, CSS overrides, or page backgrounds:
  [docs/site.md](docs/site.md).
