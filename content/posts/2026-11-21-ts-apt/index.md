---
title: ts-apt, an APT Library for TypeScript
summary: "A typed TypeScript library for APT and apt-fast operations on Debian-based Linux systems."
tags:
  - TypeScript
  - Open Source
---

<img src="logo.png" alt="ts-apt logo" width="64" height="64">

<!-- prettier-ignore-start -->
> [!NOTE]
> This post may become out of date. See the project's
> [README](https://github.com/awalsh128/ts-apt/blob/main/README.md) for the latest.
<!-- prettier-ignore-end -->

I released [ts-apt](https://github.com/awalsh128/ts-apt), a TypeScript library for APT package operations on
Debian-based Linux systems. It works with the standard APT binaries and with
[apt-fast](https://github.com/ilikenwf/apt-fast).

I pulled it out of my [cache-apt-pkgs-action](https://github.com/awalsh128/cache-apt-pkgs-action) rewrite. The
APT code had grown into the hardest part of that action, so it made sense to give it its own tests and release
cycle.

## Features

- **Package operations:** install, remove, upgrade and search packages, and read package metadata and
  installed file lists.
- **apt-fast when available:** it falls back to apt-get automatically when apt-fast isn't installed.
- **Pluggable command runners:** commands run through a small interface, so you can swap in your own.
- **Typed errors:** separate errors for validation, availability and command failures.
- **Locking:** mutating operations take a lock, and read-only ones can run in parallel.

## Quick Start

It needs Node.js 24 or newer and a Linux environment with APT tooling.

```bash
npm install ts-apt
```

```ts
import { createPackageManager } from "ts-apt";

const manager = await createPackageManager(false);

const searchResults = await manager.search(["vim", "python"]);
const installed = await manager.listInstalled();

console.log(searchResults.length, installed.length);
```

<!-- prettier-ignore-start -->
> [!NOTE]
> Mutating operations need `sudo`. If the running user doesn't have it, those calls fail.
<!-- prettier-ignore-end -->

## Testing

Unit tests run on their own. The integration tests run against real APT tooling, so they are slower:

```bash
npm run test:unit
npm run test:integration
```

## Links

- [Source and README](https://github.com/awalsh128/ts-apt)
- [API reference](https://awalsh128.com/ts-apt/)
- [npm package](https://www.npmjs.com/package/ts-apt)

Parsing of the apt output uses [js-internet-message](https://github.com/moll/js-internet-message), which
avoids brittle string handling. Bugs and requests go in the repo's issues.
