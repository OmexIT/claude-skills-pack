---
name: decision-matrix
description: "Use when the user needs help deciding between options with trade-offs: help me decide, compare options, which should we choose, trade-off analysis, or a weighted decision matrix for a technical, product, or strategic choice."
---

# Decision matrix

Make a hard choice explicit: criteria and weights first, evidence-backed scores second, and a recommendation that either follows the totals or explains why not. This makes the decision; `adr` records it afterwards.

Ask only what is missing: the decision and its deadline, the options, the constraints, and who is affected. Gauge reversibility first: an easy-to-undo choice deserves a short comparison, not a full matrix.

## Rules
- Fix criteria and weights before scoring any option, with a reason for each weight. Equal weights everywhere means priorities were not set.
- Include the status quo or "do nothing" as an option unless it is truly impossible.
- Score from evidence (benchmarks, docs, prices, code you read, team experience) and cite it. Mark guesses as guesses and lower confidence accordingly.
- Count switching costs: migration effort, learning curve, lock-in, ongoing maintenance and operating cost. Include only the cost and risk rows that differ between options.
- If the winner feels wrong, recheck criteria and weights and say what the matrix missed rather than quietly overriding it.
- Recommendation names the trade-off accepted, the top risk with its mitigation, and the trigger that would reopen the decision.

## Workflow context
- `decision-matrix` chooses between options; `adr` records an architecture decision once made; `opportunity-assessment` asks whether to do something at all.
- Often follows `design-doc` alternatives; feeds `adr` and `design-doc`.

## Output
Fill `assets/decision-matrix.md`.

## Output contract
```yaml
produces:
  - type: "decision"
    format: "markdown"
    path: "claudedocs/<feature>-decision-matrix.md"
    sections: [criteria, weights, options, scores, recommendation]
    handoff: "Write claudedocs/handoff-decision-matrix-<timestamp>.yaml - suggest: adr, design-doc"
```
