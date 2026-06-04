# PPTX — Editable PowerPoint Generation

> Compile content into a native, editable `.pptx` (PowerPoint / WPS / Keynote),
> coloured from the same style tokens as the HTML and whiteboard engines.
> Output: `output/pptx/<name>.pptx` — real text frames and shapes, not images.

## What this engine is for

Use `pptx` mode when the user wants an **editable source file** they can open and
tweak in PowerPoint / WPS / Keynote, rather than a self-contained HTML deck.
It is the third compilation target of a chosen style: same palette and fonts,
different container.

It is **not** a pixel-perfect copy of the HTML deck. PowerPoint has no CSS,
absolute-position bento, or web animation; this engine renders a clean, native,
on-brand deck using the style's tokens and a set of editable layout archetypes.

## Pipeline (spec → builder → .pptx)

Generation is **spec-driven** so the output is deterministic and editable:

1. Pick a style from `catalog/styles.json` (Phase 3 of SKILL.md).
2. Write a slide spec as JSON (see format below) from the user's real content.
3. Run the builder:
   ```bash
   python3 scripts/build-pptx.py --style <style-id> --spec <spec.json> --out output/pptx/<name>.pptx
   ```
   For Chinese content set the CJK face (default `PingFang SC`):
   ```bash
   python3 scripts/build-pptx.py --style bold-signal --spec deck.json --out output/pptx/deck.pptx --cjk-font "PingFang SC"
   ```
4. Validate / preview (see below), then deliver the `.pptx`.

**Dependency:** `python-pptx` (`pip install python-pptx`). Optional: LibreOffice
(`soffice`) to render the `.pptx` to PNG for a preview.

## Spec format

```json
{
  "title": "Deck title",
  "slides": [
    { "type": "cover",   "eyebrow": "...", "title": "...", "title_size": 80, "subtitle": "...", "footer": "..." },
    { "type": "agenda",  "heading": "...", "items": ["...", "..."] },
    { "type": "section", "num": "01", "title": "...", "subtitle": "..." },
    { "type": "content", "heading": "...", "lead": "...", "bullets": ["...", "..."] },
    { "type": "two_col", "heading": "...", "left_title": "...", "left": ["..."], "right_title": "...", "right": ["..."] },
    { "type": "stat",    "heading": "...", "items": [{ "value": "10¹²", "label": "..." }] },
    { "type": "statement","text": "Big punchy line", "size": 54, "sub": "..." },
    { "type": "closing", "title": "...", "title_size": 60, "subtitle": "..." }
  ]
}
```

| Slide type | Use for |
|---|---|
| `cover` | Title slide: eyebrow + big display title + subtitle + footer |
| `section` | Chapter divider with a large accent number |
| `agenda` | Numbered list of topics |
| `content` | Heading + optional lead + accent-marked bullets |
| `two_col` | Side-by-side comparison (two surface cards) |
| `stat` | 2–4 big numbers with captions |
| `statement` | One large punch line (accent side-bar) |
| `closing` | Final CTA / takeaway |

## Token mapping

The builder pulls these from the selected style's `tokens` and applies them as
literal values (PowerPoint has no CSS variables):

| Token | Used for |
|---|---|
| `color_bg` | slide background |
| `color_primary` | display titles, key text |
| `color_accent` | bars, bullet markers, section numbers, eyebrows |
| `color_surface` | card fills (two_col) |
| `color_text` / `color_text_muted` | body / secondary text |
| `font_heading` | display/title font (Latin) |
| `font_body` | body font (Latin) |
| `--cjk-font` | East-Asian face for CJK glyphs (set per run) |

## Font caveat (important)

A `.pptx` only **references** font names; it does not embed them by default.
The deck displays correctly only if the viewer has those fonts installed:
- Latin display fonts (e.g. Archivo Black, Source Serif 4) must be installed,
  or PowerPoint substitutes a default.
- CJK text uses the `--cjk-font` (default `PingFang SC` on macOS). For Windows/
  cross-platform sharing prefer a widely available face (e.g. `Microsoft YaHei`
  or `Noto Sans SC`) via `--cjk-font`.
- To guarantee fidelity when sending externally, embed fonts in PowerPoint
  (File → Options → Save → Embed fonts) or export a PDF.

## Design quality (TASTE applies)

Even though PowerPoint is editable, the same `TASTE.md` rules hold:
- Real content, no placeholder text.
- Distinctive fonts from the style (no Inter/Roboto as display).
- Locked palette; off-black/off-white from tokens, not pure #000/#fff.
- Left-aligned editorial layouts and generous margins; avoid centred-everything.
- MOTION_INTENSITY is effectively 0 (no gratuitous transitions).

## Validation

- Reopen with `python-pptx` and confirm slide count + that text frames contain
  real runs (editable), not images.
- If LibreOffice is available:
  ```bash
  soffice --headless --convert-to pdf --outdir output/pptx output/pptx/<name>.pptx
  ```
  to preview, or convert to PNG per slide.
- Open in PowerPoint / WPS / Keynote and confirm text is editable and on-palette.

## Limitations

- No bento/absolute-position fidelity to the HTML deck — this is a native deck.
- Charts/data-viz are simple (numbers + captions); for rich charts, build them in
  the HTML engine or add native PowerPoint charts manually after generation.
- Font display depends on the viewer's installed fonts (see caveat).
