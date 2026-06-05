# PPTX — Editable PowerPoint Generation (profile-driven)

> Compile distilled content into a native, editable `.pptx` (PowerPoint / WPS /
> Keynote), styled by a **design profile** so the deck carries the chosen style's
> design DNA. Output: `output/pptx/<name>.pptx` — real text frames and shapes.

## How it works (content → profile → layout → output)

1. **Distill content** into a format-agnostic *deck spec* (see format below):
   pull the key points out of the source material, ≤ ~8-word headlines, one idea
   per slide, real content only, **zero em-dashes**. Cut ruthlessly; split rather
   than shrink.
2. **Pick a style** from `catalog/styles.json` by tone (Phase 3 of SKILL.md). If
   the style has a **design profile** (`catalog/profiles/<id>.json`) the deck gets
   that style's real type scale, colour roles, chrome and component treatments.
   Styles without a profile fall back to a token-derived default (still valid).
3. **Build** (the builder does the layout):
   ```bash
   python3 scripts/build-pptx.py --style <style-id> --spec <spec.json> --out output/pptx/<name>.pptx --cjk-font "PingFang SC"
   ```
4. **Validate / preview** (see below), then deliver the `.pptx`.

**Styles that currently have a polished profile** (best results, presentation-grade):
`editorial-forest` (serif, cream) · `bold-poster` (poster, offset shadow) ·
`monochrome` (light minimal) · `blue-professional` (corporate blue) ·
`swiss-modern` (grid/grotesque) · `neo-grid-bold` (bold, lemon) ·
`soft-editorial` (soft rounded) · `cobalt-grid` (cobalt, dark-ground) ·
`stencil-tablet` (stencil/mono) · `vellum` (warm minimal).
Any other catalog style works via the token default but looks plainer.

**Dependency:** `python-pptx`. Optional: LibreOffice (`soffice`) for PNG/PDF preview.

## Deck-spec format

```json
{
  "title": "Deck title (used in footline)",
  "slides": [
    { "type": "cover",   "eyebrow": "...", "title": "...", "subtitle": "...", "footer": "..." },
    { "type": "section", "num": "01", "title": "...", "subtitle": "..." },
    { "type": "agenda",  "heading": "...", "items": ["...", "..."] },
    { "type": "content", "heading": "...", "lead": "...", "bullets": ["...", "..."] },
    { "type": "two_col", "heading": "...", "left_title": "...", "left": ["..."], "right_title": "...", "right": ["..."] },
    { "type": "stat",    "heading": "...", "items": [{ "value": "3×", "label": "..." }] },
    { "type": "statement","text": "One punchy line", "sub": "..." },
    { "type": "quote",   "text": "...", "attribution": "..." },
    { "type": "closing", "title": "...", "subtitle": "..." }
  ]
}
```

Keep card titles in `two_col` SHORT (they sit in a fixed title zone). Keep
`stat` values short (`3×`, `500`, `1年+`). Headlines ≤ 8 words.

## What the profile drives (so you don't hand-tune the builder)

The builder reads `catalog/profiles/<id>.json` for: the **type-scale** (semantic
roles hero/display/headline/eyebrow/body/bullet/caption/stat_number/stat_unit/
quote/card_title, each with pt + weight + face + em-tracking + leading +
transform), **colour roles** per ground (`bg` + an alternate `bg_alt` used for
section/statement so dark-ground flips read correctly), **fonts** (display/body/
mono + CJK faces set as the East-Asian run font), **spacing** (margins, gaps,
card padding, radii, rule weights), **components** (heading rule, bullet marker
shape, card border/fill, footline, page number), **depth** (flat vs offset
shadow), **decor** motifs, and machine-enforced **rules** (no em-dash, locked
accent, off-black/white, mono uppercase, body not bold, single-weight display
faces not faux-bolded). Hierarchy is guaranteed by the type-scale contrast +
colour roles + a contrast guard.

## Font caveat

A `.pptx` only references fonts; it does not embed them. Display/CJK faces must
be installed on the viewer or PowerPoint substitutes. CJK uses `--cjk-font`
(default `PingFang SC`; for Windows sharing prefer `Microsoft YaHei` or a Noto
face). To guarantee fidelity externally, embed fonts in PowerPoint or export PDF.

## Validation

- Reopen with python-pptx; confirm slide count + that text frames hold real runs
  (editable), not images.
- Preview: `soffice --headless --convert-to pdf --outdir output/pptx output/pptx/<name>.pptx`
  then `pdftoppm -png -r 110 <pdf> out`, and eyeball.
- `scripts/stress-test.py` validates every profile's schema + a profiled build.

## Fidelity target

Same design **DNA**, native layout — not a pixel copy of the HTML deck.
PowerPoint can't reproduce HTML bento/absolute-overlap, `clamp()` fluid type,
optical-size axes, web fonts, or tilted display type. Flat and offset-shadow
styles reproduce faithfully; correct fonts/weights/tracking, real type-scale
contrast, colour-role hierarchy, consistent chrome and component treatments are
all carried by the profile.

## Adding a profile for another style

Profiles live in `catalog/profiles/<id>.json`. To add one, read the style's
`templates/slides/gallery/<id>/design.md`, distill it into the schema (use
`catalog/profiles/editorial-forest.json` as the reference example; see
`docs/PROFILE-SCHEMA.md`), then add `profile_ref: "<id>"` under the style's
`capabilities.slides` in `catalog/styles.json`.
