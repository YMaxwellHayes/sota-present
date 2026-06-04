# TASTE — Anti-Slop Design Rules

> Design quality rules that apply to ALL output modes (slides, whiteboard).
> Read this file FIRST, before any other sub-skill.

## Three Design Dials

Every generation starts with three dials (0-10). Defaults by mode:

| Dial | Slides | Whiteboard |
|------|--------|------------|
| DESIGN_VARIANCE | 7 | 5 |
| MOTION_INTENSITY | 7 | 0 |
| VISUAL_DENSITY | 6 | 8 |

- **DESIGN_VARIANCE**: 1=conservative/corporate, 10=experimental/art-directed
- **MOTION_INTENSITY**: 0=static, 10=maximum animation. Whiteboard is always 0 (SVG is static)
- **VISUAL_DENSITY**: 1=spacious/minimal, 10=information-dense

## Banned Patterns (Anti-AI-Tells)

### Typography Bans
- ❌ Inter, Roboto, Arial, Helvetica as display fonts
- ❌ System font stacks for headlines
- ❌ Using the same font for heading and body
- ✅ Use distinctive display fonts: Fraunces, Cormorant Garamond, Syne, Archivo Black, etc.
- ✅ Pair display serif/sans with clean sans-serif body

### Color Bans
- ❌ Generic indigo (#6366f1) as primary accent
- ❌ Purple-to-pink gradients on white backgrounds
- ❌ Pure black (#000) on pure white (#FFF) — use off-black (#1a1a1a) and off-white (#fafafa)
- ❌ More than 3 accent colors in one piece
- ✅ One strong accent + 1-2 supporting colors
- ✅ Dark backgrounds with carefully chosen light text, or warm light backgrounds

### Layout Bans
- ❌ Everything centered (hero section with centered text + button)
- ❌ Generic card grids (3 equal cards side by side)
- ❌ Cards-inside-cards (nested rounded rectangles)
- ❌ Same padding/margin everywhere
- ✅ Asymmetric layouts: bento grids, editorial splits, Z-axis overlap
- ✅ Deliberate whitespace hierarchy
- ✅ Break the grid intentionally

### Content Bans
- ❌ Em-dashes (—) everywhere
- ❌ Section numbers ("01", "02", "03" as decoration)
- ❌ Fake product screenshots or mockup images
- ❌ "Scroll down" cues or arrow animations
- ❌ Generic stock-photo-style illustrations
- ❌ Lorem ipsum or placeholder text
- ✅ Real content, real data
- ✅ Decorative elements that serve a purpose

### Decoration Bans
- ❌ Gratuitous glassmorphism (frosted glass cards)
- ❌ Purposeless drop shadows
- ❌ Gradient text (unless the style specifically calls for it)
- ❌ Hand-rolled SVG illustrations (blobs, leaves, organic shapes)
- ❌ Confetti, stars, or random decorative elements
- ✅ Shadows only when they communicate depth/hierarchy
- ✅ Decorative elements that reinforce the content message

## Typography Rules

### Font Selection
1. **Display font**: Choose from curated list (see STYLE_PRESETS.md or template's design.md)
2. **Body font**: Clean, readable sans-serif (different family from display)
3. **Mono font**: For code/technical content (JetBrains Mono, Fira Code, IBM Plex Mono)

### Type Scale
- Use dramatic scale contrast: very large headings (80-200px) vs small body (16-24px)
- Never use sizes between 14-18px for body text in 1920×1080 canvas
- Line height: 1.4-1.6 for body, 1.0-1.2 for display headings
- Letter spacing: negative for large display (-0.02em to -0.04em), positive for small caps (+0.05em)

### Italic Rules
- Italic descenders (g, j, p, q, y) need extra bottom clearance
- Never clip italic descenders with overflow:hidden
- Add padding-bottom: 0.2em on italic display text

## Color Consistency Lock

Once a palette is chosen, lock it for the entire piece:
1. **One primary accent** — used for CTAs, highlights, key elements
2. **1-2 supporting colors** — used for secondary elements, backgrounds, borders
3. **Background/text pair** — must pass WCAG AA contrast (4.5:1 minimum)
4. **No color drift** — every element uses a color from the locked palette

## Motion Rules (Slides only)

### Allowed
- transform: translate, scale, rotate
- opacity transitions
- GSAP ScrollTrigger for scroll-based reveals
- Staggered entrance animations (0.1-0.2s between elements)
- Ease: cubic-bezier(0.16, 1, 0.3, 1) (expo-out)

### Banned
- Scroll event listeners that trigger React state updates (use CSS or GSAP)
- Animation on layout properties (width, height, top, left)
- More than 3 different animation types in one piece
- Infinite looping animations (except subtle background effects)

### Motion Skeleton (GSAP)
```javascript
// Sticky stack scroll
gsap.to(".stack-item", {
  y: (i) => i * -100,
  scale: (i) => 1 - i * 0.05,
  opacity: (i) => 1 - i * 0.3,
  stagger: 0.2,
  scrollTrigger: {
    trigger: ".stack-container",
    start: "top top",
    end: "+=200%",
    scrub: true,
    pin: true
  }
});
```

## Layout Archetypes

### Asymmetric Bento
- Grid with unequal cell sizes
- One dominant cell (2x2) + several smaller cells
- Content density varies by cell

### Editorial Split
- Two-column layout with different content density
- Left: large type, sparse
- Right: dense content or imagery

### Z-Axis Overlap
- Elements overlap with deliberate z-ordering
- Background decorative elements behind content
- Cards that break out of their container

### Full-Bleed Type
- Typography that extends to or beyond canvas edges
- Used for impact slides or section headers
- Clipped text as design element

## Pre-Flight Checklist (Before Delivery)

- [ ] No banned patterns remain (check all 4 ban categories)
- [ ] Typography uses distinctive fonts (not system defaults)
- [ ] Color palette is locked and consistent
- [ ] Layout uses at least one non-centered, non-grid archetype
- [ ] Motion serves purpose (no gratuitous animation)
- [ ] All text is real content (no lorem ipsum)
- [ ] Contrast passes WCAG AA (4.5:1 for body, 3:1 for large text)
- [ ] Design dial values match the mode defaults (or user's preference)
- [ ] No em-dashes in visible text
- [ ] No fake screenshots or mockup images
