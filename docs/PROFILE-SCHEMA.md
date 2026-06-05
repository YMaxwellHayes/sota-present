# PPTX Design Profile — schema & authoring guide

A **design profile** (`catalog/profiles/<id>.json`) tells the PPTX engine
(`scripts/build-pptx.py`) how to render a style as a native, editable deck that
carries that style's design DNA. It is distilled, by hand or subagent, from the
style's `templates/slides/gallery/<id>/design.md` (the authoritative spec) plus
its `tokens` in `catalog/styles.json`.

Use **`catalog/profiles/editorial-forest.json`** as the canonical worked example
— copy its shape exactly.

## Required top-level keys
`id`, `ground_default`, `grounds`, `fonts`, `type_scale`, `spacing`,
`components`, `depth`, `decor`, `rules`. Optional: `section_ground`,
`statement_ground`, `cover_ground` (default to `bg`/`bg_alt`).

## Field reference (all values are RESOLVED literals — no clamp/CSS-vars/placeholders)

- **`grounds`**: map of ground → colour roles. Always define `bg` (main content
  ground) and `bg_alt` (the dramatic/inverse ground used by section/statement/
  quote). Each ground has: `fill, heading, body, muted, accent, surface, border`.
  On a dark ground, `heading`/`body` flip to light and `accent` to the bright
  brand hue. The engine's contrast guard repairs any role that doesn't separate
  ≥ 0.16 luminance from `fill`, but author them right.
- **`fonts`**: `display`, `body`, `mono` (Latin family names, first family only),
  `cjk`, `cjk_mono` (East-Asian faces set as the `a:ea` run font), and
  `single_weight_display` (true for Shrikhand / Archivo Black / Bungee / stencil
  faces with no usable bold).
- **`type_scale`**: the semantic roles `hero, display, headline, eyebrow, body,
  bullet, caption, stat_number, stat_unit, quote, card_title`. Each =
  `{ pt, weight, face("display"|"body"|"mono"), tracking(em), leading, transform("none"|"upper") }`.
  - **px → pt**: design.md sizes are at a 1920px stage; PPTX is 960pt wide →
    **pt = px × 0.5**. (vw sizes: px = vw × 19.2, then × 0.5.)
  - **weight**: the engine bolds a role ONLY if `weight ≥ 600` and the face isn't
    single-weight. Keep elegant medium display weights (400-500) low so big serif
    renders refined, not faux-bold. Never bold body (`body_max_weight`).
  - **body readability**: if the design's body computes below ~15pt, bump to 16-17.
- **`spacing`**: `margin_x, margin_top, margin_bottom, gap_card, gap_bullet,
  card_pad` (inches); `radius_card` (rounded-rect fraction, 0 = square, ~0.05 soft,
  ~0.09 very soft); `rule_pt, rule_card_pt` (hairline weights).
- **`components`**: `footline, pageno, heading_rule` (bool); `marker`
  (`square|circle|dash|bar|none`); `card_border` (bool) + `card_fill` (role name,
  usually `surface`); `monogram` (bool).
- **`depth`**: `mode` `flat` or `offset`; `shadow` bool; for offset:
  `offset_dx, offset_dy` (inches), `offset_color` (role). Use `offset` only when
  the design has a stacked offset shadow (e.g. bold-poster).
- **`decor`**: small motif list, e.g. `{ "type": "edge_bar", "where": "cover", "color": "accent" }`.
- **`rules`**: `no_em_dash, lock_accent, off_black_white, mono_upper,
  body_max_weight, display_force_bold` — machine-enforced by the renderer.

## 12-step distillation checklist (design.md → profile)
1. Copy `colors` → `grounds.bg` roles; pick the darkest/brand tone for `grounds.bg_alt.fill` and flip text light.
2. Identify the display + body + mono `fontFamily` → `fonts`.
3. Decide `single_weight_display` from the display face.
4. Pick a CJK face matching the body voice (serif → Noto Serif SC; sans → Noto Sans SC; mono chrome → Noto Sans Mono CJK SC).
5. Map the biggest display size → `hero`; section size → `display`; content heading → `headline`.
6. Map the mono label → `eyebrow`; smallest mono → `caption`.
7. Map body/body-card → `body`/`bullet` (bump to 16-17pt if tiny).
8. Map the stat figure + unit → `stat_number`/`stat_unit`; pull-quote → `quote`; card title → `card_title`.
9. Convert every px → pt (× 0.5); keep `tracking` in em; keep `leading` from lineHeight.
10. Read Depth: flat vs offset → `depth`.
11. Read components/Do's-Don'ts: set `marker`, `card_border/fill`, `radius_card`, rule weights, and the `rules` block.
12. Validate the JSON parses; add `profile_ref: "<id>"` under the style's `capabilities.slides` in `styles.json`; run `python3 scripts/stress-test.py --no-render` (schema check) and build + render once to eyeball.
