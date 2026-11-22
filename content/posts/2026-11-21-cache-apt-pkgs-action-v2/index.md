---
title: Cache APT Packages Action v2
summary: "A TypeScript rewrite of the cache-apt-pkgs-action, now in release candidate."
tags:
  - GitHub
  - TypeScript
  - Open Source
---

<img src="logo.png" alt="Cache APT Packages logo" width="64" height="64">

> [!NOTE] This post may become out of date. See the project's
> [README](https://github.com/awalsh128/cache-apt-pkgs-action/blob/main-2/README.md) for the latest.

Version 2 of [cache-apt-pkgs-action](https://github.com/awalsh128/cache-apt-pkgs-action) is in release
candidate (`v2.0.0-rc.1`). It is a rewrite of the Bash version in TypeScript, and its inputs and outputs are
backwards compatible. I'd like people to try it before the first stable release.

Version 1 stays in maintenance mode and still gets patch updates. I wrote about it in
[Cache APT Packages v1 Released](/posts/2021-09-18-github-actions-cache-apt-pkgs-v1-released) announcement.

## Why a rewrite

The Bash scripts grew too complex to read. The action needed arrays, maps, pattern matching and real logging,
without shell and environment quirks. TypeScript fit because GitHub maintains typed libraries for it
(`@actions/core`, `@actions/cache`, `@actions/artifact`), it needs no compiled binaries, and it allows unit
tests and smoke tests in CI. See the
[v2 FAQ](https://github.com/awalsh128/cache-apt-pkgs-action/blob/main-2/V2_FAQ.MD) for more information.

The APT logic now lives in its own library, [ts-apt](https://github.com/awalsh128/ts-apt).

## Using it

```yaml
steps:
  - uses: awalsh128/cache-apt-pkgs-action@v2.0.0
    with:
      packages: graphviz doxygen
      version: 1.0
```

Change `version` to start a fresh cache (e.g. after a runner image change). The action runs on `node24`, so
self-hosted runners need a runner version that supports it. GitHub-hosted runners already do.

> [!IMPORTANT] v2 has no floating `v2` tag, on purpose. A tag that moves lets a compromised release change
> what your workflow runs. Pin an exact `v2.*.*` release or a full commit SHA. `@v1` and `@latest` still point
> at v1.

## What changed inside

- **Logging:** it uses native GitHub calls, so messages show up as run annotations.
- **Output:** it is more verbose for now, and I'll tune that as the version matures.
- **Artifacts:** the manifests, cache key and logs are stored as workflow artifacts. A failed run uploads them
  anyway.
- **Debug:** turn it on with the `debug` input or in the repository settings.

## Inputs and outputs

- `packages` - the space delimited list to install, with APT version syntax allowed (e.g. `xdot=1.2-2`)
- `version` - the cache version label
- `execute_install_scripts` - run each package's `preinst` and `postinst` script after a restore
- `empty_packages_behavior` - `error`, `warn` or `ignore` when `packages` is empty
- `debug` - more logging, plus the logs and manifests as an artifact

Outputs are `cache-hit`, `package-version-list` and `all-package-version-list`, which has the exact versions
installed (dependencies included) for audit logs.

## Help wanted

I'm looking for co-maintainers to help review changes and investigate issues. I haven't had as much time for
this action as I'd like, and I want it to stay responsive. If you're interested, reach out on the repo.

The [Version 2 FAQ](https://github.com/awalsh128/cache-apt-pkgs-action/blob/main-2/V2_FAQ.MD) covers the rest.
