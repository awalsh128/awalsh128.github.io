#!/usr/bin/env bash
# Replace origin/master's history with one "Initial commit." of the current files. Destructive: it force-pushes.
#
# Usage: scripts/wipe_git_history.sh
#
# Run it from a clean master that matches origin/master. It writes a git bundle backup next to the repo, asks you to
# type "wipe", and force-pushes only if origin/master has not moved since the fetch. It skips git hooks for the commit.
#
# It rewrites master only. Other branches, tags and pull request refs keep the old history until you delete them, and
# GitHub keeps old commits reachable by SHA, in forks and in caches until it garbage-collects them (ask GitHub support
# to purge cached views). Treat anything that was ever public as exposed.

set -euo pipefail

# shellcheck source=common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"
cd "${root}"

branch="$(git branch --show-current)"
[[ "${branch}" == master ]] || fail "check out master first (on '${branch}')."
[[ -z "$(git status --porcelain)" ]] || fail "the working tree is not clean; commit or stash first."
git fetch --quiet origin
head="$(git rev-parse master)"
[[ "${head}" == "$(git rev-parse origin/master)" ]] || fail "master and origin/master differ; push or pull first."

backup="$(dirname "${root}")/$(basename "${root}")-$(date +%Y%m%d-%H%M%S).bundle"
git bundle create --quiet "${backup}" --all
info "backed up every ref to ${backup}."

info "origin is $(git remote get-url origin)."
others="$(git for-each-ref --format='%(refname:short)' refs/remotes/origin refs/tags |
  grep -v -x -e origin -e origin/master -e origin/HEAD || true)"
if [[ -n "${others}" ]]; then
  info "these refs still hold the old history until you delete them:"
  echo "  ${others//$'\n'/$'\n'  }" >&2
fi

read -r -p 'Type "wipe" to replace origin/master with one commit: ' answer
[[ "${answer}" == wipe ]] || fail "aborted; nothing changed."

# Until the push succeeds, master is untouched; on any failure go back to it and drop the temporary branch.
finished=0
cleanup() {
  if [[ "${finished}" -eq 0 ]]; then
    git checkout --quiet --force master 2> /dev/null || true
    git branch --quiet -D wipe_tmp 2> /dev/null || true
  fi
}
trap cleanup EXIT

git checkout --quiet --orphan wipe_tmp
git add -A
git commit --quiet --no-verify -m "Initial commit."
git push --force-with-lease=master:"${head}" origin wipe_tmp:master
git branch --quiet -M master
git branch --quiet --set-upstream-to=origin/master master
finished=1
info "origin/master is now one commit. Backup: ${backup}."
