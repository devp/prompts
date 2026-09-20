# antislop-skills

Two sweeps that remove content which misleads humans and agents. Deletion-biased, but
pointed at *wrongness* first, not length.

## Premise

Deletion is recoverable (`git log --diff-filter=D`). Misleading content is not auditable —
nothing fails, nobody notices, the agent confidently does the wrong thing. Asymmetric cost,
so bias to delete.

But volume is not the variable. A 3k-token accurate AGENTS.md costs ~nothing against a 1M
window. A 300-token wrong one is expensive. What degrades output, in order: contradiction,
falsity, irrelevance, then volume.

Tier matters more than size. Always-loaded content (AGENTS.md, CLAUDE.md — every turn, every
agent) pays volume cost. On-demand content (docs the agent greps when relevant) does not.
So: ruthless about AGENTS.md, conservative about docs.

Every fact gets one canonical home, chosen by how visibly it rots:

| Home | Rot visible? |
| --- | --- |
| code | yes — tests fail |
| comment | no, but colocated — caught reviewing the line |
| repo doc | no |
| ticket | external — 404s on tracker migration |
| someone's head | gone silently |

Ticket is second-worst, and an agent with no tracker access can't reach it at all. A ticket
ref is a pointer, not the content.

## Order

1. **`/antislop-falsity`** — mechanical falsity, then simplify, then semantic falsity.
   AGENTS.md first: smallest artifact, highest leverage per token, and its simplified form is
   the input for judging every doc downstream (a doc's orphan status changes once AGENTS.md
   stops pointing at it).
2. **`/antislop-tests`** — independent, runs any time, never shares a PR with the above.

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
