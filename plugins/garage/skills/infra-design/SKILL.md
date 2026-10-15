---
name: infra-design
description: "Use when the user is designing infrastructure or deployment: Docker images, Kubernetes, Terraform, CI/CD pipelines, environments, or deployment strategy."
---

# Infrastructure design

Design container, orchestration, IaC, and deployment setup for a service, and produce working
configs, not just diagrams.

## Inputs (ask only if missing)
- Service(s) to deploy (or the `design-doc` handoff), target environments, expected load
- Existing infra: read the repo first (Dockerfiles, compose files, manifests or Helm charts,
  Terraform, CI workflows). Extend what exists; do not introduce Kubernetes, Terraform, or a new CI
  system where the repo uses something else unless the user asks.
- Cloud provider and platform constraints

## Decision rules

### Containers
- Multi-stage builds; the runtime image carries no build tools. Order layers from least to most
  changing.
- Run as non-root, no secrets in layers or build args, pin base images by version (digest for
  production), scan with the scanner the pipeline already uses.
- Local dev: one compose file with health checks for dependency ordering.

### Kubernetes
- Deployment for stateless services, Job/CronJob for batch. Databases on a managed service unless
  the team already operates them in-cluster (then StatefulSet with tested backup and restore).
- Requests on every container, memory limits always; CPU limits per the cluster's policy (they cause
  throttling on latency-sensitive services).
- Replicas: fixed count when load is steady; HPA when load varies and a metric tracks it. A
  PodDisruptionBudget once there are two or more replicas.
- Probes: readiness gates traffic; liveness only for a hang the process cannot detect itself, and
  never pointed at a dependency check (it restarts healthy pods during a DB outage). Startup probe
  for slow starts.
- Config in ConfigMaps, credentials in Secrets or the platform's secret manager (encrypted at rest).
  Spring services bind them through `@ConfigurationProperties`.
- Least-privilege ServiceAccounts, no `hostNetwork`, NetworkPolicy where the cluster enforces it.

### Terraform
- Remote state with locking, separate state per environment, never committed.
- Directory per long-lived environment; workspaces only for ephemeral ones.
- `terraform plan` in CI on every PR; `apply` only from a reviewed plan, never `-auto-approve` in
  production. `destroy`, `state rm`, imports, and resource replacement need explicit confirmation
  and a recovery story (backup, snapshot, or recreate path).

### CI/CD and rollout
- Pipeline: lint, unit test, build, integration test, security scan, deploy to staging, smoke test,
  deploy to production.
- Strategy from risk: rolling for most services; canary with metric-based promotion when a bad
  release is costly and traffic is enough to judge; blue-green when instant cutback matters and
  double capacity is affordable.
- Rollback is one documented command to the previous known-good artifact. It is safe only when DB
  migrations are backward compatible (expand, migrate, contract; see `db-migration`).

## Anti-patterns to flag
- Root or privileged containers; `latest` tags; secrets in images, repos, or plain env files
- No probes, or a liveness probe that checks dependencies
- Local or committed Terraform state; `apply -auto-approve` in production
- A rollback path that cannot undo a schema change

## Workflow context
- Follows `design-doc` or `spec-to-impl` (DEVOPS agent); `migration-plan` covers moving existing systems.
- Feeds `monitoring-plan`, `runbook`, and `security-review`; `performance-review` for resource sizing.

## Output contract
```yaml
produces:
  - type: infra-design
    format: markdown
    path: "claudedocs/<service>-infra-design.md"
    sections: [docker, kubernetes, terraform, cicd, deployment_strategy, rollback]
    handoff: "Write claudedocs/handoff-infra-design-<timestamp>.yaml - suggest: spec-to-impl, monitoring-plan"
```
