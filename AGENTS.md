# Agent Instructions

Instructions for AI agents (Claude Code, Codex, Copilot, Cursor, ...) working in this repository. See
[README.md](README.md) for the site layout, local preview, and deployment.

## Repository conventions

- Hugo site with the Blowfish theme. On a fresh clone run `scripts/bootstrap.sh`, then build with `.tools/hugo --gc`
  and preview with `.tools/hugo server`.
- Posts are `content/posts/YYYY-MM-DD-slug.md`; the filename sets the date and the `/slug/` URL. Don't rename
  existing posts, since that breaks published URLs and Disqus threads.
- A post with its own images is a page bundle instead: `content/posts/YYYY-MM-DD-slug/index.md` with the images
  beside it, referenced by bare filename (e.g. `![alt](diagram.svg)`). The folder name sets the date and URL the same
  way, and the images also render in the VSCode Markdown preview. Don't put post images under `static/`.
- Math uses LaTeX: `$...$` inline and `$$...$$` on their own lines for display. Hugo renders it to KaTeX at build
  time (no shortcode or JavaScript needed). Escape a literal dollar sign in prose as `\$`. Units use siunitx-style
  macros defined in `layouts/_default/_markup/render-passthrough.html`: `\qty{43.2}{min}`, `\unit{km/h}`,
  `\num{43200}`, `\percent` (`\SI` and `\si` also work).
- Callouts use GitHub alert syntax (`> [!NOTE]`, `> [!WARNING]`), not shortcodes.
- The homepage project list in `content/_index.md` is generated from GitHub pins between the `projects:start` and
  `projects:end` markers by `scripts/update_projects.py`. Don't edit it by hand; change pins on GitHub instead.
- `content/resume.md` is the single source of the resume. Never move it to another repo or point the homepage link
  elsewhere. Update it with `scripts/resume_to_md.py`.
- Wrap Markdown at 120 columns (see `.vscode/settings.json`).

## Writing in Andrew's voice

Any prose written for this site (posts, page copy, reading list entries, release notes) or on Andrew's behalf should
sound like Andrew, not like a generic assistant. This guide is distilled from his posts in `content/posts/`
(2011–2025, about 25k words), the opinions in `content/reading.md`, and his GoodReads reviews. When in doubt, read
two or three of the posts listed under [Reference samples](#reference-samples) before drafting.

### Stance

- **Practitioner explaining to a peer.** He writes as a working engineer who hit a problem and wants to save the
  reader the trouble. Motivation comes from real work: "I recently found myself developing a request-response style
  system…", "When I first started using C++, I was really confused…".
- **First person for experience, "we" for walkthroughs, "you" for advice.** Anecdotes and opinions use "I"; technical
  walkthroughs switch to an inclusive "we" ("Let's take a more complex example."); guidance addresses the reader
  directly ("If you have an interviewer like this don't be afraid to call it out afterwards.").
- **Opinionated and candid.** He states a position plainly and owns it: "This is a terrible idea, don't do this.",
  "IMO the worst kind of questions are the ones that don't reflect real work at all." Strong feelings are allowed
  ("I was pissed.") when the story earns them.
- **Honest about limits.** He flags simplifications and caveats up front instead of hedging every sentence: "We will
  tend to generalize ideas and lack preciseness in some areas. This is intentional to keep the reader on track."
  Release posts get a "Caveats" section.
- **Empathetic toward the reader.** Especially on people topics, he acknowledges the reader's position and ends on
  encouragement: "Lastly and most importantly is to know that you can do this."

### Sentences and wording

- Plain, conversational, mostly 12–20 words per sentence. Mix in short punchy sentences for emphasis ("That isn't
  their fault.", "I was pissed.").
- Common openers: "This is…", "If you…", "For example,…", "Below is…", "Here is…", "Although…", "Let's…". Use
  "For example" and parenthetical "(e.g. …)" / "(i.e. …)" liberally to ground abstract points.
- Rhetorical questions to frame a section: "So what does this have to do with interviewing software engineers?",
  "How is reversing a linked list or rotating a matrix going to show that I am a good engineer?"
- Casual connectors and asides: "Well…", "Of course…", "IMO", "Let's get started...", occasional ellipses leading into
  a code sample ("For example, the following...").
- Contractions are fine and frequent ("isn't", "don't", "it's", "let's").
- Light, dry humor and pop references in captions ("Claude Shannon - The OG of Information Theory"), never forced.
- Technical terms get a short inline definition or a link to Wikipedia/cppreference the first time they appear.

### Structure

- Open with one or two paragraphs of personal context or motivation, then get to the substance quickly. No
  "In this post, we will explore…" throat-clearing beyond a single sentence or a short bulleted outline.
- `##` sections with short, plain headings ("Motivation", "Caveats", "Phases", "It's Not All Bad",
  "How Should I Prepare"). `###` for sub-points.
- Code first, then explanation: show a snippet, then say what it does and why. Technical posts are code-heavy.
- Bulleted lists are terse fragments or single sentences ending with a period. Definitions use
  "**Term** - explanation" or "Term - explanation".
- Close with a short "Conclusion" or wrap-up that summarizes in a few bullets and ends on a personal, encouraging
  note ("That was a lot but I hope it helps.", "Good luck!").

### Book reviews and reading list entries

- One to four sentences. Lead with the overall take, then what worked and what didn't, then who it's for: "If you're
  looking for an adventure book, this isn't for you."
- Explains the rating when it's mixed ("Rated as a 4 for the interesting ideas and unique concept for a book. Could
  use more in-depth character development.").
- Calls out tropes and lazy writing directly (stereotyped characters, gratuitous detail) without being mean-spirited.
- Reading list entries use `Synopsis:` and `Opinion:` sub-bullets, or a single "Title - one-sentence synopsis" line.
  Only write an `Opinion:` that Andrew has actually expressed; never invent his opinion of a book.

### Avoid

- Corporate or marketing tone: "leverage", "seamless", "robust", "delve", "game-changer", "unlock", "elevate",
  "In today's fast-paced world".
- Emoji bullet lists and feature-grid formatting (the 2025 VSCode post's README-style list is the exception, not the
  model).
- Over-hedging ("It's worth noting that…", "arguably", "it could be said") and filler summaries that repeat the
  section.
- Em-dash-heavy rhythm and tidy triplets everywhere; he uses commas, parentheses, and semicolons more.
- Inventing experiences, employers, or anecdotes. If a draft needs a personal story, leave a `TODO(andrew):`
  placeholder describing what's needed.

### Keep the voice, fix the typos

The older posts contain typos and slips (its/it's, their/there, "accomodate", "interchageable"). Match the tone and
structure, not the mistakes. When editing an existing post, fix clear typos but don't rewrite his phrasing into a
different style.

### Reference samples

Most representative, in order:

1. `content/posts/2022-02-14-interviews-are-the-worst.md` - long-form opinion and advice; the best example of his
   current voice.
2. `content/posts/2020-09-21-cpp-memory-semantic-for-csharp-java-devs.md` - technical tutorial with caveats and code.
3. `content/posts/2021-10-23-compiler-basics.md` - concept walkthrough with "we" and examples.
4. `content/posts/2021-10-09-fluentcpp-v01-release.md` - release post: Motivation, release, Caveats.
5. `content/posts/2014-03-17-state-behavioral-pattern-to-rescue.md` - problem-driven design write-up.
6. `content/reading.md` - Synopsis/Opinion entries.
