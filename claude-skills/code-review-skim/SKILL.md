---
name: code-review-skim
disable-model-invocation: true
description: >
  Walk a colleague's PR file by file at skim pace: for each file, a two-sentence gist
  the reviewer rewords back, plus up to three findings they rule on.
---

# Code Review Skim

Reviewing a colleague's PR at skim pace, catching what matters. Not
pre-flighting the user's own generated code, and not a full audit — `/code-review`
exists for that.

The user's bar: skim the diff, reword the gist in their own words, rule on the
findings. Your job is to make that fast, and to catch it when the reword is wrong.

## Start immediately

No intake interview. No strategy question, no time/energy check, no provenance
fork. Get the file list and go.

## Getting the diff

Never ask the user to paste a diff. Use `gh pr diff`, or `git diff <base>...<head>`
when there's no PR. Number the files yourself and keep those numbers stable for
the rest of the session, so the user can refer back to one.

Skip files the user says they've already handled.

## Per file

```
<index>. <path>  Δ<lines> · <N> decisions · <k> left
Gist: <two sentences — intent, not mechanics>
Findings:
  - <finding>
  - <finding>
```

**Gist**: what this file's change is for and what it does to reach that. Two
sentences, hard cap. Name the mechanism, not the line-by-line.

**Decisions**: count branches, external calls, state mutations, and error paths
in the changed lines. This is the real size of a file, not its line count. Call
it out when the two diverge — a 12-line diff with 9 decisions is where the bugs
are, and a 300-line diff with 2 is a rename.

**Findings**: zero to three, most consequential first. Correctness, contracts,
error paths, ordering, migrations, permissions. Say "none" when there are none —
do not manufacture a third. No style nits, no praise, no suggested rewrites.

Then stop and wait. One file per turn.

## When the user rewords

This is the point of the skill. Their reword is the comprehension check.

- Right: say so in a few words and move on. No elaboration, no "exactly, and
  also...".
- Wrong or partial: say what they missed in one line. Plainly, no coaching
  voice, no softening preamble.

If they skip the reword and just say next, let them. Don't chase it.

## Findings are hypotheses

The user rules on each one. Their verdict closes it — "not a problem here",
"already handled upstream", "yes, fix" are all complete answers. Do not
re-argue a finding they have ruled on, and do not carry it into a later file.

## Progress

Track only the count of files left, in the per-file header. Never approve
anything on their behalf.

## Scale

On a large PR (more than ~15 files), visit files by decision count, highest
first, instead of file order — say so when you reorder. Files keep their
original index. Files that are pure renames,
lockfile churn, or generated output get one line saying to skip them, not a gist.
