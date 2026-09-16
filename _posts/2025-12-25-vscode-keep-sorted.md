---
title: VSCode Keep Sorted Extension 0.0.1
last_modified_at: 2025-12-25 00:00:01 -0700
tags:
  - VSCode
  - vscode
  - vscode extension
  - keep-sorted
---

<table width="100%">
  <tr>
    <td width="48"><img src="/assets/img/2025-12-25-vscode-keep-sorted/logo.png" alt="Logo" width="48" height="48"></td>
    <td style="padding-left:1em"><h1>VSCode Keep Sorted Extension 0.0.1 Released</h1></td>
  </tr>
</table>

I recently released lightweight VS Code extension that automatically keeps sorted blocks in your code organized using
**[Google's Keep Sorted](https://github.com/google/keep-sorted)** formatter, seeing a gap in an available extension that
handles code blocks generically and with options to modify behavior.

The extension has pretty comprehensive code coverage, diagnostics and error handling to create a more reliable
extension.

It is a language agnostic sorting tool, working in any programming language or file type that provides:

- 🔍 **Automatic Detection**: Recognizes `// keep-sorted start` and `// keep-sorted end` blocks in any file type
- 💡 **Quick Fix Actions**: To sort just the block, the entire file or the entire workspace.
- ✨ **Autocomplete for Options**: Get intelligent suggestions for keep-sorted options when typing on a
  `keep-sorted start` line
- 📊 **Real-time Diagnostics**
  - Shows warnings with squiggly underlines for unsorted content
  - Logging integration with VSCode with severity levels for general information and debugging
- ⚡ **Performance Optimized**
  - Uses native binaries for fast sorting operations for x86, ARM, Darwin and Windows
  - No outside libraries required to be brought into the development environment (i.e. Go compiler).
- 🎛️ **Flexible Configuration**: File exclusion patterns, enable/disable toggle, and optional file logging

See http://github.com/awalsh128/vscode-keep-sorted/README.md for the complete documentation of the extension.

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

### Block Sorting

Use `block=yes` to sort complex multi-line blocks like structs or objects:

```typescript
// keep-sorted start block=yes
const widgets = [
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
];
// keep-sorted end
```

### Prefix Ordering

Use `prefix_order` to control the order of specific prefixes:

```javascript
// keep-sorted start prefix_order=INIT_,,FINAL_
INIT_DATABASE, INIT_LOGGING, PROCESS_DATA, VALIDATE_INPUT, FINAL_CLEANUP, FINAL_SHUTDOWN;
// keep-sorted end
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

```markdown
<!-- keep-sorted start group_prefixes=and,with -->

hamburger with lettuce and tomatoes peanut butter and jelly spaghetti with meatballs

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

```markdown
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

IMPORTANT: See [google/keep-sorted#options](https://github.com/google/keep-sorted?tab=readme-ov-file#options) for
complete documentation on all the options that are available.

### Setting Up Keep Sorted Blocks

Add keep-sorted markers around the content you want to keep sorted:

```javascript
// keep-sorted start
import { zebra } from "./animals";
import { apple } from "./fruits";
import { car } from "./vehicles";
// keep-sorted end
```

The extension will detect when these blocks are not properly sorted and provide automatic fixes.

### Sorting Methods

#### 1. Quick Fixes (Lightbulb)

When the extension detects unsorted content:

1. A warning squiggle appears under the unsorted block
2. Click the lightbulb 💡 icon or press `Ctrl+.` / `Cmd+.`
3. Choose from available actions:
   - **"Sort all lines in block (keep-sorted)"** - Sorts just the selected block
   - **"Sort all lines in file (keep-sorted)"** - Sorts all keep-sorted blocks in the file

#### 2. Command Palette

Use `Ctrl+Shift+P` / `Cmd+Shift+P` and search for:

- **"Keep Sorted: Fix Current File"** - Sort all keep-sorted blocks in the active file
- **"Keep Sorted: Fix Entire Workspace"** - Sort all keep-sorted blocks across all workspace files

#### 3. Problems Panel

1. Open the Problems panel (`Ctrl+Shift+M` / `Cmd+Shift+M`)
2. Look for keep-sorted warnings
3. Use "Quick Fix" or "Fix All" options directly from the panel

### Supported File Types

Keep Sorted works with any file type and is language agnostic. Common use cases include:

- import statements,
- lists,
- top level file types and classes, and
- many more.

## Troubleshooting

### Extension Not Working?

1. **Check Extension Status**

   - Ensure the extension is enabled in VS Code
   - Verify `keep-sorted.enabled` is set to `true` in settings

2. **No Diagnostics Appearing?**

   - Make sure your blocks use the correct syntax: `// keep-sorted start` and `// keep-sorted end`
   - Check if files are excluded via `keep-sorted.exclude` patterns
   - Verify the file is saved (diagnostics appear after save)

3. **Commands Not Available?**

   - Open Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and search for "Keep Sorted"
   - If commands don't appear, try reloading VS Code (`Developer: Reload Window`)
   - Verify the extension is activated (check status bar or Extensions view)

4. **Performance Issues?**

   - Add problematic file patterns to `keep-sorted.exclude`
   - Check VS Code's Output panel (select "Keep Sorted" from dropdown) for error messages

5. **Viewing Extension Logs**
   - Open the Output panel: `View` → `Output` or `Ctrl+Shift+U` / `Cmd+Shift+U`
   - Select "Keep Sorted" from the dropdown menu
   - Logs show extension activity, errors, and diagnostic information
   - For persistent logs, configure `keep-sorted.logFilepath` in settings

### Fixes Are Malformed

This is usually due to the underlying Google `keep-sorted` command itself and have an incorrect block setup.

An example where the block isn't inside the list.

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

Breaks the syntax because non-alphanumeric characters have precedence in the sort order.

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

The command is working correctly but the declaration is incorrect. The correct block setup should be.

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

To ensure your statements are correct see
[google/keep-sorted#options](https://github.com/google/keep-sorted?tab=readme-ov-file#options) for more information.

### Getting Help

- **Report Issues**: [GitHub Issues](https://github.com/awalsh128/vscode-keep-sorted/issues)
- **Feature Requests**: [GitHub Discussions](https://github.com/awalsh128/vscode-keep-sorted/discussions)
- **Documentation**: [Keep Sorted Project](https://github.com/google/keep-sorted)

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE.md](LICENSE.md) file for details.
