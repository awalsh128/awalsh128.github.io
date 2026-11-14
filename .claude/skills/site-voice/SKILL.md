---
name: site-voice
description: Write or edit prose for the awalsh128.com Hugo site in Andrew's voice. Use for any text published on the site or written on Andrew's behalf for it, including blog posts, release posts, page copy, and reading list entries or book reviews in content/reading.md. Use it whenever a task adds or rewrites prose under content/, even a short blurb, so the result reads like Andrew and not like a generic assistant. Takes precedence over my-writing-style for this repo.
---

# Site voice

Andrew writes as a working engineer explaining a problem to a peer. This guide is distilled from his posts in
`content/posts/` (2011-2025, about 25k words), the opinions in `content/reading.md`, and his GoodReads reviews.

## Workflow

1. **Name the form**: technical tutorial, opinion post, release post, concept walkthrough, design write-up, page copy,
   or reading list entry. Done when you can point to a sample below that matches it.
2. **Read two of the matching samples in full**, not just their titles. His rhythm is hard to get from a description.
   For a reading list entry or book review, also read `references/reading-entries.md`.
   - `content/posts/2022-02-14-interviews-are-the-worst.md` - long-form opinion and advice; the best example of his
     current voice.
   - `content/posts/2020-09-21-cpp-memory-semantic-for-csharp-java-devs.md` - technical tutorial with caveats and code.
   - `content/posts/2021-10-23-compiler-basics.md` - concept walkthrough with "we" and examples.
   - `content/posts/2021-10-09-fluentcpp-v01-release.md` - release post: Motivation, release, Caveats.
   - `content/posts/2014-03-17-state-behavioral-pattern-to-rescue.md` - problem-driven design write-up.
3. **Draft** using the stance, wording, and structure below. When the draft needs a personal story, an employer, or an
   opinion Andrew hasn't written down, leave a `TODO(andrew):` placeholder describing what's needed.
4. **Check** every anecdote and opinion in the draft traces to Andrew's own writing or sits behind a `TODO(andrew):`.
   Done when no sentence claims an experience he hasn't described.

When editing an existing post, fix clear typos (its/it's, their/there, "accomodate") and keep his phrasing. Match the
tone and structure of the older posts, not their slips.

## Stance

- **Practitioner explaining to a peer.** Motivation comes from real work: "I recently found myself developing a
  request-response style system…", "When I first started using C++, I was really confused…".
- **"I" for experience, "we" for walkthroughs, "you" for advice.** Anecdotes and opinions use "I"; technical
  walkthroughs use an inclusive "we" ("Let's take a more complex example."); guidance addresses the reader directly
  ("If you have an interviewer like this don't be afraid to call it out afterwards.").
- **Candid.** State a position plainly and own it: "This is a terrible idea, don't do this.", "IMO the worst kind of
  questions are the ones that don't reflect real work at all." Strong feelings are fine ("I was pissed.") when the
  story earns them.
- **Upfront about limits.** Flag simplifications once, early: "We will tend to generalize ideas and lack preciseness in
  some areas. This is intentional to keep the reader on track." Release posts get a "Caveats" section.
- **Warm toward the reader.** On people topics, acknowledge the reader's position and end on encouragement: "Lastly and
  most importantly is to know that you can do this."

## Wording

- **Engineer's plain words.** Say "use", "start", "remove", "problem" the way he would across a desk. Reach for the
  concrete noun and the everyday verb, and let a code sample or an example carry the point.
- **Commas, parentheses, and semicolons** carry the rhythm. Sentences run 12-20 words, with a short one landing after a
  long one ("That isn't their fault.").
- **Openers:** "This is…", "If you…", "For example,…", "Below is…", "Here is…", "Although…", "Let's…". Ground abstract
  points with "For example" and "(e.g. …)" / "(i.e. …)".
- **Rhetorical questions frame a section:** "So what does this have to do with interviewing software engineers?"
- **Casual connectors:** "Well…", "Of course…", "IMO", "Let's get started...", an ellipsis leading into a code sample.
- **Contractions** are frequent ("isn't", "don't", "it's").
- **Dry humor** in captions and asides ("Claude Shannon - The OG of Information Theory"), only where it comes naturally.
- **Terms** get a short inline definition or a Wikipedia/cppreference link on first use.
- **State it once, then commit.** Make the claim, give the example, move on. End a section when its point is made.
  Use as many list items as the content has: two, four, or one.

## Structure

- **Open with one or two paragraphs** of personal context or motivation, then get to the substance. One sentence or a
  short bulleted outline can say what's coming.
- **`##` sections** with short, plain headings ("Motivation", "Caveats", "Phases", "It's Not All Bad", "How Should I
  Prepare"); `###` for sub-points.
- **Code first, then explanation:** show the snippet, then say what it does and why.
- **Prose paragraphs, with simple lists** for real lists: terse fragments or single sentences ending with a period.
  Definitions read "**Term** - explanation". The 2025 VSCode post's README-style list is the one exception.
- **Close with a short "Conclusion"** that sums up in a few bullets and ends on a personal, encouraging note ("That was
  a lot but I hope it helps.", "Good luck!").
