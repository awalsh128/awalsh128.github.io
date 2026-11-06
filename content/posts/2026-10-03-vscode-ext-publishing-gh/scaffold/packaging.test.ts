// Checks what `vsce package` would ship, so a later change can't ship development files or drop the bundle.
// TODO: Move this next to your other tests if they live elsewhere, and add chai if you don't use it already.
// TODO: Add any other paths that must never ship to the excluded prefixes.
import { execSync } from "child_process";
import { expect } from "chai";

describe("packaging", () => {
  const files = execSync("npx vsce ls", { encoding: "utf8" })
    .trim()
    .split("\n");

  it("includes the bundle", () => {
    expect(files).to.include("dist/extension.js");
  });

  ["node_modules/", "src/", "out/", ".githooks/"].forEach((prefix) => {
    it(`excludes ${prefix}`, () => {
      expect(files.filter((file) => file.startsWith(prefix))).to.deep.equal([]);
    });
  });
});
