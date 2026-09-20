# Philosophy

The opinions this suite embeds, and how well each is backed. Documentation — nothing here is
loaded at run time. The skills enforce these; this file is where you argue with them.

## Summary

- the problem is misleading context, not wasted tokens
   - therefore, delete docs and comments if wrong/doc-rot/bit-rot
- deletion is recoverable, misleading is risky, rewrite/review is expensive
   - therefore, bias to delete
- focus on per-turn context (AGENTS.md, CLAUDE.md)
- useless tests are useless (and misleading if they ever break)

## Grading key

| Grade | Means |
| --- | --- |
| **measured** | checked in this repo or session — the check is named |
| **reported** | external or industry evidence, not checked here |
| **argued** | reasoning only. Plausible mechanism, no measurement |

Most of this is **argued**. That's fine for a cleanup heuristic and not fine as a claim about
how models behave — the two are mixed together below, so they're separated explicitly.

## Inventory

| # | Opinion | Enforced by | Grade |
| --- | --- | --- | --- |
| 1 | Misleading context is worse than verbose context | falsity preamble | argued |
| 2 | Deletion is recoverable; misleading content is not auditable | falsity preamble | **measured** (recovery half) + argued |
| 3 | Volume is not the main variable | falsity D1–D2 framing | **contested** — see below |
| 4 | Per-turn context costs more than on-demand docs | falsity D1, D2 | argued (the arithmetic is checkable) |
| 5 | Mechanical checks before any judgment pass | falsity D3 | **measured** |
| 6 | Don't delete on your own judgment in a judgment pass | falsity D4 | argued |
| 7 | Verbose-but-true comments don't justify a sweep | falsity D5 | argued |
| 8 | README/CHANGELOG are non-duplicative by construction | falsity D6 | argued (near-definitional) |
| 9 | Why/provenance/constraint comments are always kept | falsity D7 | argued |
| 10 | A ticket is a bad home for provenance | falsity Phase 3 | **measured** |
| 11 | A stale comment is worse than no comment | falsity Phase 3 | argued |
| 12 | Comment-only changes are mechanically provable | falsity ride-along | verifiable, not yet run here |
| 13 | One proof regime per PR | falsity D8, tests D6 | argued |
| 14 | No shell access means no findings | falsity D9 | argued (follows from 5) |
| 15 | Flaky tests train people to ignore red | tests Phase 1 | **reported** |
| 16 | A coverage delta is a valid deletion gate | tests D1, D2 | **measured** mechanism, argued inference — see below |
| 17 | Don't add mutation tooling for a cleanup | tests D4 | argued (scope discipline) |
| 18 | The test sweep needs an exclusive checkout | tests D7 | argued |
| 19 | The `claude-md-management` rubric is backwards for this purpose | README plugin section | **measured** |

### What the measured ones rest on

- **#2** — `git log --diff-filter=D` recovers deleted files. Trivially verifiable. The other
  half of the claim ("misleading content is not auditable") is argued: nothing fails, so
  there's no signal to count.
- **#5** — the candidate extraction in falsity Phase 1 was run against this repo's README and
  produced a real, filterable token list. The phase is not aspirational.
- **#10** — an agent without tracker access cannot read a ticket. Not a preference; it either
  has the MCP connection or it doesn't.
- **#19** — counted from `claude-md-management/1.0.0/skills/claude-md-improver/references/quality-criteria.md`:
  70 of 100 points reward having more content, and "Architecture Clarity" pays 20 for the
  directory-map prose this suite deletes.
- **#15** is **reported**, not measured — flaky-test desensitization is well documented in
  industry postmortems and test-infrastructure research. Nothing was measured in your repos.

## The two weak links

Both are load-bearing. Know where they give.

**#3 — "volume is not the main variable."** This is the shakiest claim in the suite and it
shapes D1/D2. Published work on long-context behavior cuts both ways: retrieval stays strong
across large windows, but plausible distractors do measurably degrade output. "A 3k-token
accurate AGENTS.md is free" is an assumption, not a result. If it's wrong, the suite is
under-aggressive on true-but-unnecessary content — which is the safer direction to be wrong in,
and is why it's left standing.

**#16 — "unchanged coverage means safe to delete."** Coverage measures execution, not
assertion quality. Two tests can cover identical lines and assert different things; deleting
one leaves coverage flat while removing a real check. The gate has a known hole. It's used
anyway because the alternative — deleting on a read of the test — has no gate at all, and
because mutation testing (#17) is deliberately out of scope. Treat a flat-coverage delete as
*permitted*, not *proven*.

## Deliberately out of scope

Docs that are true today, current, and duplicate what code already says. Nothing in the suite
catches them — they're not false, so the falsity sweep can't fire. Deleting them is a pure
taste call about future rot, it can't be gated on evidence, and a repo-wide sweep would cost
more review attention than it returns. Handle by hand, on files you're already in.

## Changing your mind

Each directive is a table row in the skill that enforces it. Edit the row. The skills read
their directives aloud before acting, so a bad one surfaces on the next run rather than
silently shaping a sweep.
