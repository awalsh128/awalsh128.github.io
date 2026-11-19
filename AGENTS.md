# Agent Instructions

Instructions for AI agents (Claude Code, Codex, Copilot, Cursor, ...) working in this repository. See
[README.md](README.md) for the site layout, local preview, and deployment.

## Repository conventions

- Hugo site with the Blowfish theme. On a fresh clone run `scripts/setup_dev.sh`, then build with `.tools/hugo --gc`
  and preview with `.tools/hugo server`.
- Posts are `content/posts/YYYY-MM-DD-slug.md`; the filename sets the date and the `/slug/` URL. Don't rename
  existing posts, since that breaks published URLs and Disqus threads.
- Post images go in a page bundle (`content/posts/YYYY-MM-DD-slug/index.md`), never under `static/`.
- Generated files are never edited by hand: the project list in `content/_index.md`, the library list in
  `content/api.md`, `content/resume.pdf`, `data/linkedin_recommendations.json`, and `.tar.gz` bundle archives.
  `content/resume.md` is the single source of the resume and stays in this repo.
- Wrap Markdown at 120 columns.

## Drafts stay private

This repo is public, so unpublished posts never go in it, not even as `draft: true`, untracked files, or a stash.

- Write drafts in the private repo `awalsh128/awalsh128.github.io.private` (cloned at
  `../awalsh128.github.io.private`), under `_drafts/` with the same name a post would get here
  (`_drafts/YYYY-MM-DD-slug/index.md` for a bundle). Commit them there.
- If you find a draft in this repo, move it to the private repo and remove it here.
- Bring a draft into `content/posts/` only when Andrew says it's ready to publish. Remove `draft: true` and any
  agent prompt files (such as `agent.md`) and resolve every `TODO(andrew):` first, then delete it from the private repo.

## Read before you start

- Writing or editing a post (bundles, links to other posts, code blocks, math, callouts, tags):
  [docs/posts.md](docs/posts.md).
- Any prose for the site or on Andrew's behalf (posts, page copy, reading list, release notes): the `site-voice` skill,
  [.claude/skills/site-voice/SKILL.md](.claude/skills/site-voice/SKILL.md). Never invent his experiences or opinions;
  leave a `TODO(andrew):` placeholder for what's needed.
- The resume, homepage projects, CSS overrides, or page backgrounds: [docs/site.md](docs/site.md).
