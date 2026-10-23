# Readied Action Coding Workflow — trial notes

Possible main working mode, on trial (for both work and personal). Stays in `wip/` until trialed.

## The bet being tested

That paying a steady, moderate overhead (menu decisions, small increments,
parked branches) buys retained understanding and eliminates big review walls —
and that retained understanding is what actually drives your defect rate.

If understanding *isn't* the constraint — if skimming generated diffs would
have been fine — then the overhead bought nothing, and either hand-writing or
plain batch review wins on both speed and defects.

## How to tell if it's working

Gut feel day to day, plus `/how-am-i-doing` weekly: what shipped, what stalled,
and where time went (driven / delegated / sidetrack), read from the real trail.

## Failure modes to watch for

**Defects**
- *Approval is a weaker guarantee than authorship.* Hand-written code fails at
  things you knew you skipped; approved code fails at things you didn't know
  were there.
- *Integration bugs at the seams.* Each branch individually correct and
  reviewed, the bug living in the interaction — nobody built the seam. The
  independence-claim rule only catches collisions the agent can predict.
- *Agent-written tests test what the agent suspected.* Narrower than tests you'd
  have written, which encode your own hunches about what's fragile.

**Time**
- *Menu overhead compounds.* Evaluating independence claims is cheap once and
  expensive fifty times a day.
- *Rebase churn* if the collapse-to-main-within-a-day discipline slips even a
  little.
- *The queue becomes a second inbox.* Parked work still occupies background
  attention. "There's stuff waiting" is an open loop even with notifications
  off, and open loops are costly.

## Behavioral checks

- Does **"pick zero"** actually get used, or does the menu create pressure to
  always take something? (If it's never used, the menu is driving you rather
  than serving you.)
- Does **one-chain-at-a-pause** hold, or is there constant pull toward the broad
  sweep?
- What fraction of speculative on-deck work is usable vs. discarded? High
  discard is fine and expected; near-total discard means the menu step is
  proposing badly.
- A week later, can you explain everything that landed in main? Anything you
  can't is comprehension debt that the guardrails failed to catch.

## Kill criteria

Worth abandoning or heavily simplifying if, after a fair trial:
- Approved-branch defects clearly exceed driven-branch defects, or
- Time-to-merge is meaningfully worse with no defect improvement, or
- The parked queue is generating more background load than the review walls it
  replaced.
