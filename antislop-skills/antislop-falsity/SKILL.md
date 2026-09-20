---
name: antislop-falsity
disable-model-invocation: true
description: >
  Find and remove agent-context, docs, and comments that are false, contradictory, or
  duplicated — starting with AGENTS.md/CLAUDE.md. Findings are claims cited to file:line,
  not diffs. Run as /antislop-falsity.
---

# antislop-falsity

Hunt wrongness, not length. A true-but-verbose line costs ~nothing; a short wrong one costs a
lot. See `../README.md` for why — don't restate it here or in your output.

Read `../README.md` before starting. It holds the decisions.

## Phase 0 — baseline

Report before touching anything. Numbers, not prose.

- token count of always-loaded tier: every `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, and any
  `.claude/` instruction file in the repo
- count of files under `docs/` (or equivalent) and their oldest/newest mtime
- whether `claude-md-management` is enabled — if yes, run its audit now and keep only the Red
  Flags section

## Phase 1 — mechanical falsity

Free and automated. Not a judgment pass, so it runs first. Target: always-loaded tier only.

For every path, filename, command, make target, script, env var, and tool named in those
files, check it exists:

```sh
rg -o '`[^`]+`' AGENTS.md CLAUDE.md | sort -u          # candidate tokens
test -e <path>                                          # paths and files
command -v <binary>                                     # binaries
make -n <target>                                        # make targets, no side effects
rg -n '<script-name>' package.json pyproject.toml Makefile
```

Every miss is a finding. No judgment required — the reference is dead or it isn't.

Also mechanical:

- same instruction stated in two always-loaded files (one is already wrong, or will be)
- version pins in prose vs the lockfile/manifest
- a documented command whose flags the installed tool rejects

Stop here and report. Phase 2 needs a file already stripped of dead references — a false line
often *reads* useful ("run `make test` before commit" looks like a keeper until the target is
gone), and a usefulness pass would keep it.

## Phase 2 — simplify the always-loaded tier

User judgment, on survivors. Present each line with one of:

- **would happen anyway** — the model does this without being told
- **earns its slot** — repo-specific, non-obvious, changes behavior
- **belongs on-demand** — true and useful, but only relevant sometimes → move to a doc the
  agent can grep, out of the always-loaded tier

Don't delete on your own judgment in this phase. Propose, let the user rule.

If a line is repo-specific but only *sometimes* relevant, moving beats deleting. Volume cost
is real in tier 1 and ~zero in tier 2.

## Phase 3 — semantic falsity

Expensive, so it runs last and only on what survived. Now widen to docs and comments.

A finding requires a citation on both sides:

> `docs/auth.md:41` says sessions expire after 24h.
> `src/session.py:88` sets `MAX_AGE = 3600`.

Rules:

- comment contradicts adjacent code → delete the comment (stale comment is a bug, worse than
  no comment)
- doc describes behavior the code lacks → delete, or fix if the doc is the spec and the code
  is the bug — say which you think it is
- doc duplicates README or AGENTS.md → delete the copy, keep the one with the better home
- comment whose only content is a ticket ref → inline one line of *why*, keep the link. An
  agent with no tracker access cannot follow it

Exempt, always: `README.md`, `CHANGELOG.md`. Code cannot answer "what is this project" or
"what changed in 2.0". Non-duplicative by construction.

Keep, always: a comment carrying *why*, provenance, a rejected alternative, or a constraint
imposed from outside the repo (vendor bug, wire format, legal). Code cannot express absence.

## Ride-along comment cleanup

Only inside a file a Phase 3 finding already opened. Never a standalone sweep — a true,
harmless, verbose comment costs nothing at read time and deleting it buys nothing.

When you do touch comments in a code file, prove the change is comments-only:

1. tokenize both revisions dropping comments, diff the token streams (Python: `tokenize`;
   JS/TS: a parser — no regex)
2. cheap universal fallback: byte-compare build artifacts (`.pyc`, bundle, binary)
3. full test + typecheck + lint green

Directive comments break the no-op — `# type: ignore`, `# noqa`, `# pragma: no cover`,
`@ts-expect-error`, `eslint-disable`, `//go:build`, `# fmt: off` — and so do
tooling-consumed ones (doctests, JSDoc used for types, OpenAPI annotations). Step 3 catches
them loudly. That's the point: don't skip it, and don't hand-wave it as "should pass."

## Output

Claims, ranked by blast radius. The user rules on the claim, not the diff.

```
<file:line>  <what it says>  →  <what's true, cited>  →  delete | fix | move | keep
```

Batch by claim, small. If a phase produces nothing, say so and stop — a clean phase is a
result. Do not pad the report to look productive.

Never mix this with test deletions. Different proof regime, different PR.
