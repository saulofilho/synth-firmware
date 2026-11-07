# synth-firmware

A Claude Code **plugin** for building a firmware for the **M-VAVE FM-1**
groovebox — the JieLi AC791N chip on the **Felucca → SLOOP → GR!MM** platform —
from identity through a signed **FM-1 Firmware Hub** release.

Modeled on **[COQUI](https://github.com/saulofilho/coqui-fm1)**, a Latin and
Caribbean groovebox forked from GR!MM 2.0.2. COQUI is the worked reference the
skill points to; this plugin packages the *method* so the next firmware reuses
the phases, the chip rules, and the publishing flow.

## What's inside

| Piece | What it does |
| --- | --- |
| **Skill** `synth-firmware` | The playbook: the phase model, the AC791N chip rules, the toolchain, build/test/install, and the release + hub flow. Auto-loads when the task matches. References in `skills/synth-firmware/references/`. |
| **Agent** `firmware-builder` | A subagent you delegate a phase or an engine to ("add a cumbia groove"). Respects the rules, builds, runs host tests, never pushes or emails on its own. |
| **Command** `/firmware-new <theme>` | Scaffold a new firmware from a genre/theme. |
| **Command** `/firmware-phase [n]` | Work the next (or a named) phase. |
| **Command** `/firmware-check [path]` | Lint the source for chip-rule violations. |
| **Command** `/firmware-release <X.Y>` | Walk to a signed hub release (stops before anything outward-facing). |
| **Hook** (PostToolUse) | After an edit to firmware C/H, flags `float`/`double`, 64-bit division, and ROM-range constants early. Advisory, never blocks. |

## Install

From a local checkout, add it as a marketplace and install:

```sh
/plugin marketplace add /Users/saulofilho/Documents/dev/projetos-git/synth-firmware
```

```sh
/plugin install synth-firmware@synth-firmware
```

Or, once pushed to GitHub:

```sh
/plugin marketplace add saulofilho/synth-firmware
```

## Scope — honest about it

The skill encodes the FM-1/Felucca *method* at high fidelity: phases, chip
rules, toolchain, release, hub submission. It does **not** generate the DSP for a
new sound engine — that stays real engineering. The plugin accelerates the
skeleton, keeps the constraints, and gets the release right.

## Licence

GPL-3.0-only, matching the GR!MM / Felucca lineage it builds on.
