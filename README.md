# Claude Code Skills Pack

**43 ready-to-use skills for Claude Code** covering the entire software development lifecycle — from discovery and planning through design, implementation, verification, quality review, release, and operations.

Skills range from lightweight methodology guides (50-100 lines) to comprehensive multi-agent orchestrators (500+ lines) that coordinate parallel implementation from a spec document.

---

## What are Claude Code Skills?

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) is Anthropic's AI coding agent that runs in your terminal and IDE. **Skills** are reusable prompt packages that extend Claude Code with domain-specific expertise. They're invoked as slash commands:

```
> /prd Build a collaborative document editor
> /spec-to-impl claudedocs/PRD.md
> /verify-impl --api --db --ui
> /finalize
```

When you invoke a skill, Claude loads the methodology, applies structured thinking, and produces output using professional templates.

---

## What's Included

### Product Discovery & Strategy (3 skills)
| Skill | What it does |
|-------|-------------|
| `/opportunity-assessment` | Evaluate whether to build a feature — cost, benefit, risk, strategic alignment |
| `/competitive-analysis` | Structured competitor landscape, feature comparison, differentiation |
| `/go-to-market` | Launch plan with messaging, channels, enablement, and measurement |

### Planning & Requirements (13 skills)
| Skill | What it does |
|-------|-------------|
| `/prd` | Product requirements document — problem, goals, users, scope, metrics |
| `/design-doc` | System design / RFC — architecture, data model, APIs, alternatives |
| `/adr` | Architecture decision record — context, decision, alternatives, consequences |
| `/user-flow` | User journey mapping — states, decisions, error recovery, accessibility |
| `/flow-map` | Pre-implementation path mapping — happy, failure, timeout, recovery paths |
| `/ui-design` | Multi-agent UI/UX design — wireframes, tokens, components, a11y, testIDs |
| `/api-design` | API design review — naming, versioning, error contracts, pagination |
| `/data-design` | Polyglot data architecture — PostgreSQL, MongoDB, Elasticsearch, Typesense |
| `/search-design` | Search infrastructure — Elasticsearch + Typesense index, mapping, relevance |
| `/infra-design` | Infrastructure architecture — Docker, Kubernetes, Terraform, CI/CD |
| `/ticket-breakdown` | Break specs into epics + engineering tickets with acceptance criteria |
| `/experiment-design` | A/B test or staged rollout — hypothesis, metrics, guardrails |
| `/decision-matrix` | Weighted criteria evaluation for complex choices |
| `/migration-plan` | Safe database/API/infrastructure migration with rollback |

### Implementation & Verification (4 skills)
| Skill | What it does |
|-------|-------------|
| `/spec-to-impl` | **Multi-agent orchestrator**: spec → tasks → parallel implementation → tested artifacts |
| `/verify-impl` | **Live verification**: API (curl), DB (Postgres/Mongo/Elastic/Typesense), UI (Playwright), Mobile |
| `/mobile-dev` | Mobile development patterns — Flutter, React Native, Android (Kotlin) |
| `/finalize` | Post-implementation — lint → test → clean up → commit → PR |

### Quality & Review (10 skills)
| Skill | What it does |
|-------|-------------|
| `/pr-review` | Structured code review — correctness, security, performance, testing |
| `/evidence-review` | **Default-to-rejection QA gate** — requires proof, not claims |
| `/test-plan` | Risk-based test strategy with coverage matrix |
| `/security-review` | Threat-model-lite with OWASP-aligned checks |
| `/performance-review` | Performance analysis — hot paths, query patterns, caching |
| `/ux-review` | Heuristic evaluation + WCAG accessibility audit |
| `/docs-review` | Documentation clarity, correctness, and consistency review |
| `/metrics-review` | Analytics instrumentation and data quality audit |
| `/tech-debt-assessment` | Inventory, categorize, and prioritize technical debt |
| `/debug-triage` | Bug triage — reproduction, hypotheses, bisection, minimal fix |

### Release & Operations (5 skills)
| Skill | What it does |
|-------|-------------|
| `/release-notes` | Release notes — highlights, breaking changes, rollback |
| `/monitoring-plan` | Observability strategy — golden signals, SLOs, alerts, dashboards |
| `/runbook` | Operational runbook — deployment, scaling, failure recovery |
| `/incident-response` | Incident workflow — severity, roles, stabilization |
| `/postmortem` | Blameless postmortem — timeline, root causes, action items |

### Team & Communication (4 skills)
| Skill | What it does |
|-------|-------------|
| `/stakeholder-update` | Structured status update — progress, risks, decisions needed |
| `/sprint-retro` | Sprint retrospective — patterns, wins, improvements |
| `/onboarding-doc` | New team member guide — setup, architecture, tribal knowledge |
| `/linkedin-post` | LinkedIn post draft — hook, body, CTA optimized for engagement |

### Project Setup (1 skill)
| Skill | What it does |
|-------|-------------|
| `/claude-md` | Generate a CLAUDE.md project config for Claude Code |

### Auto-guidance (2 skills)
| Skill | What it does |
|-------|-------------|
| `repo-conventions` | Repo-specific conventions applied automatically (not a slash command) |
| `handoff` | Inter-skill artifact protocol for chaining (not a slash command) |

---

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated

### Quick install (personal — all projects)

```bash
git clone https://github.com/OmexIT/claude-skills-pack.git
mkdir -p ~/.claude/skills
cp -R claude-skills-pack/skills/* ~/.claude/skills/
```

Skills are immediately available — no restart needed.

### Team install (per-repository)

```bash
git clone https://github.com/OmexIT/claude-skills-pack.git /tmp/skills-pack
mkdir -p .claude/skills
cp -R /tmp/skills-pack/skills/* .claude/skills/
rm -rf /tmp/skills-pack
git add .claude/skills && git commit -m "chore: add Claude Code skills pack"
```

---

## Usage Guide

### Basic usage

Type `/` followed by the skill name:

```
> /prd User authentication with SSO support
> /design-doc Payment processing service
> /security-review src/api/auth/
```

### Skill chaining — the full workflow

Skills are designed to feed into each other. Each skill produces structured output with an **output contract** that downstream skills consume automatically via the **handoff protocol**.

#### Example: Feature from idea to PR

```bash
# 1. Validate the idea
/opportunity-assessment "Add payment link feature for merchants"

# 2. Write requirements
/prd Payment links — merchants can generate shareable payment URLs

# 3. Design the system
/design-doc @claudedocs/PRD-payment-links.md

# 4. Design the UI (if applicable)
/ui-design @claudedocs/DESIGN-DOC-payment-links.md

# 5. Design the data layer
/data-design @claudedocs/DESIGN-DOC-payment-links.md

# 6. Map all paths before coding
/flow-map @claudedocs/DESIGN-DOC-payment-links.md

# 7. Implement everything from the spec
/spec-to-impl claudedocs/DESIGN-DOC-payment-links.md

# 8. Verify the implementation
/verify-impl

# 9. Final quality gate
/evidence-review

# 10. Ship it
/finalize
```

Each step discovers the previous step's output automatically (via `claudedocs/handoff-*.yaml`).

#### Example: Quick bug fix

```bash
/debug-triage "NullPointerException in PaymentService.processRefund()"
# → Fix the bug
/finalize
```

#### Example: Mobile feature

```bash
/mobile-dev --platform flutter "Add biometric authentication"
/spec-to-impl claudedocs/PRD-biometric-auth.md
/verify-impl --mobile
/finalize
```

### Comprehensive skills (multi-agent orchestrators)

Three skills are significantly more powerful than the rest — they orchestrate parallel agent teams:

#### `/spec-to-impl` — Spec to Implementation

Transforms a specification document into working, tested code using parallel agents.

```bash
# Single spec
/spec-to-impl docs/PRD.md

# Multiple spec files (merged as one project)
/spec-to-impl docs/MONEY_REQUEST.md docs/PAYMENT_LINK.md

# Check progress mid-execution
status

# Add a task mid-execution
add task: add rate limiting to the payment API
```

**How it works:**
1. **PARSE** — Reads spec, extracts requirements, APIs, entities, runs build check
2. **PLAN** — Creates task board, assigns to agents (BE, FE, Flutter, DBA, QA, etc.), generates `e2e/test-plan.yaml`
3. **EXECUTE** — Dispatches agents in parallel waves using Git worktrees

**Key features:**
- 12 agent types: ARCH, BE, FE, Flutter, RN, Android, AngularJS, QA, DBA, DEVOPS, SEC, TECH_WRITER
- Mandatory codebase scan (prevents duplicate patterns)
- Evidence-based wave gates (no "tests pass" without proof)
- 3-retry budget with escalation (reassign / decompose / revise / defer)
- Cleanup phase (worktree pruning, branch deletion, handoff artifact)

**Supported stacks:**
| Layer | Technologies |
|---|---|
| Backend | Java 21 + Spring Boot 3.x |
| Frontend (Web) | React 18 + TypeScript + Tailwind, AngularJS |
| Frontend (Mobile) | Flutter, React Native, Android (Kotlin) |
| Database | PostgreSQL, MongoDB |
| Search | Elasticsearch, Typesense |
| Infrastructure | Docker, Kubernetes, Terraform |
| Testing | JUnit 5, Vitest, Playwright, Flutter tests, Detox, Espresso |

#### `/verify-impl` — Live Verification

Validates implementation through 4 verification layers against a running system.

```bash
# Auto-discover test plan, run all layers
/verify-impl

# Specific layers
/verify-impl --api --db
/verify-impl --ui
/verify-impl --mobile

# Specific test cases
/verify-impl --tc TC-001 TC-003

# From a spec (no test plan yet)
/verify-impl path/to/spec.md
```

**4 verification layers:**

| Layer | What it checks | Tool |
|---|---|---|
| **API** | HTTP status codes, response bodies, auth enforcement, validation | `curl` |
| **Database** | Row existence, field values, referential integrity, ledger balance | `psql`, `mongosh`, Elasticsearch API, Typesense API |
| **UI** | Element visibility, form submission, navigation, screenshots | Playwright |
| **Mobile** | Widget tests, component tests, device emulation | Flutter test, Jest, Espresso |

**Output:** Pass/fail per test case with evidence (actual output, screenshots, query results).

#### `/ui-design` — Multi-Agent UI/UX Design

Produces complete design artifacts from a spec — ready for implementation.

```bash
# Design from spec
/ui-design claudedocs/PRD.md

# Platform-specific
/ui-design docs/SPEC.md --platform flutter

# Tokens only
/ui-design docs/SPEC.md --tokens-only
```

**5 design agents:** UX Lead, UI Designer, Component Architect, Accessibility Reviewer, UX Copywriter

**Produces:**
- UX inventory + IA map + user flows
- ASCII wireframes (default + loading + empty + error states)
- Design tokens (CSS vars / Tailwind config / Flutter ThemeExtension)
- Component specs with props, state model, and data-testIDs
- Accessibility audit (WCAG 2.1 AA + keyboard + ARIA + screen reader)
- UX copy spec (all labels, errors, empty states, tooltips)

### Evidence-based quality gate

`/evidence-review` defaults to **NEEDS WORK** — the opposite of typical reviews:

```bash
/evidence-review
```

**Automatic FAIL triggers:**
- Zero issues reported (impossible for real implementations)
- "Tests pass" without actual test runner output
- Screenshots from a design tool, not the running app
- Perfect scores without supporting documentation

**Rating scale:** REJECT → NEEDS WORK → CONDITIONAL PASS → PASS

### Post-implementation finalization

`/finalize` handles everything after coding is done:

```bash
/finalize
```

**Pipeline:** Scan → Lint → Test → Clean → Stage → Commit → PR

- Runs language-appropriate linters (checkstyle, eslint, dart analyze, ktlint)
- Runs test suites and shows actual output
- Cleans orphaned worktrees, stale branches, temp files
- Creates conventional commit with correct type and scope
- Creates PR with summary and test evidence

### Thin skills (methodology guides)

The remaining 32 skills are lightweight methodology guides (50-100 lines) that teach Claude *how to think* about a specific task:

