#!/usr/bin/env bash
# Preflight environment check for sota-present skill

set -e

echo "🔍 Running preflight checks for sota-present..."

errors=0

# Check Node.js
echo -n "  Node.js ≥ 20... "
if command -v node &> /dev/null; then
  version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$version" -ge 20 ]; then
    echo "✅ $(node -v)"
  else
    echo "❌ Found $(node -v), need ≥ 20"
    errors=$((errors + 1))
  fi
else
  echo "❌ Not found"
  errors=$((errors + 1))
fi

# Check Python 3
echo -n "  Python 3... "
if command -v python3 &> /dev/null; then
  echo "✅ $(python3 --version)"
else
  echo "❌ Not found"
  errors=$((errors + 1))
fi

# Check optional: lark-cli
echo -n "  lark-cli (optional)... "
if command -v lark-cli &> /dev/null; then
  echo "✅ Available"
else
  echo "⚠️  Not found (Feishu upload will be unavailable)"
fi

# Check optional: whiteboard-cli
echo -n "  @larksuite/whiteboard-cli (optional)... "
if command -v whiteboard-cli &> /dev/null; then
  echo "✅ Available"
else
  echo "⚠️  Not found (SVG→PNG conversion will be limited)"
fi

# Check optional: python-pptx (for editable PowerPoint output)
echo -n "  python-pptx (optional, for .pptx)... "
if python3 -c "import pptx" 2>/dev/null; then
  echo "✅ $(python3 -c 'import pptx;print(pptx.__version__)')"
else
  echo "⚠️  Not found (run: pip install python-pptx — needed for pptx mode)"
fi

# Check optional: LibreOffice (for .pptx → PNG/PDF preview)
echo -n "  LibreOffice (optional, pptx preview)... "
if command -v soffice &> /dev/null || [ -x "/Applications/LibreOffice.app/Contents/MacOS/soffice" ]; then
  echo "✅ Available"
else
  echo "⚠️  Not found (pptx preview render unavailable; file still valid)"
fi

# Check optional: SVG→PNG converter
echo -n "  SVG→PNG converter (optional)... "
if command -v rsvg-convert &> /dev/null; then
  echo "✅ librsvg available"
elif command -v cairosvg &> /dev/null; then
  echo "✅ cairosvg available"
elif python3 -c "import cairosvg" 2>/dev/null; then
  echo "✅ cairosvg (Python) available"
else
  echo "⚠️  Not found (install librsvg or cairosvg for PNG export)"
fi

# Check required directories
echo -n "  Project structure... "
if [ -d "skills" ] && [ -d "catalog" ] && [ -d "templates" ]; then
  echo "✅"
else
  echo "❌ Missing required directories"
  errors=$((errors + 1))
fi

# Check required files
echo -n "  Core files... "
if [ -f "SKILL.md" ] && [ -f "skill.json" ]; then
  echo "✅"
else
  echo "❌ Missing SKILL.md or skill.json"
  errors=$((errors + 1))
fi

echo ""
if [ $errors -eq 0 ]; then
  echo "✅ Preflight passed! Ready to generate."
  exit 0
else
  echo "❌ Preflight failed with $errors error(s)"
  exit 1
fi
