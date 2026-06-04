# COURSE — Code-to-Course Generation Workflow

> 4-phase workflow for transforming codebases into interactive single-page HTML courses.
> Output: self-contained HTML with scroll-snap modules and interactive elements.

## Philosophy

- **"Build first, understand later"** — start with what the software DOES, then explain the code
- **"Show don't tell"** — 50%+ visual content per screen
- **"Quizzes test doing, not memorizing"** — scenario-based, not definition-based
- **Original code only** — never simplified examples, always real code from the codebase
- **No recycled metaphors** — find fresh analogies specific to this codebase

## Phase 1: Codebase Analysis

### Deep Reading
Scan the target codebase to extract:
1. **Components and responsibilities** — what each module/file does
2. **Data flows** — how information moves between components
3. **Design patterns** — architectural choices (MVC, pub/sub, pipeline, etc.)
4. **Tech stack** — languages, frameworks, libraries, tools
5. **"Teachable moments"** — interesting patterns, clever solutions, common pitfalls

### Build a Module Graph
```
[User-facing behavior] → [Feature modules] → [Core abstractions] → [Infrastructure]
```

This inverted structure ensures the learner starts with what they can see/experience.

## Phase 2: Curriculum Design

### Structure 4-6 Modules
Each module is a scroll-snap section:

```markdown
Module 1: "What This Does" — user-facing behavior, the "why"
Module 2: "How It's Built" — architecture overview, component map
Module 3: "The Core Engine" — the most interesting/important code
Module 4: "Data Flow" — how information moves through the system
Module 5: "Key Patterns" — reusable engineering patterns found
Module 6: "Going Deeper" — extension points, testing, deployment
```

### Plan Interactive Elements (4-6 types per course)

Choose from 17 available types:

| # | Element | Best For |
|---|---------|----------|
| 1 | **Code ↔ English Translation** | Side-by-side real code + plain English |
| 2 | **Multiple-Choice Quiz** | Instant feedback, per-question explanations |
| 3 | **Drag-and-Drop Matching** | Match concepts to descriptions |
| 4 | **Group Chat Animation** | iMessage-style chat between code components |
| 5 | **Message/Data Flow Animation** | Step-by-step data movement |
| 6 | **Interactive Architecture Diagram** | Hover/click components for descriptions |
| 7 | **Layer Toggle Demo** | Tab between HTML/CSS/JS layers |
| 8 | **"Spot the Bug" Challenge** | Click the buggy code line |
| 9 | **Scenario Quiz** | "What would a senior engineer do?" |
| 10 | **Callout Boxes** | "Aha!" moments, key CS insights |
| 11 | **Pattern/Feature Cards** | Grid cards for engineering patterns |
| 12 | **Flow Diagrams** | Horizontal step sequences with arrows |
| 13 | **Permission/Config Badges** | Annotated config/permission listings |
| 14 | **Glossary Tooltips** | Hover/tap plain-English definitions |
| 15 | **Visual File Tree** | Annotated directory structure |
| 16 | **Icon-Label Rows** | Visual concept listings with colored icons |
| 17 | **Numbered Step Cards** | Visual sequential steps |

### Write Module Briefs (for complex projects)

For each module, write a brief before generating:

```markdown
## Module Brief: [Title]
- **Key insight**: One sentence the learner must walk away with
- **Code files**: Which files to feature
- **Interactive elements**: Which 2-3 types to use
- **Analogy**: Fresh metaphor for this concept
- **Quiz concept**: What to test (doing, not memorizing)
```

## Phase 3: Design System Setup

### Load Base Files
1. Copy `templates/course/base/styles.css` — complete course CSS
2. Copy `templates/course/base/main.js` — interactive element engine
3. Read `skills/TASTE.md` for design quality rules

### Inject Tokens
Apply the selected style's tokens to `:root` in styles.css:

```css
:root {
  --color-primary: /* from style */;
  --color-secondary: /* from style */;
  --color-accent: /* from style */;
  --color-bg: /* from style */;
  --font-heading: /* from style */;
  --font-body: /* from style */;
  --font-mono: /* from style */;
}
```

### Course-Specific Design Rules
- **Scroll-snap**: Each module is a full-viewport section
- **Progress tracking**: Fixed top nav with scroll progress bar
- **Dot navigation**: Side dots for each module, clickable
- **Keyboard**: Arrow keys for module navigation
- **Responsive**: Breakpoints at 768px and 480px
- **DESIGN_VARIANCE**: 6 (moderately creative)
- **MOTION_INTENSITY**: 4 (subtle, non-distracting)

