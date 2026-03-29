---
name: performance-review
description: Review a feature/PR for performance and reliability risks: budgets, hot paths, query patterns, caching, concurrency, load testing, and monitoring. Triggers: "performance review", "slow", "latency", "throughput", "load test".
argument-hint: "[feature / PR]"
effort: high
---

# Performance review

## What I'll do
Produce a practical performance assessment with concrete measurements, identified bottlenecks, and a prioritized optimization plan.

## Inputs I'll use (ask only if missing)
- Feature/PR description or code to review
- Target workload (requests/sec, users, data volume)
- Current baseline metrics (if known)
- Performance SLOs or budget (latency targets, error rate)

## Parallel Expert Panel

Performance reviews benefit from multi-layer specialist analysis:

### Expert Roster

| Expert | Model | Focus |
|---|---|---|
| `BACKEND_PERF` | `sonnet` | API latency, service-to-service calls, serialization overhead, thread management |
| `DB_PERF` | `opus` | Query patterns, N+1 detection, index coverage, connection pooling, transaction scope |
| `FRONTEND_PERF` | `sonnet` | Bundle size, render performance, network waterfall, Core Web Vitals |
| `INFRA_PERF` | `sonnet` | Resource utilization, scaling strategy, connection limits, CDN/caching layers |

### Execution Pattern

```
Phase 1: Hot path mapping (sequential — establishes shared context)
    ↓
Phase 2: Parallel expert analysis
  ┌──────────────┬──────────────┬──────────────┬──────────────┐
  │ BACKEND_PERF │ DB_PERF      │ FRONTEND     │ INFRA_PERF   │
  │              │              │ _PERF        │              │
  └──────┬───────┴──────┬───────┴──────┬───────┴──────┬───────┘
         └──────────────┼──────────────┘──────────────┘
                        ↓
Phase 3: Bottleneck synthesis + load test plan (sequential)
```

- Launch all applicable experts in parallel after hot path is mapped
- Skip FRONTEND_PERF for backend-only reviews, skip DB_PERF if no database involved
- Each expert produces findings with quantified impact estimates
- Synthesize into prioritized optimization plan ordered by user-facing impact

## How I'll think about this
1. **Map the hot path**: Trace the request lifecycle end-to-end — from entry point through every service call, database query, and external dependency to response.
2. **Identify cost drivers**: For each step, estimate relative cost. Database queries, network calls, serialization, and file I/O are usually the dominant factors — not CPU logic.
3. **Check query patterns**: Look for N+1 queries, missing indexes, full table scans, unbounded result sets, and unnecessary joins. Check if queries are proportional to input size.
4. **Evaluate caching**: Is anything cached that shouldn't be (stale data risk)? Is anything uncached that should be (repeated identical lookups)? Are cache invalidation strategies correct?
5. **Assess concurrency**: Look for lock contention, long-held transactions, connection pool exhaustion, thread starvation, and race conditions under load.
6. **Check resource bounds**: Verify pagination on all list endpoints. Check payload sizes. Confirm memory usage doesn't grow with input size unboundedly.
7. **Measure, don't guess**: Identify what to profile and how. Propose specific benchmarks, not vague "load test it."

## Anti-patterns to flag
- Optimizing code that isn't on the hot path
- Adding caching without an invalidation strategy
- "It works in dev" without load testing against realistic data volumes
- Unbounded queries hidden behind pagination that only limits the API response
- Premature optimization that adds complexity without measured benefit

## Quality bar
- Every recommendation links to a specific code path or query
- Performance budgets are quantified (p50/p95/p99), not vague ("should be fast")
- At least one measurement plan with concrete steps to reproduce
- Risks are ranked by impact (user-facing latency > background job speed)
- Includes regression detection strategy (how we'll know if it gets worse)

## Workflow context
- Typically follows: `/design-doc`, `code-review:code-review` (official plugin)
- Feeds into: `/test-plan` (performance test cases), `/monitoring-plan`
- Related: `/security-review` (rate limiting overlaps)

## Output
Fill `templates/perf-review.md`.

## Learning & Memory

After review completes, save:
- Performance baselines and budgets established for this project
- Hot path patterns specific to this architecture
- Query optimization patterns that proved effective
- Load test configurations and results for regression comparison

## Output contract
```yaml
produces:
  - type: "performance-review"
    format: "markdown"
    path: "claudedocs/<feature>-performance-review.md"
    sections: [hot_paths, query_patterns, caching, load_test_plan]
    handoff: "Write claudedocs/handoff-performance-review-<timestamp>.yaml — suggest: test-plan, monitoring-plan"
```
