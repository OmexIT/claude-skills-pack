---
name: monitoring-plan
description: "Use when the user needs observability for a service or feature: a monitoring plan, metrics, alerts, dashboards, SLOs, logging, or tracing."
---

# Monitoring plan

Decide what to measure, when to alert, and who gets paged, so the team knows something is wrong,
why, and how bad before users report it.

## Inputs (ask only if missing)
- Service or feature, and its critical user journeys
- SLOs or targets, if any exist
- Current monitoring stack and what already exists (extend it, do not replace it)
- Who responds to alerts

## Decision rules
1. **Golden signals first**: latency, traffic, errors, saturation per critical journey. Add domain
   metrics only where they catch a failure the golden signals miss.
2. **Page on symptoms, notify on causes.** Pages fire when users are affected (error rate, SLO burn);
   cause signals (disk, queue depth) go to a channel unless they predict imminent user impact.
3. **SLOs drive paging.** Alert on error-budget burn rate (fast and slow windows), not on every blip.
   Set targets from measured baseline and user need, not a default like 99.9%.
4. **Every page has a runbook entry and an owner.** An alert nobody can act on is noise; downgrade or
   delete it.
5. **Money flows** get domain signals: reconciliation mismatches, transactions stuck in a pending
   state past their expected window, ledger imbalance, duplicate-effect detection. These page.
6. **Logs are structured** with timestamp (UTC, ISO-8601 with offset), level, request or trace ID,
   and error code. Use external IDs, never personal data, secrets, or tokens in logs.
7. **Traces** where a request crosses services; propagate the standard trace context the stack
   already uses.

## Anti-patterns to flag
- Pages without a runbook entry or owner; alerting on every metric
- SLOs defined but no burn-rate alert
- Dashboards with no health-first hierarchy
- Logs that cannot be correlated across services

## Output
Fill `assets/monitoring-plan.md`; replace every placeholder threshold with a value justified by
baseline data or mark it "to calibrate".

## Workflow context
- This skill decides what fires and why; `runbook` says what a human does when it fires; `incident-response` runs a live incident.
- Follows `design-doc` or `infra-design`; related: `performance-review`, `experiment-design` (experiment dashboards).

## Output contract
```yaml
produces:
  - type: "monitoring-plan"
    format: "markdown"
    path: "claudedocs/<feature>-monitoring-plan.md"
    sections: [golden_signals, slos, alerts, dashboards, logging]
```
