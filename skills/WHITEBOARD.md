# WHITEBOARD — Feishu SVG Generation Rules

> Generate SVG diagrams that render as editable objects in Feishu/Lark whiteboards.
> Output: `.svg` file compliant with Feishu's strict renderer constraints.

## Feishu SVG Renderer Constraints (HARD RULES)

These are non-negotiable. Violations will cause rendering failures in Feishu.

### Allowed Elements (Whitelist)
```xml
<rect>        — rectangles, rounded corners
<circle>      — circles
<ellipse>     — ellipses
<line>        — straight lines
<polyline>    — multi-segment straight lines
<text>        — text labels
<tspan>       — text spans (inside <text>)
<g>           — grouping
<defs>        — definitions (markers only)
<marker>      — arrowhead definitions
```

### Forbidden Elements (Blacklist)
```xml
❌ <polygon>          — ONLY allowed inside <marker> defs for arrowheads (see Arrow Rules); never as standalone content
❌ <path>             — no curves, no bezier, no arcs
❌ <filter>           — no blur, no drop-shadow filters
❌ <linearGradient>   — no gradients
❌ <radialGradient>   — no gradients
❌ <clipPath>         — no clipping
❌ <mask>             — no masks
❌ <pattern>          — no patterns
❌ <foreignObject>    — no HTML embedding
❌ <image>            — no embedded images
❌ <use>              — no symbol references
❌ <style>            — no CSS blocks (use inline styles)
```

### Attribute Constraints
- **Colors**: All solid hex values. No `rgba()`, no `hsl()`, no `opacity` attribute
- **For paler tints**: Use a lighter solid hex color, not transparency
- **Transforms**: Only `translate()`, `rotate()`, `scale()`. No `skewX/Y`, no `matrix()`
- **Font**: NEVER set `font-family` at all. Feishu's renderer ignores external fonts and falls back to its own default (Noto Sans SC); setting a family is silently dropped. Omit `font-family` entirely.
- **Styling**: All inline via `style=""` attribute. No `<style>` blocks, no class-based CSS

## Canvas Specifications

- **Width**: 1600-1700px logical coordinate space
- **Height**: Proportional to content (typically 900-1200px)
- **Margins**: Minimum 80px padding from all edges
- **No fixed dimensions**: Use viewBox, not width/height attributes on root `<svg>`

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 1200">
  <!-- content here -->
</svg>
```

## Text Layout Rules

### Character Width Estimation
- CJK characters: ~1em wide
- Latin characters: ~0.6em wide
- Numbers: ~0.6em wide

### Text Wrapping
SVG `<text>` doesn't auto-wrap. Use multiple `<tspan>` elements:

```xml
<text x="100" y="200" style="font-size:20px; fill:#333;">
  <tspan x="100" dy="0">First line of text</tspan>
  <tspan x="100" dy="28">Second line of text</tspan>
  <tspan x="100" dy="28">Third line of text</tspan>
</text>
```

### Typography Controls
- **Size**: Use font-size for hierarchy (title: 36-48px, label: 20-24px, body: 16-18px, caption: 12-14px)
- **Weight**: font-weight: "bold" or "normal"
- **Case**: text-transform: "uppercase" for labels
- **Spacing**: letter-spacing for display text
- **Never set font-family** (Feishu falls back to Noto Sans SC; any family you set is ignored)

## Shadow Rules

**Only hard offset shadows** — no blur, no filter.

To create a shadow:
1. Draw the shadow shape (same as the main shape) offset by +10-12px on x and y
2. Fill with a darker color from the palette (not black with opacity)
3. Draw the main shape on top

```xml
<!-- Shadow (painted first, behind) -->
<rect x="112" y="112" width="400" height="200" rx="12"
      style="fill:#c4b5a0;"/>

<!-- Main shape (painted second, on top) -->
<rect x="100" y="100" width="400" height="200" rx="12"
      style="fill:#FAF7F2; stroke:#2A241B; stroke-width:2;"/>
