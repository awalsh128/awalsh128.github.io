// Merges the release settings from "Publishing a VS Code Extension from GitHub" into ./package.json. Run by scaffold.sh.
//
// The identity fields (name, publisher, repository) always take the given values; everything else is added only when
// missing (or when FORCE=true). Prints one line per change or kept value that differs from the post.
//
// Usage: PUBLISHER=... NAME=... REPO=owner/repo BRANCH=main FORCE=false node merge-package-json.cjs

const fs = require("fs");
const { PUBLISHER, NAME, REPO, BRANCH, FORCE } = process.env;
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
const report = [];
const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);

function identity(key, value) {
  if (pkg[key] !== undefined && !same(pkg[key], value)) {
    report.push(`changed ${key}: ${JSON.stringify(pkg[key])} -> ${JSON.stringify(value)}`);
  }
  pkg[key] = value;
}

function add(obj, key, value, label) {
  if (obj[key] === undefined || FORCE === "true") {
    obj[key] = value;
  } else if (!same(obj[key], value)) {
    report.push(`TODO: kept your existing ${label}; compare it with the post's value: ${JSON.stringify(value)}`);
  }
}

identity("name", NAME);
identity("publisher", PUBLISHER);
identity("repository", { type: "git", url: `https://github.com/${REPO}` });
add(pkg, "main", "./dist/extension.js", "main");

pkg.scripts ??= {};
const scripts = {
  bundle:
    "esbuild src/extension.ts --bundle --platform=node --format=cjs --target=node20 --external:vscode --minify --keep-names --sourcemap --outfile=dist/extension.js",
  compile: "tsc -b && npm run bundle",
  "vscode:prepublish": "npm ci && npm run compile",
  setup: "npm install && git config core.hooksPath .githooks && npm run compile",
};
for (const [key, value] of Object.entries(scripts)) add(pkg.scripts, key, value, `scripts.${key}`);

add(pkg, "commitlint", { extends: ["@commitlint/config-conventional"] }, "commitlint");
add(
  pkg,
  "release",
  {
    branches: [BRANCH],
    tagFormat: "v${version}",
    plugins: [
      "@semantic-release/commit-analyzer",
      "@semantic-release/release-notes-generator",
      ["semantic-release-vsce", { packageVsix: true }],
      ["@semantic-release/github", { assets: [{ path: "*.vsix", label: "Extension package (VSIX)" }] }],
      [
        "@semantic-release/git",
        {
          assets: ["package.json", "package-lock.json"],
          message: "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}",
        },
      ],
    ],
  },
  "release",
);

fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2) + "\n");
console.log(report.join("\n"));
