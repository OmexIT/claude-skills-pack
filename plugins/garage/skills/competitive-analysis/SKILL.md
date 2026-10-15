---
name: competitive-analysis
description: "Use when the user asks for a competitive analysis, competitor review, market landscape, feature comparison against rivals, or who else solves this problem."
---

# Competitive analysis

Map who else solves the customer's problem, compare on what drives buying decisions, and say plainly where we should defend, catch up, concede, or stand apart.

Ask only what is missing: our product or feature, our target customer, the focus (whole product, one feature, pricing, a segment), and known competitors.

## Rules
- Facts come from sources: competitor sites, pricing pages, public docs, reviews, filings, or the user's own notes. Cite each with a date. Never invent prices, features, or customer counts; mark anything unconfirmed as unconfirmed. If you cannot browse, say the analysis rests on the user's input and your general knowledge, and flag what to check.
- Cover direct rivals, other ways customers solve the same problem (spreadsheets, manual work, agencies, doing nothing), and adjacent players likely to move in.
- Compare on what customers weigh when they buy (price, time to first value, fit with tools they use, reliability, support), not a raw feature checklist. Having a feature is not the same as doing it well.
- Be honest about our weaknesses and their strengths. Look at direction, not only today: who is shipping fast, raising money, or bundling.
- Write in plain language for product, sales, and finance readers; avoid technical jargon.

## Workflow context
- `competitive-analysis` maps the market; `opportunity-assessment` decides whether a given idea is worth doing; `go-to-market` turns positioning into a launch.
- Feeds `prd`, `opportunity-assessment`, and `go-to-market`.

## Output
Fill `assets/competitive-analysis.md`.

## Output contract
```yaml
produces:
  - type: "analysis"
    format: "markdown"
    path: "claudedocs/<feature>-competitive-analysis.md"
    sections: [landscape, feature_comparison, strengths_weaknesses, differentiation]
```
