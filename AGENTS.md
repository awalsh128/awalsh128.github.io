# Agent Instructions

Instructions for AI agents (Claude Code, Codex, Copilot, Cursor, ...) working in this repository. See
[README.md](README.md) for the site layout, local preview, and deployment.

## Repository conventions

- Hugo site with the Blowfish theme. On a fresh clone run `scripts/setup_dev.sh`, then build with
  `.tools/hugo --gc` and preview with `scripts/preview.sh`.
- Posts are `content/posts/YYYY-MM-DD-slug.md`; the filename sets the date and the `/slug/` URL. Don't rename
  existing posts, since that breaks published URLs and Disqus threads.
- A post whose slug matches one of my repositories that has a GitHub Pages site sets `slug: <repo>-release`,
  or the repo's site takes over its URL ([docs/posts.md](docs/posts.md), "Release posts").
- Post images go in a page bundle (`content/posts/YYYY-MM-DD-slug/index.md`), never under `static/`.
- Generated files are never edited by hand: the project list in `content/_index.md`, the library list in
  `content/api.md`, `content/resume.pdf`, `data/linkedin_recommendations.json`, `data/popular_posts.json`, and
  `.tar.gz` bundle archives. `content/resume.md` is the single source of the resume and stays in this repo.
- Wrap Markdown at 110 columns; Prettier does it (`proseWrap: always`), width comes from `.editorconfig`.

## Read before you start

- Writing or editing a post (bundles, links to other posts, code blocks, math, callouts, tags):
  [docs/posts.md](docs/posts.md).
- Any prose for the site or on Andrew's behalf (posts, page copy, reading list, release notes): never invent
  his experiences or opinions; leave a `TODO(andrew):` placeholder for what's needed.
- The resume, homepage projects or Posts section, CSS overrides, or page backgrounds:
  [docs/site.md](docs/site.md).

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
- Preview drafts with the local-only `hugo.local.toml` (listed in `.git/info/exclude`, never committed):
  `scripts/preview.sh -D --config hugo.toml,hugo.local.toml`. If it is missing, recreate it from the private
  repo's README ("Serve the drafts"). Production builds don't read it, so drafts can't be published by
  accident.
- If you find a draft in this repo, move it to the private repo and remove it here.
- A draft is ready when Andrew says so: set `draft: false` in its front matter in the private repo. Its
  Publish posts workflow then opens the PR here (`publish/<slug>`), or run `scripts/publish_draft.sh` by hand
  (the script's header says what it does; `-n` lists what it would publish). The script commits nothing:
  commit the deletions in the private repo, then commit the new posts here on a branch and open a PR. Drafts
  with no `draft` key or `draft: true` are never published. The Octo STS policy that lets the workflow open
  the PR is `.github/chainguard/publish-post.sts.yaml`.
