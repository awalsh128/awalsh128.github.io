---
title: "A Safer curl | bash"
date: "2026-11-04T00:00:00.000-07:00"
author: awalsh128
tags:
  - Security
  - System Administration
modified_time: "2026-11-04T00:00:00.000-07:00"
summary: "Download a script, check its SHA-256, and only then run it, using tools you already have."
---

I've had to fetch a file and run it a few times. For example, [](/posts/2026-11-04-bt-toggle-linux-logins) used to
tell readers to do this, and a repo I maintain did it at runtime (since fixed by bundling the file instead).

Piping `curl` straight into `bash` is how a lot of software asks to be installed (e.g. [Homebrew](https://brew.sh/),
[nvm](https://github.com/nvm-sh/nvm#install--update-script), [Bun](https://bun.sh/), [rustup](https://rustup.rs/)).
It's convenient and a simple two-liner, but you're running whatever the server sends at that moment, and you can't see
it first. A dropped connection can even run half a script. At best it stops partway; at worst it leaves your system
half-changed.

This isn't hypothetical either. Attackers altered the [Codecov Bash Uploader](https://about.codecov.io/security-update/),
which CI pipelines ran with `curl | bash`, and it quietly sent their secrets out for two months before a customer's
hash check caught it.

I started writing a small wrapper to address this, then realized it was mostly re-implementing two tools that are already on almost every Linux machine: `curl` and `sha256sum` (from coreutils). They're packaged, maintained, and audited by far more people than any wrapper I'd write, so this post uses them directly.

## Download, Check, Then Run

The pattern is three steps chained with `&&`, so each one only happens if the previous one worked.

```bash
PUB_SHA256="<the authoritative hash for the script from the published source>"
curl -q --proto '=https' --tlsv1.2 -fsSLO https://example.com/install.sh &&
printf '%s  %s\n' "$PUB_SHA256" 'install.sh' | sha256sum --check &&
bash install.sh
```

Here is what each part does:

- `-q` - ignores `~/.curlrc`, so a modified config can't change the download. It has to be the first option.
- `--proto '=https' --tlsv1.2` - HTTPS only (including after redirects), with TLS 1.2 or newer.
- `-f` - fails on an HTTP error instead of saving the error page as the script.
- `-sSLO` - quiet but still shows errors, follows redirects, and saves under the remote file name.
- `PUB_SHA256` - the script's hash as its publisher lists it (e.g. on their release page), copied in by you rather than
  fetched with the script.
- `printf '%s  %s\n' "$PUB_SHA256" 'install.sh'` - writes the line `sha256sum` expects: the hash, two spaces, and the
  file name. macOS's `shasum` rejects the line without the second space, and the format string makes it easy to see.
- `sha256sum --check` - compares the file to the hash and fails on a mismatch.
- `bash install.sh` - only runs once the whole file is on disk and matches, so a dropped connection never runs half a
  script.

On macOS, use `shasum -a 256 --check` in place of `sha256sum --check`.

## Example

Posts on this site, that install something, show a command like the one below. The hash is computed from the file
when the site is built, so it always matches what the site serves. Try it; the script only prints its arguments.

{{< verified-download sources="hello.sh" run="hello.sh" args="--name you" >}}

{{< code-include source="hello.sh" collapse="true" >}}

To read a script before running it, leave off the last line (and the `&&` before it), then open the file after the
check passes.

```bash
less hello.sh
```

### Checking It Came From This Site's Build

The hash above lives on the same site as the file, so if someone could change one, they could change the other. For a
check that doesn't depend on this site, every build signs the published scripts with a
[GitHub artifact attestation](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations).
It ties the file to the commit and workflow that built it, signed through [Sigstore](https://www.sigstore.dev/).

```bash
gh attestation verify hello.sh --repo awalsh128/awalsh128.github.io
```

## What About Other Tools?

I looked for an existing tool before settling on plain coreutils. None of them was both pinned to a hash and still
maintained when I checked (November 2026).

- [preflight](https://github.com/spectralops/preflight) - pipes through `preflight run sha256=<hash>` and stops on a
  mismatch, which is the closest match. No release since 2022.
- [hashpipe](https://github.com/jbenet/hashpipe) - passes the data through only if the hash matches. No commits since
  2022, and it defaults to base58 multihashes rather than the hex hashes projects publish.
- [vet](https://github.com/vet-run/vet) - shows the script, a diff since your last run, and shellcheck output, then asks
  before running. It's the most active of the three, but it doesn't check a hash, so it protects you only as well as
  your review does.

None of them is in Ubuntu's repositories either, so you'd be installing a tool from a third party to avoid trusting a
third party.

## Caveats

- **It's not a sandbox.** The script runs as you, with everything you can touch. A hash only proves you got the bytes
  you expected, not that they're safe. Read the script first.
- **The hash is only as good as where it came from.** If the hash and the script come from the same site, someone who
  can change one can usually change both. The attestation check above is the way around that for this site.
- **Changing a script breaks old commands.** That's on purpose: a command you copied last year fails instead of running
  something you never saw.
- **It can't see past the first script.** If that script downloads and runs something else, that part is up to the
  script. [Playwright's install scripts](https://github.com/advisories/GHSA-7mvr-c777-76hp) (CVE-2025-59288) are a
  real example: they downloaded packages with TLS certificate checks turned off, so a verified install script would
  still have pulled in whatever an attacker served.

That's it. It won't make an untrustworthy script safe, but it does take the guesswork out of what actually runs.

## References

- [CWE-494: Download of Code Without Integrity Check](https://cwe.mitre.org/data/definitions/494.html) - MITRE's
  entry for running downloaded code without checking where it came from or that it's unchanged.
- [NIST SP 800-218, Secure Software Development Framework](https://csrc.nist.gov/pubs/sp/800/218/final) - practice
  PS.2.1 asks publishers to make integrity checks available (e.g. hashes of release files on a well-secured site).
- [OpenSSF Scorecard: Pinned-Dependencies](https://github.com/ossf/scorecard/blob/main/docs/checks.md#pinned-dependencies) -
  flags dependencies in shell scripts and workflows that aren't pinned to a hash.
- [curl manual](https://curl.se/docs/manpage.html) - the `-q`, `--proto`, `--proto-redir`, and `--tlsv1.2` options used
  above.
- [GitHub artifact attestations](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations) -
  how the build signs the published scripts.
- [SLSA build provenance](https://slsa.dev/spec/v1.0/provenance) - the OpenSSF format for recording which build
  produced a file, which GitHub's attestations follow.
- [Sigstore](https://www.sigstore.dev/) - the signing service behind the attestations.
