---
name: performance-review
description: "Use when a feature or PR needs a performance and reliability review, or the user reports something slow: latency, throughput, hot paths, query patterns, caching, concurrency, or load testing."
---

# Performance review

> Delegation, model labels, and task tracking below use Claude Code notation. In Codex or another client, follow `../../references/cross-client.md`.

A measured performance and reliability assessment of one feature, PR, or hot path: bottlenecks,
a prioritized optimization plan, and how to prove it. This is the deep dive; `code-audit` covers
performance only as one breadth dimension. A specific regression or failing behavior goes to
`debug-triage`; alerts and dashboards to `monitoring-plan`.

## Inputs (ask only if missing)

- Feature, PR, or code path to review
- Target workload (requests per second, users, data volume) and current baseline, if known
- SLO or budget (latency percentiles, error rate, cost). If none exists, state the assumed budget
  and label conclusions that depend on it.

## Lenses and fan-out

| Lens | Label | Runs when | Focus |
|---|---|---|---|
| `BACKEND` | `sonnet` | Server code in scope | Request path latency, remote calls, serialization, thread and pool use |
| `DB` | `opus` | Database in scope | Query patterns, plans, indexes, transaction scope, connection pools |
| `FRONTEND` | `sonnet` | UI in scope | Bundle size, rendering, network waterfall, Core Web Vitals |
| `INFRA` | `sonnet` | Scaling or capacity in scope | Resource limits, autoscaling, connection limits, CDN and cache layers |

Map the hot path first. **Fan-out is conditional:** one endpoint, job, or module runs the active
lenses inline. Fan out only for a wide scope (several services or tiers): dispatch the active
lenses as parallel Agent calls in one message with the hot-path map, then synthesize by
user-facing impact.

## Workflow

1. **Hot path:** trace the request or job end to end: entry point, each service call, query, and
   external dependency.
2. **Evidence first:** start from what exists: SLO dashboards, profiles, traces, slow-query logs,
   query plans, load-test results. Without measurements, findings are leads and the plan says how
   to measure them. Static thresholds are leads, not defects.
3. **Queries:** N+1 access, unbounded result sets, missing pagination, scans, lock-heavy writes,
   row-by-row bulk work. Index and N+1 claims need the query, the plan, or workload evidence.
4. **Caching:** repeated identical reads that could be cached, and existing caches without an
   invalidation strategy, TTL, or stated staleness tolerance.
5. **Concurrency and resources:** lock contention, long transactions, pool exhaustion, thread
   starvation, memory that grows with input size, payload size.
6. **Remote calls:** timeouts on every call; retries only for retryable, idempotent operations,
   bounded with backoff and jitter so they do not amplify an outage; bulkheads or circuit breakers
   where the failure mode needs them and the open-circuit result is safe. Never return a fabricated
   success for a failed mutating call.
7. **Measurement plan:** concrete benchmark or load test (tool, data volume, target percentiles),
   what to profile, and how regressions will be detected after release.

Rank recommendations by user-facing impact (interactive latency before background throughput).
Reject optimizations off the hot path, caches without invalidation, and complexity without a
measured benefit.

## Output

Fill `assets/perf-review.md`. Every recommendation links to a specific code path, query, or
measurement.

## Workflow context

- Typically follows: `design-doc`, `code-audit` (performance leads), `code-review:code-review` (official plugin).
- Feeds into: `test-plan` (performance test cases), `monitoring-plan` (SLO alerts).
- Related: `security-review` (rate limiting and resource exhaustion overlap).

## Output contract
```yaml
produces:
  - type: "performance-review"
    format: "markdown"
    path: "claudedocs/<feature>-performance-review.md"
    sections: [hot_paths, query_patterns, caching, load_test_plan]
    handoff: "Write claudedocs/handoff-performance-review-<timestamp>.yaml - suggest: test-plan, monitoring-plan"
```
