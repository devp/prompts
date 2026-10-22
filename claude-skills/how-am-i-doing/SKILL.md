---
name: how-am-i-doing
disable-model-invocation: true
description: >
  Read-only retrospective over the real trail — tickets, PRs, reviews, Claude Code sessions,
  sidetrack forks, Slack asks, journal — for a window (default: this week). 3–5 lines on what
  shipped, what stalled, and where time went. No advice unless asked.
---

# how-am-i-doing

`/how-am-i-doing [window]`. Window: default this week (Monday 00:00 → now); accepts
"last week", a date, or a date range. Evidence over self-report: count what the systems
recorded, not what the journal says I meant to do.

## Sources — use what's reachable, skip the rest

Run independent pulls in parallel. A source that isn't connected or fails gets skipped and
listed; never block on it, never ask me to paste.

- **Linear** — Linear MCP if connected: my issues completed, moved (status changed), and
  stalled (in progress with no update for ≥3 workdays) in the window.
- **GitHub** — `gh`:
  - merged: `gh search prs --author @me --merged-at '>=<start>' --json repository,number,title,closedAt`
  - reviews given: `gh search prs --reviewed-by @me --updated '>=<start>' --json repository,number,author`,
    excluding my own PRs
  - review turnaround, per reviewed PR: `gh api repos/<o>/<r>/issues/<n>/timeline` — my
    `review_requested` event → my first `reviewed` event. Report median and worst.
- **Claude Code sessions** — local files; reachable only on the machine where the
  sessions ran. Say which machine's data this is.
  - started: distinct `sessionId` in `~/.claude/history.jsonl` with `timestamp` in window
    (ms epoch).
  - closed: background sessions from `claude agents --json --all` with `startedAt` in
    window and `state` `done` or `stopped`; plus any transcript
    (`~/.claude/projects/*/<sessionId>.jsonl`) containing `result: closed`.
  - session titles: last `ai-title` record in the transcript.
- **Sidetrack forks** — journal lines `HH:MM sidetrack-fork <slug>: …`:
  - spawned: lines ending in the goal.
  - acted on: slugs with an `operator turn` line, or whose `sidetrack/<slug>` branch merged.
- **Slack** — Slack MCP if connected. Direct asks to me in the window
  (`slack_search_public_and_private`, `keywords: ["<my handle>"]` and
  `filters: "with:<@Uxxx> after:<start>"`); answered = I replied in that thread/DM after
  the ask. Drop bot digests.
- **Journal** — `~/kb/journal/YYYY/MM/YYYY-MM-DD.md` for each day in the window: the
  sidetrack-fork lines above, plus the entries themselves for LOOP detection.

## Time split

Attribute each workstream (ticket/PR/repo) to one bucket by where the work happened:
- **driven** — commits authored by me on branches I didn't fork, navigator sessions.
- **delegated** — background sessions and forks that landed (merged or review-ready
  branch I acted on).
- **sidetrack** — forks and tooling/env sessions not tied to a ticket.

Proportions are rough; say so if one bucket is mostly guesswork.

## Output

3–5 lines, no headers:
- what shipped (counts + the one or two that mattered)
- what stalled (ticket/PR, since when)
- where time went: driven / delegated / sidetrack, rough share
- review load: reviews given, median turnaround; open Slack asks, if any

Then LOOP per `grwm`'s LOOP detection rules — only if visible across the window.

Last line: `skipped: <sources not reachable>` (omit if none).

No advice, no suggestions, no encouragement unless I ask.

## Guardrails

- Read-only everywhere: no posts, reactions, comments, ticket or task changes, journal
  writes.
- Don't credit anything not evidenced in a source. Session prompts show intent, not
  outcome.
