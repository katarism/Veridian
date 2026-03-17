# Market Research Workbench

A human-in-the-loop market research system built on Claude Code. Six specialized subagents collaborate across the full pipeline: material collection → quality rating → market analysis → evidence audit → report output.

Switch to any market by editing a single config file (`market_config.md`) — no agent files need to change.

> **中文文档** → [README_zh.md](README_zh.md)

> [!IMPORTANT]
> **Prerequisite:** This system requires `pdftotext` to extract text from PDFs before analysis.
> Run `./setup.sh` after cloning — it will check and install everything automatically.
> Manual install: `brew install poppler` (macOS) · `sudo apt install poppler-utils` (Linux)

---

## Architecture

```
Human question
  └─→ orchestrator (routing + task decomposition)
        ├─→ materials-strategist (search strategy + quality rating)
        │     └─→ web-researcher (fetch + PDF extraction)
        │
        ├─→ [Human confirms material quality] ←── must pause and wait
        │
        ├─→ analyst (analysis + hypotheses + investor Q&A)
        ├─→ evidence-auditor (evidence quality audit)
        └─→ writer (final report)
```

**Design principles:**
- Every inference must be tagged with evidence quality (★1–5)
- Local vs. global perspective must be explicitly distinguished
- Material gaps cannot be hidden — they must be surfaced to the human
- Human decision nodes cannot be skipped

---

## Quick Start

### Prerequisites
- [Claude Code](https://claude.ai/code) CLI installed
- `pdftotext` installed (for PDF text extraction)
  ```bash
  # macOS
  brew install poppler

  # Ubuntu/Debian
  sudo apt install poppler-utils
  ```

### 1. Clone the repo
```bash
git clone https://github.com/YOUR_USERNAME/market-research-workbench.git
cd market-research-workbench
```

### 2. Run setup
```bash
chmod +x setup.sh && ./setup.sh
```
This checks for `pdftotext` and installs it automatically if missing.

### 3. Configure your target market
Edit `market_config.md` with your market parameters:

```yaml
market_name: "US SaaS"
local_perspective_label: "US"
target_companies:
  - Salesforce
  - ServiceNow
  - Workday
analysis_angles:
  A: "Market structure — who owns which segments, customer concentration, competitive dynamics"
  B: "Land-and-expand vs. enterprise-first strategic divergence"
  C: "Financial performance — revenue growth and profitability comparison"
```

### 4. Start Claude Code and ask a question
```bash
claude
```

Ask the orchestrator a question, for example:
> "Compare the cloud transition strategies of Salesforce and ServiceNow."

The orchestrator will first confirm the analysis angle, then begin material collection.

---

## File Structure

```
.
├── CLAUDE.md                        # System rules (Claude Code project instructions)
├── market_config.md                 # ← The only file you need to edit per market
├── README.md                        # This file
├── README_zh.md                     # Chinese documentation
├── .gitignore
├── .claude/
│   └── agents/
│       ├── orchestrator.md          # Coordinator: routing + task decomposition
│       ├── materials-strategist.md  # Search strategy + quality rating
│       ├── web-researcher.md        # Pure execution: fetch + PDF extraction
│       ├── analyst.md               # Analysis: insight + hypotheses + investor Q&A
│       ├── evidence-auditor.md      # Evidence audit
│       └── writer.md                # Structured report output
│
├── raw_materials/                   # [gitignored] Raw PDFs and extracted text
│   └── {company}/
│       ├── pdfs/                    # Downloaded PDF files
│       └── md/                      # pdftotext output (analyst's only read source)
│
├── material_status.md               # [gitignored] Runtime state (auto-maintained)
└── output/                          # [gitignored] Analysis report output
    ├── analyst_report_v1.md
    ├── audit_report_v1.md
    ├── final_report.md
    └── qa_1.md                      # Follow-up Q&A output
```

---

## Agent Roles

| Agent | Model | Role | Tools |
|-------|-------|------|-------|
| orchestrator | opus | Receives questions, decomposes tasks, routes, maintains state | Read, Write, Bash |
| materials-strategist | opus | Search strategy, quality rating (★1–5) | Read, Write, Bash |
| web-researcher | haiku | Fetch execution, PDF-to-text conversion | WebFetch, WebSearch, Write, Read |
| analyst | opus | Three-part analysis: insight → hypotheses → investor Q&A | Read, Write |
| evidence-auditor | sonnet | Verifies evidence support for each inference | Read, Write |
| writer | sonnet | Generates final readable report | Read, Write |

---

## Material Quality Rating Scale

| Rating | Source Type | Usable for Inference |
|--------|-------------|----------------------|
| ★★★★★ | Official financial reports, Q&A PDFs, SEC filings | ✓ Highest confidence |
| ★★★★☆ | Official earnings summaries, official press releases | ✓ |
| ★★★☆☆ | Trade media, analyst reports | ✓ (note: analyst opinion, not client voice) |
| ★★☆☆☆ | General news articles | Background only |
| ★☆☆☆☆ | Anonymous reviews, job postings | ✗ Not usable for inference |

The analyst only uses ★★★ and above for inferences.

---

## Analysis Output Format

Each `analyst_report_v{N}.md` contains three sections:

1. **Unspoken Insight** — The implicit logic every successful player in the market understands, but customers never say out loud
2. **Three Core Hypotheses + Falsification Conditions** — Each hypothesis with supporting evidence citations and the conditions needed to falsify it
3. **Investor 5 Questions** — Sharp questions a top investor would ask to attack the business model, answered to the extent current materials allow

All inferences use a standardized evidence citation format:
```
[filename, p.XX, ★N US]   ← local perspective
[filename, p.XX, ★N GL]   ← global perspective
[inference, no direct evidence]  ← must be tagged when unsupported
```

---

## Switching Markets

Only edit `market_config.md` — all agents adapt automatically:

```yaml
# Example: switching to European banking
market_name: "European Banking"
local_perspective_label: "EU"
target_companies:
  - HSBC
  - Deutsche Bank
  - BNP Paribas
primary_sources:
  - "Annual reports / 20-F filings"
  - "Earnings call transcripts (official)"
secondary_sources:
  - "Financial Times, Bloomberg"
  - "Gartner Magic Quadrant"
non_listed_companies:
  - McKinsey
structural_data_gaps:
  - "McKinsey: private firm, no independent financial data available"
```

---

## License

MIT
