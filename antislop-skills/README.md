# antislop-skills

## Premise

- the problem is misleading context, not wasted tokens
   - therefore, delete docs and comments if wrong/doc-rot/bit-rot
- deletion is recoverable, misleading is risky, rewrite/review is expensive
   - therefore, bias to delete
- focus on per-turn context (AGENTS.md, CLAUDE.md)
- useless tests are useless (and misleading if they ever break)

## Operation

1. **`/antislop-falsity`** — mechanical falsity, then simplify, then semantic falsity.

   AGENTS.md first: smallest artifact, highest leverage per token, and its simplified form is
   the input for judging every doc downstream (a doc's orphan status changes once AGENTS.md
   stops pointing at it).

2. **`/antislop-tests`** — independent, runs any time

Both can run in parallel, in **separate worktrees**. Same checkout and the falsity sweep's
edits corrupt the test sweep's coverage baseline. Separate PRs either way.

Each SKILL.md is standalone — paste-able into a session that has no skills installed. Phase 1
of the falsity sweep needs shell and repo access; without it the skill says so and stops.

## Assumptions — check these

Each skill is self-contained and carries its own **Directives** table near the top, which it
reads out before doing anything. Those are the assumptions the sweep makes on your behalf.
Skim them once per repo — opinions, not laws.

Change one for a single run by saying so when the skill reads them back. Change it permanently
by editing that skill's Directives table: `antislop-falsity/SKILL.md` or
`antislop-tests/SKILL.md`. Not duplicated here — one fact, one home.

Most likely to need changing:

- the coverage drop that blocks a test deletion (currently: any drop, line or branch)
- which files count as per-turn context for your setup
- whether verbose-but-true comments get cleaned up at all

Out of scope on purpose: docs that are true today but duplicate code. Judgment call, by hand.

## Plugin

`claude-md-management@claude-plugins-official` already covers part of the falsity pass —
`skills/claude-md-improver/references/quality-criteria.md` has a working Red Flags list
(dead file refs, commands that would fail, outdated versions, cross-file duplication).

Enable it, harvest the Red Flags, **discard its score**: 70 of its 100 points reward *having
more content*, and "Architecture Clarity" pays 20 points for exactly the directory-map prose
that duplicates code and rots.

## Install

```sh
ln -s ~/code/prompts/antislop-skills/antislop-falsity ~/.claude/skills/antislop-falsity
ln -s ~/code/prompts/antislop-skills/antislop-tests   ~/.claude/skills/antislop-tests
```
