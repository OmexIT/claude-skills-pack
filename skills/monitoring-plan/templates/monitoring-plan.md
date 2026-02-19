# Monitoring Plan: <service / feature>

## Overview
- **Service**: What it does
- **Critical user journeys**: The flows that must always work
- **Current monitoring**: What exists today
- **On-call**: Who responds, via what channel

## SLOs (Service Level Objectives)
| Metric | Target | Measurement window | Error budget |
| --- | --- | --- | --- |
| Availability | 99.9% | 30-day rolling | 43.2 min/month |
| Latency (p95) | < 200ms | 30-day rolling | 0.1% of requests > 200ms |
| Error rate | < 0.1% | 30-day rolling | 1 in 1000 requests |

## Metrics

### Golden signals
| Signal | Metric name | Source | Dashboard |
| --- | --- | --- | --- |
| Latency | `http_request_duration_ms` | App metrics | <link> |
| Traffic | `http_requests_total` | Load balancer | <link> |
| Errors | `http_errors_total` | App metrics | <link> |
| Saturation | `cpu_usage_percent`, `memory_usage_percent` | Infrastructure | <link> |

### Business metrics
| Metric | What it measures | Source |
| --- | --- | --- |
| ... | ... | ... |

### Custom / domain-specific metrics
| Metric | What it measures | Why it matters |
| --- | --- | --- |
| ... | ... | ... |

## Alerts

### Critical (pages on-call immediately)
| Alert | Condition | Runbook | Escalation |
| --- | --- | --- | --- |
| High error rate | Error rate > 1% for 5 min | <link> | → SEV-2 if >5% |
| Service down | Health check failing for 2 min | <link> | → SEV-1 immediately |
| SLO burn rate | Error budget burn > 10x normal | <link> | → Engineering lead |

### Warning (notifies channel, no page)
| Alert | Condition | Runbook |
| --- | --- | --- |
| Elevated latency | p95 > 500ms for 15 min | <link> |
| Disk usage high | > 80% on any node | <link> |
| Queue depth growing | > 1000 messages for 10 min | <link> |

### Informational (dashboard only)
| Metric | Threshold | Purpose |
| --- | --- | --- |
| Deploy marker | On deploy | Correlate changes with metrics |
| Traffic anomaly | > 2x normal | Detect unusual patterns |

## Dashboards

### Service health (overview)
- **Purpose**: Is the service healthy? Answerable in 5 seconds.
- **Contents**:
  - Traffic (requests/sec)
  - Error rate (%)
  - Latency (p50, p95, p99)
  - Active alerts
  - Recent deploys
- **Link**: <link>

### Debugging (detailed)
- **Purpose**: Why is the service unhealthy? Answerable in 30 seconds.
- **Contents**:
  - Per-endpoint breakdown
  - Database query latency
  - External dependency health
  - Resource utilization
  - Error breakdown by type
- **Link**: <link>

### Business (impact)
- **Purpose**: Is the feature working for users?
- **Contents**: Business metrics, user journey completion rates
- **Link**: <link>

## Logging

### Log format
```json
{
  "timestamp": "ISO8601",
  "level": "info|warn|error",
  "message": "Human-readable message",
  "request_id": "req_abc123",
  "user_id": "usr_xyz",
  "service": "service-name",
  "duration_ms": 42,
  "error_code": "VALIDATION_ERROR"
}
```

### Log levels
- **ERROR**: Something failed that needs investigation
- **WARN**: Unexpected but handled condition
- **INFO**: Significant business events (user actions, state changes)
- **DEBUG**: Diagnostic detail (disabled in production by default)

### Retention
- Hot storage: X days
- Cold storage: X months
- PII considerations: ...

## Tracing
- **Enabled**: Yes / No / Partial
- **Trace propagation**: Which headers carry trace context
- **Key spans**: Entry point → database → external API → response
- **Sampling rate**: X% of requests

## On-call response
- **Alert channels**: PagerDuty / Slack / Email
- **Response SLA**: Critical: 5 min, Warning: 30 min
- **Escalation**: <see /runbook>

## Review cadence
- **Alert tuning**: Monthly — review false positive rate, adjust thresholds
- **SLO review**: Quarterly — are targets still appropriate?
- **Dashboard review**: Quarterly — is the information still useful?

## Open questions
- ...
