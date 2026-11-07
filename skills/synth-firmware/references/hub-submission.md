# Release & FM-1 Firmware Hub submission

## Release workflow

Two GitHub Actions workflows (from COQUI, keep the shape):

**`.github/workflows/release.yml`** — a tag `vX.Y` triggers a build with the
hub's shared, reviewed workflow, which runs the host tests, signs a build
attestation (the hub's "Built from source" badge), and publishes the `.fwsc`:

```yaml
name: release
on:
  push:
    tags: ['v*']
jobs:
  build:
    uses: zvenson/fm1-build/.github/workflows/build.yml@v1
    permissions:
      contents: write
      id-token: write
      attestations: write
    with:
      build: ./build.sh --release "${GITHUB_REF_NAME#v}"
      packages: build/*.fwsc
```

A tag below `1.0`, or with `-rc` / `-beta`, is a **beta** on the hub.

**`.github/workflows/pages.yml`** — publishes `hub/` to GitHub Pages on pushes
that touch `hub/**`. The hub's data/audio are generated beforehand
(`tools/gen_hub.py`) and committed; the workflow only publishes. Turn Pages on
once: Settings → Pages → Source: **GitHub Actions**.

## Cutting a release

```sh
tools/prep_release.sh 1.0      # version everywhere + card + screens + emulator + hub
git diff                       # review
git commit -am "Release 1.0"
git tag v1.0 && git push origin v1.0
```

Verify the attestation after the workflow publishes:

```sh
gh attestation verify coqui-1.0.fwsc --repo <owner>/<repo> \
  --signer-workflow zvenson/fm1-build/.github/workflows/build.yml
```

## fmhub.json (repo root)

The hub reads this, not the email. Text, image, and links live here:

```json
{
  "what": "One or two sentences describing the firmware.",
  "author": "<name as it should appear>",
  "kinds": ["groove"],
  "play": "https://<owner>.github.io/<repo>/emu/",
  "image": "docs/card.png",
  "color": "#FF2D8A"
}
```

## The device test (required before submitting)

Document a real-FM-1 test in `docs/TEST-RESULTS-1.0.md` (in English — the hub is
English). Cover: install from the factory V-firmware and from another firmware,
leaving again by installing another firmware over yours, answering your
`FM-1_9NN` over USB, an interrupted update resumed by the installer, the USB
rescue working, and the heaviest scene's audio-CPU peak (`fm1_cpu.py`).

## The hub email

Send **only after** the device test is documented and 1.0 is published. Draft it
in `docs/HUB-EMAIL.md`. To `zven@thefirmwarehub.com`. Links, not attachments.
Include: firmware name, author name as it should appear, repo link, the
`FM-1_` identity, the licence, that it was tested on a real FM-1, and that both
flash IDs are accepted. **Never send it without the user's explicit go-ahead.**
