---
name: notion-skim
description: >
  Walk a long Notion page section by section at skim pace: for each section, a two-sentence
  gist the user rewords back, plus up to three findings they rule on. Trigger on "skim this
  Notion page", "help me skim this doc", "walk this spec at skim pace", or a pasted Notion
  URL plus "what's in here". For a doc too long to read but too load-bearing to summarize
  away. A plain "tldr this" is `tldr-ticket`; reading one properly for retention before
  acting is `ticket-read-along`. Never run two of the three on the same request.
---

# notion-skim

A Notion page mixes background, decisions, and open asks in one undifferentiated scroll,
and nothing marks which is which. The job is to walk it at skim pace and make the user
rule on what's load-bearing — not to summarize it for them.

## Start immediately

No intake interview. No strategy question, no time/energy check. Get the section list and go.

## Getting the page

In order of preference:

1. Notion MCP tools, if this session has any.
2. `WebFetch` on the URL — works only for publicly shared pages.
3. Ask for an export or a paste.

Unlike a diff, a paste is a legitimate fallback here — a private Notion page may have no
other route in. Ask once, plainly, and don't relitigate it.

Then list the top-level sections, number them, and keep those numbers stable for the rest
of the session so the user can refer back to one.

Skip sections the user says they've already read.

## Notion-specific traps

- **Open every toggle.** Collapsed content is where decisions get parked. A toggle you
  didn't expand is not a section you skimmed.
- **Page comments carry load.** An unresolved comment often overrides the prose above it.
  Read them if the access route exposes them; say so explicitly if it doesn't.
- **Database views and linked pages are pointers, not content.** Name them and move on.
- **Subpages are separate skims.** List them at the end, don't recurse without asking.
- **Last-edited dates matter.** A section untouched for a year next to one edited this week
  is a finding, not trivia.

## Per section

```
<index>. <heading>  ~<words>w · <N> live items · <M> sections left
Gist: <two sentences — what it establishes, not what it says>
Findings:
  - <finding>
  - <finding>
```

**Gist**: what this section establishes and how it gets there. Two sentences, hard cap.
Name the claim, not the paragraph order.

**Live items**: count the things a reader could act on or be bound by — decisions recorded,
open questions, action items, owners named, dates or commitments, hard constraints,
requirements. This is the real size of a section, not its word count. Call it out when the
two diverge: 900 words with 0 live items is background, a three-line section with 4 is the
actual document.

**Findings**: zero to three, most consequential first. Contradictions with an earlier
section, decisions with no decider, action items with no owner, constraints buried in
prose, content stale enough to mislead, a claim that conflicts with a linked doc. Say
"none" when there are none — do not manufacture a third. No writing-quality notes, no
praise, no suggested rewrites.

Then stop and wait. One section per turn.

## When the user rewords

This is the point of the skill. Their reword is the comprehension check.

- Right: say so in a few words and move on. No elaboration, no "exactly, and also...".
- Wrong or partial: say what they missed in one line. Plainly, no coaching voice, no
  softening preamble.

If they skip the reword and just say next, let them. Don't chase it.

## Findings are hypotheses

The user rules on each one. Their verdict closes it — "not a problem", "decided elsewhere",
"yes, that's stale" are all complete answers. Do not re-argue a finding they have ruled on,
and do not carry it into a later section.

## Never invent

If the page doesn't say it, it doesn't go in a gist or a finding — not even as a guess
phrased confidently. A section that genuinely says nothing gets a gist saying that.

## Progress

The user tracks what's read; you don't. Keep the count of sections left in the per-section
header and nothing more. Never mark a doc reviewed or agreed-to on their behalf.

## Scale

Order by live-item density, not page order, when the doc is long enough that attention will
run out — say so when you reorder. Sections that are meeting-notes boilerplate, templated
headers, changelogs, empty toggles, or embeds get one line saying to skip them, not a gist.
