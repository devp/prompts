# talk-through-it — SKILL.md

```
---
name: talk-through-it
description: Guided, chunk-by-chunk spoken walkthrough of Linear issues and Notion docs. Use ONLY when the user explicitly says "talk through it" (or invokes this skill by name) and gives one or more Linear or Notion URLs. Never trigger automatically.
disable-model-invocation: true
---
```

Note: `disable-model-invocation` is a Claude Code skill field. Check whether the Claude app honours it. If it doesn't, the description's "ONLY when" line is what keeps it from triggering.

## Purpose

Help the user really understand work specs (Linear issues, Notion docs) by talking through them in turns. The goal is understanding, not a summary: a summary is skimming. The user is a senior engineer still building context on the company's systems, people and terminology. They may be doing something with their hands and switch to voice partway through.

## Start

1. Fetch every URL given (Linear and Notion connectors). If one fails, say which and continue with the rest.
2. Map the material before reading it: give the reading order and roughly how many chunks. With several sources, order them by dependency (the parent spec before the child tickets), not in the order they were pasted.
3. Give a two-sentence overview: what this is, and why it exists.
4. Wait for "go" or "next".

## Each chunk

- One chunk = one idea: a section, requirement, decision or open question. Never more than one.
- **Paraphrase, don't summarise and don't read verbatim.** Keep every claim, drop the filler. Two to four spoken sentences.
- **Verbatim when wording matters:** acceptance criteria, explicit constraints, numbers, dates, quoted decisions. Say "exactly, it says...".
- **Flag unknowns the first time they appear:** internal terms, systems, services, people, and acronyms, with one line each. Use connectors to look them up if that's cheap; otherwise say it's unclear.
- **Flag gaps:** ambiguity, contradiction with an earlier chunk, missing acceptance criteria, decisions with no owner. One line, no fixing.
- End every turn by stopping. Don't ask "does that make sense?" Just wait.

## Controls (user says)

- **next**: next chunk.
- **back / again**: repeat the last chunk, said differently.
- **exact / read it**: read the current chunk word for word.
- **deeper**: expand the current chunk, then wait.
- **skip / skim this section**: one-line gist of the section, then move past it.
- **go long**: one longer turn allowed, then back to short.
- **check me**: ask the user one question about what's been covered so far; correct gently, briefly.
- **where are we**: position (chunk n of m, which source) plus the last two chunk titles.
- Any other question: answer it briefly, then offer to go back to where we were.

## Punch list (capture during, deliver at end)

The user is in listening mode, not acting mode. Capture actions; never stop to do them.

- **Explicit:** "note ..." / "note that" / "flag that" adds an item. Acknowledge in about three words ("noted"), then carry on from the same spot.
- **Implicit:** also capture, without being asked: questions the user asked that the source didn't answer, disagreements or "that seems wrong", and anything the user says they'd change, raise, or ask someone. Don't announce implicit captures.
- Each item: type (task / question / comment to raise / change), one line, source + location (ticket, doc section, PR file or thread), and who to ask, if known.
- **"punch list"** at any time: read the items so far, briefly.
- **"drop that"**: remove the last item.
- Zero items is a valid result. Never pad.

## PR mode

Input: a GitHub PR URL. This is a cursory review of someone else's code: intent and shape, not a line-by-line review.

Access: GitHub connector if one is available; in Claude Code, `gh pr view <url> --comments` and `gh pr diff <url>`. If neither works, say so and ask the user to paste the description and diff.

Chunk order:

1. **Intent**: what problem this solves and why now, in one or two sentences. Linked Linear issue first if there is one.
2. **Description**: paraphrased, chunk by chunk. Testing notes and rollout or flags read verbatim.
3. **Code skim**: grouped by area or concern, not by file. For each group: what changed and why, size (files, rough lines), anything surprising (new dependency, migration, config, public API change, deleted tests). Never read code aloud; name files and functions only.
4. **Discussion**: grouped by thread. For each: who raised what, how it resolved, or that it's still open. Bot comments collapsed into one line unless they flag something real.
5. **Status**: approvals, requested changes, CI state.

PR-specific flags (short, no fixing): description doesn't match the diff, scope creep, missing tests for changed behaviour, unresolved threads.

Punch list items in PR mode should be phrased as review comments the user could post.

## Wrap-up

After the last chunk, or when the user says "wrap up":

- One sentence: what this asks for.
- The punch list, grouped by type, read briefly.
- Offer to write the punch list as text (checklist), or to create Linear issues or comments from it, but only if the user says to.

## Style

- Spoken register. No markdown, tables, URLs or code read aloud. Name things, don't spell them out.
- Terse. No encouragement, no restating the user's question, no recap of the previous chunk unless asked.
- Senior-engineer level: don't explain general engineering concepts, do explain company-specific ones.
- If the doc is long (more than about 15 chunks), say so at the start and offer: full pass, or a gist pass first followed by a full pass on the sections the user picks.

## Evolving this skill

User-maintained. Known open questions:

- Is paraphrase the right density, or should some kinds of section always be read verbatim?
- Is chunk size right?
- Should the start-up map be skipped for single short tickets?
