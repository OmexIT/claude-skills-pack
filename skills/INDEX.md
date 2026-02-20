# Skills Index

## Product Discovery & Strategy
- **/opportunity-assessment** — Evaluate whether to build a feature (cost/benefit/risk/alignment)
- **/competitive-analysis** — Structured competitor and market positioning analysis
- **/go-to-market** — Launch plan with messaging, channels, enablement, and measurement

## Planning & Requirements
- **/prd** — Product Requirements Document (templates/prd.md)
- **/design-doc** — System design / RFC (templates/design-doc.md)
- **/adr** — Architecture Decision Record (templates/adr.md)
- **/user-flow** — User journey mapping with states, errors, and edge cases
- **/api-design** — API design and review (REST, GraphQL, RPC patterns)
- **/ticket-breakdown** — Break PRD/design into epics + tickets (templates/ticket-breakdown.md)
- **/experiment-design** — A/B test / staged rollout plan (templates/experiment-plan.md)
- **/decision-matrix** — Structured decision-making with weighted criteria
- **/migration-plan** — Safe migration planning (database, API, infrastructure)

## Quality & Review
- **/pr-review** — Structured PR review (**manual-only**)
- **/test-plan** — Risk-based test plan (templates/test-plan.md)
- **/security-review** — Threat-model-lite with OWASP-aligned checks
- **/performance-review** — Performance analysis and optimization plan
- **/ux-review** — Heuristic evaluation, accessibility audit, cognitive walkthrough
- **/docs-review** — Doc clarity + consistency checklist (references/style-guide.md)
- **/metrics-review** — Analytics instrumentation and data quality audit
- **/tech-debt-assessment** — Inventory, prioritize, and plan debt repayment

## Release & Operations
- **/release-notes** — Release notes draft (**manual-only**)
- **/monitoring-plan** — Observability strategy (metrics, alerts, dashboards, SLOs)
- **/runbook** — Operational runbook for deployment, scaling, and recovery
- **/incident-response** — Incident workflow + status updates (**manual-only**)
- **/postmortem** — Blameless postmortem (**manual-only**)

## Team & Communication
- **/stakeholder-update** — Structured status update for leadership (**manual-only**)
- **/sprint-retro** — Sprint retrospective facilitation (**manual-only**)
- **/onboarding-doc** — New team member onboarding guide

## Project Setup
- **/claude-md** — Generate a CLAUDE.md project configuration file for Claude Code

## Auto-guidance
- **repo-conventions** — Repo-specific conventions (**auto guidance; not a slash command**)

---

## Workflow chain

```
Discover         Plan              Build            Quality           Release          Operate
─────────        ──────            ─────            ───────           ───────          ───────
/opportunity  →  /prd          →  /ticket-       →  /pr-review   →  /release-     →  /monitoring
-assessment      /design-doc      breakdown         /test-plan       notes            -plan
/competitive  →  /adr             /experiment-      /security-    →  /go-to-       →  /runbook
-analysis        /user-flow       design            review           market        →  /incident-
                 /api-design                        /performance-    /stakeholder-    response
                 /decision-                         review           update        →  /postmortem
                 matrix                             /ux-review
                 /migration-                        /metrics-
                 plan                               review
                                                    /tech-debt-
                                                    assessment
```
