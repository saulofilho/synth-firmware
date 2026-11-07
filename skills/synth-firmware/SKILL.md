---
name: synth-firmware
description: >-
  Use when building, forking, or releasing a firmware for the M-VAVE FM-1
  groovebox (JieLi AC791N chip, Felucca / SLOOP / GR!MM lineage) — a new
  firmware from a theme or genre, a new sound engine or pattern set, the web
  hub + WebAssembly emulator, or a signed submission to the FM-1 Firmware Hub.
  Triggers on: FM-1, M-VAVE, Felucca, GR!MM, AC791N, .fwsc, fmhub, firmware
  phase/release, "fork the firmware", JieLi toolchain.
---

# Building an FM-1 firmware (Felucca platform)

A playbook for making a firmware for the **M-VAVE FM-1** groovebox. The FM-1 runs
a **JieLi AC791N** and a shared base platform, **Felucca → SLOOP → Dinghy**;
most community firmwares (GR!MM, zp12, sloopDX) are forks of that base. This
skill encodes the *method*: the phase model, the chip's hard rules, the
toolchain, and the release + Firmware Hub flow. It does **not** generate the
DSP for you — each engine is real engineering — but it keeps the skeleton,
constraints, and publishing correct.

**Reference implementation: COQUI** (`saulofilho/coqui-fm1`), a Latin/Caribbean
groovebox forked from GR!MM 2.0.2. Cite it for concrete file names and patterns.

## When you start

Establish these before touching code (ask the user if unknown):

1. **Base fork** — which firmware to fork (GR!MM, zp12, or the bare Felucca BSP)
   and its exact version. Match the licence (GR!MM is GPL-3.0-only).
2. **Theme / mood** — the genre, feel, and sound palette. This drives naming,
   boot screen, and every engine decision.
3. **Scope of 1.0** — the list of genres/engines that ship first. Keep it small.
4. **Hardware reality** — develop against host build + web emulator until a
   physical FM-1 is available; accept **both** flash IDs (`0x856014` and
   `0xB36014`) so newer units work.
5. **Repo + publish policy** — local git first; push to GitHub only when the
   user says so.

Then work in **phases**. Do not skip ahead — each phase assumes the last built
and the host tests pass. Full detail in
[references/phases.md](references/phases.md); the short form:

| Phase | Deliverable |
| --- | --- |
| 0 · Environment | Toolchain + SDK installed; base firmware compiles; host tests green |
| 1 · Identity | Name, free `FM-1_9NN` id, own store magics, `APP_NAME`, boot/palette, both flash IDs, credits in `LICENSING.md` |
| 2 · Engine | The sound engine (synthesis/percussion/voices); per-voice cost measured with `fm1_ticks()` |
| 3 · Patterns + Hub | Pattern/groove system; the web hub + WebAssembly emulator + editor |
| 4 · Melodic | ARP/patch work (bass/harmony lines over held chords) |
| 5 · Mood | Generative + ambience + idle/home screen |
| 6 · Release | Release workflow, physical-device test, tag, Firmware Hub email |

## The chip's rules (never violate)

These cause link failures, crashes, or audio glitches. The build catches most,
but write code that respects them from the start. Full list in
[references/chip-rules.md](references/chip-rules.md). The ones that bite:

- **Integers only.** No `float`/`double` (no FPU, no libgcc soft-float → link
  fails). Use fixed point: Q15 for levels, Q12 for gains, 32-bit phase for
  oscillators. Compute constants on the host and emit them as numbers
  (`tools/gen_tables.py`).
- **No 64-bit division.** `a / b` on 64-bit values needs `__udivdi3`, absent →
  link fails. Shift, or divide 32-bit values. Division by zero does not trap; it
  returns garbage — guard divisors.
- **Audio budget.** `app_audio()` has 5.8 ms for 256 frames, less in practice.
  Target under **2.9 ms**. Do per-block work (every 16–32 frames), not per-frame.
  Measure with `fm1_ticks()` on host *and* `tools/fm1_cpu.py` on the device.
- **No flash / screen / waiting inside audio.** Share with the main loop through
  `volatile`, one writer each; write struct fields in a half-done-safe order.
- **Hardware only through `hal/`.** No raw register access outside `hal/`.
- **A disabled feature must cost zero CPU** (skip the code whole; don't run it at
  a level of 0). Host tests compare byte-for-byte against the base when off.

## Build, test, install

See [references/toolchain.md](references/toolchain.md) for setup. Day to day:

- **Build:** `./build.sh` (JieLi clang via `tools/build.py`). It fails loudly
  with the reason (image/RAM/pool too big, a ROM-range constant, a register
  touched outside `hal/`).
- **Host tests:** `sh tests/run_host.sh` — run after every engine change.
- **Web emulator:** `sh web/build_web.sh` (compiles to WebAssembly);
  `node web/test_web.mjs` checks the emulator + editor against the host build.
- **On the device** (needs Windows/macOS Chrome/Edge — `python-rtmidi` has no
  WSL ALSA): `tools/fm1_install.py pkg.fwsc`, `tools/fm1_cpu.py --health`.

## Release + Firmware Hub

Full flow in [references/hub-submission.md](references/hub-submission.md). Order:

1. `tools/prep_release.sh X.Y` — bumps version everywhere, rebuilds card/screens,
   web emulator, and hub data.
2. Commit, then `git tag vX.Y && git push origin vX.Y`. The `release.yml`
   workflow builds via `zvenson/fm1-build@v1`, runs host tests, signs a build
   attestation ("Built from source" badge), and publishes the `.fwsc`.
3. Keep `fmhub.json` at the repo root (what/author/kinds/play/image/color).
4. Email the hub (`zven@thefirmwarehub.com`) **only after** a real-device test
   is documented and 1.0 is published.

## Guardrails

- Keep the upstream copyright and licence headers; add your changes as a second
  credit line. Fill `LICENSING.md` with every borrowed source.
- Check the chosen `FM-1_9NN` id is free in the hub catalog
  (`thefirmwarehub.com/catalog.json`) before committing to it.
- Never publish or email on the user's behalf without explicit confirmation.
- The pool (reverb/delay/grain/tape buffers) is nearly full on the base; to fit
  new engines, drop sources that don't fit the theme rather than growing it.