## Phase 4: Content Generation

### HTML Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Course Title — Codebase Course</title>
  <!-- Google Fonts for heading + body + mono -->
  <style>
    /* Inlined styles.css with token overrides */
  </style>
</head>
<body>
  <nav class="course-nav">
    <!-- Fixed top nav with progress bar + dot navigation -->
  </nav>

  <main class="course-main">
    <!-- Module 1 -->
    <section class="module" id="module-1" data-label="What This Does">
      <!-- Content with semantic class names -->
      <!-- Interactive elements use class + data-* attributes -->
    </section>

    <!-- Module 2 -->
    <section class="module" id="module-2" data-label="How It's Built">
      <!-- ... -->
    </section>

    <!-- More modules... -->
  </main>

  <footer class="course-footer">
    <!-- Generated by sota-present from [codebase name] -->
  </footer>

  <script>
    /* Inlined main.js */
  </script>
</body>
</html>
```

### Module Content Rules
- Each `<section class="module">` contains only `<section>` elements
- **No inline `<style>` or `<script>`** — all CSS/JS is in the base files
- Interactive elements auto-initialize via class names + `data-*` attributes
- Code snippets use `<pre><code>` with syntax highlighting classes
- All images must have meaningful `alt` text

### Interactive Element Examples

#### Code ↔ English Translation
```html
<div class="code-translation">
  <div class="code-panel">
    <pre><code class="language-javascript">
app.get('/api/users', async (req, res) => {
  const users = await db.query('SELECT * FROM users');
  res.json({ data: users });
});
    </code></pre>
  </div>
  <div class="english-panel">
    <p>When someone visits /api/users:</p>
    <ol>
      <li>Ask the database for all users</li>
      <li>Wrap the result in a {data: ...} object</li>
      <li>Send it back as JSON</li>
    </ol>
  </div>
</div>
```

#### Multiple-Choice Quiz
```html
<div class="quiz-container" data-quiz-id="q1">
  <h3 class="quiz-question">What happens if the database query fails?</h3>
  <div class="quiz-options">
    <button class="quiz-option" data-correct="false">The server crashes</button>
    <button class="quiz-option" data-correct="true">An unhandled promise rejection occurs</button>
    <button class="quiz-option" data-correct="false">The user gets a 404</button>
  </div>
  <div class="quiz-explanation" data-show="after-answer">
    Without try/catch or .catch(), a failed query becomes an unhandled rejection.
  </div>
</div>
```

#### Group Chat Animation
```html
<div class="group-chat" data-chat-id="chat1">
  <div class="chat-header">
    <span class="chat-participant">🗄️ Database</span>
    <span class="chat-participant">⚙️ API Server</span>
    <span class="chat-participant">🖥️ Browser</span>
  </div>
  <div class="chat-messages">
    <div class="message" data-from="browser" data-delay="0">
      GET /api/users
    </div>
    <div class="message" data-from="server" data-delay="1000">
      SELECT * FROM users
    </div>
    <div class="message" data-from="database" data-delay="2000">
      [{ id: 1, name: "Alice" }, ...]
    </div>
    <div class="message" data-from="server" data-delay="3000">
      { data: [...] } → 200 OK
    </div>
  </div>
</div>
```

## Phase 5: Assembly & Validation

### Assembly
The final HTML is a single self-contained file:
1. Base CSS (styles.css) with token overrides inlined
2. Module content sections
3. Base JS (main.js) inlined at the bottom
4. No external dependencies (works offline)

### Validation Checklist
- [ ] All modules scroll-snap correctly
- [ ] Progress bar updates on scroll
- [ ] Dot navigation works (click + scroll sync)
- [ ] All interactive elements used respond correctly
- [ ] Quizzes show correct/incorrect feedback
- [ ] Drag-and-drop works on both mouse and touch
- [ ] Code snippets have syntax highlighting
- [ ] Mobile responsive (768px, 480px breakpoints)
- [ ] No broken images or missing alt text
- [ ] Anti-slop checklist from TASTE.md passed
- [ ] Typography uses distinctive fonts
- [ ] Color palette consistent across all modules

### Delivery
1. Save to `output/course/index.html`
2. Open in browser for preview
3. Run `scripts/serve.sh course` for local server
4. Iterate on feedback
