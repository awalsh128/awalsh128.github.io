---
name: hugo
description: |
  Hugo help for this repo (awalsh128.com, Blowfish theme): layouts, partials, shortcodes, Hugo Pipes, config, front
  matter, taxonomies, page bundles, template lookup order, and build or render problems. Use for any change under
  layouts/, assets/, or hugo.toml, or when a Hugo build or template fails. For post prose use site-voice; for post
  conventions read docs/posts.md.
---

# Hugo (awalsh128.com)

## This repo

- Hugo **extended**, run through `.tools/hugo` (install with `scripts/setup_dev.sh`). Build: `.tools/hugo --gc`.
  Preview: `.tools/hugo server -D`.
- Config: `hugo.toml`. Theme: Blowfish, imported as a Hugo module (`go.mod`), so theme files are not on disk. Override
  one by creating the same path under `layouts/` or `assets/`. To read the original, look in the module cache
  (`.tools/hugo mod graph`, then `$(go env GOMODCACHE)/github.com/nunocoracao/blowfish`); never edit it in place.
- Raw HTML in Markdown is allowed (`markup.goldmark.renderer.unsafe = true`).
- Posts: `content/posts/YYYY-MM-DD-slug.md`. The filename sets the date (`[frontmatter]`) and the `/slug/` URL
  (`[permalinks]`). Don't rename existing posts.
- Custom code: `layouts/shortcodes/`, `layouts/partials/`, `layouts/_default/_markup/` (render hooks),
  `assets/css/custom/NN-*.css` (numbered, loaded in order).
- Deploy: GitHub Actions (`.github/workflows/hugo.yml`) builds and publishes. Nothing is committed to a build dir.
  `public/` and `resources/` are build output; `docs/` holds contributor docs, not site output.
- Repo conventions live in [docs/posts.md](../../../docs/posts.md) and
  [docs/site.md](../../../docs/site.md). Read them before touching posts, the resume, the homepage, or CSS.

## Working method

1. Check the Hugo version (`.tools/hugo version`) before using a function; docs on the web may describe a different
   release. Prefer current names (`css.Sass`, `hugo.Data` over `.Site.Data`).
2. After any layout, shortcode, or config change, run `.tools/hugo --gc` and read the warnings, not just the exit code.
   A shortcode or partial that errors fails the whole build.
3. For rendering questions, build and inspect `public/...` HTML instead of reasoning about it.

## Template essentials

```go-html-template
{{ $v := "x" }}{{ $v = "y" }}                 {{/* := declares, = reassigns */}}
{{ with .Params.subtitle }}<h2>{{ . }}</h2>{{ end }}   {{/* rebinds . and skips empty */}}
{{ range $i, $p := .Pages }}{{ $p.Title }}{{ else }}none{{ end }}
{{ partial "x.html" . }}   {{ partialCached "x.html" . }}   {{/* cached ignores per-page changes */}}
{{ $.Site.Title }}                            {{/* $ = original context inside range/with */}}
```

- Inside `range`/`with`, `.` is rebound; use `$` for the page.
- Lookup order: Kind > Layout > Output format > Language > Type > Section. Single:
  `layouts/{type}/{layout}.html` → `layouts/{section}/single.html` → `layouts/_default/single.html`. List pages are
  analogous with `list.html`; the home page uses `layouts/index.html`.
- Base templates: `baseof.html` declares `{{ block "main" . }}{{ end }}`; child templates `{{ define "main" }}`.
- Shortcodes: `{{< name >}}` outputs HTML as-is; `{{% name %}}` renders its inner content as Markdown. Built-ins
  include `details`, `figure`, `highlight`, `ref`, `relref`, `youtube`.
- Pipes: `resources.Get "css/x.css" | minify | fingerprint`, then use `.RelPermalink` and `.Data.Integrity`.
- Page bundles: `index.md` is a leaf (page plus co-located resources, no children); `_index.md` is a branch
  (section or list page).

## Gotchas

- Every `if`, `with`, `range`, `block`, `define` needs an `{{ end }}`.
- Drafts only render with `-D` or `buildDrafts`.
- Go dates use the reference time `Mon Jan 2 15:04:05 MST 2006`, not `YYYY-MM-DD`.
- Don't pipe `.Content` into `safeHTML`; it is already safe. Use `safeHTML` only for strings you trust.
- Stale or odd module state: `.tools/hugo --gc`, then `.tools/hugo mod tidy` if `go.sum` is out of date.
- Debug: `{{ debug.Dump . }}` or `{{ printf "%#v" .Params }}`, removed before committing.

## References (read only the one you need)

- `references/configuration.md`: all config keys, environments, params, menus, modules.
- `references/content-management.md`: front matter fields, bundles, taxonomies, URLs, archetypes.
- `references/templates.md`: full syntax, lookup tables, partials, shortcodes, render hooks.
- `references/functions.md`: function namespaces with signatures.
- `references/deployment.md`: other hosts. Not needed here, since this repo deploys through GitHub Actions.
