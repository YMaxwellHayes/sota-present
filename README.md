<div align="center">

# sota-present

**Turn one content description into polished HTML slide decks, editable PowerPoint files, and Feishu whiteboards — with coordinated aesthetics and built-in taste.**

A [Claude Code](https://docs.claude.com/en/docs/claude-code) Skill for state-of-the-art presentations.

English · [简体中文](./README.zh-CN.md)

<img src="docs/preview/showcase.png" alt="sota-present showcase — HTML slide decks, an editable PowerPoint, and a Feishu whiteboard" width="820">

<sub>Two HTML slide styles, an editable PowerPoint (bottom-left), and a Feishu whiteboard (bottom-right) — three output formats from one skill, all on coordinated palettes.</sub>

</div>

---

## What it is

`sota-present` is a Claude Code Skill. You describe your content once, and Claude produces presentation material in **three output formats**:

- 🎞️ **HTML slide decks** — single self-contained file, zero dependencies, fixed 1920×1080 stage with keyboard / touch / wheel navigation.
- 📊 **Editable PowerPoint (.pptx)** — a native, fully editable source file (PowerPoint / WPS / Keynote): real text frames and shapes, not images.
- 🖼️ **Feishu (Lark) whiteboard SVGs** — compliant with Feishu's strict renderer, rendered as *editable* whiteboard objects, ready to drop into a Feishu doc.

Ask for more than one and you get them from the same content, sharing one palette so they look like a family.

## Why use it

Most "ask an AI to make slides" attempts produce the same tell-tale slop: indigo accents, Inter everywhere, centered card grids, purple gradients, em-dashes. `sota-present` exists to fix three problems at once:

| Problem | How `sota-present` solves it |
|---|---|
| **AI design looks generic** | A non-negotiable anti-slop rule layer (`TASTE`) bans the tells (Inter/Roboto as display, generic indigo, centered-everything, em-dashes, fake screenshots…) and runs a pre-flight checklist before delivery. |
| **Multi-channel rework + style drift** | One content description compiles to HTML, editable PowerPoint, and Feishu whiteboard from a single shared design-token system, so the formats stay on one palette instead of drifting apart. |
| **Platform constraints are painful** | Feishu's whiteboard renderer has brutal rules (no `<path>`, no gradients, no opacity, single font). `sota-present` encodes them as rules + a validator, so you get an uploadable, editable whiteboard without learning the renderer. |

It is a **scaffold for taste, assets, and platform-fit** — not a black box. Content depth and correctness still come from you and Claude; what the skill guarantees is a higher quality floor and cross-output consistency.

## Quick start

```bash
npx skills add YMaxwellHayes/sota-present
```

Then just ask Claude Code, in natural language:

```
"Make a 12-slide HTML deck on our Q3 strategy."
"Make an editable PowerPoint of our Q3 strategy."
"Draw a Feishu whiteboard of our system architecture."
"Make a tech-talk deck plus a matching Feishu whiteboard of the architecture."
```

**Requirements:** Node.js ≥ 20, Python 3. Optional: `python-pptx` (editable .pptx), `lark-cli` + `@larksuite/whiteboard-cli` (push whiteboards into Feishu), LibreOffice (.pptx preview), `librsvg`/`cairosvg` (SVG→PNG). Run `bash scripts/preflight.sh` to check.

## Usage

### HTML slides
Claude detects `slides` mode, shows you 3 distinct style previews built from your real content, you pick one, and it generates the full deck into `output/slides/`.

### Editable PowerPoint
Claude detects `pptx` mode, turns your content into a slide spec, and runs `scripts/build-pptx.py` (python-pptx) to compile a native, fully editable `.pptx` into `output/pptx/` using the chosen style's palette and fonts. Open and edit it in PowerPoint / WPS / Keynote.

### Feishu whiteboard
Claude detects `whiteboard` mode, picks a matching palette, writes a constraint-compliant SVG, validates it with `scripts/whiteboard-cli.sh`, and can embed it into a Feishu doc as an editable whiteboard (via the `lark-doc` / `lark-whiteboard` skills).

### Combined (coordinated)
Ask for more than one. For HTML + whiteboard, Claude prefers a `verified_dual` style so they share one palette and read as a coordinated set; the same tokens also drive the PowerPoint engine.

## How it works

A layered architecture keeps the three output engines independent but consistent:

```
        TASTE (anti-slop rules)  +  STYLE-SYSTEM (shared design tokens)
                              │  the shared spine
        ┌─────────────────────┼─────────────────────┐
   HTML engine           PPTX engine          Feishu whiteboard engine
   (SLIDES.md)           (PPTX.md)            (WHITEBOARD.md)
        │                     │                       │
  gallery/preset       python-pptx builder     palette catalog + SVG rules
   templates           (native .pptx)
```

- `skills/TASTE.md` — anti-AI-slop design rules (applied to all paths).
- `skills/SLIDES.md` — 7-phase HTML slide workflow, fixed 1920×1080 stage.
- `skills/PPTX.md` — editable PowerPoint via the spec-driven `build-pptx.py`.
- `skills/WHITEBOARD.md` — Feishu SVG generation under the renderer's hard rules.
- `skills/STYLE-SYSTEM.md` — the design-token bridge that keeps the outputs in sync.
- `catalog/` — the curated style/template/palette indexes.

## What's inside

| Asset | Count |
|---|---|
| Curated styles (`styles.json`) | **69** |
| HTML slide templates (indexed) | **46** (34 gallery + 12 presets) |
| Feishu whiteboard palettes | **35** |
| Verified dual-mode pairings | **12** (HTML + whiteboard guaranteed to match) |

## Quality & testing

`scripts/stress-test.py` is a reproducible code-path stress harness covering catalog integrity, all 35 palettes through the SVG validator, validator precision (good SVGs pass, 9 classes of bad SVG rejected), all 34 gallery templates rendering non-blank, and script smoke tests. Current status: **26/26 checks pass, 34/34 templates render.**

```bash
python3 scripts/stress-test.py            # full (renders templates)
python3 scripts/stress-test.py --no-render # fast (skip Chrome renders)
```

## License

[MIT](./LICENSE).
