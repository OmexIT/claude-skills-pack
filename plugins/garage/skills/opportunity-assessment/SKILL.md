---
name: opportunity-assessment
description: "Use when the user is deciding whether a feature or product idea is worth building: should we build this, is this worth it, cost and benefit, risk, strategic fit, or prioritization."
---

# Opportunity assessment

Answer one question: is this worth doing now, compared with the other things the same people could do? The result is build, don't build, or find out more first, with the reasoning a product or finance reader can check.

Ask only what is missing: the idea, the goals it would serve, known constraints (time, team, existing commitments), and what else the team could do instead.

## Rules
- Problem first: show it is real, frequent, and painful with evidence (support contacts, usage data, lost deals, research). Label assumptions as assumptions.
- Size the benefit roughly: who gains, how many, and roughly how much in revenue, retention, cost saved, or risk removed. An order of magnitude is enough; state the basis.
- Cost is the whole lifecycle, not the build: design, testing, migration, support, and the ongoing cost of running and maintaining it.
- Compare against the real alternative, usually other work the same team would do, not only "do nothing". Consider buying or partnering when relevant.
- Name the risks (will people want it, can we build it, can we ship it on time, what blocks us) and how reversible the bet is. Suggest a smaller test first when the bet is costly to undo.
- Write in plain language for product and finance readers: no technical jargon, no internal shorthand, short sentences. Keep it to what changes the decision.
- Flag reasoning that skips the evidence: upside only, ignoring running costs, "we already built half of it", or a decision resting on someone's authority.

## Workflow context
- `opportunity-assessment` decides whether to pursue an idea; `decision-matrix` chooses between known options; `prd` specifies the idea once it is a go.
- Often follows `competitive-analysis`; "find out more" outcomes often lead to `experiment-design`.

## Output
Fill `assets/opportunity-assessment.md`.

## Output contract
```yaml
produces:
  - type: "assessment"
    format: "markdown"
    path: "claudedocs/<feature>-opportunity-assessment.md"
    sections: [cost_benefit, risk_analysis, strategic_alignment, recommendation]
```
