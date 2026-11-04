#!/usr/bin/env bash
# Render content/resume.md to content/resume.pdf with the same layout and styling as the web page.
#
# Builds the site into a temporary directory, serves it on localhost, and prints the resume page with headless
# Chrome/Chromium. Print styling lives in assets/css/custom/50-resume-print.css.
#
# Browser lookup order: $CHROME, then google-chrome / chromium on PATH, then Playwright's cached Chromium
# (install one with: npx playwright install chromium-headless-shell).
#
# Usage: scripts/resume_to_pdf.sh [output.pdf]

set -euo pipefail

root="$(git rev-parse --show-toplevel)"
hugo="${root}/.tools/hugo"
output="${1:-${root}/content/resume.pdf}"
page="assets/text/resume.html"

info() { echo "resume_to_pdf: $*" >&2; }
fail() { echo "resume_to_pdf: error: $*" >&2; exit 1; }

[[ -x "${hugo}" ]] || fail "Hugo not found at ${hugo}; run scripts/bootstrap.sh."

find_chrome() {
  if [[ -n "${CHROME:-}" ]]; then
    echo "${CHROME}"
    return
  fi
  local cmd
  for cmd in google-chrome google-chrome-stable chromium chromium-browser; do
    if command -v "${cmd}" > /dev/null; then
      command -v "${cmd}"
      return
    fi
  done
  local cache="${PLAYWRIGHT_BROWSERS_PATH:-${HOME}/.cache/ms-playwright}"
  local candidate
  for candidate in \
    "${cache}"/chromium_headless_shell-*/chrome-headless-shell-linux64/chrome-headless-shell \
    "${cache}"/chromium-*/chrome-linux64/chrome; do
    if [[ -x "${candidate}" ]]; then
      echo "${candidate}"
      return
    fi
  done
}

chrome="$(find_chrome)"
[[ -n "${chrome}" ]] || fail "no Chrome/Chromium found; set CHROME or run 'npx playwright install chromium-headless-shell'."

work="$(mktemp -d)"
server_pid=""
cleanup() {
  [[ -n "${server_pid}" ]] && kill "${server_pid}" 2> /dev/null || true
  rm -rf "${work}"
}
trap cleanup EXIT

port="$(python3 -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1])')"
base="http://127.0.0.1:${port}/"

info "building site..."
(cd "${root}" && "${hugo}" --quiet --baseURL "${base}" --destination "${work}/site")
[[ -f "${work}/site/${page}" ]] || fail "build did not produce ${page}."

python3 -m http.server "${port}" --bind 127.0.0.1 --directory "${work}/site" > /dev/null 2>&1 &
server_pid=$!
for _ in $(seq 50); do
  curl -fs -o /dev/null "${base}${page}" && break
  sleep 0.1
done
curl -fs -o /dev/null "${base}${page}" || fail "local server did not start on port ${port}."

info "printing with $(basename "${chrome}")..."
"${chrome}" \
  --headless \
  --disable-gpu \
  --no-first-run \
  --user-data-dir="${work}/profile" \
  --no-pdf-header-footer \
  --run-all-compositor-stages-before-draw \
  --virtual-time-budget=10000 \
  --print-to-pdf="${work}/resume.pdf" \
  "${base}${page}" > /dev/null 2>&1 || fail "Chrome failed to print ${base}${page}."

[[ -s "${work}/resume.pdf" ]] || fail "Chrome produced no PDF."
mv "${work}/resume.pdf" "${output}"
info "wrote ${output#"${root}/"}"
