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

| Path             | Contents                                                        |
| ---------------- | --------------------------------------------------------------- |
| `content/posts/` | Blog posts; `YYYY-MM-DD-slug.md` sets the date and `/slug/` URL |
| `content/notes/` | Reference notes, served at `/notes/<name>/`                     |
| `content/*.md`   | Standalone pages (projects, reading, resume)                    |
| `static/`        | Files copied as-is (`/assets/...` images and PDFs, `CNAME`)     |
| `assets/img/`    | Images processed by the theme (avatar, homepage background)     |
| `assets/icons/`  | Custom icons; the file name is the author-link key and tooltip  |
| `scripts/`       | `resume_to_md.py`: normalizes a Google Docs resume export       |
| `hugo.toml`      | Site, theme, and menu configuration                             |

Callouts use GitHub alert syntax (`> [!NOTE]`, `> [!WARNING]`, ...).

## Resume

`content/resume.md` is the resume page, published at `/assets/text/resume.html` and linked
from the homepage icon (`resume` in `hugo.toml`, icon `assets/icons/resume.svg`, tooltip
"Resume"). To update it from a Google Doc markdown export:

```sh
python3 scripts/resume_to_md.py exported.md            # rewrites content/resume.md, keeps front matter
python3 scripts/resume_to_md.py exported.md --output - # preview
```

## Theme updates

```sh
hugo mod get -u github.com/nunocoracao/blowfish/v2
```

## Deployment

Pushing to `master` runs `.github/workflows/hugo.yml`, which builds and deploys to GitHub Pages.
