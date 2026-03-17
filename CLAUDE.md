# Market Research Workbench

## Market Configuration (Single Source of Truth for All Agents)

**`market_config.md` is the market parameter config file for this project. All agents must read it before starting.**
- Target companies, analysis angles, source rating standards, non-listed company list, structural data gaps — all defined here
- Edit this file to switch the entire agent system to a different market, without modifying any agent files
- **Agents read config only — they must never modify `market_config.md`**

## System Architecture
This project is a human-in-the-loop market research collaboration system.
The human is responsible for question quality; the agent team is responsible for material quality and analysis execution.

## Key Principle: Frame Before Materials

When the orchestrator receives a question, the first step is to confirm the analysis angle with the human (reading options from `market_config.md`).
Material collection only begins after human confirmation. **The orchestrator must never interpret the question frame on its own.**

## Agent Invocation Order
Human question → orchestrator routing
→ materials-strategist defines strategy
→ web-researcher executes fetch
→ materials-strategist rates materials
→ [Human confirms materials]
→ analyst analyzes
→ evidence-auditor audits
→ writer outputs
→ Human reviews, asks next question

## Q&A Branch (After Report Delivery)

When `final_report.md` exists, follow-up questions enter the Q&A flow — do not restart the full analysis chain:

- Concept explanation → orchestrator answers directly (reads final_report.md)
- Evidence tracing → evidence-auditor → output/qa_{N}.md
- Deep follow-up → analyst (Q&A mode) → output/qa_{N}.md
- Needs new materials → ask user to confirm before fetching
- Format adjustment → writer

**The distinction between a follow-up question and a new research question is made by the orchestrator. If it's a new research question, return to stage 0.**

## Key Constraints (All Agents Must Follow)
- Every inference must be tagged with evidence quality ★1–5
- Local perspective and global perspective must be explicitly distinguished (perspective labels come from `market_config.md`)
- Material gaps must not be concealed — they must be presented to the human
- Human decision nodes cannot be skipped
- Analysis angle is confirmed by the human, not inferred by the orchestrator
- The `analysis_frame` field in `material_status.md` must only be written after human confirmation
- Communicate with the user in the language they use; technical proper nouns (company names, product names, technical terms) may remain in their original language

## Working Directory Conventions
- Raw material PDFs: `raw_materials/{company}/pdfs/`
- PDF-converted text: `raw_materials/{company}/md/` (analyst's only read source)
- Material status table: `material_status.md`
- Final reports: `output/`

## PDF Processing Convention
- After web-researcher downloads a PDF, **immediately batch-convert to `/md/*.md` using `pdftotext -layout`**
- analyst **only reads text files under `/md/`** — never reads PDFs directly
- Conversion command: `for pdf in raw_materials/{company}/pdfs/*.pdf; do pdftotext -layout "$pdf" "raw_materials/{company}/md/$(basename $pdf .pdf).md"; done`
