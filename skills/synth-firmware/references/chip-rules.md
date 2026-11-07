# The chip's rules (JieLi AC791N)

The FM-1 runs a JieLi AC791N with JieLi's own clang (`pi32v2`). Fast enough for a
lot of synth, but it has habits that cost firmware authors time. The build
catches most; respect them from the start anyway. These mirror COQUI's
`docs/RULES.md`.

## Integers only

- **No `float`, no `double`.** No FPU and no libgcc soft-float — the link fails.
  Fixed point instead: **Q15** (value × 32768) for levels, **Q12** for gains, a
  **32-bit phase** for oscillators.
- **No 64-bit division.** `int64_t` multiply is fine; `a / b` or `a % b` on
  64-bit values needs `__udivdi3`, which is absent → link fails. Shift, or divide
  32-bit values.
- **Division by zero does not crash** — it returns a wrong value (the trap is
  off, because the compiler may hoist a division ahead of the test guarding it).
  Test your divisors.
- **Compute constants on the host** and write them into the source as numbers.
  See `tools/gen_tables.py` → `firmware/gen/analog_tables.h`.

## What the build rejects

`./build.sh` fails, with the reason, when:

- the image, the RAM, or the pool is too big;
- code calls or loads an address in the chip ROM (`0xFFC00000..0xFFCFFFFF`). A
  constant that *looks* like one counts: `-32767 << 7` is `0xFFC00080`. Rework the
  arithmetic so that value never appears (clamp to another range, or shift after
  the clamp, not before);
- code outside `hal/` touches a hardware register (raw address, `volatile`
  pointer cast, inline asm) — put a helper in `hal/` and call it;
- code that runs while the flash is busy (`.ram_text`, the flash driver) calls
  anything.

## The audio interrupt

`app_audio()` has 5.8 ms for 256 frames, and less in practice (USB and the key
scan interrupt it). Late → the sound crackles; never ends → the watchdog resets.

- Do per-frame only what must be per-frame. Envelopes, filter coefficients, LFOs:
  once per block of 16 or 32 frames is plenty.
- Measure: `fm1_ticks()` before/after ÷ `FM1_TICKS_PER_US`. Under 2.9 ms leaves
  room.
- **Off costs nothing.** A feature switched off must cost **no** CPU — skip its
  code whole, tested once a block, never run at a level of 0 or through a filter
  that passes everything. Off, the sound is identical to the base byte-for-byte;
  the host tests compare it.
- Measure on the **FM-1**, not only on the host (`tools/fm1_cpu.py`). The device's
  compiler makes other code; check the loop in `build/*.dis` too.
- No flash, no screen, no `platform_poll()`, no waiting inside audio.
- Share with the main loop through `volatile`, one writer each. A 32-bit store is
  atomic; a struct is not — write the fields in an order safe to see half-done
  (set pitch before gate).

## The main loop

- Call `platform_poll()` at least every few ms (USB) and never less than every
  8 s (watchdog).
- Draw only what changed: a full screen is ~115 KB over SPI.
- A flash erase stops everything (sound too) for tens of ms. Save only in silence.

## When it crashes

A fault shows a red screen with three numbers: the vector, the **PC** (where it
happened), and the return address. Look the PC up in `build/*.dis`. Then it
restarts. If it crashes during boot twice, the FM-1 enters the USB rescue by
itself (hold `OCT-` at power-on), where the updater still works.
