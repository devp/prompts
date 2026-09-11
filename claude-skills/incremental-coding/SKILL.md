---
name: incremental-coding
disable-model-invocation: true
description: >
  Paced coding loop: one failing test, the minimum code to pass it, stop, propose the
  next increment. Use when the user runs /incremental-coding or asks for small steps —
  "one at a time", "don't batch this", "TDD it", "stop generating whole files". Stays
  on for the rest of the session until the user says "batch mode" or turns it off.
---

# Incremental Coding

Default coding behavior is replaced for this session: no multi-file, multi-function
generation. Work advances one verified increment at a time.

## Core loop

1. Before implementation code, write **one** test — or one clearly scoped behavior
   check — for the next smallest unit of work.
2. Run it. Confirm it fails, and that it fails for the expected reason. A test that
   passes immediately or errors for an unrelated reason is not a starting point.
3. Write the **minimum** code to pass that one test. Stop there. Do not pull in the
   next piece of functionality because it's obvious or adjacent.
4. Run it. Confirm it passes. Report the actual output, not "should pass".
5. Propose the next increment. Wait for a go-ahead if it involves a design choice;
   proceed automatically if it's mechanical continuation (next case in an obvious
   sequence).

Default chunk size: one function, one test, one run. If a chunk can't be verified by
running it, it's too big — split it and say how.

## Hard limits

- **No batch generation.** Multiple files or multiple functions in one turn only on
  an explicit request ("generate the whole thing, I'll review it as a block").
- **No silent scope creep.** If a test reveals the need for a bigger refactor, stop
  and name it as a decision point. Do not absorb it into the current increment.
- **No speculative scaffolding.** Config, helpers, and abstractions arrive when a
  test needs them, not before.
- One increment per turn. End the turn after step 4; don't chain increments to look
  productive.

## Reviewing a batch diff

Batch review can't always be avoided — generated code, a teammate's PR. Don't read
it top-to-bottom as text:

1. Write (or ask the user for) 3–6 concrete questions the diff must answer: "does
   this handle the empty-list case?", "why this data structure over X?", "what
   breaks if this runs twice?".
2. Check out the branch and run it — or step through it — to answer each question
   directly. Answers inferred from reading code don't count.
3. Only then do a fast visual pass for style and naming. That part can stay linear;
   it's low-stakes.

## Escape hatch

Batch mode is fine, without argument, when:

- The task is trivial or mechanical — boilerplate, config, a rename.
- It's throwaway prototype code the user plans to rewrite.
- The user says "batch mode" for this task.

Otherwise the loop holds: it catches problems while they're still cheap.
