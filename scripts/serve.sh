#!/usr/bin/env bash
# Local preview server for sota-present output
# Usage: serve.sh [slides|whiteboard] [port]

set -e

MODE=${1:-slides}
PORT=${2:-8080}

case $MODE in
  slides)
    DIR="output/slides"
    ;;
  whiteboard)
    DIR="output/whiteboard"
    ;;
  *)
    echo "Usage: serve.sh [slides|whiteboard] [port]"
    exit 1
    ;;
esac

if [ ! -d "$DIR" ]; then
  echo "❌ Directory not found: $DIR"
  echo "   Run render.sh first to generate content."
  exit 1
fi

echo "🌐 Starting local server..."
echo "  Mode: $MODE"
echo "  Directory: $DIR"
echo "  URL: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Try different static file servers
if command -v python3 &> /dev/null; then
  cd "$DIR" && python3 -m http.server "$PORT"
elif command -v npx &> /dev/null; then
  cd "$DIR" && npx serve -p "$PORT"
elif command -v php &> /dev/null; then
  cd "$DIR" && php -S localhost:"$PORT"
else
  echo "❌ No static file server found"
  echo "   Install Python 3, Node.js, or PHP"
  exit 1
fi
