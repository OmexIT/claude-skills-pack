---
name: decision-matrix
description: Structure a decision with weighted criteria, options evaluation, and clear recommendation. For technical, product, or strategic choices. Triggers: "decision matrix", "help me decide", "compare options", "which should we choose", "trade-off analysis".
argument-hint: "[decision to make]"
effort: medium
---

# Decision matrix

## What I'll do
Structure a complex decision into a weighted evaluation framework that makes trade-offs explicit and produces a defensible recommendation.

## Inputs I'll use (ask only if missing)
- The decision to make (what are we choosing between?)
- Options being considered (at least 2)
- Criteria that matter (what makes one option better?)
- Constraints (budget, timeline, team skills, compatibility)
- Stakeholders (who's affected by this decision?)

## How I'll think about this
1. **Define criteria before evaluating options**: If you evaluate options first, you'll unconsciously weight criteria to justify your preference. List what matters, then score.
2. **Weight criteria honestly**: Not all criteria are equally important. Performance mattering 2x more than developer experience is a legitimate choice — but make it explicit.
3. **Score with evidence**: "Option A is better for performance" needs numbers or benchmarks. Opinions without evidence make the matrix theater, not analysis.
4. **Include hidden costs**: Migration effort, learning curve, community/ecosystem health, vendor lock-in, and long-term maintenance cost. These often dominate technical choices.
5. **Test the winner**: If the matrix picks an option that feels wrong, examine the criteria and weights. Either your gut has information the matrix doesn't, or your weights are off.
6. **Document for posterity**: The matrix isn't just for making the decision — it's for explaining it 6 months later when someone asks "why did we choose this?"

## Anti-patterns to flag
- Criteria chosen to favor a predetermined conclusion
- Equal weights on everything (signals you haven't prioritized)
- Scoring without evidence ("this feels like a 4 out of 5")
- Missing "do nothing" or "status quo" as an option
- Ignoring switching costs and migration effort
- Matrix has a clear winner but recommendation says "it depends"

## Quality bar
- At least 3 criteria with justified weights
- At least 2 options (ideally 3-4, including status quo)
- Scores are supported by evidence or reasoning
- Total scores drive the recommendation (or deviation is explained)
- Risks and trade-offs of the recommended option are acknowledged
- Decision is documented in a format that's useful 6 months later

## Workflow context
- Typically follows: `/design-doc` (alternatives), `/opportunity-assessment`
- Feeds into: `/adr` (record the decision), `/design-doc` (implement the choice)
- Related: `/competitive-analysis` (vendor/tool comparisons)

## Output
Fill `templates/decision-matrix.md`.

## Learning & Memory

After decision matrix evaluation completes, save:
- Decision frameworks that produced clear outcomes vs those that led to inconclusive results
- Weighting approaches that reflected actual priorities (and cases where initial weights needed recalibration)
- Criteria that mattered most in practice for this type of decision (technical, organizational, cost, risk)

## Output contract
```yaml
produces:
  - type: "decision"
    format: "markdown"
    path: "claudedocs/<feature>-decision-matrix.md"
    sections: [criteria, weights, options, scores, recommendation]
    handoff: "Write claudedocs/handoff-decision-matrix-<timestamp>.yaml — suggest: adr, design-doc"
```
