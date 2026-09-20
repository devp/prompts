---
name: antislop-falsity
disable-model-invocation: true
description: >
  Find and remove agent-context, docs, and comments that are false, contradictory, or
  duplicated — starting with AGENTS.md/CLAUDE.md. Findings are claims cited to file:line,
  not diffs. Run as /antislop-falsity.
---

# antislop-falsity

The problem is misleading context, not wasted tokens. A true-but-verbose line costs ~nothing;
a short wrong one costs a lot.

Deletion is recoverable (`git log --diff-filter=D`). Misleading content is not auditable —
nothing fails, nobody notices, the agent confidently does the wrong thing. Rewriting and
reviewing are both expensive. That asymmetry is why this sweep is deletion-biased.

## Directives

These drive the sweep. Read them to the user in one block at the start, and ask whether any
should change for this repo before Phase 1. Edit this section to change them permanently.

| # | Directive |
| --- | --- |
| D1 | Per-turn context is `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, and any instruction file under `.claude/`. Ruthless here — paid for on every turn of every agent |
| D2 | On-demand content (docs the agent greps when relevant) is cheap. Conservative there |
| D3 | Mechanical checks run before any judgment pass, always |
| D4 | Never delete on your own judgment in Phase 2. Propose, let the user rule |
| D5 | Verbose-but-true comments are ride-along only — inside files a finding already opened. Never a standalone sweep |
| D6 | `README.md` and `CHANGELOG.md` are exempt. Code cannot answer "what is this project" or "what changed in 2.0" |
| D7 | A comment carrying *why*, provenance, a rejected alternative, or an outside constraint (vendor bug, wire format, legal) is always kept. Code cannot express absence. **Before deleting any comment, quote it and state which D7 category it fails.** No quote, no deletion |
| D8 | Never share a PR with test deletions. Different proof regime |
| D9 | No shell or repo access means Phase 1 cannot run. Say so and stop. Phases 2-3 on pasted files are opinion, not findings — run them only if the user asks knowing that |
| D10 | Every changed line traces to a numbered finding. No formatting, punctuation, or rewording passes. A file with no finding is not opened |
| D11 | Writing is allowed but priced by tier: words added to per-turn context spend the budget this sweep exists to cut; the same words in `docs/` are ~free. Report the price |
| D12 | Headline the metric. Per-turn context size before and after, lines and bytes, is the first and last thing reported |

## Phase 0 — baseline

Report before touching anything. Numbers, not prose.

- **per-turn context size, per file and total, in lines and bytes** (D1, D12). This is the
  number the sweep is judged on. Capture it exactly — you report the delta at the end
- `wc -lc` on each per-turn file is enough. Don't estimate tokens; bytes are the honest proxy
- count of files under `docs/` (or equivalent) and their oldest/newest mtime
- whether the `claude-md-management` plugin is enabled. If yes, run its audit and keep **only**
  its Red Flags section — its score rewards having more content, which is backwards here

## Phase 1 — mechanical falsity

Free and automated, so it runs first (D3). Per-turn context only.

For every path, filename, command, make target, script, env var, and tool named in those
files, check it exists:

```sh
rg -o '`[^`]+`' AGENTS.md CLAUDE.md | sort -u          # candidate tokens, then filter
test -e <path>                                          # paths and files
command -v <binary>                                     # binaries
make -n <target>                                        # make targets, no side effects
rg -n '<script-name>' package.json pyproject.toml Makefile
```

Every miss is a finding. No judgment required — the reference is dead or it isn't.

Also mechanical:

- same instruction stated in two per-turn files (one is already wrong, or will be)
- version pins in prose vs the lockfile/manifest
- a documented command whose flags the installed tool rejects

Stop and report. Phase 2 needs a file already stripped of dead references — a false line often
*reads* useful ("run `make test` before commit" looks like a keeper until the target is gone),
and a usefulness pass would keep it.

## Phase 2 — simplify the per-turn context

User judgment, on survivors. Propose only (D4). Label each line:

- **would happen anyway** — the model does this without being told
- **earns its slot** — repo-specific, non-obvious, changes behavior
- **belongs on-demand** — true and useful but only sometimes relevant → move to a doc the
  agent can grep, out of the per-turn context

Moving beats deleting for that third case (D1, D2), but a move is **verbatim relocation**.
Rewriting content in transit makes it unreviewable — the diff shows a new file and a deletion,
and nobody can tell which words changed.

**Report a count for all three labels, including zeroes.** A sweep that returns only "belongs
on-demand" has pulled one lever: it relocated bulk and challenged nothing. The `would happen
anyway` count is the pass working. If it is zero, say so explicitly and say why — that is a
finding about the file, not a quiet skip.

## Phase 3 — semantic falsity

Expensive, so last, and only on survivors. Widen to docs and comments.

A finding requires a citation on both sides:

> `docs/auth.md:41` says sessions expire after 24h.
> `src/session.py:88` sets `MAX_AGE = 3600`.

- comment contradicts adjacent code → delete the comment. A stale comment is a bug, worse
  than no comment
- doc describes behavior the code lacks → delete, or fix if the doc is the spec and the code
  is the bug. Say which you think it is
- doc duplicates README or AGENTS.md → delete the copy, keep the better home
- comment whose only content is a ticket ref → inline one line of *why*, keep the link

That last rule exists because a ticket rots invisibly — it 404s on tracker migration — and an
agent with no tracker access cannot reach it at all. A colocated comment at least gets read
when someone reviews the line.

## Ride-along comment cleanup

Only inside a file a Phase 3 finding already opened (D5). A true, harmless, verbose comment
costs nothing at read time and deleting it buys nothing.

**The D7 check comes first, and it is the expensive one to get wrong.** A verbose comment and
an irreplaceable one look alike: both are long, both restate context the code doesn't show.
Quote the comment, then name the D7 category it fails, before proposing the deletion. These
are keeps, not candidates:

- names an alternative that was considered and rejected ("it is a table and not a JSON column
  because…")
- states a consequence outside this file ("…would flow to customer-sync-service on every
  submit")
- marks this code as an exception to a pattern the reader will assume ("implemented, not a 501
  stub like the rest of this router")
- carries a ticket ref — inline the why, keep the link, never drop both

Length is not evidence. A long comment explaining a rejected design is the highest-value line
in the file; deleting it is unrecoverable in a way deleting prose is not.

When you do touch comments in a code file, prove the change is comments-only:

1. tokenize both revisions dropping comments, diff the token streams (Python: `tokenize`;
   JS/TS: a parser — no regex)
2. cheap universal fallback: byte-compare build artifacts (`.pyc`, bundle, binary)
3. full test + typecheck + lint green

Directive comments break the no-op — `# type: ignore`, `# noqa`, `# pragma: no cover`,
`@ts-expect-error`, `eslint-disable`, `//go:build`, `# fmt: off` — and so do tooling-consumed
ones (doctests, JSDoc used for types, OpenAPI annotations). Step 3 catches them loudly. Don't
skip it and don't hand-wave it as "should pass."

## Output

Lead with the metric (D12), then the claims:

```
per-turn context:  AGENTS.md  400 → 279 lines,  65.8KB → 52.6KB   (-20%)
                   added back:  +50 lines to AGENTS.md  (D11: spent budget)
                   moved out:   175 lines → docs/migration-context.md  (verbatim)

Phase 2 rulings:   would-happen-anyway 0 · earns-its-slot 34 · belongs-on-demand 6
```

A zero in `would-happen-anyway` next to a large `belongs-on-demand` means the sweep relocated
bulk without challenging anything. Say that out loud rather than shipping it as a win.

Then the claims, ranked by blast radius. The user rules on the claim, not the diff.

```
<file:line>  <what it says>  →  <what's true, cited>  →  delete | fix | move | keep
```

Every row in the diff maps to a row here (D10). If a file appears in the diff with no claim
behind it, drop the file from the change.

Batch by claim, small. If a phase produces nothing, say so and stop — a clean phase is a
result. Do not pad the report to look productive.
