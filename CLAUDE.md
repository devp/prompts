# prompts

## Agents
Background jobs land their own work: rebase your worktree branch onto main, `git -C <main checkout> merge --ff-only <branch>`, push main, delete worktree + branch. No PR.
If the ff-merge is blocked by overlapping uncommitted edits in the main checkout, stop and tell me.
