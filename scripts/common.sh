# Shared helpers for this repo's shell scripts and git hooks. Source it; don't run it:
#   . "$(dirname "$0")/common.sh"            (from scripts/)
#   . "$(dirname "$0")/../scripts/common.sh" (from .husky/)
# POSIX sh, because Husky runs hooks with sh.

# Repository root, found from the calling script's location so scripts work from any directory.
root="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

# Messages go to stderr, prefixed with the calling script's name (e.g. "resume_to_pdf: ...").
script_name="$(basename "$0" .sh)"
info() { echo "${script_name}: $*" >&2; }
fail() {
  echo "${script_name}: error: $*" >&2
  exit 1
}
