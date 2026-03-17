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
echo "Setup complete. Launching Claude to guide you through configuration..."
echo ""
claude "You are setting up the Market Research Workbench. Follow these steps in order:

STEP 1 — Configure market_config.md:
Read market_config.md, then guide the user through configuring it interactively — ask one section at a time: market name and local perspective label, target companies, analysis angles (A/B/C), primary and secondary sources, and non-listed companies. After each answer, write the updated values into market_config.md. Once all fields are filled, confirm the config is complete.

STEP 2 — Capture first research question:
Ask the user for their first research question (or recognize it if they have already stated one during this conversation). Wait for a clear question before proceeding.

STEP 3 — Confirm analysis angle:
Read the analysis_angles from market_config.md and present them to the user. Ask the user to select one angle (A/B/C/D) or describe their own. Wait for confirmation.

STEP 4 — Write material_status.md with confirmed state:
Once the user has confirmed an angle, write a new file called material_status.md in the working directory with the following content (fill in the actual values):

current_phase: frame_confirmed
human_confirmed: false
confirmed_at: null
last_updated: {current datetime}
analyst_version: null
analysis_frame: \"{the angle the user confirmed}\"
analysis_frame_confirmed: true
structural_gaps: []

STEP 5 — Hand off to orchestrator:
Tell the user: 'Configuration complete. Starting analysis...' Then invoke the orchestrator sub-agent with this instruction: 'The analysis frame has already been confirmed by the user during setup. analysis_frame_confirmed is true in material_status.md. The user's research question is: {the question from Step 2}. Skip frame confirmation (Step 0b) and proceed directly to Stage 1: material collection.'"
