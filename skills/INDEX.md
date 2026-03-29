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

## Auto-guidance
- **repo-conventions** — Repo-specific conventions (**auto guidance; not a slash command**)
- **handoff** — Inter-skill artifact protocol for chaining (**auto guidance; not a slash command**)

---

## Claude Code Features Leveraged

Skills in this pack leverage these Claude Code capabilities:

### Parallel Execution
- **Multi-agent orchestration**: Orchestrator skills (spec-to-impl, code-audit, ui-design, spec-panel) launch multiple Agent calls in a single message for parallel execution
- **Wave-based dispatch**: Complex skills execute in coordinated waves — independent agents run concurrently, dependent agents wait for prerequisites
- **Background agents**: Low-priority agents (TECH_WRITER, OBS, COPY) run with `run_in_background: true` while critical-path agents execute
- **Parallel expert panels**: Review skills (security-review, performance-review, ux-review) spawn specialist agents in parallel for multi-perspective analysis

### Agent Configuration
- **Model routing**: Agents route to optimal models — `opus` for architecture/security/deep reasoning, `sonnet` for implementation/analysis, `haiku` for documentation/lightweight tasks
- **Effort levels**: Skills declare `effort: high|medium` in frontmatter to control reasoning depth
- **Context isolation**: Complex skills use `context: fork` to run in subagent context, preserving the user's main conversation
- **Worktree isolation**: Parallel implementation agents use `isolation: "worktree"` for conflict-free concurrent code changes

### Coordination
- **Handoff protocol**: Skills chain via `claudedocs/handoff-<skill>-<timestamp>.yaml` manifests with artifact status tracking
- **Task management**: Skills use TaskCreate/TaskUpdate for real-time progress tracking visible to the user
- **Memory integration**: Skills save reusable patterns (architecture decisions, review findings, performance baselines) to memory for cross-session learning
- **Agent Teams** (experimental): For complex specs with tightly-coupled agents that need direct communication

### MCP Integration
- **Figma MCP**: spec-to-impl DESIGN agent extracts design tokens, components, and layouts from Figma (use `figma` official plugin for full Figma workflows)
- **Stitch MCP**: ui-design generates screens from text specifications when Stitch is available
- **Chrome DevTools / Playwright**: verify-impl automates browser-based UI verification

---

## Skill Chaining — Input/Output Contracts

Skills produce structured output that downstream skills consume. The `/handoff` auto-guidance skill manages discovery.

```
SKILL              PRODUCES (type)           CONSUMED BY
─────              ───────────────           ───────────
── Discovery ──
/opportunity    →  assessment             →  /prd, /decision-matrix
/competitive    →  analysis               →  /prd, /go-to-market

── Planning ──
/prd            →  prd                    →  /design-doc, /ticket-breakdown, /spec-to-impl, /spec-panel
/design-doc     →  design-doc             →  /spec-to-impl, /test-plan, /security-review, /infra-design, /spec-panel
/adr            →  adr                    →  /design-doc
/user-flow      →  user-flow             →  /flow-map, /ux-review, /test-plan, /ui-design
/flow-map       →  flow-map              →  /spec-to-impl, /test-plan
/ui-design      →  ui-design + testids   →  /spec-to-impl (FE), /verify-impl (testIDs)
/api-design     →  api-design            →  /spec-to-impl, /test-plan, /spec-panel
/data-design    →  data-design           →  /spec-to-impl (DBA), /migration-plan
/search-design  →  search-design         →  /spec-to-impl, /data-design
/infra-design   →  infra-design          →  /spec-to-impl (DEVOPS), /monitoring-plan
/ticket-break.. →  tickets               →  /spec-to-impl
/experiment-..  →  experiment-plan       →  /ticket-breakdown, /metrics-review
/decision-mat.. →  decision              →  /adr, /design-doc
/migration-plan →  migration-plan        →  /ticket-breakdown, /test-plan, /runbook

── Implementation ──
/spec-to-impl   →  code + test-plan      →  /verify-impl, /finalize, /code-audit, /monitoring-plan
                    + obs-contract
/mobile-dev     →  mobile-guidance       →  /spec-to-impl (FLUTTER/RN/ANDROID)
/verify-impl    →  verification          →  /finalize, /evidence-review
/finalize       →  commit + PR           →  /release-notes

── Quality ──
/spec-panel     →  panel-analysis        →  /spec-to-impl, /ticket-breakdown, /test-plan
/code-audit     →  code-audit            →  /finalize, /tech-debt-assessment, /test-plan
/test-plan      →  test-plan             →  /spec-to-impl (QA planning input)
/security-rev.. →  security-review       →  /finalize, /test-plan
/performance-.. →  performance-review    →  /test-plan, /monitoring-plan
/ux-review      →  ux-review             →  /ticket-breakdown
/docs-review    →  docs-review           →  /finalize
/metrics-rev..  →  metrics-review        →  /experiment-design
/evidence-rev.. →  evidence-review       →  /finalize
/tech-debt-..   →  assessment            →  /ticket-breakdown, /design-doc
/debug-triage   →  triage                →  /postmortem, /test-plan

── Operations ──
/monitoring     →  monitoring-plan       →  /runbook, /incident-response
```

## Workflow chain

```
Discover         Plan              Build              Quality            Complete         Operate
─────────        ──────            ─────              ───────            ────────         ───────
/opportunity  →  /prd          →  /flow-map       →  /evidence-     →  /finalize     →  /monitoring
-assessment      /design-doc      /ui-design          review            (commit+PR)      -plan
/competitive  →  /adr             /spec-to-impl                    →  /release-     →  /runbook
-analysis        /user-flow       /mobile-dev        /test-plan        notes         →  /incident-
                 /flow-map        /verify-impl
                 /ui-design
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
