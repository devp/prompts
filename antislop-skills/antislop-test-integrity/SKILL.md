---
name: antislop-test-integrity
disable-model-invocation: true
description: >
  Check whether a test suite is telling the truth — tests that never run, suites that can't
  run in one process, skips with no tracking issue, flake history. Cheap by default; deletion
  is a byproduct, not the goal. Run as /antislop-test-integrity.
---

# antislop-test-integrity

A suite lies when a test doesn't run. The file reads as covered, the suite reads as green, and
nothing is being checked. That is the failure this skill exists to find, and it is cheap to
find.

Deleting tests is not the goal. Two well-maintained repos were swept for worthless tests and
yielded 104 lines of inert `it.skip()` blocks between them, at a cost of roughly half an hour
and 184k tokens. The same runs turned up 17 tests that never executed — incidentally, after
all the expensive work was done. This skill inverts that order.

## Directives

These drive the check. Read them to the user in one block at the start, and ask whether any
should change for this repo. Edit this section to change them permanently.

| # | Directive |
| --- | --- |
| D1 | **Cheap by default.** Four checks, no instrumentation, minutes. Never run coverage, never gate a candidate, until the user has seen the report and asked for more |
| D2 | **Don't build the environment.** If the suite doesn't run in one documented command, report what's missing and stop. Installing a database server is a different job with a different owner |
| D3 | A clean report is the product, not a failure. Most suites are healthy; say so and stop |
| D4 | Integrity findings are handed over, not fixed here. A test that never ran may well fail when un-hidden — that's the owner's call, not a drive-by |
| D5 | Deletion needs its own evidence: a skip with no live tracking issue, or a coverage gate the user explicitly approved |
| D6 | Own PR, and the evidence ships in the body — counts before and after, tracking-issue status. "No longer needed" is a conclusion, not a reason |
| D7 | If the expensive path runs: exclusive checkout **and** an idle machine. A suite running beside a gate run steals CPU, times out untouched tests, and invalidates the measurement |
| D8 | Don't introduce mutation-testing tooling. Use it only if the repo already has it |

## The four checks

Minutes, from a checkout that already works. This is the whole skill most of the time.

**1. Collected vs on disk.** The highest-value check and the cheapest. Count test functions in
the tree; count what the runner reports collecting. The gap is the finding.

```sh
rg -c '^\s*(def test_|it\(|test\(|it\.each)' --glob '<test globs>' | awk -F: '{n+=$2} END {print n}'
pytest --collect-only -q | tail -1        # or: vitest list, jest --listTests, manage.py test -v2
```

Causes seen in the wild: a class that doesn't inherit the runner's base, two modules sharing a
basename so only one imports, an import-time side effect that swallows collection, a fixture
error reported as a skip.

**2. Can the suite run as one process?** Anything at import time that forces sharding hides
check 1 — a module blanking `settings.DATABASES`, a global monkeypatch, an `os.environ` write.
If the suite only runs split, say so and name the file.

**3. Skips without a live issue.** `@skip`, `xfail`, `it.skip`, `@Ignore`. Report each with
whether it names an issue and whether that issue is open. Inert, so low-value to remove — but
free to find, and a skip with a closed issue is a decision someone forgot to finish.

**4. Flake history.** `gh run list` / CI API: red then green on an unchanged commit. Note the
sample size — a suite with few repeated commits can't show flakes even if it has them.

## Output

A health report. No PR unless something in it warrants one.

```
collected 3,863 · on disk 3,880          →  17 NEVER RUN   (tests/features/test_x.py::ClassY)
single-process  no                        →  events/tests/test_commands.py:15 blanks DATABASES
skips 2 · with live issue 0               →  CampaignDetailsForm.test.tsx
flake signal none (1,207 runs, 11 repeats — too few to conclude)
```

State the sample-size caveat wherever one applies (D3). "No flakes found" and "no flakes" are
different claims.

## The expensive path, offered not taken

Change-detector and coverage-duplicated candidates need an instrumented run plus one suite run
per candidate. Offer it priced, and expect the honest answer to be no:

```
Coverage-gated categories: ~1 instrumented run + 1 suite run per candidate
(suite 108s → est. 25min). Want it?
```

If it runs: a deletion is blocked by any drop in line or branch coverage, and a candidate that
fails the gate is dropped silently.

Know what you're buying. On one real suite (1,674 tests, 78.9% coverage), 1,179 of 1,585 tests
contributed zero unique lines and zero unique arcs — the gate would wave three quarters of the
suite through, including a 33-case pause-state truth table and a deliberately hardcoded digest.
Flat coverage is a permit, not a proof, and on suites like that it is not even a permit.

## Risk to hold

An implementation-looking test is sometimes the only pin on a subtle invariant, and "tests the
essence" is not a definition. Without a gate you have no deletion finding — say so rather than
proposing deletions from reading alone.
