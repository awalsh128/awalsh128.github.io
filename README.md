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
| `content/*.md`      | Standalone pages (reading)                                      |
| `static/`           | Files copied as-is (`/assets/...` images and PDFs, `CNAME`)     |
| `assets/img/`       | Images processed by the theme (avatar, homepage background)     |
| `assets/icons/`     | Custom icons; the file name is the author-link key and tooltip  |
| `hugo.toml`         | Site, theme, and menu configuration                             |

Callouts use GitHub alert syntax (`> [!NOTE]`, `> [!WARNING]`, ...).

## Resume

The homepage resume icon (`resume` in `hugo.toml`, icon `assets/icons/resume.svg`) links to
https://lykotek.com/assets/resume. The resume lives only in the lykotek.com repo; don't copy it here.

## Theme updates

```sh
hugo mod get -u github.com/nunocoracao/blowfish/v2
```

## Deployment

Pushing to `master` runs `.github/workflows/hugo.yml`, which builds and deploys to GitHub Pages.
