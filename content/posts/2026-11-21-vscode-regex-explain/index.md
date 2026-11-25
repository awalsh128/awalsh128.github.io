---
title: Regex Explain for VS Code
summary:
  "Explain a regex in plain English on hover, and get a warning when it can backtrack catastrophically."
tags:
  - VS Code
  - TypeScript
  - Security
  - Open Source
---

<img src="logo.png" alt="Regex Explain logo" width="64" height="64">

<!-- prettier-ignore-start -->
> [!NOTE]
> This post may become out of date. See the project's
> [README](https://github.com/awalsh128/vscode-regex-explain/blob/main/README.md) for the latest.
<!-- prettier-ignore-end -->

I released [Regex Explain](https://github.com/awalsh128/vscode-regex-explain), a VS Code extension that
explains a regular expression in plain English, and warns about patterns that can backtrack catastrophically
(i.e. ReDoS). The explanation engine is also published as an npm library.

There are already a lot of Regex tools available as VS Code extensions. What pushed me was a more
comprehensive way to explain regular expressions, through visualization, sandboxing, plain english
descriptions, and realtime feedback. The extensions available handled these features separately but I wanted
something that packaged them more robustly.

It is on the
[Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=awalsh128.regex-explain) and
the [Open VSX Registry](https://open-vsx.org/extension/awalsh128/regex-explain), and needs VS Code 1.100.0 or
newer.

## Features

- **Hover explanations:** for regex literals and for patterns passed to regex APIs, in nine languages.
- **Selection explanations:** select any pattern in any file and hover it.
- **Backtracking warnings:** with an equivalent safe pattern when one exists.
- **Explanation panel:** it sits beside the editor, explains the regex step by step and tests it against your
  input.

## Hover

Hover a regex, or select one and hover the selection. For this email pattern:

```text
/^(?<user>[\w.+-]+)@([a-z\d-]+\.)+[a-z]{2,}$/i
```

the hover lists each part with what it matches. For example `^` is "Assert position is at the start of the
input", and `(?<user>[\w.+-]+)` is "Capture group #1 named `user`". It also ends with a note on how many
characters the pattern matches and what each flag does.

## Backtracking warnings

For `/^(?:a+)+$/` the hover starts with a warning:

> **Warning:** `a+` is repeated by `(?:a+)+` and can match the same text in many ways, so a failed match can
> take exponential time. Equivalent safe pattern: `/^a+$/`

Turn off `regexExplain.checkBacktracking` if you don't want these.

## The panel

Open it from the hover, the Command Palette (**Regex Explain: Explain Regex**) or the editor context menu. It
draws the regex as a state machine, with a step list and a table of matches for the input you type. It follows
your cursor while it is open, and **Open in regex101** sends the pattern and input to
[regex101.com](https://regex101.com).

## Finding regexes

Regexes are found by parsing the file with [tree-sitter](https://tree-sitter.github.io/), so regex-like text
in comments, other strings and division is ignored. String escapes are decoded, so `"\\d+"` is explained as
`\d+`. The [README](https://github.com/awalsh128/vscode-regex-explain#readme) has the list of languages, the
settings and the known limitations.

Bugs and requests go in the repo's [issues](https://github.com/awalsh128/vscode-regex-explain/issues).
