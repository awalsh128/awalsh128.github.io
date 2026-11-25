#!/usr/bin/env sh
# Fail when a copied Blowfish layout drifts from the theme's own file.
#
# layouts/_default/list.html and term.html are copies of Blowfish's with GroupByDate changed to GroupByLastmod
# (docs/site.md, "Year grouping"). After undoing that one change they must equal the theme's file, so a theme
# upgrade that touches them shows up here instead of silently diverging. Fix by re-copying the theme's file
# and reapplying the change. Run by the Hugo deploy workflow; run it by hand after bumping Blowfish.

# shellcheck source=common.sh
. "$(dirname "$0")/common.sh"

hugo="${root}/.tools/hugo"
[ -x "${hugo}" ] || hugo="hugo"

# The theme module's directory comes from Hugo's mount listing, so the check follows go.mod.
theme="$("${hugo}" config mounts | sed -n 's/.*"dir": "\(.*blowfish[^"]*\)".*/\1/p' | head -n 1)"
[ -d "${theme}/layouts" ] || fail "can't find the Blowfish module; run a Hugo build first so it downloads."

status=0
for name in list term; do
  if ! sed 's/GroupByLastmod/GroupByDate/g' "${root}/layouts/_default/${name}.html" |
    diff -u "${theme}/layouts/_default/${name}.html" - >&2; then
    info "layouts/_default/${name}.html differs from Blowfish beyond GroupByLastmod."
    status=1
  fi
done
[ "${status}" -eq 0 ] && info "theme overrides match Blowfish."
exit "${status}"
