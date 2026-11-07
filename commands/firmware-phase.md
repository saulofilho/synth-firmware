---
description: Work the next (or a named) phase of the FM-1 firmware in this repo.
argument-hint: [phase number or name, e.g. "2" or "mood"] (optional)
---

Advance the FM-1 firmware using the **synth-firmware** skill (see
`references/phases.md`).

Target phase: **$ARGUMENTS** (if empty, read `PLAN.md` and determine the next
unfinished phase).

Steps:

1. Read `PLAN.md` and the relevant `firmware/src/*.c` to confirm the current
   state. Do not start a phase whose predecessor doesn't build.
2. Summarize what this phase delivers and the files it will touch; confirm with
   me before large changes.
3. Implement within the chip's rules (`references/chip-rules.md`). Build
   (`./build.sh`) and run host tests (`sh tests/run_host.sh`) after each
   meaningful change; add a host test for new behavior.
4. Report files changed, build + test results (the pass/fail lines), any
   resource-budget movement, and the next step.

Consider delegating the heavy lifting to the **firmware-builder** agent.
