# sota-present — State-of-the-Art Presentations

> Generate HTML slide decks and Feishu whiteboard SVGs from a single content
> description, with coordinated aesthetics across both outputs.

## Trigger

Activate when the user asks to create, design, or generate:
- A slide deck / presentation / slides / PPT
- A whiteboard diagram / Feishu whiteboard / SVG diagram
- Both of the above from the same content

## Mode Detection

Determine output mode from user intent:

| Signal | Mode |
|--------|------|
| "slides", "deck", "presentation", "PPT", "演示", "幻灯片" | `slides` |
| "whiteboard", "feishu", "SVG diagram", "画板", "白板" | `whiteboard` |
| Both signals, or "同时", or ambiguous | `dual` (or ask) |

If the user wants **both** HTML slides and whiteboard SVGs, set mode to `dual`.

## Workflow

### Phase 1: Preflight

Run `scripts/preflight.sh` to validate environment (Node.js ≥ 20, Python 3, optional lark-cli/whiteboard-cli).

### Phase 2: Content Discovery

Ask the user (or infer from context):
1. **Purpose** — pitch / teaching / conference / internal / personal
2. **Length** — 5-10 / 10-20 / 20+ slides
3. **Content readiness** — full content / notes / topic only
4. **Density** — low (speaker-led) / high (reading-first)

### Phase 3: Style Selection ("show, don't tell")

1. Read `catalog/styles.json`
2. Match styles against mood/occasion/tone from content
3. Generate **3 distinct single-slide HTML previews** using real content
4. Present previews to user; let them pick
5. If mode is `dual`, prefer a `verified_dual` style — the selected style then
   provides BOTH an HTML template and a whiteboard palette, guaranteeing
   aesthetic coordination across the two outputs

### Phase 4: Route to Sub-Skill

Based on mode, read the corresponding sub-skill files and follow their workflow:

| Mode | Files to Read |
|------|---------------|
| `slides` | `skills/TASTE.md` + `skills/SLIDES.md` |
| `whiteboard` | `skills/TASTE.md` + `skills/WHITEBOARD.md` |
| `dual` | `skills/TASTE.md` + `skills/SLIDES.md` + `skills/WHITEBOARD.md` + `skills/STYLE-SYSTEM.md` |

**Always read `skills/TASTE.md`** — design quality rules apply to both modes.

### Phase 5: Generate

Follow the sub-skill workflow to produce output in `output/<mode>/`.

### Phase 6: Validate & Deliver

- **Slides**: open in browser, run anti-slop checklist (see TASTE.md)
- **Whiteboard**: run `scripts/whiteboard-cli.sh` for SVG rule validation + PNG export
- **Dual**: validate both outputs, verify color coordination

### Phase 7: Share & Export (Optional)

- Preview HTML locally via `scripts/serve.sh`
- Publish HTML to a public URL via the **lark-apps** skill (飞书妙搭 / Miaoda)
- Export slides to PDF via Playwright
- Create a Feishu doc with the whiteboard:
  embed the SVG via lark-doc's `<whiteboard type="svg">…</whiteboard>` in
  `docs +create --api-version v2` (one step → doc + editable whiteboard), then
  verify with `lark-cli whiteboard +query --output_as image`

## Design Quality Rules (Always Active)

Before generating ANY output, internalize `skills/TASTE.md`. Non-negotiable:
- DESIGN_VARIANCE ≥ 6/10 (avoid generic layouts)
- MOTION_INTENSITY matched to mode (see table below)
- All banned patterns from TASTE.md are forbidden
- Typography rules enforced (no system font stacks as display, no Inter/Roboto)
- Anti-AI-tells checklist passed before delivery

## Design Dials Quick Reference

| Dial | Slides | Whiteboard |
|------|--------|------------|
| DESIGN_VARIANCE | 7 | 5 |
| MOTION_INTENSITY | 7 | 0 |
| VISUAL_DENSITY | 6 | 8 |

## Canvas Constraints Quick Reference

| | Slides | Whiteboard |
|--|--------|------------|
| Dimensions | 1920×1080 fixed | 1600-1700px width |
| Fonts | Google Fonts | none set (Feishu → Noto Sans SC) |
| Colors | CSS custom props | Inline solid hex |
| Animation | GSAP timelines | None (static) |

## File Reference

| File | Purpose | When to Read |
|------|---------|-------------|
| `skills/TASTE.md` | Anti-slop design rules | Always |
| `skills/SLIDES.md` | HTML slide generation (7-phase) | mode=slides or dual |
| `skills/WHITEBOARD.md` | Feishu SVG generation | mode=whiteboard or dual |
| `skills/STYLE-SYSTEM.md` | Design token architecture | mode=dual, or style debugging |
| `catalog/styles.json` | Unified style catalog (69 styles) | Phase 3 |
| `catalog/slides-index.json` | Slide template details | During slide generation |
| `catalog/whiteboard-index.json` | Palette details | During whiteboard generation |

## Template Statistics

(Counts verified against `catalog/` on 2026-06-03.)

- **HTML slide templates**: 46 indexed in `slides-index.json` (34 gallery + 12 presets). An additional 34-template "bold pack" lives in `catalog/_source/bold-templates-original.json` (raw import dump, not yet merged into the main index).
- **Whiteboard palettes**: 35 in `whiteboard-index.json` (Restrained → Balanced → Bold). Note: upstream `beautiful-feishu-whiteboard` advertises 37 — 2 palettes were dropped during import; reconcile if needed.
- **Verified dual-mode pairings**: 12 styles flagged `verified_dual` in `styles.json` (slides + whiteboard aesthetic match confirmed): editorial-forest, bold-poster, block-frame, monochrome, raw-grid, neo-grid-bold, coral, pin-and-paper, soft-editorial, grove, long-table, stencil-tablet.
