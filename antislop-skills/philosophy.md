# Philosophy

## Summary

- the problem is misleading context, not wasted tokens
   - therefore, delete docs and comments if wrong/doc-rot/bit-rot
- deletion is recoverable, misleading is risky, rewrite/review is expensive
   - therefore, bias to delete
- focus on per-turn context (AGENTS.md, CLAUDE.md)
- useless tests are useless (and misleading if they ever break)

## Opinions


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
| 9 | Why/provenance/constraint comments are always kept | falsity D7 | **measured** — violated twice before D7 got teeth |
| 10 | A ticket is a bad home for provenance | falsity Phase 3 | **measured** |
| 11 | A stale comment is worse than no comment | falsity Phase 3 | argued |
| 12 | Comment-only changes are mechanically provable | falsity ride-along | verifiable, not yet run here |
| 13 | One proof regime per PR | falsity D8, integrity D6 | argued |
| 14 | No shell access means no findings | falsity D9 | argued (follows from 5) |
| 15 | Flaky tests train people to ignore red | integrity check 4 | **reported** |
| 16 | A coverage delta is a valid deletion gate | integrity, opt-in path | **measured as weak** — demoted out of the default path |
| 17 | Don't add mutation tooling for a cleanup | integrity D8 | argued (scope discipline) |
| 18 | The gate run needs an exclusive checkout and an idle machine | integrity D7 | **measured** — contention invalidated a gate run |
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

## What the first runs changed

Three sweeps, two repos. Summary of what moved from argued to measured.

**#4 (per-turn context is the thing to cut) — the sweeps do move it.** amp-service AGENTS.md
400 → 279 lines, 65.8KB → 52.6KB (−20%). events AGENTS.md 718 → 593 lines, 37.8KB → 32.0KB
(−15%). Both achieved mainly by relocating bulk to on-demand files, and both partly undone by
new prose written back into the per-turn tier. The *cut* is measured. Whether it improves
output is not — nothing here measured behavior, so **#3 stays contested.**

**#16 (coverage as a deletion gate) — the hole is bigger than argued.** On a 1,674-test suite
at 78.9% coverage, 1,179 of 1,585 tests contributed zero unique lines and zero unique arcs.
The gate would wave three quarters of the suite through, and the tests it scores at zero
include the highest-value ones: a 33-case pause-state truth table, a deliberately hardcoded
digest, closed-enum rejection. Upgrade to **measured — and measured as weak.** It is a permit,
not a proof, and on suites like this it is not even a permit. Hence the opt-in demotion.

**#9 (why/provenance comments are always kept) — violated in practice, twice, in one PR.**
A ride-along pass deleted a docstring explaining why a table was chosen over a JSON column
(naming the cross-service consequence), and a comment marking endpoints as implemented rather
than 501 stubs like the rest of their router. Both are exactly the D7 category. Length reads
as verbosity; irreplaceable context is often long. The directive needed teeth, not restating —
hence falsity D7's quote-and-justify requirement.

**#15 (flaky tests) — no local evidence either way.** 790 CI runs on amp-service, zero flake
signal, and only 11 commits ever run twice. A 1-in-50 flake would leave no trace. Still
**reported**, not measured here.

**New, unlisted until now: cost is a real constraint.** A tests sweep on a large monorepo ran
31 minutes and 184k tokens without finishing. Establishing "healthy suite, nothing findable"
costs one test run and one CI query; proving it costs a full instrumented run plus a suite run
per candidate. The second budget rarely buys anything the first didn't already indicate.

**Also new: the sweep's best output isn't deletion.** A run surfaced a test class that never
executes — 17 tests silently uncollected — and a module that blanks `settings.DATABASES` at
import, forcing the suite to run in shards. Neither is a deletion candidate; both mean the
suite is lying about what it checks.

**So the test sweep was retired and replaced.** The deletion premise was testable and got
tested: across two well-maintained repos it yielded 104 lines of inert `it.skip()` blocks, for
roughly half an hour and 184k tokens. The tests were fine. What paid was the incidental
integrity finding, so `/antislop-tests` became `/antislop-test-integrity`: four cheap checks,
no instrumentation, deletion demoted to a byproduct behind an opt-in gate. A suite about
deleting what doesn't earn its keep should apply that standard to itself.

### The two weak links

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
