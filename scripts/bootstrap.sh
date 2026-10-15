#!/usr/bin/env bash
# Bootstrap a fresh clone for local development. Safe to re-run; finished steps are skipped.
#
# - Installs Hugo extended into .tools/ (git-ignored), pinned to the version CI uses.
# - Enables the repository's git hooks (.githooks/).
# - Runs a test build, which downloads the Hugo theme module.
#
# Usage: scripts/bootstrap.sh

set -euo pipefail

root="$(git rev-parse --show-toplevel)"
tools_dir="${root}/.tools"
hugo="${tools_dir}/hugo"
workflow="${root}/.github/workflows/hugo.yml"

info() { echo "bootstrap: $*"; }
fail() { echo "bootstrap: error: $*" >&2; exit 1; }

# Prerequisites. Go is required by Hugo to fetch the theme module; gh is only needed by the pre-commit hook.
for cmd in git go python3 curl tar; do
  command -v "${cmd}" > /dev/null || fail "${cmd} is required but not installed."
done
if ! command -v gh > /dev/null; then
  info "warning: gh CLI not found; the pre-commit hook will skip syncing homepage projects."
elif ! gh auth status > /dev/null 2>&1; then
  info "warning: gh is not authenticated (run 'gh auth login'); the pre-commit hook will skip syncing projects."
fi

# Hugo, pinned to the CI version so local and deployed builds match.
version="$(sed -n 's/^ *HUGO_VERSION: *\([0-9.]*\).*/\1/p' "${workflow}")"
[[ -n "${version}" ]] || fail "could not read HUGO_VERSION from ${workflow}."

if [[ -x "${hugo}" ]] && "${hugo}" version | grep -q "v${version}-.*+extended"; then
  info "Hugo extended ${version} already installed in .tools/."
else
  case "$(uname -s)/$(uname -m)" in
    Linux/x86_64) platform="linux-amd64" ;;
    Linux/aarch64 | Linux/arm64) platform="linux-arm64" ;;
    Darwin/*) platform="darwin-universal" ;;
    *) fail "unsupported platform $(uname -s)/$(uname -m); install Hugo extended ${version} manually." ;;
  esac
  url="https://github.com/gohugoio/hugo/releases/download/v${version}/hugo_extended_${version}_${platform}.tar.gz"
  info "installing Hugo extended ${version} (${platform}) into .tools/..."
  mkdir -p "${tools_dir}"
  curl -fsSL "${url}" | tar -xz -C "${tools_dir}" hugo
fi

# Git hooks.
if [[ "$(git -C "${root}" config --local core.hooksPath || true)" == ".githooks" ]]; then
  info "git hooks already enabled."
else
  git -C "${root}" config --local core.hooksPath .githooks
  info "enabled git hooks (.githooks/)."
fi

# Test build; the first build also downloads the theme module pinned in go.mod.
info "running a test build (downloads the theme module on first run)..."
(cd "${root}" && "${hugo}" --gc --quiet)

info "done. Preview with: .tools/hugo server"