```bash
# Planning
/prd Feature X                    # → claudedocs/PRD-feature-x.md
/design-doc @claudedocs/PRD.md    # → claudedocs/DESIGN-DOC-feature-x.md
/api-design POST /api/v1/payments # → claudedocs/api-design-payments.md
/data-design payments entity      # → claudedocs/data-design-payments.md

# Review
/security-review src/auth/        # → claudedocs/security-review-auth.md
/performance-review src/payments/  # → claudedocs/performance-review-payments.md
/ux-review /dashboard              # → claudedocs/ux-review-dashboard.md

# Operations
/monitoring-plan payment-service   # → claudedocs/monitoring-plan-payments.md
/runbook payment-service           # → claudedocs/runbook-payments.md
/incident-response                 # → guided incident workflow
```

Each thin skill includes:
- **Methodology** — structured thinking approach (5-8 steps)
- **Anti-patterns** — common mistakes to avoid
- **Quality bar** — concrete success criteria
- **Workflow context** — what comes before/after
- **Output contract** — structured output for downstream skills

---

## Skill Chaining

Skills produce structured output that downstream skills consume via the **handoff protocol**. The `handoff` auto-guidance skill manages discovery.

```
SKILL              PRODUCES (type)           CONSUMED BY
─────              ───────────────           ───────────
/prd            →  prd                    →  /design-doc, /spec-to-impl
/design-doc     →  design-doc             →  /spec-to-impl, /ui-design, /data-design
/ui-design      →  ui-design + testids   →  /spec-to-impl (FE), /verify-impl
/flow-map       →  flow-map              →  /spec-to-impl, /test-plan
/data-design    →  data-design           →  /spec-to-impl (DBA)
/spec-to-impl   →  code + test-plan      →  /verify-impl, /finalize
/verify-impl    →  verification          →  /finalize, /evidence-review
/evidence-rev.. →  review (rated)        →  /finalize
/finalize       →  commit + PR           →  /pr-review, /release-notes
```

Each skill writes a handoff artifact to `claudedocs/handoff-<skill>-<timestamp>.yaml` containing: produced artifacts, quality assessment, and context for the next skill.

---

## Lifecycle

```
Discover         Plan              Build              Quality            Complete         Operate
─────────        ──────            ─────              ───────            ────────         ───────
/opportunity  →  /prd          →  /ui-design       →  /evidence-     →  /finalize     →  /monitoring
-assessment      /design-doc      /flow-map            review            (commit+PR)      -plan
/competitive  →  /adr             /spec-to-impl      /pr-review     →  /release-     →  /runbook
-analysis        /flow-map        /mobile-dev        /test-plan        notes         →  /incident-
                 /ui-design       /verify-impl       /security-     →  /go-to-          response
                 /api-design                         review            market        →  /postmortem
                 /data-design                        /performance-
                 /search-design                      review
                 /infra-design                       /ux-review
                 /ticket-                            /metrics-
                 breakdown                           review
                 /decision-                          /tech-debt-
                 matrix                              assessment
                 /migration-
                 plan
```

---

## Customization

### Adapt to your team

1. **Edit repo conventions** — Fill in `skills/repo-conventions/references/*` with your actual architecture, API style, and testing standards
2. **Tune triggers** — Modify the `description` field in each skill's frontmatter to match your vocabulary
3. **Swap templates** — Replace templates with your org's existing formats
4. **Adjust quality bars** — Modify anti-patterns and criteria to match your standards

### Create your own skill

```
my-skill/
├── SKILL.md          # Required: frontmatter + methodology
└── templates/        # Optional: output templates
    └── output.md
```

Every skill follows this structure:

```yaml
---
name: my-skill
description: When to trigger this skill...
argument-hint: "[context]"
---

# My Skill

## What I'll do
## Inputs I'll use
## How I'll think about this
## Anti-patterns to flag
## Quality bar
## Workflow context
## Output contract
```

---

## Contributing

1. Create a folder in `skills/` with your skill name
2. Add a `SKILL.md` following the standard structure
3. Add templates in `templates/` if the skill produces a document
4. Update `skills/INDEX.md` with your skill in the appropriate category
5. Submit a PR

---

## License

MIT — use, modify, and distribute freely. See [LICENSE](LICENSE).
