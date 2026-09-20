---
name: antislop-tests
disable-model-invocation: true
description: >
  Remove tests not worth running forever — flaky, change-detector, permanently skipped, or
  duplicated by broader coverage. Every deletion gated on a coverage delta. Run as
  /antislop-tests.
---

# antislop-tests

Useless tests are useless, and misleading the moment they break.

**The proof runs backward here.** In every other cleanup you prove nothing changed. Here the
suite goes green trivially the moment you delete a test, so green means nothing. You have to
prove the test was worthless — that it cannot fail for a real reason.

Treat that as the whole job. Git makes deletion recoverable in theory; in practice nobody
restores a deleted test after an incident, they write a new worse one.

## Directives

These drive the sweep. Read them to the user in one block at the start, and ask whether any
should change for this repo before Phase 1. Edit this section to change them permanently.

| # | Directive |
| --- | --- |
| D1 | A deletion is blocked by **any** drop in line **or** branch coverage |
| D2 | No coverage run means no finding. Reading a test and calling it pointless is an opinion, not evidence |
| D3 | Prefer fixing a flaky test over deleting it. Delete only when the gate shows its coverage is duplicated |
| D4 | Don't introduce mutation-testing tooling for this sweep. Use it only if the repo already has it |
| D5 | A candidate that fails the gate is dropped silently. Don't argue it back |
| D6 | Own PR. Never mixed with comment or doc changes — a reviewer checking a coverage gate shouldn't also be checking a token-stream proof |
| D7 | Needs an exclusive checkout **and an idle machine**. Gate runs are serialized — nothing else executing. A suite running beside a gate run steals CPU, times out untouched tests, and invalidates the measurement |
| D8 | Don't build the environment. If the suite doesn't run in one documented command, report what's missing and stop. Installing a database server is a different job with a different owner |
| D9 | If most tests contribute zero unique lines or arcs, the gate is uninformative for this suite. Say so in Phase 0, drop the coverage-duplicated category, and don't spend a run on it |
| D10 | **Exit early.** Zero skips, zero xfails, no flake signal, and an uninformative gate means there is nothing this sweep can find. Report Phase 0 and stop before any per-test coverage run |
| D11 | Budget before running. Per-candidate gating costs one suite run each; per-test coverage contexts cost a full instrumented run. On a monorepo, scope to one package per sweep — never the whole tree |

## Phase 0 — baseline

Report before proposing anything:

- total test count, suite wall-clock, slowest 10 tests
- flake rate if CI history is reachable (`gh run list` / CI API): tests that have gone red then
  green on an unchanged commit
- current line and branch coverage — this is the gate's reference point, capture it exactly
- **is the gate informative here?** Run per-test coverage contexts and count tests contributing
  zero unique lines and zero unique arcs. A high share means route-test overlap, not
  redundancy, and the gate would wave most of the suite through. Report the share and apply D9

Measured on one real suite (1,674 tests, 78.9% coverage): 1,179 of 1,585 tests contributed no
unique coverage. Expect this to be common, not exceptional.

**Then decide whether to continue (D10).** State the four Phase 0 signals and the call:

```
skips 0 · xfails 0 · flake signal none (790 CI runs) · gate uninformative (74% zero-unique)
→ nothing findable. Stopping.
```

A healthy suite is the normal outcome and it is cheap to establish. Getting there costs one
test run and one CI-history query; going further costs a full instrumented run plus one suite
run per candidate. Don't spend the second budget to confirm the first.

## Phase 1 — candidates

Ranked by value, highest first.

**Flaky.** Worse than useless: they train the team to ignore red. Evidence is CI history — red
then green with no code change between. Highest-value item on the list, and D3 applies.

**Never runs at all.** Higher value than anything else here, and it is not a deletion — it is a
bug. A test that is silently not collected is false assurance: the file reads as covered, the
suite reads as green, nothing is being checked. Causes seen in the wild: a class that doesn't
inherit the runner's base, a module basename colliding with another so only one is imported, an
import-time side effect that swallows collection, a fixture error reported as a skip. Compare
the collected count against the count of test functions on disk; the gap is the finding.

Related and also not a deletion: anything at import time that prevents the suite running as one
process — a module blanking `settings.DATABASES`, a global monkeypatch, an `os.environ` write.
Report it. A suite that can only run in shards hides exactly the problem above.

**Permanently skipped.** `@skip`, `xfail`, `it.skip`, `@Ignore` with no tracking issue or a
closed one. Not running, not maintained, still read by everyone who greps the file.

**Change-detector.** Asserts on how, not what:

- mock call counts, call order, or arguments to internal collaborators
- private methods or attributes
- exact log strings or error message text
- snapshots regenerated on failure without ever being read

**Coverage-duplicated.** A narrow test whose paths a broader test already exercises.

## Phase 2 — the gate

Per candidate, in this order. Stop at the first hard answer.

1. **Coverage delta.** Delete it, re-run coverage.
   - unchanged → duplicated by a broader test → **safe to delete**
   - line or branch coverage drops (D1) → it was the only thing on that path → **keep, or
     write the replacement first**
2. **CI history.** Has it ever gone red for a real cause? `git log` the test file against
   adjacent fix commits. Never-failed *and* coverage-duplicated is a strong delete.
3. **Mutation testing**, only if already present (`mutmut`, `cosmic-ray`, `stryker`) — D4.
   Definitive, expensive.

## Risk to hold

"Tests the essence" is not a definition, and an implementation-looking test is sometimes the
only pin on a subtle invariant. The coverage gate is what makes this defensible. Without a
coverage run you have no finding (D2) — say so rather than proposing deletions from reading
alone.

## Output

```
<test path::name>  <category>  <coverage delta>  <CI history>  →  delete | fix | keep
```

Deleting nothing is a good outcome. Report the baseline and stop.

**Integrity findings ship even when no deletion does.** Tests that never run, and imports that
break single-process execution, are the highest-value output this sweep produces — they mean
the suite is lying about what it checks. Report them separately from deletion candidates, with
the collected-vs-on-disk counts, and hand them over rather than fixing them here (D6).
