# Andrew Walsh Website

Source for [awalsh128.com](https://awalsh128.com), built with [Hugo](https://gohugo.io) and the
[Blowfish](https://blowfish.page) theme (pulled in as a Hugo module, pinned in `go.mod`).

## Local preview

Requires [Hugo extended](https://gohugo.io/installation/) (0.165.0, matching CI) and Go.

```sh
hugo server   # http://localhost:1313, live reload
hugo --gc     # build into public/
```

## Layout

| Path                | Contents                                                        |
| ------------------- | --------------------------------------------------------------- |
| `content/posts/`    | Blog posts; `YYYY-MM-DD-slug.md` sets the date and `/slug/` URL |
| `content/_index.md` | Homepage content (projects list above recent posts)             |
| `content/*.md`      | Standalone pages (reading, resume)                              |
| `static/`           | Files copied as-is (`/assets/...` images and PDFs, `CNAME`)     |
| `assets/img/`       | Images processed by the theme (avatar, homepage background)     |
| `assets/icons/`     | Custom icons; the file name is the author-link key and tooltip  |
| `scripts/`          | Resume export normalizer and homepage projects sync             |
| `.githooks/`        | Pre-commit hook that syncs homepage projects with GitHub pins   |
| `hugo.toml`         | Site, theme, and menu configuration                             |

Callouts use GitHub alert syntax (`> [!NOTE]`, `> [!WARNING]`, ...).

## Resume

`content/resume.md` is the resume page, published at `/assets/text/resume.html` and linked
from the homepage icon (`resume` in `hugo.toml`, icon `assets/icons/resume.svg`, tooltip
"Resume"). To update it from a Google Doc markdown export:

```sh
python3 scripts/resume_to_md.py exported.md            # rewrites content/resume.md, keeps front matter
python3 scripts/resume_to_md.py exported.md --output - # preview
```

## Homepage projects

The Projects list in `content/_index.md` mirrors the repositories pinned on
[github.com/awalsh128](https://github.com/awalsh128), between the `projects:start` and `projects:end`
markers. A pre-commit hook regenerates it with `scripts/update_projects.py` (via an authenticated `gh` CLI)
and stages the result. Enable the hook once per clone:

```sh
git config core.hooksPath .githooks
python3 scripts/update_projects.py --output -   # preview without writing
```

If `gh` is unavailable or the query fails, the hook warns and the commit proceeds with the existing list.

## Theme updates

```sh
hugo mod get -u github.com/nunocoracao/blowfish/v2
```

## Deployment

Pushing to `master` runs `.github/workflows/hugo.yml`, which builds and deploys to GitHub Pages.
