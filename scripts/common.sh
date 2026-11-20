# Shared helpers for this repo's shell scripts and git hooks. Source it; don't run it:
#   . "$(dirname "$0")/common.sh"            (from scripts/)
#   . "$(dirname "$0")/../scripts/common.sh" (from .husky/)
# POSIX sh, because Husky runs hooks with sh.

# Repository root: the parent of this file's folder (scripts/), found from its absolute path so scripts work from any
# directory without running git. BASH_SOURCE is this file under bash; POSIX sh (dash, which Husky uses) leaves it
# unset, so fall back to the calling script's $0.
root="$(cd "$(dirname "${BASH_SOURCE:-$0}")/.." && pwd)"

# Messages go to stderr, prefixed with the calling script's name (e.g. "resume_to_pdf: ...").
script_name="$(basename "$0" .sh)"
info() { echo "${script_name}: $*" >&2; }
fail() {
  echo "${script_name}: error: $*" >&2
  exit 1
}
