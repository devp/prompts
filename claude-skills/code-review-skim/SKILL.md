---
name: code-review-skim
disable-model-invocation: true
description: >
  Skim-review a PR: verdict and blast radius up front, then tagged findings
  in descending importance, then a scoped approval line. Author mode (arg
  `self`) preflights the user's own change and drafts the PR description.
---

# Code Review Skim

Reviewing a PR at skim pace, catching what matters — a colleague's, or the
user's own before it goes out. Not a full audit — `/code-review` exists for that.

The author owns diagnosis; their self-review is the real review. This pass
exists to catch cheap major problems, to say where a close read is warranted,
and to leave a visible record of what was and wasn't reviewed.

## Start immediately

No intake interview. No strategy question, no time/energy check, no provenance
fork. Get the diff and go. Sole exception: the author-mode question below.

## Inputs

Never ask the user to paste a diff. Use `gh pr diff`, or `git diff <base>...<head>`
when there's no PR. Skip files the user says they've already handled.

Intent comes from the PR description and any ticket or doc it links. Fetch
those with whatever tools are available. Never ask the user for them. If none
is reachable, say so in one line and judge intent from the description alone.

## Reading

Weigh files by decisions, not lines: branches, external calls, state mutations,
error paths in the changed lines. A 12-line diff with 9 decisions is where the
bugs are; a 300-line diff with 2 is a rename. Pure renames, lockfile churn,
generated output, and Markdown get no findings.

Look at what the diff does, not what the description highlights:

- **Shape**: files touched and size vs. what the ticket implies. Anything
  surprising is worth a line.
- **Missing**: tests for new behavior, rollback or migration handling, a
  contract change with no matching consumer change.
- **Seams and state**: boundaries between components, shared state, ordering.
  Self-review by the author (or their agent) is weakest here.
- **Intent**: does the diff do what the ticket meant, not just what it said?

## Blast radius

Ask: if this PR were wrong in a way a skim can't see, what happens? Weigh
severity, detectability (loud vs. silent), reversibility.

- **SKIM**: failures would be loud and revertable.
- **CLOSE READ**: something could fail silently or irreversibly — migrations,
  data writes, auth, API/contract changes, parity with existing query logic.
  Name the files that put it here; those are the ones the user should read.

This is a separate axis from the verdict. A PR can be OK with nothing found
and still be CLOSE READ.

## Verdict

- **RUBBER STAMP**: mechanical, nothing to rule on.
- **OK**: real logic, nothing significant.
- **HIGH-PRI**: would cause a bug, data loss, a leak, or a broken deploy.

## Output

One turn, this shape:

```
Verdict: <RUBBER STAMP | OK | HIGH-PRI> · Blast radius: <SKIM | CLOSE READ>
<one line: why — for CLOSE READ, which files and what could fail silently>

Shape: <N files, Δ lines; surprises vs. ticket, or "as expected">
Missing: <what's absent, or "none">
Intent: <matches | drifts: how>

Findings:
  1. [blocking] path:line — <finding>
  2. [non-blocking] path:line — <finding>
  3. [follow-up] path:line — <finding>

Approve with: Reviewed <X, Y>. Didn't dig into <Z>.
```

Omit `Findings:` when there are none. Then stop; the user rules on findings
and may ask about any file.

## Findings

Most consequential first, across all files. Correctness, contracts, error
paths, ordering, migrations, permissions. No style nits, no praise, no "have
you considered". Don't manufacture findings to fill the list.

Tags:

- **blocking**: only when the blast-radius call supports it — the failure
  would be silent, irreversible, or severe.
- **non-blocking**: worth a one-line comment; the author can take it or not.
- **follow-up**: a want, not a need. Not a comment — the user merges and does
  it themselves.

A finding that rests on a framework default, a sibling-code convention, or the
other side of a service contract cites the `file:line` where you checked it.
Can't check it: tag it `unverified`, don't state it as fact.

Judge the code, not the author. Don't speculate about their workflow or depth.

## Findings are hypotheses

The user rules on each one. Their verdict closes it — "not a problem here",
"already handled upstream", "yes, fix" are all complete answers. Do not
re-argue a finding they have ruled on.

## Approval line

A draft for the user, stating scope: what was reviewed, what wasn't. Never
approve anything on their behalf.

## Author mode

For the user's own change, before anyone else reviews it. Their own read is
the real review; this pass points it at the right lines. No quizzing, no
asking them to justify the code.

Ask one yes/no question — "author mode?" — before starting when any of these
hold, then proceed:

- the PR is a draft
- the PR author is the current `gh` user
- the current `gh` user is an assignee (not just a requested reviewer)
- there is no PR, and the branch's commits are by the current `git` user

The argument `self` turns it on without asking.

Additions to the output:

- Two more finding tags: **cut** for extras the ticket didn't ask for
  (abstractions, config, error handling, files); **simpler?** for a new
  dependency or pattern where something simpler exists — name it.
- `Own these:` after findings — the CLOSE READ `path:line` ranges the user
  should be able to rewrite from memory. They check that themselves.
- Generated tests covering CLOSE READ paths: say whether they'd fail if the
  code broke. Unknown → `unverified`. Mutate code to find out only when asked,
  on a clean tree, reverting each mutation.
- If the diff is too big to hold in one head, propose split points.

Replace the approval line with a PR description draft:

```
What changed: <...>
Covers: <ticket / doc>
Checked: <what, and how>
Least sure about: <...>
Not touched: <...>
Generated-heavy: <left for the user>
Ask reviewers: <one specific thing self-review misses>
```

The ask is specific — "is this contract what the consumer expects?" — not a
general review request.

## Several PRs

One output block per PR. Dedupe findings that recur across them. A "none" from
a delegated reviewer means nothing found, not nothing there.

## Posting comments

Only when the user asks. Default preferences, offered once, overridable:
`suggestion` blocks or the exact change wanted plus a one-line reason, so
acceptance is one click; label blocking comments as blocking; don't post
follow-ups; neutral wording; line numbers from the PR head commit, not the
local checkout; a single comment, not a pending review.

## Scale

On a large PR (more than ~15 files), read files by decision count, highest
first, and say which files you didn't read in the approval line.
