# Monitoring Plan: <service / feature>

## Overview
- **Service**: what it does
- **Critical user journeys**: the flows that must always work
- **Current monitoring**: what exists today (stack, dashboards, alerts)
- **On-call**: who responds, via what channel

## SLOs
| Journey / metric | Target | Window | Error budget | Basis (baseline data or user need) |
| --- | --- | --- | --- | --- |
| <availability of journey X> | <target> | <window> | <budget> | <why this target> |

## Metrics
| Signal | Metric name | Source | Why it matters |
| --- | --- | --- | --- |
| Latency | | | |
| Traffic | | | |
| Errors | | | |
| Saturation | | | |
| <domain, e.g. reconciliation mismatches> | | | |

## Alerts
| Alert | Condition | Route (page / channel / dashboard) | Runbook entry | Owner |
| --- | --- | --- | --- | --- |
| SLO fast burn | <burn rate over short window> | page | <link> | |
| SLO slow burn | <burn rate over long window> | channel | <link> | |
| <cause signal> | <threshold, or "to calibrate"> | channel | <link> | |

Expected alert volume and known false-positive sources:

## Dashboards
- **Health** (is it healthy? answered at a glance): traffic, error rate, latency percentiles, active
  alerts, deploy markers.
- **Debugging** (why is it unhealthy?): per-endpoint breakdown, dependency health, DB latency, error
  types.
- **Business** (is the feature working for users?), only if the feature has business metrics.

## Logging
- Format and required fields: timestamp (UTC, ISO-8601 with offset), level, request or trace ID,
  service, error code
- Excluded: personal data, secrets, tokens
- Retention:

## Tracing
- Propagation format and key spans:
- Sampling:

## Review
- Alert tuning and SLO review cadence:

## Open questions
- …
