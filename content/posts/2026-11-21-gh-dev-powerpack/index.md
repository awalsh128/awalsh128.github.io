---
title: GitHub Dev Powerpack
summary:
  "One command copies composable template sets for repo hygiene, releases and CI into a new or existing repo."
tags:
  - GitHub
  - Open Source
---

<img src="logo.svg" alt="gh-dev-powerpack logo" width="64" height="64">

> [!NOTE] This post may become out of date. See the project's
> [README](https://github.com/awalsh128/gh-dev-powerpack/blob/main/README.md) for the latest.

I published [gh-dev-powerpack](https://github.com/awalsh128/gh-dev-powerpack), a repo of templates and helper
scripts that bootstrap a new project, or raise the quality of an existing one, with a single command. It
covers repo hygiene, conventional commits, the release flow, API docs, language tooling and agent config.

Recently I had authored several applications and was refining best practices across all. There was quite a bit
of drift and manual upkeep. Also having to bootstrap new projects required examining the best goldern
template. This repo enabled me to use agentic AI hooks and reference this so I got it automatically created
and/or updated. For example the
[Cross Repo Draft Skill](https://github.com/awalsh128/skills/blob/main/skills/github/cross-repo-drift/SKILL.md)
encorporates this.

## Bootstrap a repo

Run a dry run first, then the real thing:

```bash
./bootstrap.sh -n ~/repos/my-project common conventional-commits   # dry run
./bootstrap.sh    ~/repos/my-project common conventional-commits
```

Or install it as a `gh` extension and run it from anywhere:

```bash
gh extension install awalsh128/gh-dev-powerpack
gh dev-powerpack ~/repos/my-project common conventional-commits
gh extension upgrade dev-powerpack   # later, to get new templates
```

Files that already exist in the target are skipped unless you pass `-f`. When two sets have the same file, the
set listed first wins, so list language sets before `common` (e.g. `dotnet common` to get the .NET
`.editorconfig`). Placeholders like `__OWNER__` and `__REPO__` are filled from the target's `origin` remote.

## Template sets

- `common` - `.editorconfig`, `SECURITY.md`, issue forms, a PR template, Dependabot for pinned actions and a
  label sync workflow
- `conventional-commits` - commitlint, a husky `commit-msg` hook and a PR title check
- `release-flow` - `staging` to `main` promotion after CI passes, plus rulesets
- `npm-publish` - semantic-release with release candidates on `staging` and official releases from `main`
- `npm-pages` - TypeDoc API docs deployed to GitHub Pages on official releases
- `vscode-extension` - semantic-release with VS Code's even and odd pre-release versions, publishing to the
  Marketplace and Open VSX
- `node`, `cpp`, `dotnet`, `rust` - formatting, linting and CI for each language
- `agentic` - coding-agent config for Claude Code, Codex, Copilot, Gemini and Antigravity from one source

The README has the full table, and the sets are generated from
[`templates/sets.json`](https://github.com/awalsh128/gh-dev-powerpack/blob/main/templates/sets.json).

## After you bootstrap

A few files need your project's details: the language matrix in `codeql.yml`, the package ecosystem in
`dependabot.yml`, the required check names in `rulesets/staging.json` (they must match your CI job names) and
the `TODO`s in `AGENTS.md`.

## Publishing guides

The repo also has step-by-step guides for the parts that happen outside the repo:

- GitHub setup for releases (`staging`, the Octo STS app, the `release` environment, rulesets)
- Publishing an npm package, including trusted publishing
- Publishing API docs to GitHub Pages
- Publishing a VS Code extension to the Marketplace and Open VSX

There is also `safe_fetch_exec.sh`, which checks a SHA-256 before running a downloaded script.
