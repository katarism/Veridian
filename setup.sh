#!/bin/sh
# setup.sh — Market Research Workbench first-time setup
# Checks for required dependencies and installs them if missing.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Market Research Workbench — Setup"
echo "=================================="

# Check: pdftotext
if command -v pdftotext > /dev/null 2>&1; then
  echo "${GREEN}✓ pdftotext is installed ($(pdftotext -v 2>&1 | head -1))${NC}"
else
  echo "${YELLOW}✗ pdftotext not found. Installing poppler...${NC}"

  if command -v brew > /dev/null 2>&1; then
    brew install poppler
  elif command -v apt-get > /dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y poppler-utils
  elif command -v dnf > /dev/null 2>&1; then
    sudo dnf install -y poppler-utils
  elif command -v pacman > /dev/null 2>&1; then
    sudo pacman -S --noconfirm poppler
  else
    echo "${RED}Could not detect package manager.${NC}"
    echo "Please install poppler manually:"
    echo "  macOS:          brew install poppler"
    echo "  Ubuntu/Debian:  sudo apt install poppler-utils"
    echo "  Fedora:         sudo dnf install poppler-utils"
    echo "  Arch:           sudo pacman -S poppler"
    echo "  Windows:        https://blog.alivate.com.au/poppler-windows/"
    exit 1
  fi

  echo "${GREEN}✓ pdftotext installed successfully${NC}"
fi

# Check: Claude Code CLI
if command -v claude > /dev/null 2>&1; then
  echo "${GREEN}✓ Claude Code CLI is installed${NC}"
else
  echo "${YELLOW}✗ Claude Code CLI not found.${NC}"
  echo "  Install it from: https://claude.ai/code"
fi

# Check: market_config.md
if [ -f "market_config.md" ]; then
  echo "${GREEN}✓ market_config.md found${NC}"
else
  echo "${RED}✗ market_config.md not found.${NC}"
  echo "  Please create market_config.md before starting analysis."
  echo "  See README.md for the template and configuration guide."
fi

echo ""
echo "Setup complete. Run 'claude' to start the workbench."
