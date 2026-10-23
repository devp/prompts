---
name: kickoff
disable-model-invocation: true
description: >
  Warm start on a ticket so I can drive immediately: TL;DR, then a map of entry points, call
  path, tests to run, and a suggested first failing test. Stops there — no implementation.
  Argument is the ticket ID or URL.
---

# kickoff

`/kickoff <TICKET>`. Out: enough orientation to start typing. I drive from here.

## Procedure

1. **Read the ticket** — Linear MCP if connected, else ask me to paste it. Linked PRs and
   docs only if the ticket depends on them.
2. **TL;DR** — apply the `tldr-ticket` rules and output format to the ticket. Follow that
   skill; don't restate its rules here.
3. **Map** — from the real code in the current repo, not the ticket's guesses:
   - **Entry points** — where the change starts, `file:line`, 1–3.
   - **Call path** — entry → the code that changes, one line per hop, `file:line`.
   - **Tests to run** — existing tests covering that path, as the exact command.
   - **First failing test** — name, file, and the one assertion that pins the ticket's
     ask. Description only; no test code.
4. **Stop.** No implementation, no edits, no branch.

## Output

TL;DR block, then Map as four labeled lines/lists. No recap, no plan beyond the first
test.

## Guardrails

- Read-only: no file edits, commits, or worktrees; no ticket comments or status changes.
- Don't infer code structure from names — open the file before citing `file:line`.
