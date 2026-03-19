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
- **/flow-map** — Pre-implementation path mapping: happy, failure, timeout, recovery paths
- **/ui-design** — Multi-agent UI/UX design: wireframes, tokens, components, a11y, testIDs (React, Flutter, RN, AngularJS)
- **/api-design** — API design and review (REST, GraphQL, RPC patterns)
- **/data-design** — Polyglot data architecture: PostgreSQL, MongoDB, Elasticsearch, Typesense
- **/search-design** — Search infrastructure: Elasticsearch + Typesense index, mapping, relevance
- **/infra-design** — Infrastructure architecture: Docker, Kubernetes, Terraform, CI/CD
- **/ticket-breakdown** — Break PRD/design into epics + tickets (templates/ticket-breakdown.md)
- **/experiment-design** — A/B test / staged rollout plan (templates/experiment-plan.md)
- **/decision-matrix** — Structured decision-making with weighted criteria
- **/migration-plan** — Safe migration planning (database, API, infrastructure)

## Implementation & Verification
- **/spec-to-impl** — Multi-agent orchestration: spec → tasks → parallel implementation → tested artifacts
- **/verify-impl** — Live verification: API, DB (Postgres/Mongo/Elastic/Typesense), UI (Playwright), Mobile
- **/mobile-dev** — Mobile development patterns: Flutter, React Native, Android (Kotlin)
- **/finalize** — Post-implementation: lint → test → clean up → commit → PR

## Quality & Review
- **/pr-review** — Structured PR review (**manual-only**)
- **/evidence-review** — Default-to-rejection quality gate requiring proof, not claims
- **/spec-panel** — Multi-expert spec analysis: IEEE 830 audit, spec smells scanner, cross-cutting concerns checklist, expert panel with devil's advocate, quality scoring
- **/code-audit** — Multi-agent code review: 10-dimension analysis (smells, SOLID, duplication, algorithms, security, performance, patterns, architecture, tech fitness, devil's advocate) with quality scoring
- **/test-plan** — Risk-based test plan (templates/test-plan.md)
- **/security-review** — Threat-model-lite with OWASP-aligned checks
- **/performance-review** — Performance analysis and optimization plan
- **/ux-review** — Heuristic evaluation, accessibility audit, cognitive walkthrough
- **/docs-review** — Doc clarity + consistency checklist (references/style-guide.md)
- **/metrics-review** — Analytics instrumentation and data quality audit
- **/tech-debt-assessment** — Inventory, prioritize, and plan debt repayment
- **/debug-triage** — Bug triage: reproduction, hypotheses, bisection, minimal fix

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
- **/linkedin-post** — LinkedIn post draft with hook, body, and CTA optimized for engagement

## Project Setup
- **/claude-md** — Generate a CLAUDE.md project configuration file for Claude Code

## Auto-guidance
- **repo-conventions** — Repo-specific conventions (**auto guidance; not a slash command**)
- **handoff** — Inter-skill artifact protocol for chaining (**auto guidance; not a slash command**)

---

## Skill Chaining — Input/Output Contracts

Skills produce structured output that downstream skills consume. The `/handoff` auto-guidance skill manages discovery.

```
SKILL              PRODUCES (type)           CONSUMED BY
─────              ───────────────           ───────────
/opportunity    →  assessment             →  /prd, /decision-matrix
/competitive    →  analysis               →  /prd, /go-to-market
/prd            →  prd                    →  /design-doc, /ticket-breakdown, /spec-to-impl, /spec-panel
/design-doc     →  design-doc             →  /spec-to-impl, /test-plan, /security-review, /infra-design, /spec-panel
/adr            →  adr                    →  /design-doc
/flow-map       →  flow-map              →  /spec-to-impl, /test-plan
/data-design    →  data-design           →  /spec-to-impl (DBA), /migration-plan
/search-design  →  search-design         →  /spec-to-impl, /data-design
/infra-design   →  infra-design          →  /spec-to-impl (DEVOPS), /monitoring-plan
/ui-design      →  ui-design + testids   →  /spec-to-impl (FE), /verify-impl (testIDs)
/api-design     →  api-design            →  /spec-to-impl, /test-plan, /spec-panel
/mobile-dev     →  mobile-guidance       →  /spec-to-impl (FLUTTER/RN/ANDROID)
/ticket-break.. →  tickets               →  /spec-to-impl
/spec-panel     →  panel-analysis        →  /spec-to-impl, /ticket-breakdown, /test-plan
/code-audit     →  code-audit            →  /finalize, /tech-debt-assessment, /test-plan
/spec-to-impl   →  code + test-plan      →  /verify-impl, /finalize, /pr-review, /code-audit
/verify-impl    →  verification          →  /finalize, /evidence-review
/evidence-rev.. →  review (rated)        →  /finalize
/finalize       →  commit + PR           →  /pr-review, /release-notes
/test-plan      →  test-plan             →  /verify-impl, /spec-to-impl
/security-rev.. →  review                →  /finalize, /test-plan
/pr-review      →  review                →  /release-notes
/monitoring     →  monitoring-plan       →  /runbook, /incident-response
```

## Workflow chain

```
Discover         Plan              Build              Quality            Complete         Operate
─────────        ──────            ─────              ───────            ────────         ───────
/opportunity  →  /prd          →  /flow-map       →  /evidence-     →  /finalize     →  /monitoring
-assessment      /design-doc      /ui-design          review            (commit+PR)      -plan
/competitive  →  /adr             /spec-to-impl      /pr-review     →  /release-     →  /runbook
-analysis        /flow-map        /mobile-dev        /test-plan        notes         →  /incident-
                 /ui-design       /verify-impl
                 /api-design                         /spec-panel    →  /go-to-          response
                 /data-design                        /code-audit       market        →  /postmortem
                 /search-design                      /security-
                 /infra-design                       review
                 /ticket-                            /performance-
                 breakdown                           review
                 /decision-                          /ux-review
                 matrix                              /metrics-
                 /migration-                         review
                 plan                                /tech-debt-
                                                    assessment
```
