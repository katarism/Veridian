# market_config.md — Market Parameter Configuration File
# Configure once per analysis project. Agents read this file on startup — market parameters are never hardcoded in agent files.
# Edit this file to switch the entire agent system to a different market, without modifying any agent files.

market_name: "YOUR_MARKET_NAME"
# Examples:
# market_name: "Japanese SIer Market"
# market_name: "US SaaS"
# market_name: "European Banking"
# market_name: "China EV"

local_perspective_label: "XX"
# Local perspective label. Used by analyst for evidence citations: [filename, p.XX, ★N XX]
# Examples: JP / CN / US / EU / KR

global_perspective_label: "GL"
# Global perspective label. Used by analyst for evidence citations: [filename, p.XX, ★N GL]
# Usually keep as "GL"

target_companies:
  - Company A
  - Company B
  - Company C
# Example (Japanese SIer): NEC / Fujitsu / Hitachi / NTT Data / SCSK
# Example (US SaaS): Salesforce / ServiceNow / Workday / HubSpot

analysis_angles:
  A: "Market structure — [customize: who owns which segments, customer concentration, competitive dynamics, pricing power]"
  B: "Transition depth — [customize: e.g. Land-and-expand vs. enterprise-first strategic divergence]"
  C: "Financial performance — [customize: revenue growth and profitability comparison across companies]"
  D: "Other: ___"
# The narrative for angle B varies by market. Examples:
# US SaaS: "Land-and-expand vs. enterprise-first strategic divergence"
# European Banking: "Legacy core vs. cloud-native migration speed"

primary_sources:
  - "Official financial reports / annual reports (primary documents)"
  - "Investor Q&A session records (PDF)"
  - "Official stock exchange disclosure filings"
# Typical ★★★★★ sources
# Example (Japanese market):
#   - "Listed company earnings reports and securities reports (official IR)"
#   - "Earnings briefing Q&A records (PDF)"
# Example (US market):
#   - "SEC 10-K / 10-Q filings"
#   - "Earnings call transcripts (official)"

secondary_sources:
  - "Specialized industry media"
  - "Gartner / IDC reports"
  - "Trusted financial media"
# Typical ★★★ sources
# Example (Japanese market):
#   - "Nikkei xTECH, Nikkei Business and other specialist media"
# Example (US market):
#   - "TechCrunch, The Information"
#   - "Gartner Magic Quadrant"

non_listed_companies:
  - "[Non-listed company name]"
# Companies for which independent financial data cannot be obtained.
# materials-strategist reads this list and issues structural gap warnings.
# Examples:
# - Deloitte Digital
# - McKinsey
# - Accenture (no standalone Japan financial data)

structural_data_gaps:
  - "[Company name] (private company): [specific explanation, e.g. no standalone local financial data; available information is limited to official press releases, job postings, etc. Not applicable for local financial comparisons.]"
# Industry structural gaps — not a download failure, but data that does not exist
# Examples:
# - "Stripe: private company, detailed financials not disclosed"
# - "Accenture: private company, no standalone Japan financials. Available info limited to official press releases and job postings."