```

## Arrow Rules

Use `<marker>` definitions, never hand-drawn arrowhead polygons:

```xml
<defs>
  <marker id="arrowhead" markerWidth="10" markerHeight="7"
          refX="10" refY="3.5" orient="auto">
    <polygon points="0 0, 10 3.5, 0 7" style="fill:#333;"/>
  </marker>
</defs>

<line x1="100" y1="200" x2="400" y2="200"
      style="stroke:#333; stroke-width:2;"
      marker-end="url(#arrowhead)"/>
```

Note: `<polygon>` is allowed ONLY inside `<marker>` definitions for arrowheads.

## Palette Application

Read the selected palette from `catalog/whiteboard-index.json` or from the style's tokens.
Map palette colors to semantic roles:

| Role | Usage |
|------|-------|
| primary | Key nodes, main borders, headers |
| secondary | Supporting elements, secondary borders |
| accent | Highlights, callouts, important arrows |
| background | Canvas fill, large background areas |
| surface | Card/panel fills, node backgrounds |
| text | All text elements |
| text-muted | Captions, secondary labels |

## Diagram Types

### Flow/Pipeline
Sequential boxes connected by arrows, left-to-right or top-to-bottom.

### Architecture Map
System components as labeled boxes with connection lines showing data flow.

### Comparison
Side-by-side columns with matching rows for feature comparison.

### Timeline
Horizontal or vertical sequence of events with date/phase labels.

### Mind Map
Central node with radiating branches to sub-topics.

### Hierarchy
Top-down tree structure with parent-child relationships.

### Infographic
Mix of shapes, numbers, and text for data storytelling.

## Generation Workflow

1. **Plan the diagram**: Identify nodes, relationships, and hierarchy
2. **Choose layout**: Flow, grid, radial, or hierarchical
3. **Calculate positions**: Map nodes to x,y coordinates on the 1600×1200 canvas
4. **Apply palette**: Assign colors from the selected style's tokens
5. **Write SVG**: Compose using only allowed elements with inline styles
6. **Validate**: Run `scripts/whiteboard-cli.sh` for rule checking
7. **Export PNG**: Convert to PNG for preview
8. **Upload** (optional): Push to Feishu via lark-cli

## SVG Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 1200">

  <!-- Background -->
  <rect x="0" y="0" width="1600" height="1200" style="fill:#FAFAFA;"/>

  <!-- Title -->
  <text x="800" y="60" style="font-size:36px; font-weight:bold; fill:#1a1a1a; text-anchor:middle;">
    Diagram Title
  </text>

  <!-- Content nodes -->
  <!-- Shadow -->
  <rect x="112" y="132" width="300" height="180" rx="12" style="fill:#e0d5c5;"/>
  <!-- Node -->
  <rect x="100" y="120" width="300" height="180" rx="12"
        style="fill:#FFFFFF; stroke:#2563EB; stroke-width:2;"/>
  <text x="250" y="210" style="font-size:20px; font-weight:bold; fill:#0F172A; text-anchor:middle;">
    Node Title
  </text>
  <text x="250" y="250" style="font-size:14px; fill:#64748B; text-anchor:middle;">
    Description text
  </text>

  <!-- Arrows -->
  <defs>
    <marker id="arrow" markerWidth="10" markerHeight="7"
            refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" style="fill:#333;"/>
    </marker>
  </defs>
  <line x1="400" y1="210" x2="500" y2="210"
        style="stroke:#333; stroke-width:2;" marker-end="url(#arrow)"/>

</svg>
```

## Validation Checklist

- [ ] Only allowed elements used (no path, filter, gradient, clipPath)
- [ ] No `<style>` blocks — all styling inline
- [ ] No rgba/hsl colors — all solid hex
- [ ] No opacity attributes
- [ ] viewBox set correctly (1600-1700px width)
- [ ] 80px+ margins on all edges
- [ ] Text doesn't overflow its container shape
- [ ] All arrows use `<marker>` definitions
- [ ] Shadows are hard-offset only (no blur)
- [ ] Font-size hierarchy clear (title > label > body > caption)
