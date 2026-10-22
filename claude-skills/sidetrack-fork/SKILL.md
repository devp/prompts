---
name: sidetrack-fork
disable-model-invocation: true
description: >
  Spin a side task off into a background copy of this session. The fork inherits context,
  plans first, works in its own worktree within a turn cap, never asks for input, and parks
  with a card until pulled. Argument is the goal, one line.
---

# sidetrack-fork

`/sidetrack-fork <goal>`. Two roles: **launcher** (this session, now) and **fork** (the
background copy). The fork sees these instructions in its inherited context.

## Launcher

1. `slug` = goal as kebab-case, ≤5 words.
2. Append the start line to the journal (see Journal).
3. One Bash call:

   ```sh
   claude --bg --resume "$CLAUDE_CODE_SESSION_ID" --fork-session -n "🧵🔀: <goal, ≤40 chars>" \
     "You are the sidetrack fork. slug: <slug>. goal: <goal>. Follow the Fork section of the sidetrack-fork instructions above; skip Launcher."
   ```

   `--bg --resume` on a running session starts a copy with the transcript so far;
   `--fork-session` gives it its own id. Prints the job id.
4. Reply one line: `forked <job id> · sidetrack/<slug>`. Then resume what this session was
   doing. No `result:` line here — this session isn't done.

## Fork

### Rules

- **Never ask for input.** No questions, no `needs input:`. On ambiguity: write the
  assumption into the plan and take the conservative path; if no conservative path exists,
  stop at plan-only and park. Done means parked, not waiting.
- **Isolation.** Before the first edit:
  `git worktree add .claude/worktrees/sidetrack-<slug> -b sidetrack/<slug>`, then
  `EnterWorktree` with that `path` if the tool exists. Not in a repo → plan-only unless the
  goal is read-only.
- **Turn cap: 30** tool-calling turns, unless the goal states another cap. At the cap, stop
  and park with `scoped wrong — <why>` as the state. Continue past it only when the user
  replies with a reason; their reply sets the new cap.
- Commit in the worktree. Push the branch if the repo has a remote. No PR, no merge, no
  touching the launcher's checkout, unless the goal says so.

### Output

1. **Plan**, first section of the first message: goal restated in one line, steps,
   assumptions, what "review-ready" means for this goal. Then execute.
2. **Park card**, final message:

   ```
   result: parked — <one-line state>
   branch: sidetrack/<slug> (<worktree path>)
   review-ready: <commits or files a reviewer can take now, or "nothing">
   assumptions:
   - <each assumption that shaped the work>
   left:
   - <what's not done>
   ```

   The `result:` line is for the job-list classifier (same convention as `done`); it must
   lead the message, verbatim prefix `result: parked — `.

### Operator turn

On the first message from the user after launch, before replying: append the operator-turn
line (see Journal) unless it's already there. Then handle the message; re-park with a fresh
card when done.

## Journal

Today's work journal: `~/kb/journal/YYYY/MM/YYYY-MM-DD.md`. If missing, create it with the
header `# <Weekday>, YYYY-MM-DD` (`date +'# %A, %F'`). Append-only, never edit other lines.
At most two lines per fork:

```
HH:MM sidetrack-fork <slug>: <goal>
HH:MM sidetrack-fork <slug>: operator turn
```

Launcher writes the first; fork writes the second, once — check with
`rg -qF 'sidetrack-fork <slug>: operator turn' <file>` before appending.
