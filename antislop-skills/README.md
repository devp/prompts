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

## Decisions

Defaults below are runnable. Change them in this file, not in the skills.


| Decision | Default |
| --- | --- |
| Coverage drop that blocks a test deletion | any drop in line **or** branch coverage |
| Verbose-but-true comment cleanup | ride-along only — inside files a falsity finding already opened. Never a standalone sweep |
| Docs that are true today but duplicate code | out of scope here. Judgment call, handled by hand |


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
