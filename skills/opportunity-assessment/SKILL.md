---
name: opportunity-assessment
description: Evaluate whether a feature or product idea is worth building through cost/benefit analysis, risk assessment, strategic alignment, and effort estimation. Triggers: "should we build this", "opportunity assessment", "cost benefit", "is this worth it", "prioritization".
argument-hint: "[feature idea / proposal]"
effort: high
---

# Opportunity assessment

## What I'll do
Produce a structured assessment of whether an opportunity is worth pursuing, how it compares to alternatives, and what the key risks are.

## Inputs I'll use (ask only if missing)
- The opportunity (feature, product, initiative)
- Strategic goals it might serve
- Known constraints (timeline, team size, technical debt)
- Alternative uses of the same resources

## How I'll think about this
1. **Problem validation first**: Before assessing the solution, verify the problem is real, frequent, and important enough to solve. A well-built solution to a non-problem is waste.
2. **Impact estimation**: Who benefits and how much? Rough sizing is fine — order of magnitude matters more than precision. Is this a 10-user problem or a 10,000-user problem?
3. **Effort estimation with honesty**: Include not just build time, but: design, testing, documentation, migration, monitoring, ongoing maintenance, and opportunity cost. The real cost is always higher than the build estimate.
4. **Risk identification**: Technical risk (can we build it?), market risk (do users want it?), execution risk (can we ship it on time?), and dependency risk (what blocks us?).
5. **Strategic alignment**: Does this move the product toward its long-term vision, or is it a distraction? Good ideas that don't align with strategy are still distractions.
6. **Reversibility**: How easy is it to undo if it doesn't work? Reversible decisions should be made faster; irreversible ones deserve more analysis.
7. **Opportunity cost**: What won't get built if we build this? The value of this feature minus the value of what we could have built instead.

## Anti-patterns to flag
- Assessing only the upside ("it could be huge!")
- Ignoring maintenance and operational costs
- Sunk cost reasoning ("we already built the API, might as well build the UI")
- HIPPO decision-making (highest paid person's opinion) without evidence
- Comparing to doing nothing when the real alternative is doing something else

## Quality bar
- Problem is validated with evidence (data, user research, support tickets), not assumptions
- Impact is sized with at least an order-of-magnitude estimate
- Effort includes the full lifecycle cost, not just initial development
- Risks are categorized and have mitigation strategies
- Recommendation is clear: build / don't build / investigate further — with reasoning
- Alternative uses of resources are explicitly considered

## Workflow context
- Typically follows: Customer feedback, research, `/competitive-analysis`
- Feeds into: `/prd` (if "build"), backlog deprioritization (if "don't build")
- Related: `/experiment-design` (for "investigate further" outcomes)

## Output
Fill `templates/opportunity-assessment.md`.

## Learning & Memory

After completing an opportunity assessment, persist the following to project memory for future skill invocations:

- **Market patterns**: Recurring market dynamics, demand signals, and timing patterns observed during assessment
- **Opportunity evaluation criteria**: Scoring dimensions and thresholds that proved most predictive for this domain
- **Strategic alignment factors**: How the team's strategic priorities influenced the recommendation, so future assessments stay calibrated

Store in: `claudedocs/memory/opportunity-assessment.md`

## Output contract
```yaml
produces:
  - type: "assessment"
    format: "markdown"
    path: "claudedocs/<feature>-opportunity-assessment.md"
    sections: [cost_benefit, risk_analysis, strategic_alignment, recommendation]
```
