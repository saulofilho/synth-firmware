# The phase model

A firmware grows in phases. Each assumes the previous one builds and the host
tests pass. This is the order COQUI followed; adapt the content to your theme,
keep the order.

## Phase 0 — Environment

Goal: you can compile the **base** firmware (unmodified fork) and its host tests
pass, before changing anything.

- Install the JieLi toolchain and AC79 SDK (see `toolchain.md`).
- Clone the base firmware at a pinned version. Build it. Run `tests/run_host.sh`.
- Record the resource budget (image, RAM `.data`+`.bss`, pool, stack) of the
  unmodified base — this is your baseline. The pool is usually the tight one.

## Phase 1 — Identity

Goal: the firmware is unmistakably yours and installs as its own package, with
no collision with the base's saves.

- **Name** and a free identity `FM-1_9NN` — check `thefirmwarehub.com/catalog.json`.
- **Own store magics** (4-char tags for project/slot/song/sound) so the base's
  saves are not read as yours.
- `APP_NAME`, **boot screen**, and **colour palette** from the theme.
- Accept **both** flash IDs (`0x856014`, `0xB36014`) in app, rescue, and loader.
- A compatibility note: installing the base over you and back must work.
- Credits in `LICENSING.md`.

## Phase 2 — Sound engine

Goal: the core instrument. For COQUI this was synthesized percussion (congas,
bongos, timbales, cowbell, clave, güiro, shaker, cajón, kicks/snares).

- Keep voices **synthesized** where you can — samples eat pool; synthesis
  barely touches it, leaving the sample slots free for the user.
- Measure cost per voice with `fm1_ticks()`. Budget to stay under 2.9 ms audio
  at the worst realistic polyphony.
- Add one engine `.c` at a time; rerun host tests each time.

## Phase 3 — Patterns + Hub

Goal: the performance layer, plus a public page people can hear.

- A **pattern / groove** system that runs on the sequencer clock, saved into the
  project (bump the on-disk track version) and into sounds.
- The **hub** (`hub/`, GitHub Pages): animated boot scene, the patterns with a
  playable grid and audio rendered *from the firmware itself*
  (`tools/gen_hub.py`), install + controls. Turn Pages on once (Settings → Pages
  → Source: GitHub Actions).
- The **web emulator** (`hub/emu/`): the firmware compiled to WebAssembly
  (`web/build_web.sh`), base page adapted. `node web/test_web.mjs --emulator`
  checks sound + screens against host.
- The **web editor** (`hub/emu/editor.html`): adapt the base editor to your
  marks, colours, and formats.

## Phase 4 — Melodic

Goal: pitched material that plays with the groove.

- New ARP/arpeggiator modes: lines of 1–2 bars over the degrees of a held chord
  (one key → a major chord), on the sequencer's bar.
- FM/patch work: rename and retune the base's sounds to your theme; let
  bass/harmony patches carry their line on load.
- Add a host test for the new lines (e.g. `latin_arp_test.py`).

## Phase 5 — Mood

Goal: the generative and atmospheric character, and the idle screen.

- A **GENERATE** mode (decides notes per sub-beat with positional weight).
- An **AMBIENCE** page: scenes layered over the *existing* effects — no new DSP
  or pool.
- A **HOME / idle** screen that expresses the theme.
- A host test for the generator (e.g. `gen_clave_test.py`).

## Phase 6 — Release

Goal: a signed, documented, device-tested 1.0 on the Firmware Hub. See
`hub-submission.md`.

- `.github/workflows/release.yml` (tag → GitHub builds via `zvenson/fm1-build@v1`,
  runs tests, signs attestation, publishes `.fwsc`).
- `.github/workflows/pages.yml` for the hub.
- `tools/prep_release.sh X.Y` (version, card, screens, emulator, hub).
- `fmhub.json`, `CHANGELOG.md`, a device-test script (`docs/TESTE-FM1.md`), and
  the hub email draft (`docs/HUB-EMAIL.md`).
- **Test on a real FM-1**, document it (`docs/TEST-RESULTS-1.0.md`), then tag and
  email the hub.
