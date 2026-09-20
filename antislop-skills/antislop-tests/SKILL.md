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
| D7 | Needs an exclusive checkout. If another sweep is running, take a separate worktree — concurrent edits corrupt the coverage baseline and manufacture flakes |

## Phase 0 — baseline

Report before proposing anything:

- total test count, suite wall-clock, slowest 10 tests
- flake rate if CI history is reachable (`gh run list` / CI API): tests that have gone red then
  green on an unchanged commit
- current line and branch coverage — this is the gate's reference point, capture it exactly

## Phase 1 — candidates

Ranked by value, highest first.

**Flaky.** Worse than useless: they train the team to ignore red. Evidence is CI history — red
then green with no code change between. Highest-value item on the list, and D3 applies.

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
