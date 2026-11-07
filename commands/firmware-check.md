---
description: Lint the firmware source for FM-1 chip-rule violations (float, 64-bit division, etc.).
argument-hint: [path, default firmware/src] (optional)
---

Scan the FM-1 firmware source for the chip-rule violations that cause link
failures, crashes, or audio glitches (see the **synth-firmware** skill,
`references/chip-rules.md`).

Target: **${ARGUMENTS:-firmware/src}**

Run the plugin's linter and read its output:

```sh
sh ${CLAUDE_PLUGIN_ROOT}/hooks/check-chip-rules.sh "${ARGUMENTS:-firmware/src}"
```

Then review each hit yourself — the grep is a prompt, not a verdict. Confirm for
each: is it a real `float`/`double`, a genuine 64-bit `/` or `%`, a hardware
register touched outside `hal/`, or work that shouldn't be inside `app_audio()`?
Report the real violations with file:line and a fix, and dismiss the false
positives (e.g. `float` in a comment, a 32-bit division). Finish by running
`./build.sh` — it is the authority on image/RAM/pool size and ROM-range
constants.
