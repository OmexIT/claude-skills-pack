---
name: metrics-review
description: "Use when the user wants a feature's analytics or instrumentation reviewed: event taxonomy, data accuracy, tracking gaps, dashboard usefulness, or are we tracking this right."
---

# Metrics review

Audit a feature's existing analytics: whether the events answer the decisions people need to make, whether the numbers can be trusted, and what to add, fix, or delete.

Ask only what is missing: the feature, the decisions the data should inform, and who consumes it. Then read the tracking calls in the code and the event definitions or dashboards the user can share; do not review from the event list alone.

## Rules
- Start from questions: every event and dashboard tile maps to a decision. Unused events are deletion candidates, not harmless.
- Follow the project's existing naming convention; if there is none, propose one (for example `object_action`) and apply it consistently. Prefer one event with descriptive properties over many near-duplicate events.
- Trace the key funnel end to end and mark steps with no event as blind spots.
- Check accuracy against a second source (server logs, database counts, payment records): duplicate firing on retries or re-renders, events lost to ad blockers or closed tabs, funnel steps that exceed the step before, time zone and identity mismatches. Business-critical conversions should be recorded server-side.
- Privacy: no personal data in event properties, consent respected before tracking, retention defined.
- Findings name the evidence (code location, query, sample count) and the decision at risk, ranked: data integrity, then gaps, then nice-to-have.

## Workflow context
- `metrics-review` audits existing tracking and data quality; `experiment-design` plans what to measure for a future change; `monitoring-plan` covers operational health signals, not product analytics.
- Often follows a launch or precedes `experiment-design`.

## Output
Fill `assets/metrics-review.md`.

## Output contract
```yaml
produces:
  - type: "metrics-review"
    format: "markdown"
    path: "claudedocs/<feature>-metrics-review.md"
    sections: [event_taxonomy, instrumentation, data_quality, dashboards]
    handoff: "Write claudedocs/handoff-metrics-review-<timestamp>.yaml - suggest: experiment-design"
```
