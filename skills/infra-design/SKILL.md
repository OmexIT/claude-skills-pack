---
name: infra-design
description: >
  Design infrastructure architecture: Docker containers, Kubernetes orchestration, Terraform IaC,
  CI/CD pipelines, and deployment strategies. Triggers: "infra design", "infrastructure",
  "deployment architecture", "k8s design", "terraform", "docker architecture", "CI/CD pipeline".
argument-hint: "[service / feature / environment]"
effort: high
---

# Infrastructure design

## What I'll do
Design the container, orchestration, IaC, and deployment architecture for a service or feature. Produce actionable configs, not just diagrams.

## Inputs I'll use (ask only if missing)
- Service(s) to deploy (or handoff artifact from /design-doc)
- Target environment (local dev, staging, production)
- Scale requirements (expected traffic, data volume)
- Existing infra (current Docker/K8s/Terraform setup)
- CI/CD platform (GitHub Actions, GitLab CI, Jenkins)
- Cloud provider constraints (AWS, GCP, Azure, on-prem)

## How I'll think about this

### Docker
1. **Multi-stage builds**: Build stage (compile, test) → Runtime stage (minimal base image). Never ship build tools in production images.
2. **Layer optimization**: Order Dockerfile instructions from least-changing (OS packages) to most-changing (application code). Maximize cache hits.
3. **Security**: Non-root user. No secrets in image layers. Scan with Trivy/Grype. Pin base image versions (not `latest`).
4. **Compose for local dev**: All services (app, DB, cache, search) in one `docker-compose.yml`. Health checks for dependency ordering. Named volumes for data persistence.

### Kubernetes
5. **Resource design**: Deployment for stateless services. StatefulSet for databases. Job/CronJob for batch. Never bare Pods.
6. **Scaling**: HPA with CPU + custom metrics. PodDisruptionBudget for availability during rollouts. Resource requests AND limits on every container.
7. **Networking**: Service for internal communication. Ingress for external. NetworkPolicy to restrict pod-to-pod traffic. No `hostNetwork: true`.
8. **Configuration**: ConfigMap for non-sensitive config. Secret for credentials (encrypted at rest). `@ConfigurationProperties` maps to environment variables from ConfigMap.
9. **Health**: Liveness probe (restart if stuck). Readiness probe (remove from LB if unhealthy). Startup probe for slow-starting apps. Different endpoints for each.
10. **RBAC**: Least-privilege ServiceAccounts. No `cluster-admin` for application pods. Namespace isolation.

### Terraform
11. **Module structure**: One module per logical resource group. Shared modules in `modules/`. Environment configs in `environments/{dev,staging,prod}/`.
12. **State management**: Remote state backend (S3/GCS with locking). Never local state in production. State per environment, not shared.
13. **Workspaces vs directories**: Prefer directory-per-environment over workspaces for production. Workspaces acceptable for ephemeral environments.
14. **Drift detection**: `terraform plan` in CI on every PR. Alert on drift between state and reality. Never `terraform apply` without plan review.

### CI/CD
15. **Pipeline design**: Lint → Unit Test → Build → Integration Test → Security Scan → Deploy Staging → Smoke Test → Deploy Prod.
16. **Deployment strategy**: Blue-green for zero-downtime. Canary for gradual rollout with metrics-based promotion. Rolling update for simple services.
17. **Rollback**: Every deployment must have a one-command rollback. Tag the previous known-good deployment. Automated rollback on health check failure.

## Anti-patterns to flag
- ⚠️ Privileged containers or running as root
- ⚠️ No resource limits on K8s pods (OOM kills, noisy neighbors)
- ⚠️ Terraform state stored in git or local filesystem
- ⚠️ Hardcoded replicas instead of HPA
- ⚠️ `latest` tag on Docker images (non-reproducible deploys)
- ⚠️ Secrets in environment variables without encryption at rest
- ⚠️ Single point of failure (single replica, no PDB)
- ⚠️ No health checks or probes configured
- ⚠️ `terraform apply -auto-approve` in production

## Quality bar
- ✅ Docker images are multi-stage, non-root, and scanned
- ✅ K8s resources have requests, limits, probes, and PDB
- ✅ Terraform state is remote with locking
- ✅ CI/CD pipeline includes security scanning stage
- ✅ Rollback procedure is documented and tested
- ✅ All secrets are managed through Secret/Vault (never in code)
- ✅ Local dev environment works with `docker compose up`

## Workflow context
- Typically follows: `/design-doc`, `/spec-to-impl` (DEVOPS agent)
- Feeds into: `/monitoring-plan`, `/runbook`, `/security-review`
- Related: `/migration-plan` (deployment changes), `/performance-review` (resource sizing)

## Learning & Memory

After infrastructure design completes, save:
- Infrastructure patterns chosen (container strategies, orchestration configs, IaC module structures) and their operational outcomes
- Deployment strategies that worked for this service profile (blue-green, canary, rolling) and the metrics that confirmed success
- Scaling configurations (resource limits, HPA thresholds, replica counts) that matched actual traffic patterns

## Output contract
```yaml
produces:
  - type: infra-design
    format: markdown
    path: "claudedocs/<service>-infra-design.md"
    sections: [docker, kubernetes, terraform, cicd, deployment_strategy, rollback]
    handoff: "Write claudedocs/handoff-infra-design-<timestamp>.yaml — suggest: spec-to-impl, monitoring-plan"
```
