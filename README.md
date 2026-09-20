# prompts

Personal prompt and skill store.

## Layout

| Path | Contents |
| --- | --- |
| `claude-skills/` | Claude Code skills, stable |
| `antislop-skills/` | Skills for removing misleading context, docs, and tests. Has its own README |
| `wip/` | Skills still being shaped |
| `manual-prompts/`, `tech/`, `util/` | Prompts pasted by hand, not loaded by any tool |
| `*.md` (top level) | Standalone prompts |

## Claude Code skills

A skill is a directory with a `SKILL.md`. Installed by symlinking it into `~/.claude/skills/`:

```sh
ln -s ~/code/prompts/claude-skills/<name> ~/.claude/skills/<name>
```

### Invocation

Every skill here sets `disable-model-invocation: true` in its frontmatter. Skills run only
when invoked as `/<name>`, never because Claude matched the `description` against a prompt.

Keep this on new skills. Without it Claude auto-triggers on phrase overlap: `ticket-read-along`
fired on "walk me through PR 3094" and ran a paced retention walkthrough on a PR that was
already mine.

The flag also locks the setting — the `/config` skill toggle can't re-enable model invocation
for a skill whose frontmatter disables it.

Known cost: user-invocable-only skills can't run in coordinator mode. The coordinator doesn't
load skill content and workers can't invoke them.

### Frontmatter

```yaml
---
name: <dir name>
disable-model-invocation: true
description: >
  What it does, and when to run it.
---
```

`description` still matters with model invocation off — it's what `/help` and the skill picker
show.
