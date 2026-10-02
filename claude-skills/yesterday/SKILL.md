---
name: yesterday
disable-model-invocation: true
description: >
  Standup recap. Pulls work journal + tasks + calendar + Slack + Claude Code chat history
  for the previous workday (or a given date), separates what got done from what was just
  activity, and outputs paste-ready standup lines.
---

# yesterday

Look-back pass: same sources as grwm plus chat history, for one past day. Out: what
moved, what's in flight, what's blocked — short enough to say aloud at standup.

## Target day

Default: previous workday (Monday → Friday). Accept a date or "today" as the argument.
Label the output with the date used.

## Inputs — gather what's available, don't block on missing ones

- **Work journal** — `~/kb/journal/YYYY/MM/YYYY-MM-DD.md` for the target day, plus the
  following day's file if it exists (morning entries often record what landed late).
  Checked boxes = done; unchecked = carried.
- **Task list** — Todoist MCP if connected: tasks completed on the target day. Else skip.
- **Calendar** — Google Calendar MCP `list_events` for the target day. Meetings attended
  are context, not accomplishments — mention only one that produced a decision.
- **Slack** — Slack MCP if connected. `slack_search_public_and_private` with
  `filters: "from:<@Uxxx> on:YYYY-MM-DD"` for what the user posted: answers given,
  decisions announced, reviews done. Drop chatter.
- **Chat history** — Claude Code prompts in `~/.claude/history.jsonl`, grouped by project
  and session, with each session's title:

  ```sh
  D=YYYY-MM-DD
  s=$(date -j -f %F-%H%M%S "$D-000000" +%s); e=$((s+86400))
  jq -r --argjson s $s --argjson e $e '
    select(.timestamp/1000 >= $s and .timestamp/1000 < $e)
    | [.project, .sessionId, (.timestamp/1000|strftime("%H:%M")),
       (.display|gsub("\n";" ")|.[0:160])] | @tsv' ~/.claude/history.jsonl
  # session title: last ai-title record in ~/.claude/projects/*/<sessionId>.jsonl
  jq -r 'select(.type=="ai-title")|.aiTitle' ~/.claude/projects/*/<sessionId>.jsonl | tail -1
  ```

  Prompts show intent, not outcome. To tell whether a session landed, read the tail of its
  transcript (last few assistant messages) — only for sessions that look like real work,
  not one-off questions.

## Procedure

1. Pull inputs (parallel where possible).
2. Cluster by workstream (project/ticket), not by source. One workstream across journal +
   chat + Slack is one line.
3. Sort each cluster into:
   - **Done** — shipped, merged, decided, unblocked someone, answered a question someone
     was waiting on.
   - **In progress** — real movement, not finished. Say where it stands.
   - **Blocked / need** — waiting on a person or decision. Name who or what.
4. Exploration, tooling, and Q&A sessions fold into the workstream they served; drop if
   they served none.

## Output

Paste-ready, standup register: Done / In progress / Blocked, 1 line per item, ≤6 items
total. Ticket IDs where known. No source attribution, no recap of inputs.

Then, only if visible: one line `side time:` naming tooling/env/exploration that ate a
large share of the day without moving a workstream. No advice attached.

## Guardrails

- Read-only against every source — never send, post, react, draft, or complete anything
  unless explicitly asked.
- Don't credit work not evidenced in the inputs. Chat prompts alone don't prove done —
  mark it in progress unless something shows it landed.
