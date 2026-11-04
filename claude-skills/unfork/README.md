# Fork → amend → fold pattern

2026-11-04. Worked example: the DEV-9347 Thumbor review (`work-notebook-d6`) and its forks
(`smart`, CF policy, CF MCP verification, this one).

## Shape

```
parent (owns doc.md) ──/fork──> child inquiry
                                   │ /unfork
                                   ▼
             doc.amend.<slug>.md  (new file, main checkout, uncommitted)
                                   │ SendMessage "amend waiting"
parent ──/fold-amends──> doc.md updated, amend deleted, one commit
child ──/done──> closed
```

Only the parent writes `doc.md`, so forks never need a worktree, a rebase or a merge. A new
file can't conflict, and the owner's next commit picks it up.

## Skills

| Skill | Runs in | Does |
|---|---|---|
| `unfork` | the fork | distills the fork into `<doc>.amend.<slug>.md`, notifies the parent, adds a journal line |
| `fold-amends` | the doc owner | merges amend files into the doc, re-checking against the current doc, then deletes them and commits |
| `done` (exists) | any | closes the thread in the job list |

`unfork` can't call `/done` itself: `disable-model-invocation` blocks invocation through the
Skill tool. It ends by suggesting `/done` instead.

## Before implementing

1. **Install path.** `~/.claude/skills` is a symlink to `~/code/work-configs/claude-skills`,
   not to the prompts repo. Per the prompts README, symlink
   `~/code/prompts/claude-skills/{unfork,fold-amends}` into that directory.
2. **Parent resolution: dry-run it once.** In this session, the inherited `<fork-source>`
   notice named the grandparent (`work-notebook-d6`), not the launching fork. A fork started
   with `claude --bg --fork-session` gets no notice of its own. The draft uses the last notice,
   then the name before the last `⑂` in `ListAgents`. Check both on a real nested fork before
   relying on them.
3. **Journal path** `~/kb/journal/...` is personal, not Vendelux-specific; the other
   prompts-repo skills use it too. Nothing else in the drafts is Vendelux-specific.
4. **Amend-file location vs. repo rules.** The notebook's `ibid` commits will sweep up amend
   files that haven't been folded yet. That's harmless, but they show up in history before
   they're folded. In a code repo, put amend files beside the doc only if the doc lives in a
   notes repo. Otherwise there's no pattern for them yet.

5. **Background-session write guard.** Background (`bg`) sessions can't write to a repo's
   main checkout until they call `EnterWorktree`, and the guard blocks Write/Edit even after
   the user approves in chat. `unfork` writes into the main checkout, so every repo that holds
   docs it amends needs `"worktree": {"bgIsolation": "none"}` in `.claude/settings.json`.
   Set for work-notebook on 2026-11-04.

## Warnings

- **Unfolded amends become a second source of truth.** Someone reading only `doc.md` misses
  them. Fold soon, or have `standup`/`grwm` list pending `*.amend.*.md`.
- **Fork evidence ages.** A fork verifies facts against the code as it was at the fork point.
  The amend format requires a sha or date on each item so the fold can re-check it cheaply.
  Without that, the fold trusts stale claims.
- **Folding is a judgment step, not a merge.** When an amend and the doc conflict, or two
  amends disagree, the result is an open question, never a silent pick.
- **Fork recommendations leak in as decisions.** A fork tends to state its conclusions
  confidently, and the fold turns them into doc decisions. The format separates `decision` (the
  user decided) from `question` (the fork recommended).
- **Context cost grows with depth.** Each fork inherits the whole transcript, and
  forks-of-forks pile up. This session has four sibling forks of one thread. Fork early, or
  use `sidetrack-fork` for questions that are mostly reading.
- **Several forks on one doc are fine.** Each gets its own amend file, and the fold sees them
  together. That's the case the old edit-in-place flow handled worst.
