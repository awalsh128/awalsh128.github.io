#!/usr/bin/env bash
# Replace origin/main's history with one "Initial commit." of the current files. Destructive: it
# force-pushes.
#
# Usage: scripts/wipe_git_history.sh
#
# Run it from a clean main that matches origin/main. It writes a git bundle backup next to the repo, asks
# you to type "wipe", and force-pushes only if origin/main has not moved since the fetch. It skips git hooks
# for the commit.
#
# It rewrites main only. Other branches, tags and pull request refs keep the old history until you delete
# them, and GitHub keeps old commits reachable by SHA, in forks and in caches until it garbage-collects them
# (ask GitHub support to purge cached views). Treat anything that was ever public as exposed.

set -euo pipefail

# shellcheck source=common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"
cd "${root}"

branch="$(git branch --show-current)"
[[ "${branch}" == main ]] || fail "check out main first (on '${branch}')."
[[ -z "$(git status --porcelain)" ]] || fail "the working tree is not clean; commit or stash first."
git fetch --quiet origin
old_head="$(git rev-parse main)"
[[ "${old_head}" == "$(git rev-parse origin/main)" ]] ||
  fail "main and origin/main differ; push or pull first."

backup="${root}-$(date +%Y%m%d-%H%M%S).bundle"
git bundle create --quiet "${backup}" --all
info "backed up every ref to ${backup}."

info "origin is $(git remote get-url origin)."
mapfile -t others < <(git for-each-ref --format='%(refname:short)' refs/remotes/origin refs/tags |
  grep -v -x -e origin -e origin/main -e origin/HEAD)
if ((${#others[@]} > 0)); then
  info "these refs still hold the old history until you delete them:"
  printf '  %s\n' "${others[@]}" >&2
fi

read -r -p 'Type "wipe" to replace origin/main with one commit: ' answer
[[ "${answer}" == wipe ]] || fail "aborted; nothing changed."

# Until the push succeeds, main is untouched. On any failure, return to it and drop the temporary branch.
# After success both are already done, so this does nothing.
cleanup() {
  git checkout --quiet --force main 2> /dev/null || true
  git branch --quiet -D wipe_tmp 2> /dev/null || true
}
trap cleanup EXIT

git checkout --quiet --orphan wipe_tmp
git add -A
git commit --quiet --no-verify -m "Initial commit."
git push --force-with-lease=main:"${old_head}" --set-upstream origin wipe_tmp:main
git branch --quiet -M main
info "origin/main is now one commit. Backup: ${backup}."
