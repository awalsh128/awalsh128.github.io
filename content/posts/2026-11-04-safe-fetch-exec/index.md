---
title: "safe-fetch-exec: A Safer curl | bash"
date: "2026-11-04T00:00:00.000-07:00"
author: awalsh128
draft: true
tags:
  - Security
  - System Administration
modified_time: "2026-11-04T00:00:00.000-07:00"
summary: "Download a script, check its SHA-256, and only then run it."
---

TODO(andrew): a sentence or two on what got you to write this (e.g. the install commands in your own posts).

Piping `curl` straight into `bash` is how a lot of software asks to be installed. It's convenient, but you're running
whatever the server sends at that moment, and you can't see it first. A dropped connection can even run half a
script.

`safe-fetch-exec` is a small wrapper that fixes the parts of that we can fix. It downloads the whole script over HTTPS,
checks its SHA-256 hash against the one you give it, and only then runs it.

{{< code-include source="safe-fetch-exec" language="bash" collapse="true" >}}

## Installing It

You can't use `safe-fetch-exec` to install `safe-fetch-exec`, so this one is a plain download and check. The hash
below is computed from the file when the site is built.

{{< verified-download sources="safe-fetch-exec" >}}

Then read it (it's short), and put it on your `PATH`.

```bash
less safe-fetch-exec
install -m 0755 safe-fetch-exec ~/.local/bin/
```

On macOS, use `shasum -a 256 --check` in place of `sha256sum --check`.

### Checking It Came From This Site's Build

The hash above lives on the same site as the file, so if someone could change one, they could change the other. For a
check that doesn't depend on this site, every build signs the published scripts with a
[GitHub artifact attestation](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations).
It ties the file to the commit and workflow that built it, signed through [Sigstore](https://www.sigstore.dev/).

```bash
gh attestation verify safe-fetch-exec --repo awalsh128/awalsh128.github.io
```

## Using It

Posts on this site that install something show a command like this instead of `curl ... | bash`:

```bash
safe-fetch-exec <sha256> https://awalsh128.com/some-post/install.sh
```

To look at the script without running it, add `--dry-run`. Anything after the URL is passed to the script.

```bash
safe-fetch-exec --dry-run <sha256> https://awalsh128.com/some-post/install.sh
```

What it does on top of `curl | bash`:

- **HTTPS only**, including after redirects, with TLS 1.2 or newer.
- **Ignores `~/.curlrc`**, so a modified config can't change the download.
- **Downloads the whole file first**, so a dropped connection never runs a partial script.
- **Checks the hash** before running anything, and stops on a mismatch.
- **Runs the script in a clean `bash`**, without your startup files or `BASH_ENV`.
- **Caps the download** at 10 MiB and 2 minutes.

## Caveats

- **It's not a sandbox.** The script runs as you, with everything you can touch. A hash only proves you got the bytes
  you expected, not that they're safe. Read it with `--dry-run` first.
- **The hash is only as good as where it came from.** If the hash and the script come from the same site, someone who
  can change one can usually change both. The attestation check above is the way around that for this site.
- **Changing a script breaks old commands.** That's on purpose: a command you copied last year fails instead of running
  something you never saw.
- **It can't see past the first script.** If that script downloads and runs something else, that part is up to the
  script.

That's it. It won't make an untrustworthy script safe, but it does take the guesswork out of what actually runs.
