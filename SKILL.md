# sota-present — State-of-the-Art Presentations

> Generate HTML slide decks, Feishu whiteboard SVGs, and interactive code
> courses from a single content description with coordinated aesthetics.

## Trigger

Activate when the user asks to create, design, or generate:
- A slide deck / presentation / slides / PPT
- A whiteboard diagram / Feishu whiteboard / SVG diagram
- A code walkthrough / codebase course / tutorial from code
- Any combination of the above

## Mode Detection

Determine output mode from user intent:

| Signal | Mode |
|--------|------|
| "slides", "deck", "presentation", "PPT", "演示", "幻灯片" | `slides` |
| "whiteboard", "feishu", "SVG diagram", "画板", "白板" | `whiteboard` |
| "course", "tutorial", "walkthrough", "课程", "教程" | `course` |
| Multiple signals or ambiguous | `dual` or ask the user |

If the user wants **both** HTML slides and whiteboard SVGs, set mode to `dual`.

## Workflow (All Modes)

### Phase 1: Preflight

Run `scripts/preflight.sh` to validate environment (Node.js ≥ 20, Python 3, optional lark-cli/whiteboard-cli).

### Phase 2: Content Discovery

Ask the user (or infer from context):
1. **Purpose** — pitch / teaching / conference / internal / personal
2. **Length** — 5-10 / 10-20 / 20+ slides (or modules for course)
3. **Content readiness** — full content / notes / topic only
4. **Density** — low (speaker-led) / high (reading-first)

### Phase 3: Style Selection ("show, don't tell")

1. Read `catalog/styles.json`
2. Match styles against mood/occasion/tone from content
3. Generate **3 distinct single-slide HTML previews** using real content
4. Present previews to user; let them pick
5. If mode is `dual`, the selected style provides BOTH an HTML template
   and a whiteboard palette — guaranteed aesthetic coordination

### Phase 4: Route to Sub-Skill

Based on mode, read the corresponding sub-skill files and follow their workflow:

| Mode | Files to Read |
|------|---------------|
| `slides` | `skills/TASTE.md` + `skills/SLIDES.md` |
| `whiteboard` | `skills/TASTE.md` + `skills/WHITEBOARD.md` |
| `course` | `skills/TASTE.md` + `skills/COURSE.md` |
| `dual` | `skills/TASTE.md` + `skills/SLIDES.md` + `skills/WHITEBOARD.md` + `skills/STYLE-SYSTEM.md` |

**Always read `skills/TASTE.md`** — design quality rules apply to all modes.

### Phase 5: Generate

Follow the sub-skill workflow to produce output in `output/<mode>/`.

### Phase 6: Validate & Deliver

- **Slides**: open in browser, run anti-slop checklist
- **Whiteboard**: run `scripts/whiteboard-cli.sh` for SVG validation + PNG export + optional Feishu upload
- **Course**: run `scripts/build-course.sh` for assembly + local preview
- **Dual**: validate both outputs, verify color coordination

### Phase 7: Share & Export (Optional)

- Preview HTML locally via `scripts/serve.sh`
- Publish HTML to a public URL via the **lark-apps** skill (飞书妙搭 / Miaoda) — this is the deployment path in a Feishu-centric environment
- Export PDF via Playwright
- Upload SVG to Feishu whiteboard via lark-cli

## Design Quality Rules (Always Active)

Before generating ANY output, internalize `skills/TASTE.md`. Non-negotiable:
- DESIGN_VARIANCE ≥ 6/10 (avoid generic layouts)
- MOTION_INTENSITY matched to mode (see table below)
- All banned patterns from TASTE.md are forbidden
- Typography rules enforced (no system font stacks as display, no Inter/Roboto)
- Anti-AI-tells checklist passed before delivery

## Design Dials Quick Reference

| Dial | Slides | Whiteboard | Course |
|------|--------|------------|--------|
| DESIGN_VARIANCE | 7 | 5 | 6 |
| MOTION_INTENSITY | 7 | 0 | 4 |
| VISUAL_DENSITY | 6 | 8 | 5 |

## Canvas Constraints Quick Reference

| | Slides | Whiteboard | Course |
|--|--------|------------|--------|
| Dimensions | 1920×1080 fixed | 1600-1700px width | Responsive |
| Fonts | Google Fonts | system-ui only | Google Fonts |
| Colors | CSS custom props | Inline hex | CSS custom props |
| Animation | GSAP timelines | None (static) | CSS + JS |

## File Reference

| File | Purpose | When to Read |
|------|---------|-------------|
| `skills/TASTE.md` | Anti-slop design rules | Always |
| `skills/SLIDES.md` | HTML slide generation (7-phase) | mode=slides or dual |
| `skills/WHITEBOARD.md` | Feishu SVG generation | mode=whiteboard or dual |
| `skills/COURSE.md` | Code course generation (4-phase) | mode=course |
| `skills/STYLE-SYSTEM.md` | Design token architecture | mode=dual, or style debugging |
| `catalog/styles.json` | Unified style catalog (69 styles) | Phase 3 |
| `catalog/slides-index.json` | Slide template details | During slide generation |
| `catalog/whiteboard-index.json` | Palette details | During whiteboard generation |
| `catalog/course-index.json` | Course theme details | During course generation |

## Template Statistics

(Counts verified against `catalog/` on 2026-06-03.)

- **HTML slide templates**: 46 indexed in `slides-index.json` (34 gallery + 12 presets). An additional 34-template "bold pack" is available in `catalog/bold-templates-original.json` (not yet merged into the main index).
- **Whiteboard palettes**: 35 in `whiteboard-index.json` (Restrained → Balanced → Bold). Note: upstream `beautiful-feishu-whiteboard` advertises 37 — 2 palettes were dropped during import; reconcile if needed.
- **Course themes**: 7 in `course-index.json`.
- **Verified dual-mode pairings**: 12 styles flagged `verified_dual` in `styles.json` (slides + whiteboard aesthetic match confirmed): editorial-forest, bold-poster, block-frame, monochrome, raw-grid, neo-grid-bold, coral, pin-and-paper, soft-editorial, grove, long-table, stencil-tablet.
