#!/usr/bin/env bash
# Set up a fresh clone for local development. Safe to re-run; finished steps are skipped.
#
# - Installs Hugo extended into .tools/ (git-ignored), pinned to the version CI uses.
# - Installs Husky through npm, which enables the repository's git hooks (.husky/).
# - Installs Playwright's headless Chromium, which scripts/resume_to_pdf.sh prints the resume PDF with.
# - Runs a test build, which downloads the Hugo theme module.
#
# Usage: scripts/setup_dev.sh

set -euo pipefail

root="$(git rev-parse --show-toplevel)"
tools_dir="${root}/.tools"
hugo="${tools_dir}/hugo"
workflow="${root}/.github/workflows/hugo.yml"

info() { echo "setup_dev: $*"; }
fail() { echo "setup_dev: error: $*" >&2; exit 1; }

# Prerequisites. Go is required by Hugo to fetch the theme module; gh is only needed by the pre-commit hook.
for cmd in git go python3 curl tar node npm; do
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

# Git hooks: Husky's `prepare` script points core.hooksPath at .husky/_ during npm install.
info "installing npm dependencies (enables the Husky git hooks)..."
(cd "${root}" && npm install --no-audit --no-fund --silent)

# Headless Chromium for the resume PDF, at the version the pinned playwright package expects. Re-running is a no-op
# once it's cached in ~/.cache/ms-playwright.
info "installing Playwright's headless Chromium (prints the resume PDF)..."
(cd "${root}" && npx --no-install playwright install chromium-headless-shell)

# Test build; the first build also downloads the theme module pinned in go.mod.
info "running a test build (downloads the theme module on first run)..."
(cd "${root}" && "${hugo}" --gc --quiet)

info "done. Preview with: .tools/hugo server"
