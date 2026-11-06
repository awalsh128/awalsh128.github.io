// Exchanges this job's GitHub OIDC token for a short-lived Open VSX publishing token and exports
// it to later steps as OVSX_PAT. Requires `permissions: id-token: write`.
import { appendFileSync, readFileSync } from "node:fs";

const OPEN_VSX = "https://open-vsx.org";
const { publisher, name } = JSON.parse(readFileSync("package.json", "utf8"));
const {
  ACTIONS_ID_TOKEN_REQUEST_URL,
  ACTIONS_ID_TOKEN_REQUEST_TOKEN,
  GITHUB_ENV,
} = process.env;
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
  throw new Error(
    `Open VSX refused trusted publishing: ${body.error ?? exchange.status}`,
  );
}

// Mask the token before anything else can print it.
console.log(`::add-mask::${body.value}`);
appendFileSync(GITHUB_ENV, `OVSX_PAT=${body.value}\n`);
