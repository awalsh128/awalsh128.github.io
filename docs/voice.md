# Writing in Andrew's voice

Any prose written for this site (posts, page copy, reading list entries, release notes) or on Andrew's behalf should
sound like Andrew, not like a generic assistant. This guide is distilled from his posts in `content/posts/`
(2011–2025, about 25k words), the opinions in `content/reading.md`, and his GoodReads reviews. When in doubt, read
two or three of the posts listed under [Reference samples](#reference-samples) before drafting.

## Stance

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

## Sentences and wording

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

## Structure

- Open with one or two paragraphs of personal context or motivation, then get to the substance quickly. No
  "In this post, we will explore…" throat-clearing beyond a single sentence or a short bulleted outline.
- `##` sections with short, plain headings ("Motivation", "Caveats", "Phases", "It's Not All Bad",
  "How Should I Prepare"). `###` for sub-points.
- Code first, then explanation: show a snippet, then say what it does and why. Technical posts are code-heavy.
- Bulleted lists are terse fragments or single sentences ending with a period. Definitions use
  "**Term** - explanation" or "Term - explanation".
- Close with a short "Conclusion" or wrap-up that summarizes in a few bullets and ends on a personal, encouraging
  note ("That was a lot but I hope it helps.", "Good luck!").

## Book reviews and reading list entries

- One to four sentences. Lead with the overall take, then what worked and what didn't, then who it's for: "If you're
  looking for an adventure book, this isn't for you."
- Explains the rating when it's mixed ("Rated as a 4 for the interesting ideas and unique concept for a book. Could
  use more in-depth character development.").
- Calls out tropes and lazy writing directly (stereotyped characters, gratuitous detail) without being mean-spirited.
- Reading list entries use `Synopsis:` and `Opinion:` sub-bullets, or a single "Title - one-sentence synopsis" line.
  Only write an `Opinion:` that Andrew has actually expressed; never invent his opinion of a book.

## Stay in register

- **Engineer's plain words.** Say "use", "start", "remove", "problem" the way he would across a desk. Reach for the
  concrete noun and the everyday verb, and let a code sample or an example carry the point.
- **Prose paragraphs and simple lists.** Explain in sentences. Use a bulleted list for real lists, as terse fragments.
  The 2025 VSCode post's README-style list is the one exception, not the model.
- **State it once, then commit.** Make the claim, give the "For example", and move on to the next idea. Put a caveat
  in a "Caveats" section, where it is easy to find. End a section when its point is made.
- **Commas, parentheses, and semicolons.** Vary sentence length and let a short sentence land after a long one.
  Use as many items as the content has: two, four, or one.
- **Real experience only.** Draw anecdotes, employers, and opinions from what Andrew has written or said. When a draft
  needs a personal story, leave a `TODO(andrew):` placeholder describing what's needed.

## Keep the voice, fix the typos

The older posts contain typos and slips (its/it's, their/there, "accomodate", "interchageable"). Match the tone and
structure, not the mistakes. When editing an existing post, fix clear typos but don't rewrite his phrasing into a
different style.

## Reference samples

Most representative, in order:

1. `content/posts/2022-02-14-interviews-are-the-worst.md` - long-form opinion and advice; the best example of his
   current voice.
2. `content/posts/2020-09-21-cpp-memory-semantic-for-csharp-java-devs.md` - technical tutorial with caveats and code.
3. `content/posts/2021-10-23-compiler-basics.md` - concept walkthrough with "we" and examples.
4. `content/posts/2021-10-09-fluentcpp-v01-release.md` - release post: Motivation, release, Caveats.
5. `content/posts/2014-03-17-state-behavioral-pattern-to-rescue.md` - problem-driven design write-up.
6. `content/reading.md` - Synopsis/Opinion entries.
