---
name: done
disable-model-invocation: true
description: >
  Close this chat. Optional argument is a closing status line. Records it in the transcript,
  then stops the session if it is a background session (no-op if foreground). Transcript is kept.
---

# done

Close-out for the current session. Argument (optional) = closing status, e.g.
`/done merged, PR #123`.

## Procedure

1. Text, one line, exactly: `result: closed — <status or 'done'>` (job-list classifier
   reads only message text; without this line state stays "working").
2. Same turn, one Bash call:

```sh
echo "closed: <status or 'done'>"; claude stop "${CLAUDE_CODE_SESSION_ID%%-*}"
```

`claude stop` takes short job id (first 8 hex of session UUID, as in `claude agents --json`
`.id`); full UUID → "No job matching". Background session: stop ends process, call is last
thing that runs. Foreground: no job, stop fails; fine.
After call, if still running, reply only "👍" plus stop's error line if any. No retry.

## Guardrails

- No reply, summary, or recap beyond the `result:` line. No kb or memory writes.
- Resume a stopped session with `claude attach <id>` / `--resume`.
