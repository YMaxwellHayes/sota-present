# SLIDES — HTML Slide Generation Workflow

> 7-phase workflow for generating self-contained HTML slide presentations.
> Output: single `.html` file with inline CSS/JS, zero external dependencies.

## Fixed 16:9 Stage Architecture (NON-NEGOTIABLE)

Every presentation uses this exact model:

```html
<div class="deck-viewport">
  <div class="deck-stage">
    <section class="slide active" data-label="01 Title">...</section>
    <section class="slide" data-label="02 Content">...</section>
    <!-- ... more slides ... -->
  </div>
</div>
```

```css
.deck-viewport {
  position: fixed;
  inset: 0;
  overflow: hidden;
  background: var(--color-bg);
}

.deck-stage {
  position: absolute;
  width: 1920px;
  height: 1080px;
  transform-origin: 0 0;
  /* JS scales this to fit viewport */
}

.slide {
  position: absolute;
  inset: 0;
  width: 1920px;
  height: 1080px;
  visibility: hidden;
  opacity: 0;
  transition: opacity 0.6s var(--motion-easing), visibility 0.6s;
}

.slide.active {
  visibility: visible;
  opacity: 1;
  z-index: 1;
}
```

JavaScript `SlidePresentation` class handles:
- **Stage scaling**: `scale = Math.min(viewportW/1920, viewportH/1080)`
- **Navigation**: arrow keys, space, page up/down, touch/swipe, mouse wheel
- **Slide transitions**: `.active` class toggling with staggered reveals

Read `assets/viewport-base.css` for the complete base CSS.
Read `assets/slide-presentation.js` for the complete JS class.

## Phase 1: Content Analysis

Parse user content into slide-worthy segments:
- One concept per slide (max 3-4 bullet points)
- Title slide + agenda + content slides + closing slide
- Rule of thumb: 1 slide per 1-2 minutes of speaking time
- Identify data that could be visualized (charts, diagrams, comparisons)

## Phase 2: Structure Design

Create a slide outline:

```markdown
Slide 1: Title — [presentation title, subtitle, author, date]
Slide 2: Agenda — [3-5 topic areas]
Slide 3: [Topic 1 title] — [key point + supporting data]
Slide 4: [Topic 1 detail] — [deeper dive, diagram or chart]
...
Slide N-1: Summary — [3-5 key takeaways]
Slide N: Closing — [CTA, contact, Q&A]
```

Assign layout archetypes to each slide:
- `cover` — title slide with large typography
- `content` — text-heavy with supporting visuals
- `content-image` — image + text split
- `data-viz` — chart, graph, or data table
- `comparison` — side-by-side analysis
- `quote` — large quote with attribution
- `closing` — CTA or contact info

## Phase 3: Template Loading

Based on the selected style from `catalog/styles.json`:

1. Read the template reference from `capabilities.slides.template_ref`
2. Load template file from `templates/slides/`
3. Extract `:root` CSS custom properties
4. Read `assets/viewport-base.css` and `assets/animation-patterns.css`
5. Read `assets/deck-stage.js` for the web component

## Phase 4: Token Injection

Replace the template's `:root` block with resolved tokens from the selected style:

```css
:root {
  --color-primary: /* from style tokens */;
  --color-secondary: /* from style tokens */;
  --font-heading: /* from style tokens */;
  --font-body: /* from style tokens */;
  /* ... all tokens from STYLE-SYSTEM.md */
}
```

Ensure Google Fonts `@import` matches the style's font choices.

## Phase 5: Content Population

Generate HTML for each slide using **absolute positioning** within the 1920×1080 canvas:

```html
<section class="slide s-cover" data-label="01 Title">
  <h1 class="title" style="position:absolute; top:320px; left:120px; font-size:96px;">
    Presentation Title
  </h1>
  <p class="subtitle" style="position:absolute; top:460px; left:120px; font-size:32px; color:var(--color-text-muted);">
    Subtitle or tagline goes here
  </p>
</section>
```

Layout rules:
- **Margins**: minimum 80px from any edge
- **Content zones**: define safe areas for text (avoid corners for critical content)
- **Visual hierarchy**: largest element = most important, use size to guide the eye
- **Whitespace**: at least 30% of each slide should be empty space
- **Type scale**: titles 80-200px, subtitles 32-48px, body 20-28px, captions 14-18px

## Phase 6: Motion & Polish

Add animations from `animation-patterns.css`:

```css
/* Entrance animations */
.reveal       { opacity: 0; transform: translateY(30px); }
.reveal-scale { opacity: 0; transform: scale(0.9); }
.reveal-left  { opacity: 0; transform: translateX(-50px); }
.reveal-blur  { opacity: 0; filter: blur(10px); }

.slide.active .reveal {
  opacity: 1;
  transform: none;
  transition: all var(--motion-duration) var(--motion-easing);
}

/* Stagger children */
.slide.active .reveal:nth-child(2) { transition-delay: 0.1s; }
.slide.active .reveal:nth-child(3) { transition-delay: 0.2s; }
.slide.active .reveal:nth-child(4) { transition-delay: 0.3s; }
```

Motion intensity dial (0-10):
- 0-3: Only basic fade transitions
- 4-6: Entrance reveals + slide transitions
- 7-10: Full GSAP timelines, parallax, 3D tilt, particle effects

## Phase 7: Validation & Delivery

### Anti-Slop Checklist
- [ ] No banned fonts (Inter, Roboto, system fonts as display)
- [ ] No banned colors (generic indigo, purple gradients)
- [ ] No centered-everything layouts
- [ ] No em-dashes in visible text
- [ ] No fake screenshots or placeholder images
- [ ] Typography scale has dramatic contrast
- [ ] At least one asymmetric/non-grid layout used
- [ ] Color palette locked and consistent across all slides

### Technical Validation
- [ ] 1920×1080 stage model correct
- [ ] Slide navigation works (keyboard + touch)
- [ ] All slides transition smoothly
- [ ] No horizontal/vertical scroll on viewport
- [ ] Print styles work (each slide on its own page)
- [ ] `prefers-reduced-motion` respected

### Delivery
1. Save to `output/slides/index.html`
2. Open in browser for user preview
3. Iterate on feedback
4. Optional: publish via lark-apps (飞书妙搭) or export PDF

## Slide Types Reference

| Type | Layout | Content |
|------|--------|---------|
| Cover | Full-bleed title, minimal | Title + subtitle + author |
| Section | Large type, accent color | Section divider |
| Content | Split or stacked | Text + bullet points |
| Content-Image | 50/50 or 60/40 split | Text + image/diagram |
| Data-Viz | Chart-centric | Chart + annotation |
| Comparison | Side-by-side | Two columns |
| Quote | Centered large text | Quote + attribution |
| Timeline | Horizontal or vertical | Sequential events |
| Grid | 2×2 or 3×3 | Equal cells with icons |
| Closing | CTA-focused | Contact, links, Q&A |

## CSS Gotchas

- Never negate CSS functions directly: `-clamp(...)` is silently dropped.
  Use `calc(-1 * clamp(...))` instead.
- `overflow: hidden` on italic display text will clip descenders.
  Add `padding-bottom: 0.2em`.
- `transform: scale()` on the stage means all child elements scale proportionally.
  Don't try to use `vw/vh` units inside slides — they won't scale with the stage.
- Use `will-change: transform` on animated elements for GPU acceleration.
