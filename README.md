# Andrew Walsh Website

This repository contains the source for a static personal website and blog built with Jekyll and the Minimal Mistakes theme.

## Local preview

This site is intended for local preview and static generation, not for GitHub Pages deployment.

### Prerequisites

- Ruby
- Bundler

On Debian/Ubuntu, the local helper script can install the required packages if missing:

```bash
./scripts/local-preview.sh
```

### Commands

```bash
# run local preview server
npm run preview

# build static output locally without deploying
npm run build:local
```

You can also run the script directly:

```bash
./scripts/local-preview.sh serve
./scripts/local-preview.sh build
```

The local build output is written to `_site-local`.

## Notes

- The build uses a repo-local Bundler cache under `.bundle` to avoid system gem permission issues.
- Dependency versions are intentionally pinned for compatibility with the current Jekyll stack.
- The site is content-focused and works well as a static blog/portfolio site.
