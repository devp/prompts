---
name: fold-amends
disable-model-invocation: true
description: >
  Merge pending `<doc>.amend.<slug>.md` files (written by /unfork) into their docs, then delete
  them. Run by the doc's owner session, the only writer of the doc. Optional argument: a doc
  or directory; default is the current project's docs.
---

# fold-amends

`/fold-amends [path]`. You are the doc's only writer, so you edit it in place and need no
worktree.

## 1. Collect

Glob `*.amend.*.md` under the path, or under the directory of the doc this session is working
on. Group the files by target doc (the stem before `.amend.`). If there are none, reply
`no amends` and stop.

## 2. Fold, one doc at a time

Read the doc as it is now, then go through each amend file, oldest first:

- **fact / correct:** check the item against the current doc. If the doc already says it, skip
  it. If the doc's claim is newer than the amend's evidence, or contradicts it, re-check the
  evidence. Do one cheap check (a `git show <sha>:<file>` or a grep). If it still conflicts,
  don't pick a side; record it as an open question.
- **decision / question / task:** put each into its section. Never state a fact in two
  sections. Rewrite claims that have been disproved instead of appending corrections.
- If two amends disagree, present it as one open question that cites both.

## 3. Report, then commit

- Show a per-doc summary: items folded, skipped (already present), and turned into questions.
- Delete the folded amend files. An amend file that's worth keeping as-is becomes a note: drop
  the `.amend.` part of the name instead of deleting it.
- Commit the doc and the deletions together, following the repo's own commit rules (CLAUDE.md).
  Message: `<doc stem>: fold amends <slug>, <slug>`.
