---
title: Winston Host Adapters
slug: winston-host-adapters-release
summary:
  "Winston loggers for VS Code extensions and GitHub Actions, plus a small interface for any other host."
tags:
  - TypeScript
  - Logging
  - GitHub
  - Open Source
---

<img src="logo.png" alt="Winston host adapters logo" width="64" height="64">

<!-- prettier-ignore-start -->
> [!NOTE]
> This post may become out of date. See the project's
> [README](https://github.com/awalsh128/winston-host-adapters/blob/main/README.md) for the latest.
<!-- prettier-ignore-end -->

I published [Winston Host Adapters](https://github.com/awalsh128/winston-host-adapters), a set of
[Winston](https://github.com/winstonjs/winston) loggers for the places my code runs: VS Code extensions and
GitHub Actions workflows. A host is anything else you give a small adapter to.

<!-- prettier-ignore-start -->
> [!NOTE]
> This is an unofficial extension of Winston and is not affiliated with the Winston project.
<!-- prettier-ignore-end -->

While developing GitHub actions, NPM based libraries, and VSCode extensions, there were certain features that
I kept replicating across my projects (e.g. file references in log lines, lazy log evaluation for expensive
operations, contextual logging based on code execution scope, etc). The aim was not to reinvent things in how
winston handles logging but to extend it for best practices in different project types.

## Features

- **Lazy logging:** `logger.debug(() => message)` builds the message only when its level is enabled.
- **One small host interface:** a transport factory, the host's level and a dispose hook. An adapter is about
  a page of code.
- **Follows the host's level:** a VS Code output channel's level, or the runner's debug setting.
- **Standalone transports:** `ActionsTransport`, `CheckRunTransport` and `OutputChannelTransport` work in any
  `winston.createLogger`.
- **Plain Winston:** Winston stays the only engine, so other transports and `child()` metadata work as usual.

## Packages

- `@awalsh128/winston-host` - the shared base, which depends only on Winston and never imports `vscode`
- `@awalsh128/winston-vscode` - `ExtensionLogger`, `OutputChannelTransport` and `forDocument`
- `@awalsh128/winston-github-actions` - annotations (also through the Checks API), groups and secret masking

## In a GitHub Action

```sh
npm install @awalsh128/winston-github-actions @actions/core
```

```ts
import { ActionsLogger } from "@awalsh128/winston-github-actions";

const logger = new ActionsLogger();
logger.info("Scanning");
logger.forLocation({ path: "src/app.ts", line: 3 }).warn("Block is not sorted"); // an annotation

logger.debug(() => `Config: ${JSON.stringify(config)}`); // built only when debug logging is on

const group = logger.group("Build"); // a collapsible group in the workflow log
build();
group.dispose(); // ends the group and logs "Build (42ms)"
```

## Writing an adapter

An adapter implements `Host` and passes it to `HostLogger`:

```ts
import { HostLogger, type Host } from "@awalsh128/winston-host";

const host: Host = {
  createTransport: (format) => new MyHostTransport({ format }), // a winston-transport subclass
  getLevel: () => "info",
  onLevelChange: (listener) => myHost.onLevel(listener), // optional
  dispose: () => myHost.close(), // optional
};
const logger = new HostLogger(host);
```

Levels, `Location` and the lazy methods are the same everywhere. Winston is Node-only, so browsers aren't
supported.

For VS Code, see the
[`winston-vscode` README](https://github.com/awalsh128/winston-host-adapters/tree/main/packages/winston-vscode#readme).
The [API reference](https://awalsh128.com/winston-host-adapters/) covers each package, and bugs go in the
repo's [issues](https://github.com/awalsh128/winston-host-adapters/issues).
