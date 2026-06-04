#!/usr/bin/env bash
# Universal render dispatcher for sota-present
# Usage: render.sh <mode> <input> <style-id> [output-dir]

set -e

MODE=${1:?Usage: render.sh <slides|whiteboard|course> <input> <style-id> [output-dir]}
INPUT=${2:?Missing input file}
STYLE_ID=${3:?Missing style ID}
OUTPUT_DIR=${4:-output/$MODE}

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🎨 Render dispatcher"
echo "  Mode: $MODE"
echo "  Input: $INPUT"
echo "  Style: $STYLE_ID"
echo "  Output: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Extract tokens for selected style
echo "📋 Extracting design tokens..."
python3 << EOF
import json, sys

with open('$SCRIPT_DIR/catalog/styles.json', 'r') as f:
    styles = json.load(f)

style = next((s for s in styles['styles'] if s['id'] == '$STYLE_ID'), None)
if not style:
    print(f"❌ Style not found: $STYLE_ID")
    sys.exit(1)

tokens = style['tokens']
print(f"✅ Found style: {style['name']}")

# Output tokens as CSS custom properties
css = ":root {\n"
for key, value in tokens.items():
    css += f"  --{key.replace('_', '-')}: {value};\n"
css += "}\n"

with open('$OUTPUT_DIR/tokens.css', 'w') as f:
    f.write(css)

print(f"✅ Tokens written to $OUTPUT_DIR/tokens.css")
EOF

# Mode-specific rendering
case $MODE in
  slides)
    echo ""
    echo "🎞️  HTML Slides"
    echo "  1. Read SKILL.md and skills/SLIDES.md"
    echo "  2. Load template from catalog/slides-index.json"
    echo "  3. Apply tokens from $OUTPUT_DIR/tokens.css"
    echo "  4. Generate slides following 7-phase workflow"
    echo "  5. Output: $OUTPUT_DIR/index.html"
    ;;

  whiteboard)
    echo ""
    echo "🖼️  Feishu Whiteboard SVG"
    echo "  1. Read SKILL.md and skills/WHITEBOARD.md"
    echo "  2. Load palette from catalog/whiteboard-index.json"
    echo "  3. Generate SVG following Feishu renderer constraints"
    echo "  4. Validate with scripts/whiteboard-cli.sh"
    echo "  5. Output: $OUTPUT_DIR/*.svg"
    ;;

  course)
    echo ""
    echo "📚 Code Course"
    echo "  1. Read SKILL.md and skills/COURSE.md"
    echo "  2. Analyze codebase structure"
    echo "  3. Design curriculum (4-6 modules)"
    echo "  4. Generate interactive HTML course"
    echo "  5. Output: $OUTPUT_DIR/index.html"
    ;;

  *)
    echo "❌ Unknown mode: $MODE"
    echo "   Valid modes: slides, whiteboard, course"
    exit 1
    ;;
esac

echo ""
echo "✅ Render setup complete"
echo "   Follow the workflow instructions above to generate content."
