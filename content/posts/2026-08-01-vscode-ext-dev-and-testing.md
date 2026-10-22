---
title: Testing framework for VSCode extension development
date: "2026-08-01T09:38:00.000-07:00"
author: awalsh128
tags:
  - VS Code
  - TypeScript
  - Testing
modified_time: "2026-08-01T16:28:39.199-07:00"
---

I created a VSCode extension recently ([awalsh128/vscode-keep-sorted](https://github.com/awalsh128/vscode-keep-sorted))
and learned a lot of lessons trying to set up the test environment. What I wanted was:

- Tests that run against a real VSCode instance, not mocks.
- An immutable test workspace, so every test starts from the same files.
- A log file per test, so I can see what the extension did when a test fails.

## Principles

Some things I learned the hard way about testing extensions.

- **Don't mock the VSCode API.** Bring up a test workspace with the extension under test instead. Mocking is almost
  impossible since many of the API calls are static and will elicit unexpected behavior. You will also end up creating
  shims and factory methods everywhere, making your extension implementation brittle.
- **Don't perform I/O out of band.** Always go through the VSCode API or you will hit unexpected behavior. The API
  batches edits and diagnostic operations to prevent flooding and to give them meaningful context (e.g. resolving
  multiple edits to the same file, possibly on the same line).
- **Always have an immutable test workspace.** This isolates each test's preconditions. If you want to test a chain of
  behaviors, do that inside an individual test.
- **VSCode API operations may be asynchronous.** You will often need to wait before the expected state can be
  asserted.

Here is the code I created so you don't have to. You can find the complete testing environment and tests at
[awalsh128/vscode-keep-sorted/src/test](https://github.com/awalsh128/vscode-keep-sorted/tree/main/src/test).

## Setup

### Layout

```text
src/test/
  runTest.ts          # launches VSCode against the test workspace
  suite/index.ts      # Mocha entry point and per-test hooks
  testing.ts          # TestWorkspace and TestLogs helpers
  *.test.ts           # your tests
  logs/               # per-test log output (add to .gitignore)
test-workspace/       # the immutable workspace tests run against
  .vscode/settings.json
```

### Dependencies

```bash
npm install --save-dev mocha chai chai-as-promised glob rimraf @vscode/test-electron \
  @types/mocha @types/chai @types/chai-as-promised @types/vscode
```

### Running

Add a test script to `package.json` that compiles and then runs the launcher. Clearing out the logs directory first
keeps old test logs from piling up.

```json
"scripts": {
  "test": "tsc -b && rimraf ./src/test/logs/ && node ./out/test/runTest.js"
}
```

To run a subset of tests, set `MOCHA_GREP` to a pattern matching the test names (e.g.
`MOCHA_GREP="activation" npm test`).

### What to change for your extension

The code below comes from my extension, so a few values are specific to it. Swap these out for your own.

- `awalsh128.keep-sorted` - your extension ID (`publisher.name`), used in `runTest.ts` and the tests.
- `keep-sorted.logFilepath` - the setting your extension reads its log file path from, used in `testing.ts`.
- `log/keep-sorted.log` - the log file path inside the test workspace, excluded from the workspace snapshot in
  `suite/index.ts`.

> [!NOTE]
> Per-test logging assumes your extension writes its log to a file whose path comes from a workspace setting. My test
> workspace's `.vscode/settings.json` has `"keep-sorted.logFilepath": "log/keep-sorted.log"`. If your extension only
> logs to an output channel, drop `TestLogs` or add a file logging setting first.

## The Code

### `runTest.ts`

This is the launcher. It downloads VSCode (if needed), opens the immutable test workspace with the extension loaded,
and turns on trace logging so each test has something to diagnose failures with.

```ts
import * as path from "path";
import { EXT_WORKSPACE_DIR, TEST_WORKSPACE_DIR } from "./testing";
import { runTests } from "@vscode/test-electron";

async function main() {
  try {
    await runTests({
      // The extension under development
      extensionDevelopmentPath: EXT_WORKSPACE_DIR,
      // Location of the suite runner
      extensionTestsPath: path.resolve(__dirname, "./suite"),
      // Enable trace logging for the extension and open the test workspace
      launchArgs: ["--log=awalsh128.keep-sorted:trace", TEST_WORKSPACE_DIR],
    });
  } catch (err) {
    console.error("Failed to run tests", err);
    process.exit(1);
  }
}

main();
```

### `suite/index.ts`

This is the Mocha entry point that runs inside the VSCode instance. The global `beforeEach` and `afterEach` hooks are
where the workspace gets restored and the logs get rotated, so none of your tests need to do it themselves.

```ts
import * as path from "path";
import * as Mocha from "mocha";
import * as vscode from "vscode";
import {
  TestLogs,
  TEST_LOGS_DIR,
  TestWorkspace,
  TEST_WORKSPACE_DIR,
} from "../testing";
import { sync as globSync } from "glob";

export function run(): Promise<void> {
  // Allow `any` here because Mocha types and our usage are compatible at runtime
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const mocha = new (Mocha as any)({ ui: "bdd", color: true, timeout: 20000 });
  const testsRoot = path.resolve(__dirname, "..");

  // Support filtering tests via MOCHA_GREP environment variable
  const grep = process.env.MOCHA_GREP;
  if (grep) {
    mocha.grep(grep);
  }

  // Snapshot the workspace, excluding the extension's log file since it changes every test
  const workspace = TestWorkspace.createWithSnapshot(TEST_WORKSPACE_DIR, [
    "log/keep-sorted.log",
  ]);
  const logs = TestLogs.create(TEST_LOGS_DIR, TEST_WORKSPACE_DIR);
  console.info("Test logs writing to directory: ", TEST_LOGS_DIR);

  // Close all open text documents before each test to ensure clean state
  mocha.suite.beforeEach(async function () {
    await vscode.commands.executeCommand("workbench.action.closeAllEditors");
  });

  mocha.suite.afterEach(async function (this: Mocha.Context) {
    await vscode.commands.executeCommand("workbench.action.closeAllEditors");
    // Rotate the logs so there is one log per test
    logs.rotate(this.currentTest);
    // Restore the workspace to its immutable / baseline state
    await workspace.restore();
  });

  return new Promise((resolve, reject) => {
    try {
      const files = globSync("**/**.test.js", { cwd: testsRoot });
      files.forEach((f) => mocha.addFile(path.resolve(testsRoot, f)));

      mocha.run((failures: number) => {
        if (failures > 0) {
          reject(new Error(`${failures} tests failed.`));
        } else {
          resolve();
        }
      });
    } catch (e) {
      reject(e);
    }
  });
}
```

### `testing.ts`

This is the reusable part. It has two classes.

- `TestWorkspace` - snapshots every file in the test workspace up front, then `restore()` puts back anything a test
  modified, created, or deleted.
- `TestLogs` - after each test, `rotate()` copies the extension's log to `logs/<test name>.log`, appends it to
  `logs/all.log`, and empties the log for the next test.

You might notice `restore()` writes files with `fs` directly, which looks like it breaks the "no out of band I/O" rule.
That is only half the job though; `syncVscodeDocument` then pushes the same content through the VSCode API so any
document VSCode still has in memory matches what is on disk.

```ts
import * as path from "path";
import * as fs from "fs";
import * as crypto from "crypto";

// The extension under development, relative to the compiled `out/test/` directory
export const EXT_WORKSPACE_DIR = path.resolve(__dirname, "../../");
// The immutable test workspace to perform test operations on
export const TEST_WORKSPACE_DIR = path.resolve(
  __dirname,
  "../../test-workspace",
);
// Location to create the trace log files per test under
export const TEST_LOGS_DIR = path.resolve(EXT_WORKSPACE_DIR, "src/test/logs");

const ENCODING = "utf8";

export class TestLogs {
  private readonly outputLogDir: string;
  private readonly filepath: string;

  private constructor(outputLogDir: string, logFilepath: string) {
    this.outputLogDir = outputLogDir;
    console.info(`TestLogs initialized with log filepath: ${logFilepath}`);
    this.filepath = logFilepath;
  }

  static create(outputLogDir: string, testWorkspaceDir: string): TestLogs {
    return new TestLogs(outputLogDir, TestLogs.logFilepath(testWorkspaceDir));
  }

  private static logFilepath(testWorkspaceDir: string): string {
    // Read the extension's log file path from the test workspace's .vscode/settings.json
    const settingsPath = path.resolve(
      testWorkspaceDir,
      ".vscode",
      "settings.json",
    );
    if (!fs.existsSync(settingsPath)) {
      throw new Error(
        "No test workspace settings.json found at " + settingsPath,
      );
    }
    try {
      const raw = fs.readFileSync(settingsPath, { encoding: ENCODING });
      // Parsing of the VSCode extensions custom settings from the test workspace
      // Important for tests against the extension specific settings
      const settings = JSON.parse(raw);
      const relativeLogFilepath = settings?.["keep-sorted.logFilepath"];
      if (!relativeLogFilepath) {
        throw new Error(
          "keep-sorted.logFilepath setting not found in test workspace settings.json",
        );
      }
      return path.join(testWorkspaceDir, relativeLogFilepath);
    } catch (err) {
      console.warn("Failed to read/parse test workspace settings.json:", err);
      throw err;
    }
  }

  private testFilepath(rawTitle: string | null): string {
    const fileSuffix = (rawTitle ?? "unknown_test").replace(
      /[^A-Za-z0-9-]+/g,
      "_",
    );
    return path.join(this.outputLogDir, `${fileSuffix}.log`);
  }

  rotate(currentTest: Mocha.Test | undefined): void {
    try {
      if (
        !fs.existsSync(this.filepath) ||
        fs.lstatSync(this.filepath).size === 0
      ) {
        return;
      }
      fs.mkdirSync(this.outputLogDir, { recursive: true });
      // Capture the log contents of the test just ran
      const content = fs.readFileSync(this.filepath, ENCODING);
      // Name it according to the test name for easy lookup in the logs directory
      const testFilepath = this.testFilepath(currentTest?.fullTitle() ?? null);
      // Write it out to the logging trace directory
      fs.writeFileSync(testFilepath, content, ENCODING);
      // Also write to a global log file that combines all test output
      fs.appendFileSync(
        path.join(this.outputLogDir, "all.log"),
        content,
        ENCODING,
      );
      // Empty the extension's logfile for the next test
      fs.writeFileSync(this.filepath, "", ENCODING);
    } catch (err) {
      console.warn("Failed to rotate test logs", err);
    }
  }
}

/** Walks a directory synchronously and returns all file paths (absolute). */
function getFilepaths(dir: string, files: string[] = []): string[] {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const filePath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      getFilepaths(filePath, files);
    } else if (entry.isFile()) {
      files.push(filePath);
    }
  }
  return files;
}

/** Snapshots each file's content and hash so the workspace can be restored later. */
function createPathToFile(
  workspaceDir: string,
  excluded: string[],
): Map<string, FileMetadata> {
  const hash = (content: string) =>
    crypto.createHash("sha256").update(content, ENCODING).digest("hex");

  return new Map(
    getFilepaths(workspaceDir).map((f) => {
      const relPath = path.relative(workspaceDir, f);
      const content = fs.readFileSync(f, { encoding: ENCODING });
      return [
        f,
        {
          path: f,
          hash: hash(content),
          content,
          excluded: excluded.includes(relPath),
        },
      ];
    }),
  );
}

interface FileMetadata {
  path: string;
  hash: string;
  content: string;
  excluded: boolean;
}

/** Snapshot of the test workspace that can be restored after each test. */
export class TestWorkspace {
  private readonly workspaceDir: string;
  private readonly excludeFilepaths: string[];
  private readonly pathToFile: Map<string, FileMetadata>;

  private constructor(
    workspaceDir: string,
    pathToFile: Map<string, FileMetadata>,
    excludeFilepaths: string[] = [],
  ) {
    this.workspaceDir = workspaceDir;
    this.pathToFile = pathToFile;
    this.excludeFilepaths = excludeFilepaths;
  }

  /** Captures the workspace's immutable baseline state. */
  static createWithSnapshot(
    workspaceDir: string,
    excludeFilepaths: string[] = [],
  ): TestWorkspace {
    return new TestWorkspace(
      workspaceDir,
      createPathToFile(workspaceDir, excludeFilepaths),
      excludeFilepaths,
    );
  }

  async restore(): Promise<boolean> {
    // Dynamically import vscode - only available when running inside extension host
    let vscode: typeof import("vscode") | undefined;
    try {
      vscode = await import("vscode");
    } catch {
      // Not running in extension host context, skip in-memory restoration
    }

    const current = createPathToFile(this.workspaceDir, this.excludeFilepaths);
    let restored = false;

    // Restore missing or modified files
    for (const [filePath, file] of this.pathToFile.entries()) {
      if (file.excluded) {
        continue;
      }
      const currentFile = current.get(filePath);
      if (currentFile?.hash === file.hash) {
        continue;
      }

      fs.writeFileSync(file.path, file.content, ENCODING);
      restored = true;
      // Sync any open in-memory document to the restored content
      await this.syncVscodeDocument(vscode, filePath, file.content);
    }

    // Remove files not in original snapshot
    for (const [filePath, file] of current.entries()) {
      if (file.excluded) {
        continue;
      }
      if (!this.pathToFile.has(filePath)) {
        fs.rmSync(file.path, { force: true });
        restored = true;
      }
    }

    return restored;
  }

  private async syncVscodeDocument(
    vscode: typeof import("vscode") | undefined,
    filePath: string,
    content: string,
  ): Promise<void> {
    if (!vscode) {
      return;
    }
    try {
      const uri = vscode.Uri.file(filePath);
      const document = vscode.workspace.textDocuments.find(
        (doc) => doc.uri.fsPath === uri.fsPath,
      );
      if (!document || document.isClosed || document.getText() === content) {
        return;
      }

      // Important to use the VSCode API to perform these operations
      // since out of band writes can create unexpected behavior
      const edit = new vscode.WorkspaceEdit();
      edit.replace(uri, new vscode.Range(0, 0, document.lineCount, 0), content);
      await vscode.workspace.applyEdit(edit);
      await document.save();
    } catch {
      // Document may be disposed/closed, ignore - disk restore is sufficient
    }
  }
}
```

## Usage in Tests

Here is an example test. You will notice none of the framework code is used here. That is because all of it is rolled
up into the global hooks in `suite/index.ts`, which run around every test. This makes the framework easy to plug into
your existing tests without much overhead.

```ts
import * as path from "path";
import { expect, use } from "chai";
import chaiAsPromised from "chai-as-promised";
import { describe, it } from "mocha";
import * as vscode from "vscode";
import { TEST_WORKSPACE_DIR } from "./testing";

// Needed for `.rejected` / `.fulfilled` assertions on promises
use(chaiAsPromised);

describe("extension", () => {
  const EXTENSION_ID = "awalsh128.keep-sorted";
  const SAMPLE_TS_FILENAME = "sample.ts";

  it("should complete activation successfully", async () => {
    // Arrange
    const extension = vscode.extensions.getExtension(EXTENSION_ID)!;

    // Act & Assert
    await expect(extension.activate()).to.not.be.rejected;
    expect(extension.isActive).to.equal(true);
  });

  const getDocument = async (filename?: string | vscode.Uri) => {
    const uri =
      filename instanceof vscode.Uri
        ? filename
        : vscode.Uri.file(
            path.join(TEST_WORKSPACE_DIR, filename ?? SAMPLE_TS_FILENAME),
          );
    return await vscode.workspace.openTextDocument(uri);
  };
  const delay = (ms: number) =>
    new Promise((resolve) => setTimeout(resolve, ms));

  describe("activation behavior", () => {
    it("should create diagnostics on save", async () => {
      // Arrange
      const document = await getDocument();

      // Act - Make an edit and save to trigger diagnostics
      const edit = new vscode.WorkspaceEdit();
      edit.insert(document.uri, new vscode.Position(0, 0), "\n");
      await vscode.workspace.applyEdit(edit);
      await document.save();

      // Wait for async diagnostic processing (see the principles above)
      await delay(1000);

      // Assert
      const diagnostics = vscode.languages.getDiagnostics(document.uri);
      expect(diagnostics).to.be.an("array").with.length.greaterThan(0);
      // No cleanup needed; the global afterEach restores the workspace
    });
    // ...
  });
});
```

> [!WARNING]
> A fixed `delay` is the simplest way to wait on async work, but it can get flaky on slow CI machines. If that happens,
> poll for the expected state with a timeout or wait on an event like `vscode.languages.onDidChangeDiagnostics`
> instead.

## Conclusion

- Test against a real VSCode instance with `@vscode/test-electron` instead of mocking the API.
- Snapshot the test workspace once and restore it after every test so each test starts clean.
- Rotate the extension's log into a file per test so failures are easy to diagnose.
- Do your edits through the VSCode API and expect to wait on async results.

That was a lot of code but I hope it saves you some of the trial and error it took me. Good luck!
