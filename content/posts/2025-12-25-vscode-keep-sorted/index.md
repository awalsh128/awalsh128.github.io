---
title: VSCode Keep Sorted Extension
last_modified_at: 2026-10-22 00:00:01 -0700
tags:
  - VSCode
  - vscode
  - vscode extension
  - keep-sorted
---

<table width="100%">
  <tr>
    <td width="48"><img src="logo.png" alt="Logo" width="48" height="48"></td>
    <td style="padding-left:1em"><h1>VSCode Keep Sorted Extension</h1></td>
  </tr>
</table>

> [!NOTE]
> Updated October 2026 for version 1.0.2. This post originally announced the 0.0.1 release in December 2025. Commands,
> settings, and features below reflect the latest version.

I released a lightweight VS Code extension that keeps marked blocks in your code sorted using
**[Google's Keep Sorted](https://github.com/google/keep-sorted)** formatter. I saw a gap for an extension that handles
blocks generically, in any language, with options to modify the sorting behavior. It is now at 1.0.2 and available on
both the [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=awalsh128.keep-sorted) and the
[Open VSX Registry](https://open-vsx.org/extension/awalsh128/keep-sorted).

The extension has pretty comprehensive code coverage, diagnostics and error handling to make it more reliable.

It is a language agnostic sorting tool that works in any programming language or file type and provides:

- ⚠️ **Real-time Diagnostics**: Warnings with squiggly underlines for unsorted blocks as you open, edit, and save files.
- 💡 **Quick Fixes and Commands**: Sort the current file or every file with Keep Sorted warnings.
- 💾 **Sort on Save**: Optional sorting on save through a source fix-all action.
- ✨ **Autocomplete and Hover Docs**: Suggestions for option names and values on `keep-sorted start` lines, with
  documentation on hover. Options that conflict with ones already on the line aren't suggested.
- ⚡ **No Extra Installs**: Native keep-sorted v0.10.0 binaries are bundled for Windows x64, Linux x64, and macOS
  Intel/Apple Silicon, so you don't need a separate keep-sorted install or a Go compiler.
- 🎛️ **Flexible Configuration**: Enable/disable toggle, autocomplete toggle, file exclusion patterns, and optional
  file logging alongside the Output panel.

See the [demo video](https://github.com/user-attachments/assets/87cce237-4214-4047-a5c4-b6a4162245d2) to see it in
action and the [README](https://github.com/awalsh128/vscode-keep-sorted#readme) for the complete documentation.

## Installation

Install Keep Sorted from the
[Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=awalsh128.keep-sorted) or the
[Open VSX Registry](https://open-vsx.org/extension/awalsh128/keep-sorted). It requires VS Code 1.100.0 or newer.

## Examples

### Basic Sorting

#### JavaScript/TypeScript Imports

```typescript
// keep-sorted start
import { Component } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import fs from "fs";
import path from "path";
// keep-sorted end
```

#### Python Imports

```python
# keep-sorted start
import json
import os
import sys
from datetime import datetime
from typing import List, Dict
# keep-sorted end
```

### Case-Insensitive Sorting

Use `case=no` to sort without considering case:

```typescript
// keep-sorted start case=no
import { ComponentA } from "./components";
import { utilityB } from "./utils";
import { ServiceC } from "./services";
import { helperD } from "./helpers";
// keep-sorted end
```

### Numeric Sorting

Use `numeric=yes` to sort numbers by their numeric value instead of lexically:

```python
# keep-sorted start numeric=yes
item_1 = "first"
item_5 = "fifth"
item_10 = "tenth"
item_50 = "fiftieth"
item_100 = "hundredth"
# keep-sorted end
```

### Descending Order

Use `order=desc` to sort in reverse:

```python
# keep-sorted start order=desc
zebra = 3
monkey = 2
aardvark = 1
# keep-sorted end
```

### Block Sorting

Use `block=yes` to sort complex multi-line blocks like structs or objects:

```typescript
const widgets = [
  // keep-sorted start block=yes
  {
    name: "alpha",
    value: 100,
  },
  {
    name: "beta",
    value: 200,
  },
  {
    name: "delta",
    value: 150,
  },
  // keep-sorted end
];
```

### Prefix Ordering

Use `prefix_order` to control the order of specific prefixes. An empty entry stands for everything else:

```python
# keep-sorted start prefix_order=INIT_,,FINAL_
INIT_DATABASE = 1
INIT_LOGGING = 2
PROCESS_DATA = 3
VALIDATE_INPUT = 4
FINAL_CLEANUP = 5
FINAL_SHUTDOWN = 6
# keep-sorted end
```

### Ignore Prefixes

Use `ignore_prefixes` to ignore certain prefixes when sorting:

```typescript
// keep-sorted start ignore_prefixes=const,let,var
const apple = 1;
let banana = 2;
var cherry = 3;
const date = 4;
// keep-sorted end
```

### Custom Grouping

Use `group_prefixes` to keep related lines together:

```text
<!-- keep-sorted start group_prefixes=and,with -->
hamburger
with lettuce
and tomatoes
peanut butter
and jelly
spaghetti
with meatballs
<!-- keep-sorted end -->
```

### Newline Separated

Use `newline_separated=yes` to add blank lines between sorted items:

```python
# keep-sorted start newline_separated=yes
def calculate_total():
    pass

def process_data():
    pass

def validate_input():
    pass
# keep-sorted end
```

### Skip Lines

Use `skip_lines=N` to skip header lines (useful for tables):

```text
<!-- keep-sorted start skip_lines=2 -->
| Name  | Value |
| ----- | ----- |
| Alpha | 100   |
| Beta  | 200   |
| Delta | 150   |
| Gamma | 175   |
<!-- keep-sorted end -->
```

### Sticky Comments

Comments stick with the line below them by default:

```python
# keep-sorted start
# Configuration for production
PROD_URL = "https://prod.example.com"
# Configuration for staging
STAGING_URL = "https://staging.example.com"
# Configuration for development
DEV_URL = "http://localhost:3000"
# keep-sorted end
```

### Regular Expression Sorting

Use `by_regex` to sort based on specific patterns:

```java
// keep-sorted start by_regex=\w+;
String bar;
Object baz;
List<String> foo;
// keep-sorted end
```

### Remove Duplicates

Duplicates are removed by default, but you can disable it:

```yaml
# keep-sorted start remove_duplicates=no
- apple
- apple
- banana
- banana
- cherry
# keep-sorted end
```

## Usage

> [!IMPORTANT]
> See [google/keep-sorted#options](https://github.com/google/keep-sorted?tab=readme-ov-file#options) for complete
> documentation on all the options that are available.

### Setting Up Keep Sorted Blocks

Place markers around only the lines that should move, using your language's comment syntax:

```python
items = [
    # keep-sorted start
    'zebra',
    'alpha',
    'delta',
    # keep-sorted end
]
```

The extension warns when these blocks aren't sorted and offers fixes.

### Sorting Methods

#### 1. Command Palette

Use `Ctrl+Shift+P` / `Cmd+Shift+P` and search for:

- **"Keep Sorted: Sort Current File"** - Sort all keep-sorted blocks in the active file.
- **"Keep Sorted: Sort All Files with Problems"** - Sort every file with Keep Sorted warnings. This covers workspace
  files scanned at startup (respecting `files.exclude` and `keep-sorted.exclude`) plus files opened or edited since.
  All changes are applied as one edit, so review them and then use **File → Save All**.

For keybindings or automation, use the command IDs `keep-sorted.fixFile` and `keep-sorted.fixWorkspace`. The old
`keep-sorted.sortFile` alias has been removed, so update any existing keybindings to `keep-sorted.fixFile`.

#### 2. Quick Fixes (Lightbulb)

When the extension detects unsorted content:

1. A warning squiggle appears under the unsorted block.
2. Put the cursor in the block and click the lightbulb 💡 icon or press `Ctrl+.` / `Cmd+.`.
3. Choose from the available actions:
   - **"Sort all lines in file (keep-sorted)"** - Sorts all keep-sorted blocks in the file.
   - **"Sort all files with problems (keep-sorted)"** - Shown when other files also have warnings.

Quick fixes are also available from the Problems panel (`Ctrl+Shift+M` / `Cmd+Shift+M`). Once a file is sorted, its
resolved warnings disappear from Problems while any remaining issues stay visible.

#### 3. Sort on Save

Add this to your VS Code user or workspace settings:

```json
{
  "editor.codeActionsOnSave": {
    "source.fixAll.keepSorted": "explicit"
  }
}
```

- `"explicit"` - Sort on an explicit save, such as `Ctrl+S` / `Cmd+S`.
- `"always"` - Also sort on Auto Save triggered by focus or window changes, but not after-delay Auto Save.
- `"never"` - Disable the save action.

Without this, saving refreshes diagnostics but doesn't sort. `editor.formatOnSave` isn't needed.

### Autocomplete and Hover

Add options after `start` and autocomplete suggests option names with documentation, then known values such as
`yes`/`no` or `order=asc|desc` after the `=`. Hover over an option to see its documentation.

### Settings

| Setting                    | Default | Description                                                             |
| -------------------------- | ------- | ----------------------------------------------------------------------- |
| `keep-sorted.enabled`      | `true`  | Enable diagnostics, sorting commands, and code actions.                 |
| `keep-sorted.autoComplete` | `true`  | Suggest option names and values after `start`, with documentation.      |
| `keep-sorted.exclude`      | `[]`    | Exclude files from diagnostics and sorting; regex first, glob fallback. |
| `keep-sorted.logFilepath`  | `""`    | Add file logging alongside Output; empty disables file logging.         |

For example, to exclude generated and vendored files:

```json
{
  "keep-sorted.exclude": ["**/node_modules/**", "**/dist/**", "**/*.min.js"]
}
```

### Supported File Types

Keep Sorted works with any file type and is language agnostic. Common use cases include:

- import statements,
- lists,
- top level file types and classes, and
- many more.

## Troubleshooting

### Extension Not Working?

1. **No Warnings or Sorting?**

   - Verify `keep-sorted.enabled` is set to `true` in settings.
   - Check that the file isn't excluded via `keep-sorted.exclude` patterns.
   - Make sure the block has matching `keep-sorted start` and `keep-sorted end` markers.

2. **Commands Not Available?**

   - Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and search for "Keep Sorted". The commands are hidden
     while `keep-sorted.enabled` is off.
   - If they still don't appear, reload VS Code (`Developer: Reload Window`).

3. **Save Doesn't Sort?**

   - Configure `source.fixAll.keepSorted` as shown in Sort on Save. Format on save alone doesn't invoke this extension.

4. **Performance Issues?**

   - Add problematic file patterns to `keep-sorted.exclude`.

5. **Viewing Extension Logs**

   - Open the Output panel: `View` → `Output` or `Ctrl+Shift+U` / `Cmd+Shift+U`.
   - Select "Keep Sorted" from the dropdown menu.
   - Logs show extension activity, errors, and diagnostic information.
   - For persistent logs, set `keep-sorted.logFilepath` (e.g. `logs/keep-sorted.log`, which is relative to the first
     workspace folder).

### Fixes Are Malformed

This is usually due to an incorrect block setup rather than the underlying Google `keep-sorted` command itself.

For example, here the block wraps the whole list instead of just its items:

```py
# keep-sorted start
items = [
  'zebra',
  'alpha',
  'delta',
  'beta',
]
# keep-sorted end
```

Sorting it breaks the syntax because non-alphanumeric characters come first in the sort order:

```py
# keep-sorted start
],
items = [
  'zebra',
  'alpha',
  'delta',
  'beta'
# keep-sorted end
```

The command is working correctly but the declaration is wrong. Keep declarations and surrounding brackets outside the
markers instead:

```py
items = [
  # keep-sorted start
  'zebra',
  'alpha',
  'delta',
  'beta',
  # keep-sorted end
]
```

See [google/keep-sorted#options](https://github.com/google/keep-sorted?tab=readme-ov-file#options) for more on
setting up blocks, including options to group multi-line entries.

### Getting Help

- **Report Issues and Request Features**: [GitHub Issues](https://github.com/awalsh128/vscode-keep-sorted/issues)
- **Documentation**: [Keep Sorted Project](https://github.com/google/keep-sorted)

## License

This project is licensed under the Apache 2.0 License. See
[LICENSE.md](https://github.com/awalsh128/vscode-keep-sorted/blob/main/LICENSE.md) for details.
