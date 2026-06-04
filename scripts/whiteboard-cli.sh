#!/usr/bin/env bash
# SVG validation and PNG export for Feishu whiteboards
# Usage: whiteboard-cli.sh <svg-file> [--upload]

set -e

SVG_FILE=${1:?Usage: whiteboard-cli.sh <svg-file> [--upload]}
UPLOAD=${2:-}

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🖼️  Feishu Whiteboard CLI"
echo "  SVG: $SVG_FILE"
echo ""

# Check if file exists
if [ ! -f "$SVG_FILE" ]; then
  echo "❌ File not found: $SVG_FILE"
  exit 1
fi

# Validate SVG against Feishu renderer constraints
echo "🔍 Validating SVG rules..."
python3 << EOF
import sys
import xml.etree.ElementTree as ET

ALLOWED_TAGS = {
    'svg', 'rect', 'circle', 'ellipse', 'line', 'polyline', 'text', 'tspan', 'g', 'defs', 'marker'
}

FORBIDDEN_TAGS = {
    'path', 'polygon', 'filter', 'linearGradient', 'radialGradient',
    'clipPath', 'mask', 'pattern', 'foreignObject', 'image', 'use', 'style'
}

def localname(t):
    return t.split('}')[-1] if '}' in t else t

try:
    tree = ET.parse('$SVG_FILE')
    root = tree.getroot()

    # Remove namespace for easier checking
    ns = {'svg': 'http://www.w3.org/2000/svg'}

    # Build child->parent map so we can apply context-sensitive rules
    parent = {}
    for p in root.iter():
        for c in p:
            parent[c] = p

    def inside_marker(elem):
        cur = parent.get(elem)
        while cur is not None:
            if localname(cur.tag) == 'marker':
                return True
            cur = parent.get(cur)
        return False

    errors = []
    warnings = []

    # Check all elements
    for elem in root.iter():
        tag = localname(elem.tag)

        if tag in FORBIDDEN_TAGS:
            # polygon is permitted ONLY as an arrowhead inside a <marker> def
            if tag == 'polygon' and inside_marker(elem):
                pass
            else:
                errors.append(f"Forbidden element: <{tag}>")
        elif tag not in ALLOWED_TAGS:
            warnings.append(f"Unknown element: <{tag}>")

        # Check for forbidden attributes
        if 'opacity' in elem.attrib:
            errors.append(f"Forbidden attribute: opacity on <{tag}>")

        # Check colors (no rgba, hsl)
        for attr in ['fill', 'stroke', 'color']:
            if attr in elem.attrib:
                value = elem.attrib[attr]
                if 'rgba' in value or 'hsl' in value:
                    errors.append(f"Forbidden color format in {attr}: {value}")

    # Check viewBox
    if 'viewBox' not in root.attrib:
        errors.append("Missing viewBox attribute")
    else:
        viewBox = root.attrib['viewBox'].split()
        if len(viewBox) == 4:
            width = float(viewBox[2])
            if not (1600 <= width <= 1700):
                warnings.append(f"viewBox width {width}px (recommended: 1600-1700px)")

    # Report
    if errors:
        print("❌ Validation failed:")
        for error in errors:
            print(f"  - {error}")
        sys.exit(1)

    if warnings:
        print("⚠️  Warnings:")
        for warning in warnings:
            print(f"  - {warning}")

    print("✅ SVG validation passed")

except ET.ParseError as e:
    print(f"❌ Invalid XML: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)
EOF

# Export to PNG
echo ""
echo "🖼️  Exporting to PNG..."
PNG_FILE="${SVG_FILE%.svg}.png"

if command -v rsvg-convert &> /dev/null; then
  rsvg-convert "$SVG_FILE" -o "$PNG_FILE" -w 2400
  echo "✅ PNG exported: $PNG_FILE (using librsvg)"
elif command -v cairosvg &> /dev/null; then
  cairosvg "$SVG_FILE" -o "$PNG_FILE" --output-width 2400
  echo "✅ PNG exported: $PNG_FILE (using cairosvg)"
elif python3 -c "import cairosvg" 2>/dev/null; then
  python3 << EOF
import cairosvg
cairosvg.svg2png(url='$SVG_FILE', write_to='$PNG_FILE', output_width=2400)
print("✅ PNG exported: $PNG_FILE (using cairosvg Python)")
EOF
else
  echo "⚠️  No SVG→PNG converter found"
  echo "   Install librsvg or cairosvg for PNG export"
fi

# Optional: Upload to Feishu
if [ "$UPLOAD" = "--upload" ]; then
  echo ""
  echo "☁️  Uploading to Feishu..."

  if ! command -v lark-cli &> /dev/null; then
    echo "❌ lark-cli not found"
    echo "   Install lark-cli for Feishu upload"
    exit 1
  fi

  # This is a placeholder - actual upload command depends on lark-cli API
  echo "⚠️  Feishu upload not yet implemented"
  echo "   Use: lark-cli docs +create --api-version v2 --content '<title>Whiteboard</title><whiteboard type=\"blank\"></whiteboard>' --as user"
fi

echo ""
echo "✅ Done!"
