# Performance review: <feature / PR>

## Context
- Target workload (requests/sec, users, data size):
- Critical endpoints/jobs:
- Current baseline (if known):

## Performance budget / SLO
- Latency target (p50/p95/p99, or the assumed budget if none exists):
- Error rate target:
- Resource limits (CPU/memory/cost):

## Risk areas
- DB queries (N+1, missing indexes, large scans)
- External calls (timeouts, retry semantics, behavior when the dependency fails)
- Payload sizes (serialization, response bloat)
- Concurrency / locking / transactions
- Caching strategy (correctness, invalidation)

## Measurements
- Evidence used (profile, trace, query plan, dashboard) or "none, leads only":
- How to benchmark locally:
- Staging load test plan:
- What to profile:

## Recommendations
### Must-do
1. …

### Should-do
1. …

### Nice-to-have
1. …

## Regression checks
- Dashboard metrics:
- Alerts:
- Canary/staged rollout plan:
