---
title: Agent Skills for Claude Code
summary:
  "Installable skills that apply one set of conventions to READMEs, CI workflows, TypeScript and tests."
tags:
  - Open Source
---

<img src="logo.svg" alt="Agent Skills logo" width="64" height="64">

> [!NOTE] This post may become out of date. See the project's
> [README](https://github.com/awalsh128/skills/blob/main/README.md) for the latest.

I published a set of [agent skills](https://github.com/awalsh128/skills) for Claude Code, or any agent that
reads `SKILL.md` files. Each skill covers a task I repeat often (e.g. writing a README, reviewing a CI
workflow, adding unit tests) and applies the same conventions every time.

The reason for these skill as opposed to letting the LLM figure it out itself was because I noticed some
decisions were taken by the agent that didn't match my semantic understanding of that area of work in terms of
best practices for specific domains (e.g. VSCE publishing, code design patterns, unit tests). LLMs can suffer
from generating anti-patterns in coding because they are trained on massive, uncurated public code that
over-represent insecure, outdated, or flawed code. My most common use case was in
[unit tests](https://github.com/awalsh128/skills/blob/main/skills/testing/unit-tests/SKILL.md).

Obviously this comes with caveats as different models evolve and skill data can become redundant or even
hinder efficient execution. It is constantly a work in progress.

## What you get

- **One folder per skill:** a `SKILL.md` plus an optional `references/` folder that loads only when needed.
- **Evals:** most skills ship their own test cases in `evals/`.
- **Plugin and marketplace manifests:** so Claude Code can install them as a plugin.

## Installation

Claude Code 2.1.275 or later can install it as a plugin:

```sh
claude plugin marketplace add awalsh128/skills
claude plugin install awalsh128@awalsh128-skills
```

The [skills CLI](https://github.com/vercel-labs/skills) works across agents:

```sh
npx skills add awalsh128/skills
```

Add `--skill create-readme` to pick one skill and `-a claude-code` to target Claude Code. You can also copy a
skill's folder into `~/.claude/skills/` by hand.

Then ask for what the skill does (e.g. "write a README for this repo").

## The skills

- `npm-audit` - triage and fix `npm audit` findings with the smallest safe change
- `project-setup` - set up a new project's VS Code or Cursor, EditorConfig, Prettier and husky baseline
- `vsce-project` - publish a VS Code extension to the Marketplace and Open VSX, and only runs when called by
  name
- `check-pr-release-type` - check a pull request title's Conventional Commits type against what its diff does
  to consumers
- `create-readme` - write, revise or audit a README, plus the repo description and topics
- `cross-repo-drift` - audit your public repos for drift from a standards source, then open fix PRs on
  approval
- `github-cicd` - create or review GitHub Actions workflows (promotion, releases, OIDC, pinned actions)
- `github-ts-action` - create, extend or review a TypeScript GitHub Action
- `code-design` - write or review code in any language, readable over terse
- `typescript` - my TypeScript specifics on top of `code-design`
- `unit-tests` - write, revise or audit unit tests in any language

## Layout

```text
skills/<group>/<skill-name>/
├── SKILL.md      # frontmatter name and description, then the instructions
├── references/   # longer material, read only when the skill needs it
└── evals/        # test cases
```

These are opinionated, since they encode my conventions. Fork the repo and change a skill's `SKILL.md` if
yours differ. The [README](https://github.com/awalsh128/skills#readme) has the full list and the latest
changes.
