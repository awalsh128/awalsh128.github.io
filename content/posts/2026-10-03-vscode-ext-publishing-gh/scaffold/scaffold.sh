#!/usr/bin/env bash
# Scaffold GitHub release publishing for a VS Code extension, as described in "Publishing a VS Code Extension from
# GitHub" (https://awalsh128.com/vscode-ext-publishing-gh/).
#
# Writes the boilerplate into an existing extension repository and merges the release settings into package.json.
# Generated files contain TODO comments where you need to make changes; the script also prints the remaining manual
# steps (registry accounts, secrets, tags). Existing files are never overwritten unless you pass --force.
#
# Usage:
#   scaffold.sh --publisher my-publisher --name my-extension --repo owner/repo [--branch main] [--dir .] [--force]
#
# Run it from the extracted scaffold.tar.gz; the files it writes are next to it. Requires bash and node.

set -euo pipefail

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

fail() {
  echo "scaffold: error: $*" >&2
  exit 1
}

publisher=""
name=""
repo=""
branch="main"
dir="."
force=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --publisher) publisher="${2:-}"; shift 2 ;;
    --name) name="${2:-}"; shift 2 ;;
    --repo) repo="${2:-}"; shift 2 ;;
    --branch) branch="${2:-}"; shift 2 ;;
    --dir) dir="${2:-}"; shift 2 ;;
    --force) force=true; shift ;;
    -h | --help) usage 0 ;;
    *) echo "scaffold: unknown argument: $1" >&2; usage 1 ;;
  esac
done

[[ -n "${publisher}" && -n "${name}" && -n "${repo}" ]] || { echo "scaffold: --publisher, --name, and --repo are required." >&2; usage 1; }
[[ "${publisher}" =~ ^[A-Za-z0-9][A-Za-z0-9-]*$ ]] || fail "publisher '${publisher}' should be letters, digits, and hyphens."
[[ "${name}" =~ ^[a-z0-9][a-z0-9._-]*$ ]] || fail "name '${name}' should be lowercase letters, digits, '.', '_', or '-'."
[[ "${repo}" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || fail "repo '${repo}' should look like owner/repo."
command -v node > /dev/null || fail "node is required."
[[ -f "${dir}/package.json" ]] || fail "no package.json in ${dir}; run this from your extension's repository or pass --dir."

# The template files ship next to this script in scaffold.tar.gz.
templates="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "${templates}/merge-package-json.cjs" ]] || fail "template files not found next to $0; extract all of scaffold.tar.gz."

cd "${dir}"
written=()
skipped=()

# Copies a template to a path in the repository unless the path already exists (or --force). Usage: emit <path> <template> [mode]
emit() {
  local path="$1" template="$2" mode="${3:-644}"
  if [[ -e "${path}" && "${force}" != true ]]; then
    skipped+=("${path}")
    return
  fi
  mkdir -p "$(dirname "${path}")"
  cp "${templates}/${template}" "${path}"
  chmod "${mode}" "${path}"
  written+=("${path}")
}

emit .vscodeignore vscodeignore
emit .githooks/commit-msg commit-msg 755
emit src/test/packaging.test.ts packaging.test.ts
emit scripts/openvsx-token.mjs openvsx-token.mjs
emit .github/workflows/publish.yml publish.yml

# Merge the release settings into package.json. The identity fields always take the arguments; everything else is
# added only when missing (or with --force), and differing existing values are reported as TODOs.
package_before="$(cat package.json)"
package_report="$(
  PUBLISHER="${publisher}" NAME="${name}" REPO="${repo}" BRANCH="${branch}" FORCE="${force}" \
    node "${templates}/merge-package-json.cjs"
)"

if [[ "$(cat package.json)" != "${package_before}" ]]; then
  echo "scaffold: updated package.json"
else
  echo "scaffold: package.json already up to date"
fi
for path in ${written[@]+"${written[@]}"}; do echo "scaffold: wrote ${path}"; done
for path in ${skipped[@]+"${skipped[@]}"}; do echo "scaffold: skipped ${path} (exists; use --force to overwrite)"; done
[[ -n "${package_report}" ]] && sed 's/^/scaffold: package.json: /' <<< "${package_report}"

cat <<EOF

TODO: Remaining steps (see the post for details on each):
  1. Install the build and commit tools:
       npm install --save-dev esbuild @vscode/vsce @commitlint/cli @commitlint/config-conventional chai
  2. Enable the commit hook in this clone (contributors run 'npm run setup'):
       git config core.hooksPath .githooks
  3. Check the 'bundle' script's entry point (src/extension.ts) and --target against your engines.vscode version.
  4. Already published? Tag the commit your current version was built from, e.g.:
       git tag -a v1.0.2 <commit> -m "Release 1.0.2" && git push origin v1.0.2
  5. Open VSX: add a trusted publisher at https://open-vsx.org/user-settings/trusted-publishers
       namespace '${publisher}', repository '${repo}', workflow 'publish.yml'.
  6. Marketplace: on https://marketplace.visualstudio.com/manage, open publisher '${publisher}' > Trusted Publishing
       and create a policy for repository '${repo}', workflow 'publish.yml'.
  7. Resolve the TODO comments in the generated files:
       grep -rn "TODO" .vscodeignore .githooks src/test/packaging.test.ts .github/workflows/publish.yml
  8. Try a dry run once it's pushed:
       gh workflow run publish.yml --repo ${repo}
EOF
