---
name: grwm
disable-model-invocation: true
description: >
  Morning briefing. Pulls work journal + task list + calendar, surfaces one best-impact
  AM move plus today's focuses. Use when user runs /grwm or asks "what should I work on
  this morning" / "help me plan today". Inputs are all optional — Todoist/Google
  Calendar/Slack MCP if connected, pasted journal/agenda text otherwise, or just ask the
  user directly.
---

# grwm

Morning planning pass: journal + tasks + calendar in, one AM-impact pick + short focus
list for today out.

## Inputs — gather what's available, don't block on missing ones

- **Work journal** — most recent entries, pasted markdown/text (or a file path if given).
  Carries yesterday's loose threads, open questions, half-finished thoughts.
- **Task list** — Todoist MCP (`mcp__claude_ai_Todoist__get-overview` or
  `find-tasks-by-date` for today/overdue) if connected. Else ask user to paste it.
- **Calendar** — Google Calendar MCP (`list_events` for today) if connected. Else ask, or
  skip if user says no meetings.
- **Slack** — Slack MCP if connected. There is no unread/badge API; approximate with two
  `slack_search_public_and_private` calls scoped `after:<last journal date>`:
  - asks aimed at the user: `keywords: ["<user's slack handle>"]` — matches the
    `<@Uxxx|handle>` mention token
  - DMs and threads in flight: `filters: "with:<@Uxxx> after:YYYY-MM-DD"`
  Drop bot-digest hits that don't name the user. Read named standup/digest channels only
  if the user asks for them.

Don't demand all of them. If only the journal is pasted, work from that and ask 1-2 quick
questions to fill gaps (what's due today, any meetings).

## Procedure

1. Pull whatever inputs are available (parallel MCP calls where possible).
2. Cross-reference: overdue/due-today tasks, calendar gaps, journal threads still open.
3. Pick **one AM-impact move** — high-leverage, fits before meetings eat the day.
   Priority order: overdue > blocking someone else > journal thread already in motion >
   new task. An unanswered direct Slack ask counts as blocking someone else.
4. List **2-4 focuses for today** — not a full task dump, just what's realistic given the
   calendar load.
5. Flag anything time-boxed (meeting prep, EOD deadline) that needs a slot.
6. Check for a LOOP — a pattern visible across journal entries / task history, not a
   single day's snapshot. Only surface if genuinely visible; skip silently otherwise.

## LOOP detection

State plainly if seen — "X has been [state] since [date]" or "Y has not been completed."
No advice attached.

Patterns to watch for:
- big rock left undecided across multiple entries
- P0/overdue label persisting without movement
- Monday check-in or Friday self-check-in left incomplete (flag on that day of week)
- EOD reflection skipped
- side work (tooling, env setup, optimization) consuming time repeatedly instead of the
  stated priority
- a design decision revisited after it was already treated as settled

## Output

AM pick first, then focus list, then deadline flags, then LOOP (if any). No recap of
inputs, no "here's what I found" preamble.

## Guardrails

- Read-only against Todoist/Calendar/Slack — never create, update, or complete
  tasks/events, and never send a message, reaction, or draft, unless explicitly asked.
- Don't invent tasks or events not present in the actual inputs.
