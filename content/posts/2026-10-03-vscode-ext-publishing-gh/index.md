---
title: Publishing a VS Code Extension from GitHub
last_modified_at: 2026-10-03 00:00:01 -0700
tags:
  # keep-sorted start
  - GitHub
  - Open Source
  - TypeScript
  - VS Code
  # keep-sorted end
---

I publish my [Keep Sorted extension](https://github.com/awalsh128/vscode-keep-sorted) to both the
[Visual Studio Marketplace](https://marketplace.visualstudio.com/) and [Open VSX](https://open-vsx.org/). I wanted
releases to come straight out of GitHub Actions instead of my machine. Getting there took more trial and error than I
expected, so here is the setup in a form you can copy into your own extension.

What I wanted was:

- Commit messages decide the next version ([Conventional Commits](https://www.conventionalcommits.org/) and
  [semantic-release](https://semantic-release.gitbook.io/)), not me.
- One manually started workflow that runs CI, publishes the VSIX to both registries, tags `vX.Y.Z`, and creates a
  GitHub release with notes and the VSIX attached.
- A workflow input to mark a release as a pre-release on both registries and on GitHub.
- No stored registry tokens, using trusted publishing for both the Marketplace and Open VSX.
- A bundled VSIX, with CI checking what ships in it.

\*Replace `my-publisher`, `my-extension`, and `owner/repo` with your own names throughout, **or fill them in below and the
post (including the code) will use them.**

{{< placeholders "my-publisher|Publisher ID" "my-extension|Extension name" "owner/repo|GitHub repository" >}}

## Contents

- [Contents](#contents)
- [0. Quick-start script](#0-quick-start-script)
- [1. Registry accounts](#1-registry-accounts)
- [2. Bundle and package the extension](#2-bundle-and-package-the-extension)
- [3. Enforce Conventional Commits](#3-enforce-conventional-commits)
- [4. Configure semantic-release](#4-configure-semantic-release)
  - [Do not add the release tools to `package.json`](#do-not-add-the-release-tools-to-packagejson)
  - [Existing extensions: tag the last release](#existing-extensions-tag-the-last-release)
  - [Try it locally](#try-it-locally)
- [5. Trusted publishing for Open VSX](#5-trusted-publishing-for-open-vsx)
- [6. Trusted publishing for the Marketplace](#6-trusted-publishing-for-the-marketplace)
- [7. The publish workflow](#7-the-publish-workflow)
- [8. Releasing](#8-releasing)
  - [When a release fails partway](#when-a-release-fails-partway)
- [9. CI checks worth adding](#9-ci-checks-worth-adding)
- [10. Pitfalls](#10-pitfalls)
- [Conclusion](#conclusion)

## 0. Quick-start script

If you'd rather not copy each file below by hand, [scaffold.tar.gz](scaffold.tar.gz) has a script that writes the
boilerplate from this post into your repository. From the root of your extension, switch to a temporary folder:

```bash
repo="$PWD" && cd "$(mktemp -d)"
```

Then download the archive, check it against the hash computed when this site was built, and run the script against
your repository only if it matches:

{{< verified-download sources="scaffold.tar.gz" then=`tar -xzf scaffold.tar.gz &&
bash scaffold/scaffold.sh --dir "$repo" --publisher my-publisher --name my-extension --repo owner/repo &&
cd "$repo"` >}}

It never overwrites existing files (pass `--force` if you want it to). In `package.json` it sets `name`, `publisher`,
and `repository` from your arguments, and only adds other settings that are missing. The generated files have `TODO`
comments where you need to make changes, and the script prints the steps it can't do for you (registry accounts,
secrets, and tagging your last release). Read through [scaffold.sh](scaffold/scaffold.sh) first; it's short.

## 1. Registry accounts

| Registry                  | What you need                                                                                                                                |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Visual Studio Marketplace | A [publisher](https://marketplace.visualstudio.com/manage) whose ID matches `publisher` in `package.json`, created with a Microsoft account. |
| Open VSX                  | An account at [open-vsx.org](https://open-vsx.org/) (Eclipse sign-in, publisher agreement signed) and a namespace matching `publisher`.      |

The `package.json` fields both registries read:

```json
{
  "name": "my-extension",
  "publisher": "my-publisher",
  "version": "1.0.0",
  "engines": { "vscode": "^1.100.0" },
  "repository": { "type": "git", "url": "https://github.com/owner/repo" },
  "main": "./dist/extension.js"
}
```

Versions must be plain `major.minor.patch`. Both registries reject suffixes such as `1.2.0-beta.1`,
and a published version number can never be reused, even after deletion.

## 2. Bundle and package the extension

Ship one bundled file instead of `node_modules/`. `vsce` warns when an extension contains hundreds
of files, and an unbundled extension that excludes `node_modules/` cannot load its runtime packages.

Bundle with [esbuild](https://esbuild.github.io/), keeping only `vscode` external:

```json
{
  "scripts": {
    "bundle": "esbuild src/extension.ts --bundle --platform=node --format=cjs --target=node20 --external:vscode --minify --keep-names --sourcemap --outfile=dist/extension.js",
    "compile": "tsc -b && npm run bundle",
    "vscode:prepublish": "npm ci && npm run compile"
  }
}
```

`vsce package` runs `vscode:prepublish` first, so every VSIX is built from a clean install.

Exclude everything except the bundle and the assets the extension needs at runtime in
`.vscodeignore`:

```gitignore {collapse="true" title=".vscodeignore"}
node_modules/
out/
src/
scripts/
docs/
.github/
.githooks/
.vscode/
.vscode-test/
dist/**/*.map
*.vsix
tsconfig*.json
```

Then test the package contents, so a later change cannot ship development files or drop the bundle.
`vsce ls` prints the files that would be packaged (the test uses [chai](https://www.chaijs.com/), so add it as a dev
dependency if you don't have it):

```typescript {collapse="true" title="src/test/packaging.test.ts"}
import { execSync } from "child_process";
import { expect } from "chai";

describe("packaging", () => {
  const files = execSync("npx vsce ls", { encoding: "utf8" }).trim().split("\n");

  it("includes the bundle", () => {
    expect(files).to.include("dist/extension.js");
  });

  ["node_modules/", "src/", "out/", ".githooks/"].forEach((prefix) => {
    it(`excludes ${prefix}`, () => {
      expect(files.filter((file) => file.startsWith(prefix))).to.deep.equal([]);
    });
  });
});
```

## 3. Enforce Conventional Commits

semantic-release reads commit messages to choose the next version:

| Commit                                         | Release |
| ---------------------------------------------- | ------- |
| `fix: ...`                                     | patch   |
| `feat: ...`                                    | minor   |
| A `BREAKING CHANGE:` footer                    | major   |
| `docs:`, `ci:`, `chore:`, `refactor:`, `test:` | none    |

Commits in any other format are ignored, so check messages before they land. Install
[commitlint](https://commitlint.js.org/):

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

Configure it in `package.json`:

```json
{
  "commitlint": {
    "extends": ["@commitlint/config-conventional"]
  }
}
```

Commit the hooks to the repository, so every clone shares them. `.githooks/commit-msg`:

```sh
#!/bin/sh
exec npx --no -- commitlint --edit "$1"
```

Make it executable and point Git at the directory. Git does not read hooks from the repository by
default, so each clone has to opt in once:

```bash
chmod +x .githooks/commit-msg
git config core.hooksPath .githooks
```

To make that one step for contributors, add a setup script:

```json
{
  "scripts": {
    "setup": "npm install && git config core.hooksPath .githooks && npm run compile"
  }
}
```

The same directory can hold a `pre-commit` hook that runs fast checks, such as lint or a docs
consistency script.

## 4. Configure semantic-release

The setup uses these plugins:

| Plugin                                                                        | Does                                                                                   |
| ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `@semantic-release/commit-analyzer`                                           | Chooses the version from commits since the last tag                                    |
| `@semantic-release/release-notes-generator`                                   | Writes release notes from `fix` and `feat` commits                                     |
| [`semantic-release-vsce`](https://github.com/felipecrs/semantic-release-vsce) | Sets the version, packages the VSIX, and publishes it to Open VSX                      |
| `@semantic-release/github`                                                    | Creates the GitHub release, attaches the VSIX, and comments on released issues and PRs |
| [`@semantic-release/git`](https://github.com/semantic-release/git)            | Commits the new version in `package.json` and `package-lock.json` back to the branch   |

Configure them under `release` in `package.json`. The plugins list leaves out
`@semantic-release/npm`, since an extension is not published to npm:

```json {collapse="true" title="package.json (release)"}
{
  "release": {
    "branches": ["main"],
    "tagFormat": "v${version}",
    "plugins": [
      "@semantic-release/commit-analyzer",
      "@semantic-release/release-notes-generator",
      ["semantic-release-vsce", { "packageVsix": true }],
      [
        "@semantic-release/github",
        {
          "assets": [{ "path": "*.vsix", "label": "Extension package (VSIX)" }]
        }
      ],
      [
        "@semantic-release/git",
        {
          "assets": ["package.json", "package-lock.json"],
          "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
        }
      ]
    ]
  }
}
```

Plugin order matters. In the prepare step, `semantic-release-vsce` packages the VSIX and sets the
version in `package.json` before `@semantic-release/git` commits it. semantic-release then pushes
the `vX.Y.Z` tag on that commit, and in the publish step Open VSX and the GitHub release receive the
same VSIX. A workflow step after semantic-release publishes that VSIX to the Marketplace (see
[section 6](#6-trusted-publishing-for-the-marketplace)).

### Do not add the release tools to `package.json`

semantic-release always installs `@semantic-release/npm`, which bundles a copy of the npm CLI.
Advisories in that bundled CLI cannot be fixed with `overrides` and can fail `npm audit` in CI, even
though the npm plugin never runs. Install the release tools only in the publish job, pinned to exact
versions (see [the workflow](#7-the-publish-workflow)).

### Existing extensions: tag the last release

semantic-release starts from the newest `v*` tag. Without one, its first release is `1.0.0`, which
an already published extension cannot reuse. Tag the commit your current version was built from
before the first run:

```bash
git tag -a v1.0.2 <commit> -m "Release 1.0.2"
git push origin v1.0.2
```

Commits before the switch rarely follow Conventional Commits, so the first automated release needs
at least one `fix:` or `feat:` commit after the tag.

### Try it locally

A dry run prints the next version and the release notes without changing anything. The vsce plugin
verifies registry credentials even in a dry run, so add `"publish": false` to its options while you
try it without tokens. Remove it before the first real release, or the release skips both registries:

```bash
GITHUB_TOKEN=$(gh auth token) npx --yes \
  --package semantic-release@25.0.9 \
  --package semantic-release-vsce@6.1.8 \
  --package @semantic-release/git@11.0.1 \
  semantic-release --dry-run --no-ci
```

## 5. Trusted publishing for Open VSX

Trusted publishing replaces a stored Open VSX token. Open VSX trusts a specific repository and
workflow, and the workflow trades its GitHub OIDC token for a short-lived token that can publish
only your extension.

1. Sign in to Open VSX and open
   [Settings → Trusted publishers](https://open-vsx.org/user-settings/trusted-publishers).
2. Add your namespace, the `owner/repo` repository, and the workflow file name (e.g. `publish.yml`).
3. Give the publishing job `id-token: write` permission.

`semantic-release-vsce` reads Open VSX credentials only from `OVSX_PAT`, so run the exchange in a
step before semantic-release and export the issued token. `scripts/openvsx-token.mjs`:

```javascript {collapse="true" title="scripts/openvsx-token.mjs"}
// Exchanges this job's GitHub OIDC token for a short-lived Open VSX publishing token and exports
// it to later steps as OVSX_PAT. Requires `permissions: id-token: write`.
import { appendFileSync, readFileSync } from "node:fs";

const OPEN_VSX = "https://open-vsx.org";
const { publisher, name } = JSON.parse(readFileSync("package.json", "utf8"));
const { ACTIONS_ID_TOKEN_REQUEST_URL, ACTIONS_ID_TOKEN_REQUEST_TOKEN, GITHUB_ENV } = process.env;
if (!ACTIONS_ID_TOKEN_REQUEST_URL || !GITHUB_ENV) {
  throw new Error("Run in GitHub Actions with `permissions: id-token: write`.");
}

// The request URL already has an api-version parameter, so only the audience is added.
const idTokenUrl = new URL(ACTIONS_ID_TOKEN_REQUEST_URL);
idTokenUrl.searchParams.set("audience", OPEN_VSX);
const idResponse = await fetch(idTokenUrl, {
  headers: { Authorization: `Bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}` },
});
const { value: idToken } = await idResponse.json();

const exchange = await fetch(`${OPEN_VSX}/api/-/trusted-publishing/token`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    namespace: publisher,
    extension: name,
    token: idToken,
  }),
});
const body = await exchange.json();
if (!exchange.ok || !body.value) {
  throw new Error(`Open VSX refused trusted publishing: ${body.error ?? exchange.status}`);
}

// Mask the token before anything else can print it.
console.log(`::add-mask::${body.value}`);
appendFileSync(GITHUB_ENV, `OVSX_PAT=${body.value}\n`);
```

Don't also set `OVSX_PAT` from a secret in the release step's `env`. A step-level variable replaces the
exported one, and an empty secret removes it.

## 6. Trusted publishing for the Marketplace

The Marketplace added [trusted publishing](https://code.visualstudio.com/api/working-with-extensions/publishing-extension#publish-with-github-actions-and-trusted-publishing)
for GitHub Actions in October 2026, and it works the same way as Open VSX's. Use it instead of a personal access token
(PAT). New global PATs (i.e. scoped to all accessible organizations) can't be created since March 15, 2026, existing
ones stop working on December 1, 2026, and a PAT scoped to one organization fails with `TF400813`.

1. Open your publisher on the [publisher management page](https://marketplace.visualstudio.com/manage) and select
   **Trusted Publishing**.
2. Create a policy with the repository owner, the repository name, and the workflow file name (e.g. `publish.yml`).
   Leave **Environment** empty unless the job uses a GitHub environment.
3. Give the publishing job `id-token: write` permission, the same as for Open VSX.

For a private repository, run the workflow within 48 hours of creating the policy. The first successful token exchange
activates it for good.

`vsce publish --oidc` (from `@vscode/vsce` 4.1.0) does the token exchange itself, but `semantic-release-vsce` doesn't
support it yet. So the workflow leaves out `VSCE_PAT`, which makes the plugin skip the Marketplace, and publishes the
VSIX the plugin packaged in a step of its own. The pre-release flag is already in the VSIX, so that step doesn't need
one.

## 7. The publish workflow

`.github/workflows/publish.yml` runs only when started by hand, with two inputs:

- `dry_run`, on by default, prints the next version and notes without publishing.
- `pre_release` publishes a pre-release on both registries and marks the GitHub release.

```yaml {collapse="true" title=".github/workflows/publish.yml"}
name: Publish Extension

on:
  workflow_dispatch:
    inputs:
      dry_run:
        description: Show the next version and release notes without publishing
        required: true
        type: boolean
        default: true
      pre_release:
        description: Mark the release as a pre-release on both registries and on GitHub
        required: true
        type: boolean
        default: false

jobs:
  # Reuse the CI workflow, which needs `on: workflow_call` among its triggers.
  ci:
    uses: ./.github/workflows/ci.yml
    secrets: inherit

  release:
    runs-on: ubuntu-24.04
    needs: ci
    permissions:
      contents: write # push the version commit and tag, create the GitHub release
      issues: write # comment on released issues
      pull-requests: write # comment on released pull requests
      id-token: write # trusted publishing to the Marketplace and Open VSX
    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 0 # semantic-release reads every commit and tag since the last release

      - uses: actions/setup-node@v6
        with:
          node-version: "24"

      - run: npm ci

      - name: Get an Open VSX publishing token
        run: node scripts/openvsx-token.mjs

      - name: Release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          VSCE_PRE_RELEASE: ${{ inputs.pre_release }}
          DRY_RUN_FLAG: ${{ inputs.dry_run && '--dry-run' || '' }}
        run: |
          npx --yes \
            --package semantic-release@25.0.9 \
            --package semantic-release-vsce@6.1.8 \
            --package @semantic-release/git@11.0.1 \
            semantic-release $DRY_RUN_FLAG

      # semantic-release-vsce doesn't support Marketplace trusted publishing yet, so publish the VSIX it packaged
      # here. No VSIX means nothing was released (or this is a dry run).
      - name: Publish to the Marketplace
        if: ${{ !inputs.dry_run }}
        run: |
          shopt -s nullglob
          vsix=(*.vsix)
          if [ ${#vsix[@]} -eq 0 ]; then
            echo "No new release; nothing to publish to the Marketplace."
            exit 0
          fi
          npx --yes @vscode/vsce@4.1.0 publish --oidc --packagePath "${vsix[@]}"

      # semantic-release marks GitHub releases as pre-releases only for prerelease branches, whose
      # versions carry a suffix the registries reject, so mark the release here instead.
      - name: Mark the GitHub release as a pre-release
        if: inputs.pre_release && !inputs.dry_run
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          tag=$(git tag --points-at HEAD --list 'v*')
          if [ -n "$tag" ]; then
            gh release edit "$tag" --prerelease
          fi
```

Notes:

- Pin third-party actions to commit SHAs in a real repository (`uses: actions/checkout@<sha> # v5`).
- The workflow token can push the version commit only if branch protection or rulesets on `main`
  allow it. Otherwise add a bypass for GitHub Actions or push with a GitHub App token.
- `[skip ci]` in the release commit keeps it from starting CI again.
- Keep the `--dry-run` flag in an environment variable rather than inline in a multi-line `run:` block:
  formatters can wrap the `${{ }}` expression across lines.

## 8. Releasing

```bash
gh workflow run publish.yml                                      # dry run
gh workflow run publish.yml -f dry_run=false                     # release
gh workflow run publish.yml -f dry_run=false -f pre_release=true # pre-release
```

A release run:

1. Runs CI.
2. Picks the version from commits since the last `v*` tag, or stops if no `fix` or `feat` commits
   landed.
3. Packages the VSIX with that version, commits `chore(release): X.Y.Z [skip ci]`, and tags `vX.Y.Z`.
4. Publishes the VSIX to Open VSX, and creates the GitHub release with the notes and the VSIX.
5. Publishes the same VSIX to the Marketplace.
6. Comments on the issues and pull requests the release resolves and labels them `released`.

Pre-releases use ordinary version numbers, since the registries reject suffixes. VS Code installs
the highest version a user's channel allows, so a later regular release supersedes a pre-release.

### When a release fails partway

If one registry fails after the tag was pushed, rerunning the workflow publishes nothing, since the
version is already tagged. Publish the VSIX attached to the GitHub release to the registry that is missing it instead:

```bash
gh release download v1.2.3 --pattern '*.vsix'
```

- **Marketplace:** trusted publishing only works inside the workflow, so upload the VSIX on the
  [publisher management page](https://marketplace.visualstudio.com/manage) (**Update** on the extension's menu).
- **Open VSX:** create an access token in your Open VSX settings, then run
  `OVSX_PAT=<token> npx ovsx publish my-extension-1.2.3.vsix`, and delete the token afterwards.

Never delete a published version to retry it. Neither registry lets you publish the same version
number twice.

## 9. CI checks worth adding

**Audit by what ships.** Runtime dependencies are bundled into the VSIX, so any advisory there
matters. Development tools never ship, but some run with publishing credentials. Splitting the audit
keeps unrelated moderate advisories from blocking every build:

```yaml
- name: Audit runtime dependencies
  run: npm audit --omit=dev --audit-level=low

- name: Audit all dependencies for high severity
  run: npm audit --audit-level=high
```

Report the rest without failing, for example with
[npm-audit-action](https://github.com/oke-py/npm-audit-action) and `fail_on_vulnerabilities: false`,
which opens an issue. Use `overrides` in `package.json` to clear advisories in transitive development
dependencies, after checking that the tools still work.

**Review dependencies in pull requests** with
[dependency-review-action](https://github.com/actions/dependency-review-action).

**Check that docs match the manifest.** A small script can compare the settings and commands in
`package.json` with the README, and fail the build when one is missing or a default differs. Run it
from the `pre-commit` hook and in CI.

**Keep labels in code.** Store labels in `.github/labels.yaml` and sync them with a workflow. That way
the labels always exist, including the `released` label that semantic-release applies and any labels
your issue forms use.

**Use issue forms.** YAML forms in `.github/ISSUE_TEMPLATE/` can require the editor, extension
version, and a reproduction, and can apply a label and assignee. Set `blank_issues_enabled: false`
in `config.yml`, and link upstream projects there for problems that belong to them.

## 10. Pitfalls

Some things I learned the hard way.

- **Non-conventional commits release nothing.** semantic-release ignores them without an error, so enforce the format
  with a hook and document it for contributors and coding agents.
- **Tag your last published version first.** Without a baseline tag the first release is `1.0.0`, which you can't
  reuse.
- **Don't use version suffixes.** Both registries reject `-beta.1` and friends, which rules out semantic-release
  prerelease branches.
- **Don't set `OVSX_PAT` at the step level.** It overrides the token exported by the trusted publishing step.
- **Fetch the full history.** `fetch-depth: 1`, the checkout default, hides the tags and commits semantic-release
  needs.
- **Bundle the extension.** An unbundled extension that excludes `node_modules/` fails to activate, so test the VSIX
  contents.
- **Don't plan on a Marketplace PAT.** New global PATs can't be created since March 15, 2026, existing ones stop
  working on December 1, 2026, and organization-scoped PATs fail with `TF400813`. Use trusted publishing.

## Conclusion

- Let Conventional Commits and semantic-release pick the version, and enforce the format with a commit hook.
- Bundle with esbuild and test what `vsce ls` says will ship.
- Use trusted publishing for both registries, so there are no publishing tokens to store or rotate.
- Release from one manually started workflow that defaults to a dry run.
- If a release fails partway, publish the VSIX attached to the GitHub release instead of retrying.

That was a lot of setup, but now a release is one command. I hope it saves you some of the trial and error. Good luck!
