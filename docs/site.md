# Site internals

Generated content, the resume, and theme overrides.

## Backgrounds

Post, list, and tag pages get a background picked at random on each load from `assets/img/backgrounds/*.jpg` (see
`layouts/partials/random-background.html`); add or remove a .jpg there to change the rotation. The homepage keeps
`assets/img/header.jpg`.

## CSS

Site CSS overrides live in `assets/css/custom/`, one file per responsibility, and are bundled into `css/custom.css` by
`layouts/partials/extend-head.html` in filename order. Add rules to the matching file (or a new numbered one); don't
recreate `assets/css/custom.css`.

## Homepage projects

The project list in `content/_index.md` is generated from GitHub pins between the `projects:start` and `projects:end`
markers by `scripts/update_projects.py`, which also downloads each project's README logo to `assets/img/projects/`
(shown by the `project-icon` shortcode). Don't edit either by hand; change pins or README logos on GitHub instead.

## Resume

`content/resume.md` is the single source of the resume. Never move it to another repo or point the homepage link
elsewhere. Update it with `scripts/resume_to_md.py`. It renders with `layouts/_default/resume.html`, and
`content/resume.pdf` is generated from the page by `scripts/resume_to_pdf.sh` (run by the pre-commit hook when the
resume, its layout, or `assets/css/custom/` is staged); don't edit the PDF by hand.

The page shows LinkedIn recommendations under References, from `data/linkedin_recommendations.json`. The pre-commit
hook refreshes it with `scripts/update_recommendations.py`, which reads only `Recommendations_Received.csv` from the
newest LinkedIn data export in `~/Downloads` (LinkedIn has no API for this). They're hidden in print, so the PDF leaves
them out. Don't edit the JSON by hand.
