---
description: Scaffold a new FM-1 firmware from a theme/genre, modeled on COQUI.
argument-hint: <theme or genre, e.g. "forró baiano" or "detroit techno">
---

Start a new M-VAVE FM-1 firmware with the theme: **$ARGUMENTS**

Use the **synth-firmware** skill. Before writing code, settle the opening
decisions with me (do not assume — ask where unknown):

1. **Base fork** — GR!MM, zp12, or bare Felucca BSP, and the exact version.
   Match its licence.
2. **Mood & palette** — the feel and colour palette that `$ARGUMENTS` implies.
3. **Scope of 1.0** — the shortlist of genres/engines that ship first.
4. **Identity** — propose a free `FM-1_9NN` (check
   `thefirmwarehub.com/catalog.json`), store magics, and `APP_NAME`.
5. **Repo** — where it lives; local git only until I say to publish.

Then lay out **Phase 0 (environment)** and **Phase 1 (identity)** as the plan,
and confirm with me before building. Do not skip to engine work.
