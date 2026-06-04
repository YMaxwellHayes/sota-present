# STYLE-SYSTEM — Unified Design Token Architecture

> The connective tissue between HTML slides and Feishu whiteboard SVGs.
> Read this file in `dual` mode to ensure aesthetic coordination across both outputs.

## Token Layers

### Layer 1: Abstract Tokens

These are the canonical token names. Every style defines values for these.

```
Colors:
  --color-primary        Main brand/accent color
  --color-secondary      Supporting color
  --color-accent         Highlight/CTA color
  --color-bg             Page/slide background
  --color-surface        Card/panel background
  --color-text           Primary text
  --color-text-muted     Secondary/caption text
  --color-border         Borders and dividers

Typography:
  --font-heading         Display font family (with weight)
  --font-body            Body text font family (with weight)
  --font-mono            Monospace font for code

Spacing:
  --spacing-unit         Base unit (default: 8px)
  --radius-sm            Small border radius (4px)
  --radius-md            Medium border radius (8px)
  --radius-lg            Large border radius (16px)

Motion:
  --motion-duration      Base animation duration (400ms)
  --motion-easing        Default easing curve

Density:
  --density-padding      Base padding multiplier
  --density-gap          Base gap multiplier
```

### Layer 2: Resolved Tokens (Per Style)

Example for "Corporate Aurora" style:

```json
{
  "color_primary": "#2563EB",
  "color_secondary": "#1E40AF",
  "color_accent": "#7C3AED",
  "color_bg": "#F8FAFC",
  "color_surface": "#FFFFFF",
  "color_text": "#0F172A",
  "color_text_muted": "#64748B",
  "color_border": "#E2E8F0",
  "font_heading": "\"Fraunces\", serif",
  "font_body": "\"DM Sans\", sans-serif",
  "font_mono": "\"JetBrains Mono\", monospace",
  "spacing_unit": "8px",
  "radius_sm": "4px",
  "radius_md": "8px",
  "radius_lg": "16px",
  "motion_duration": "400ms",
  "motion_easing": "cubic-bezier(0.16, 1, 0.3, 1)"
}
```

### Layer 3: Format-Specific Compilation

#### HTML (CSS Custom Properties)
```css
:root {
  --color-primary: #2563EB;
  --color-secondary: #1E40AF;
  --font-heading: "Fraunces", serif;
  /* ... all tokens as CSS vars */
}

.slide-title {
  font-family: var(--font-heading);
  color: var(--color-primary);
}
```

#### Feishu SVG (Inline Literal Values)
```xml
<!-- SVG doesn't support CSS custom properties in Feishu's renderer -->
<!-- Tokens must be resolved to literal values. Never set font-family. -->
<rect fill="#2563EB" rx="8" width="400" height="200"/>
<text fill="#0F172A" font-size="24">Title</text>
```

## Cross-Format Font Mapping

HTML can use Google Fonts. Feishu SVG cannot — it ignores any `font-family` and
renders everything in Noto Sans SC, so **never set `font-family` in SVG**.
Convey the font's **personality** through size, weight, and letter-spacing instead:

| HTML Font | Personality | SVG (font-family omitted) |
|-----------|-------------|---------------------------|
| Fraunces | Elegant serif | larger size, generous letter-spacing |
| DM Sans | Clean modern sans | default weight, neutral spacing |
| JetBrains Mono | Technical mono | uppercase labels, wide tracking |
| Archivo Black | Bold display | bold weight, tight tracking |

In SVG, compensate for the font limitation with:
- Careful font-size selection
- letter-spacing adjustments
- font-weight variations
- text-transform (uppercase for display impact)

## Cross-Format Color Coordination

The color story MUST be identical across formats:

```
Selected style: "Midnight Executive"
  primary:   #1a1a2e  (deep navy)
  secondary: #16213e  (midnight)
  accent:    #e94560  (coral red)
  bg:        #0f0f1a  (near black)
  text:      #eaeaea  (soft white)
```

This palette flows to:
- **HTML**: `:root { --color-primary: #1a1a2e; ... }`
- **SVG**: `<rect style="fill:#1a1a2e" ...>`

The visual result: same mood, same story, different canvas.

## Style Matching Algorithm

When the user requests `dual` mode:

1. Read `catalog/styles.json`
2. Filter styles where both `capabilities.slides` AND `capabilities.whiteboard` exist
3. Score each style against user's mood/occasion/tone
4. Prefer `verified_dual: true` styles (manually curated pairings)
5. Present top 3 with descriptions of BOTH the slide template and whiteboard palette
6. After user picks, extract tokens and flow to both pipelines

### Fallback Pairing

If no verified dual style matches well:
1. Pick the best HTML template match
2. Find a whiteboard palette in the same color family
3. Override palette colors with the HTML template's token colors
4. Warn user: "This is a generated pairing, not manually curated"

## Intensity Spectrum

Whiteboard palettes are grouped by intensity (from CATALOG.md):

| Intensity | Palette Count | Characteristics |
|-----------|---------------|-----------------|
| Restrained | 12 | Muted, professional, subtle contrast |
| Balanced | 12 | Moderate color, versatile, business-casual |
| Bold | 11 | High contrast, vibrant, expressive |

Match intensity to DESIGN_VARIANCE dial:
- DV 1-3 → Restrained palettes
- DV 4-6 → Balanced palettes
- DV 7-10 → Bold palettes

## Shadow Rules

### HTML
- Use CSS box-shadow with token-defined elevation levels
- Soft shadows: `0 4px 6px -1px rgba(0,0,0,0.1)`
- Hard shadows (neobrutalist): `4px 4px 0 var(--color-text)`

### SVG (Feishu)
- **Only hard offset shadows**: duplicate the shape, offset +10-12px x/y, paint behind
- **No blur, no filter, no opacity** — Feishu doesn't support them
- Shadow color: use a darker shade from the palette (not black with opacity)
