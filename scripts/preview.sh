#!/usr/bin/env sh
# Serve the site locally with a fresh homepage project list: refresh it through gh, then run `hugo server`.
# Without gh or a network, the preview uses the list and logos already in the working tree.
#
# Usage: scripts/preview.sh [hugo server arguments]
#   scripts/preview.sh -D --config hugo.toml,hugo.local.toml   include the private drafts

# shellcheck source=common.sh
. "$(dirname "$0")/common.sh"

python3 "${root}/scripts/update_projects.py" ||
  info "can't refresh the homepage projects; previewing with the local list."

cd "${root}" || fail "can't enter ${root}."
exec "${root}/.tools/hugo" server "$@"
