---
name: experiment-design
description: "Use when the user wants to measure the impact of a product change: A/B test, experiment, feature flag rollout, staged exposure, or deciding metrics, guardrails, duration, and a decision rule."
---

# Experiment design

Plan how a change will be measured before anyone is exposed to it: hypothesis, one primary metric, guardrails, assignment, duration, and the decision rule. Engineering should be able to implement it and product or data should be able to read the result without arguing about what counts.

Ask only what is missing: the change, the expected effect and why, the population, and how much risk and time the team accepts.

## Rules
- Hypothesis: "If we X, then Y moves by about Z, because W." Falsifiable or it is not ready.
- One primary metric with an exact definition and data source. Secondary metrics inform; they do not decide.
- Guardrails with thresholds for what must not get worse (errors, latency, revenue, support contacts, abuse), and a stop rule if one is breached.
- Randomization unit matches how the effect spreads (user, account, session, market). Check that group sizes match the planned split before reading results.
- Sample size and duration from baseline rate and the smallest effect worth acting on, even if approximate. Cover at least one full weekly cycle. If traffic cannot detect that effect, say so and propose a staged rollout with guardrails or qualitative validation instead.
- Segments are named before launch. No peeking-based early stops unless the design is sequential.
- Decision rule written in advance: what result means ship, iterate, or revert.
- Instrumentation is verified in a test environment before exposure. Auditing existing events and data quality belongs to `metrics-review`.

## Workflow context
- `experiment-design` decides what to measure and how to judge it before exposure; `metrics-review` audits whether existing tracking and data can be trusted.
- Follows `prd` or `design-doc`; feeds `ticket-breakdown` (instrumentation and flag work) and `go-to-market`.

## Output
Fill `assets/experiment-plan.md`.

## Output contract
```yaml
produces:
  - type: "experiment-plan"
    format: "markdown"
    path: "claudedocs/<feature>-experiment-design.md"
    sections: [hypothesis, metrics, segments, duration, decision_rule]
    handoff: "Write claudedocs/handoff-experiment-design-<timestamp>.yaml - suggest: ticket-breakdown, metrics-review"
```
