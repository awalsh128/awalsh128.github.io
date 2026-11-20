#!/usr/bin/env bash
# Sync generated files for the commit and stage them. Run by .husky/pre-commit; run it by hand to refresh the files.
#
# Usage: scripts/precommit.sh [--local]
#   --local  Update files in the working tree only. It makes no gh calls and no git commands, and stages nothing.
#            It skips the GitHub-backed syncs (homepage projects, API page) and the PDF and archive rebuilds, since
#            those depend on what is staged.
#
# 1. Sync the homepage project list and project logos with the REPOS list in update_projects.py.
# 2. Sync the API page with the repositories that publish API docs (update_apis.py).
# 3. Refresh the homepage's popular posts from the newest Search Console export in ~/Downloads.
# 4. Refresh the resume page's LinkedIn recommendations from the newest LinkedIn data export in ~/Downloads.
# 5. Regenerate content/resume.pdf when the resume changes.
# 6. Rebuild post download archives (e.g. scaffold.tar.gz) when the folder they're built from changes.

# shellcheck source=common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

local_only=0
case "${1:-}" in
"") ;;
--local) local_only=1 ;;
*) fail "unknown argument '$1'; usage: precommit.sh [--local]" ;;
esac

# run_sync <what> <script> <path>...: run a sync script and, unless --local, stage the paths it changed. A failing
# script (no gh, no network) only skips that sync; the commit continues with the existing files. -A also stages
# removed files, such as logos of repositories no longer listed.
run_sync() {
  what="$1"
  script="$2"
  shift 2
  if ! python3 "${root}/scripts/${script}"; then
    info "skipping ${what} sync; continuing with the existing files."
  elif [ "${local_only}" -eq 0 ] && [ -n "$(git -C "${root}" status --porcelain -- "$@")" ]; then
    git -C "${root}" add -A -- "$@"
    info "staged updated $*."
  fi
}

# The GitHub-backed syncs call gh, so --local leaves them out.
if [ "${local_only}" -eq 0 ]; then
  run_sync "homepage projects" update_projects.py content/_index.md assets/img/projects
  run_sync "API page" update_apis.py content/api.md
else
  info "--local: skipping the GitHub-backed syncs (homepage projects, API page)."
fi
# Search clicks that rank the homepage's popular posts. Without a Search Console export it changes nothing.
run_sync "popular posts" update_popular_posts.py data/popular_posts.json
# Recommendations show on the resume page (not in the PDF). Without a LinkedIn export it changes nothing.
run_sync "recommendations" update_recommendations.py data/linkedin_recommendations.json

if [ "${local_only}" -eq 1 ]; then
  info "--local: skipping the PDF and archive rebuilds, which depend on staged changes."
  exit 0
fi

# Regenerate the PDF resume when its source, layout, or styling is part of the commit.
# Renders the working tree, so stage the resume changes you want reflected in the PDF.
pdf="content/resume.pdf"
if ! git -C "${root}" diff --cached --quiet -- content/resume.md layouts/_default/resume.html assets/css/custom/; then
  if "${root}/scripts/resume_to_pdf.sh"; then
    git -C "${root}" add -- "${pdf}"
    info "staged regenerated ${pdf}."
  else
    info "skipping PDF resume; commit continues with the existing ${pdf}."
  fi
fi

# Rebuild a post's download archive when files in the folder it's built from are part of the commit.
for archive in "${root}"/content/posts/*/*.tar.gz; do
  [ -e "${archive}" ] || continue
  folder="${archive%.tar.gz}"
  rel="${archive#"${root}/"}"
  if [ -d "${folder}" ] && ! git -C "${root}" diff --cached --quiet -- "${folder}"; then
    "${root}/scripts/pack_bundle_archives.sh" "${folder}"
    git -C "${root}" add -- "${rel}"
    info "staged rebuilt ${rel}."
  fi
done
