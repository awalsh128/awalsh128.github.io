#!/usr/bin/env bash
# Rebuild the download archives in post page bundles from the folders beside them.
#
# Any content/posts/<bundle>/<name>.tar.gz that has a <name>/ folder next to it is regenerated from that folder, so the
# archive always matches the files the post shows. The archive is reproducible (sorted names, fixed times and owners,
# no gzip timestamp), so it only changes when the files do. To add one, create the folder and run this with its path.
#
# Usage:
#   scripts/pack_bundle_archives.sh                     rebuild every existing archive
#   scripts/pack_bundle_archives.sh <bundle>/<name>/    create or rebuild the archive for one folder

set -euo pipefail

root="$(git rev-parse --show-toplevel)"

pack() {
  local folder="${1%/}"
  local parent name
  parent="$(dirname "${folder}")"
  name="$(basename "${folder}")"
  tar -C "${parent}" -cf - --sort=name --mtime='2026-01-01 00:00:00Z' --mode='u+rwX,go+rX,go-w' \
    --owner=0 --group=0 --numeric-owner "${name}" | gzip -n -9 > "${folder}.tar.gz"
  echo "pack_bundle_archives: wrote ${folder#"${root}/"}.tar.gz"
}

if [[ $# -gt 0 ]]; then
  for folder in "$@"; do
    [[ -d "${folder}" ]] || { echo "pack_bundle_archives: not a folder: ${folder}" >&2; exit 1; }
    pack "$(cd "${folder}" && pwd)"
  done
  exit
fi

shopt -s nullglob
for archive in "${root}"/content/posts/*/*.tar.gz; do
  folder="${archive%.tar.gz}"
  [[ -d "${folder}" ]] && pack "${folder}"
done
