#!/usr/bin/env bash
# Publish the drafts in the private drafts repo that are marked ready with `draft: false`.
#
# Drafts live in _drafts/ of the private repo (see "Drafts stay private" in AGENTS.md). Flip a draft's front matter to
# `draft: false` there when it is ready. This script finds every such draft and, for each one:
#
#   1. refuses it while a `TODO(andrew):` is left in it, or when content/posts/ already has a post of that name,
#   2. copies it to content/posts/ without agent prompt files (agent.md) and drops the `draft: false` line, since
#      published posts don't carry the key,
#   3. builds the site once as production does, to check what was copied,
#   4. removes it from the private repo and stages the deletion there.
#
# Drafts with no `draft` key or `draft: true` are left alone. Nothing is committed or pushed: review the result, then
# commit and push the private repo's deletions and open a PR here for the new posts.
#
# Usage:
#   scripts/publish_draft.sh              publish every draft marked `draft: false`
#   scripts/publish_draft.sh <name>...    only these drafts, by name (2026-11-21-skills)
#   scripts/publish_draft.sh -n           list what would be published, change nothing
#
# DRAFTS_REPO sets the private repo's path (default: ../awalsh128.github.io.private).

set -euo pipefail

# shellcheck source=common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

drafts_repo="${DRAFTS_REPO:-${root}/../awalsh128.github.io.private}"
posts_dir="${root}/content/posts"
dry_run=0
wanted=()

for arg in "$@"; do
  case "${arg}" in
    -n | --dry-run) dry_run=1 ;;
    -*) fail "unknown option: ${arg}" ;;
    *) wanted+=("${arg%/}") ;;
  esac
done

[[ -d "${drafts_repo}/_drafts" ]] || fail "no _drafts/ in ${drafts_repo} (set DRAFTS_REPO)"
drafts_repo="$(cd "${drafts_repo}" && pwd)"

# The post file of a draft: index.md for a bundle, the file itself for a single-file draft.
post_file() {
  local entry="$1"
  if [[ -d "${entry}" ]]; then echo "${entry}/index.md"; else echo "${entry}"; fi
}

# Succeeds when the file's front matter, the block between the first two --- lines, has `draft: false`.
is_ready() {
  [[ -f "$1" ]] && awk '
    NR == 1 { if ($0 != "---") exit 1; next }
    $0 == "---" { exit !found }
    /^draft:[[:space:]]*false[[:space:]]*$/ { found = 1 }
    END { exit !found }
  ' "$1"
}

# Copy a file, leaving out its front matter's `draft: false` line.
strip_draft_key() {
  awk '
    NR == 1 { print; infm = 1; next }
    infm && $0 == "---" { infm = 0 }
    infm && /^draft:[[:space:]]*false[[:space:]]*$/ { next }
    { print }
  ' "$1" > "$2"
}

selected() {
  local name="$1" w
  [[ ${#wanted[@]} -eq 0 ]] && return 0
  for w in "${wanted[@]}"; do
    [[ "${w}" == "${name}" || "${w}" == "${name%.md}" ]] && return 0
  done
  return 1
}

ready=()
blocked=0
skipped=0
shopt -s nullglob
for entry in "${drafts_repo}"/_drafts/*; do
  name="$(basename "${entry}")"
  [[ -d "${entry}" || "${entry}" == *.md ]] || continue
  selected "${name}" || continue
  if ! is_ready "$(post_file "${entry}")"; then
    skipped=$((skipped + 1))
    continue
  fi
  if grep -rn --exclude=agent.md 'TODO(andrew)' "${entry}" > /dev/null 2>&1; then
    info "blocked, unresolved TODO(andrew): ${name}"
    grep -rn --exclude=agent.md 'TODO(andrew)' "${entry}" | sed "s|^${drafts_repo}/||; s|^|  |" >&2
    blocked=$((blocked + 1))
    continue
  fi
  if [[ -e "${posts_dir}/${name}" ]]; then
    info "blocked, content/posts/${name} already exists"
    blocked=$((blocked + 1))
    continue
  fi
  ready+=("${name}")
done

info "${#ready[@]} ready, ${blocked} blocked, ${skipped} not marked draft: false"
if [[ ${#ready[@]} -eq 0 ]]; then
  [[ ${blocked} -eq 0 ]] || exit 1
  exit 0
fi
printf '  %s\n' "${ready[@]}" >&2
[[ ${dry_run} -eq 1 ]] && exit 0

copied=()
undo() {
  local c
  for c in "${copied[@]}"; do rm -rf "${posts_dir:?}/${c}"; done
}

for name in "${ready[@]}"; do
  src="${drafts_repo}/_drafts/${name}"
  if [[ -d "${src}" ]]; then
    cp -r "${src}" "${posts_dir}/${name}"
    copied+=("${name}")
    rm -f "${posts_dir}/${name}/agent.md"
    strip_draft_key "${src}/index.md" "${posts_dir}/${name}/index.md"
  else
    copied+=("${name}")
    strip_draft_key "${src}" "${posts_dir}/${name}"
  fi
done

hugo_bin="${root}/.tools/hugo"
[[ -x "${hugo_bin}" ]] || hugo_bin="hugo"
build_dir="$(mktemp -d)"
trap 'rm -rf "${build_dir}"' EXIT
info "building the site to check the new posts"
if ! (cd "${root}" && HUGO_ENVIRONMENT=production "${hugo_bin}" --gc --minify -d "${build_dir}" > /dev/null); then
  undo
  fail "the site did not build with the new posts, so they were not copied (run hugo to see why)"
fi

for name in "${ready[@]}"; do
  git -C "${drafts_repo}" rm -r -q --cached --ignore-unmatch -- "_drafts/${name}"
  rm -rf "${drafts_repo:?}/_drafts/${name}"
  info "published ${name}"
done

branch="$(git -C "${root}" branch --show-current)"
[[ "${branch}" != "master" ]] || info "you are on master: create a branch before committing"
info "next: commit the deletions in ${drafts_repo}, then commit the new posts here and open a PR"
[[ ${blocked} -eq 0 ]] || exit 1
