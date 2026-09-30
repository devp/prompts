---
name: antislop-tests
disable-model-invocation: true
description: >
  Remove tests not worth running forever — flaky, change-detector, permanently skipped, or
  duplicated by broader coverage. Every deletion gated on a coverage delta. Run as
  /antislop-tests.
---

# antislop-tests

Read `../README.md` first — it holds the coverage threshold.

**The proof runs backward here.** Everywhere else you prove nothing changed. Here the suite
goes green trivially the moment you delete a test, so green means nothing. You have to prove
the test was worthless — that it cannot fail for a real reason.

Treat that as the whole job. Git makes deletion recoverable in theory; in practice nobody
restores a deleted test after an incident, they write a new worse one.

## Phase 0 — baseline

Report before proposing anything:

- total test count, suite wall-clock, slowest 10 tests
- flake rate if CI history is reachable (`gh run list` / CI API): tests that have gone red and
  then green on an unchanged commit
- current line and branch coverage — this is the gate's reference point, capture it exactly

## Phase 1 — candidates

Ranked by value, highest first.

**Flaky.** Worse than useless: they train the team to ignore red. Evidence is CI history —
red then green with no code change between. Highest-value deletion on the list. Prefer fixing
a flaky test that covers something real; delete it only if Phase 2 shows the coverage is
duplicated.

**Permanently skipped.** `@skip`, `xfail`, `it.skip`, `@Ignore` with no tracking issue or a
closed one. Not running, not maintained, still read by every person who greps the file.

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
   - line or branch coverage drops → it was the only thing on that path → **keep, or write
     the replacement first**
2. **CI history.** Has it ever gone red for a real cause? `git log` the test file against
   adjacent fix commits. Never-failed *and* coverage-duplicated is a strong delete.
3. **Mutation testing**, only if the repo already has it (`mutmut`, `cosmic-ray`, `stryker`).
   Definitive, expensive. Don't introduce the tooling for this sweep.

A candidate that fails the gate is not a finding. Drop it silently — don't argue it back.

## Risk to hold

"Tests the essence" is not a definition, and an implementation-looking test is sometimes the
only pin on a subtle invariant. The coverage gate is what makes this defensible; without a
coverage run, you have no finding, only an opinion. Say so rather than proposing deletions
from reading alone.

## Output

```
<test path::name>  <category>  <coverage delta>  <CI history>  →  delete | fix | keep
```

Own PR. Never mixed with comment or doc changes — a reviewer checking a coverage gate should
not also be checking a token-stream proof.

Deleting nothing is a good outcome. Report the baseline and stop.
