---
name: unfork
disable-model-invocation: true
description: >
  End a /fork child inquiry: distill what the fork established into an amend file beside the
  shared doc (`<doc>.amend.<slug>.md`), tell the parent session, log one journal line. Never
  edits the doc itself; the doc's owner folds amends in with /fold-amends. Optional argument:
  the target doc path.
---

# unfork

`/unfork [doc]`. Run in a session started with `/fork`, or in a parked `sidetrack-fork`. The
fork's result goes to an amend file that the doc's owner merges later. The fork never writes
the shared doc, so there is no worktree, rebase or merge.

## 1. Target doc and slug

- **Doc:** the argument if given. Otherwise the shared doc the conversation was about before
  the fork point (the file read or edited most in the inherited history). If that's ambiguous,
  list the candidates and ask once.
- **Slug:** the fork's question as kebab-case, ≤4 words (e.g. `smart`, `cf-policy-ttl`).
- **Path:** `<doc dir>/<doc stem>.amend.<slug>.md`, in the doc's **main checkout**, not a
  worktree. If the path exists, add `-2`, `-3` and so on. Never overwrite it.

## 2. Distill

Use only the fork's own turns, after the fork point. Write **items, not a rewritten doc**. Each
item gets a kind and its evidence:

```markdown
# amend <doc stem> ← fork <slug> (YYYY-MM-DD)

## fact
- <claim>. Evidence: `<file:line>` @ <repo sha> | <URL> | <command + result>
## correct
- doc says "<quoted claim>" → <corrected claim>. Evidence: …
## decision
- <decision the user made in this fork>. (user, in fork)
## question
- open: <new question>
- closed: <doc question> → <answer>. Evidence: …
## task
- add | change | drop: <task>
```

- Leave out empty kinds, and anything the parent already had at the fork point.
- Only the user makes decisions. If the fork merely recommended something, it goes under
  `question`.
- Evidence must pin a version (a repo sha or a fetch date), so the folder can re-verify it
  cheaply.
- If nothing is left, report `nothing to land`, write no file, and go to step 4.

## 3. Notify the parent

- **Parent:** the session this fork was created from. Use the **last** `<fork-source>` notice
  in context. Notices are inherited, so earlier ones name ancestors. Without a notice (forks
  launched with `claude --bg --fork-session` get none), take the name before the last `⑂` in
  `ListAgents`. No match → skip this step.
- `SendMessage`, ≤3 lines: `amend waiting: <path> (<n> items, <kinds>)`, plus the single
  most important item.

## 4. Close

- Journal: append `HH:MM unfork <slug>: <path or "nothing to land">` to today's
  `~/kb/journal/YYYY/MM/YYYY-MM-DD.md`. Create it with `date +'# %A, %F'` if missing.
- Reply in one line: `unforked <slug> → <path> · parent notified|parent not found`. The user
  runs `/done` to close the thread.
