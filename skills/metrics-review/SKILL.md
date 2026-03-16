---
name: metrics-review
description: Review analytics implementation and data quality for a feature. Covers event taxonomy, data accuracy, instrumentation gaps, and dashboard effectiveness. Triggers: "metrics review", "analytics review", "data quality", "instrumentation check", "are we tracking this right".
argument-hint: "[feature / event / dashboard]"
---

# Metrics review

## What I'll do
Audit the analytics instrumentation for a feature to ensure data is accurate, complete, and actually useful for decision-making.

## Inputs I'll use (ask only if missing)
- Feature or area to review
- Current instrumentation (events, properties, dashboards)
- Questions the data should answer (what decisions depend on this?)
- Data consumers (product, engineering, business, data science)

## How I'll think about this
1. **Start with questions, not events**: What decisions will this data inform? If you can't name a decision, the event probably isn't needed. Instrument to answer questions, not to "collect everything."
2. **Event taxonomy consistency**: Events should follow a consistent naming convention (noun_verb: `user_signed_up`, `report_exported`). Inconsistent naming makes data analysis painful and error-prone.
3. **Properties over events**: Often you need fewer events with richer properties, not more events. `button_clicked {location: "header", action: "save"}` beats `header_save_button_clicked`.
4. **Validate accuracy**: Are the numbers plausible? Do event counts match expected patterns? Cross-reference with server logs or database counts. Inaccurate data is worse than no data.
5. **Check for gaps**: Can you reconstruct the complete user journey from your events? If there's a step in the funnel with no tracking, you have a blind spot.
6. **Privacy by design**: Don't track what you shouldn't. No PII in analytics. No tracking users without consent. Review data retention policies.

## Anti-patterns to flag
- Events that no one looks at (dead instrumentation)
- Inconsistent event naming across features
- Missing properties that prevent useful segmentation
- Client-side only tracking (no server-side validation)
- Tracking PII in analytics events
- Dashboards that nobody checks (vanity metrics)
- No documentation of event definitions

## Quality bar
- Every tracked event has a documented purpose (what question does it answer?)
- Event naming follows a consistent taxonomy
- Key funnels are fully instrumented (no blind spots between steps)
- Data accuracy is verified against a second source
- Privacy compliance is confirmed (no PII in events, consent respected)
- Dashboards are actionable (each graph has a "so what")

## Workflow context
- Typically follows: `/experiment-design` (instrumentation for experiments), feature launch
- Feeds into: `/experiment-design` (data quality), `/go-to-market` (launch metrics)
- Related: `/monitoring-plan` (operational metrics vs product metrics)

## Output
Fill `templates/metrics-review.md`.

## Output contract
```yaml
produces:
  - type: "review"
    format: "markdown"
    path: "claudedocs/<feature>-metrics-review.md"
    sections: [event_taxonomy, instrumentation, data_quality, dashboards]
```
