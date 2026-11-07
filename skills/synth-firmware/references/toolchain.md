# Toolchain & environment

## What you need

- **JieLi Linux toolchain** (`pi32v2` clang). Default location
  `~/.jieli/toolchain`. COQUI fetches it with `tools/get_toolchain.sh`.
- **JieLi AC79 SDK** checkout. Default `~/fw-AC79_AIoT_SDK`.
- **Python** with **Pillow** (the build renders the boot screen/card).
  COQUI uses a project `.venv` created with `uv`.
- **Docker** — only if you build on something other than Linux x86_64; the build
  runs the toolchain in a container there.

The build reads two env vars (both have the defaults above):

```sh
export JIELI_TOOLCHAIN="$HOME/.jieli/toolchain"
export AC79_SDK="$HOME/fw-AC79_AIoT_SDK"
```

## Building

```sh
./build.sh                 # debug/local build
./build.sh --release 1.0   # version stamped in
```

`build.sh` checks Pillow, the toolchain, and the SDK are present, then runs
`tools/build.py`. It fails with a one-line reason when a chip rule is broken (see
`chip-rules.md`).

## Testing

```sh
sh tests/run_host.sh          # host tests — run after every engine change
APP_VER=1.0 sh tests/run_host.sh
sh web/build_web.sh           # compile to WebAssembly
node web/test_web.mjs         # emulator + editor vs host build
```

## On the device

`python-rtmidi` does not load under WSL (no `libasound`). Flash and inspect the
FM-1 from **Windows or macOS** with Python **3.12** (newer Pythons have no
`python-rtmidi` wheel yet):

```sh
py -3.12 -m pip install mido python-rtmidi
py -3.12 tools/fm1_install.py --info        # see the connected FM-1 and its mode
py -3.12 tools/fm1_install.py pkg.fwsc       # flash a package
py -3.12 tools/fm1_cpu.py --health           # live CPU / voices / mix
py -3.12 tools/fm1_cpu.py --once             # one snapshot
```

The FM-1 reports its identity over USB (`FM-1_9NN` for a firmware, `FM-1_0NN` for
the factory V-firmware, `ota-FM-1_9NN` in update mode). Both flash IDs
(`0x856014`, `0xB36014`) must be accepted so newer units flash.

## The tools (COQUI set — keep or adapt)

| Tool | Does |
| --- | --- |
| `tools/build.py` | the build (called by `build.sh`) |
| `tools/get_toolchain.sh` | fetch the JieLi toolchain |
| `tools/gen_tables.py` | host-computed constant tables → `firmware/gen/` |
| `tools/gen_hub.py` | rebuild hub data + audio from the firmware |
| `tools/gen_pixfont.py`, `gen_samples.py`, `gen_fm_patches.py` | asset/patch generation |
| `tools/fm1_install.py` | flash a `.fwsc` / query the device |
| `tools/fm1_cpu.py` | live CPU + voices on the device |
| `tools/fm1_sample_upload.py` | push user samples |
| `tools/prep_release.sh` | stamp a version across build, tests, card, emulator, hub |
| `tools/stack_check.py` | worst-case stack |
