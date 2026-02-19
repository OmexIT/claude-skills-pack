---
name: monitoring-plan
description: Design an observability strategy with metrics, alerts, dashboards, SLOs, and on-call response for a service or feature. Triggers: "monitoring plan", "observability", "alerts", "dashboards", "SLO", "on-call".
argument-hint: "[service / feature]"
---

# Monitoring plan

## What I'll do
Design a comprehensive observability strategy that ensures you know when something is wrong, why it's wrong, and how bad it is — before users tell you.

## Inputs I'll use (ask only if missing)
- Service/feature being monitored
- SLOs or performance targets (if defined)
- Current monitoring (what exists already?)
- On-call structure (who responds to alerts?)
- Critical user journeys (what must always work?)

## How I'll think about this
1. **The four golden signals**: Start with latency, traffic, errors, and saturation. These cover most problems for most services. Add custom metrics only for domain-specific concerns.
2. **Alert on symptoms, not causes**: Alert when users are affected ("error rate > 1%"), not when a specific thing breaks ("disk at 90%"). Cause-based alerts generate noise; symptom-based alerts are actionable.
3. **SLOs drive alerting**: Define what "good enough" looks like (99.9% availability, p95 < 200ms). Alert when the error budget is being consumed too fast, not on every blip.
4. **Dashboards tell stories**: A good dashboard answers "is the service healthy?" in 5 seconds and "why is it unhealthy?" in 30 seconds. Organize metrics from broad (traffic, errors) to narrow (specific endpoints, queries).
5. **Logs need structure**: Unstructured logs are almost useless at scale. Include request IDs, user IDs, timestamps, and error codes in every log line. Make logs searchable.
6. **Traces connect the dots**: For distributed systems, traces show where time is spent across services. Add trace context to all inter-service calls.

## Anti-patterns to flag
- Alerting on every metric (alert fatigue → ignored alerts)
- No alert runbook (alert fires, nobody knows what to do)
- Dashboards with 50 graphs and no clear narrative
- Logs without request IDs (can't correlate across services)
- Monitoring that doesn't cover the critical user journey
- Setting SLOs without actually alerting on error budget burn

## Quality bar
- Four golden signals are covered (latency, traffic, errors, saturation)
- SLOs are defined with error budget alerts
- Every alert has: threshold, runbook link, escalation path
- Dashboard has a clear information hierarchy (health → details → debugging)
- Structured logging with correlation IDs
- Critical user journeys have end-to-end monitoring
- Alert noise assessment: estimated alert frequency and false positive rate

## Workflow context
- Typically follows: `/design-doc`, service deployment
- Feeds into: `/runbook` (alert response procedures), `/incident-response`
- Related: `/performance-review` (performance metrics), `/experiment-design` (experiment dashboards)

## Output
Fill `templates/monitoring-plan.md`.
