---
description: Walk the FM-1 firmware to a signed Firmware Hub release.
argument-hint: <version, e.g. 1.0>
---

Prepare release **$ARGUMENTS** of this FM-1 firmware. Use the
**synth-firmware** skill (`references/hub-submission.md`). Do the preparatory,
reversible steps; **stop and ask me** before anything outward-facing.

Checklist:

1. Confirm the device test is documented (`docs/TEST-RESULTS-1.0.md`) and 1.0
   builds + host tests pass. If not, say what's missing and stop.
2. Run `tools/prep_release.sh $ARGUMENTS` (version everywhere, card, screens,
   emulator, hub). Show me the `git diff`.
3. Confirm `fmhub.json`, `CHANGELOG.md`, `release.yml`, and `pages.yml` are in
   place and correct.

**Then stop.** These are mine to approve, one at a time — do not do them for me:

- `git commit`, `git tag v$ARGUMENTS`, `git push origin v$ARGUMENTS`
- turning on GitHub Pages
- emailing the hub (`docs/HUB-EMAIL.md` → `zven@thefirmwarehub.com`)

List exactly what I should run or click, in order.
