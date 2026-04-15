# Claude Code Skills Pack

**52 ready-to-use skills for Claude Code** covering the entire software development lifecycle — from discovery and planning through design, implementation, verification, quality review, release, and operations. Includes 6 domain skills for Java/Spring Boot fintech and iGaming builds (Temporal workflows, double-entry ledgers, API scaffolding, DB migrations, architecture review) and a meta-skill for keeping custom skills in sync with the superpowers plugin workflow.

Skills range from lightweight methodology guides (~80 lines) to comprehensive multi-agent orchestrators (~1500 lines) that coordinate parallel agent teams with model routing, worktree isolation, and wave-based execution. Every code-generation skill is wired into the [superpowers](https://github.com/anthropics/claude-plugins-official) development workflow (brainstorming → plans → TDD → verification → review), so skills compose cleanly instead of going off on their own.

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

### Planning & Requirements (14 skills)
| Skill | What it does |
|-------|-------------|
| `/prd` | Product requirements document with multi-agent generation (Problem Analyst, Requirements Engineer, Metrics Designer, Edge Case Analyst) |
| `/design-doc` | System design / RFC — architecture, data model, APIs, alternatives |
| `/adr` | Architecture decision record — context, decision, alternatives, consequences |
| `/user-flow` | User journey mapping — states, decisions, error recovery, accessibility |
| `/flow-map` | Pre-implementation path mapping — happy, failure, timeout, recovery paths |
| `/ui-design` | **Multi-agent orchestrator**: 6 design agents in parallel waves — wireframes, tokens, components, a11y, testIDs |
| `/api-design` | API design review — naming, versioning, error contracts, pagination |
| `/data-design` | Polyglot data architecture with parallel store analysis — PostgreSQL, MongoDB, Elasticsearch, Typesense |
| `/search-design` | Search infrastructure — Elasticsearch + Typesense index, mapping, relevance |
| `/infra-design` | Infrastructure architecture — Docker, Kubernetes, Terraform, CI/CD |
| `/ticket-breakdown` | Break specs into epics + engineering tickets with acceptance criteria |
| `/experiment-design` | A/B test or staged rollout — hypothesis, metrics, guardrails |
| `/decision-matrix` | Weighted criteria evaluation for complex choices |
| `/migration-plan` | Safe database/API/infrastructure migration with rollback |

### Implementation & Verification (9 skills)
| Skill | What it does |
|-------|-------------|
| `/spec-to-impl` | **Multi-agent orchestrator**: spec → tasks → parallel implementation with 14 agent types, worktree isolation, wave-based dispatch. Stack defaults: Java 25 + Spring Boot 4 + Spring Modulith + Spring Data JDBC / React 19 + Next.js 15. |
| `/figma-to-code` | Convert Figma designs to production React/TypeScript via Figma MCP |
| `/verify-impl` | **Parallel verification**: API + DB + UI + Mobile layers run concurrently with evidence collection |
| `/mobile-dev` | Mobile development patterns — Flutter, React Native, Android (Kotlin) |
| `/temporal-workflow` | Java Temporal SDK 1.26+ workflow scaffold — SAGA compensation, config-driven state machines, retry profiles, Spring Boot wiring, TestWorkflowEnvironment harness |
| `/fintech-ledger` | Double-entry ledger operations — supports **Blnk** (Onbilia) + **pgledger** (PayserFlow) modes with balance invariants, idempotency, FX snapshots, sorted locking, Testcontainers integration tests |
| `/api-first` | OpenAPI 3.1 → Spring Boot 4 controller + service + Spring Data JDBC repo + MapStruct mapper + Jakarta validation + RFC 9457 errors + slice tests + integration tests in one shot |
| `/db-migration` | PostgreSQL migrations for Liquibase (Kifiya) / Flyway 10 (new projects) — audit columns, RLS, destructive-op safety, rollback-tested, CONCURRENTLY indexes |
| `/finalize` | Post-implementation — parallel lint/test → clean up → commit → PR |

### Quality & Review (13 skills)
| Skill | What it does |
|-------|-------------|
| `/pr-review` | Structured code review — correctness, security, performance, testing |
| `/evidence-review` | **Default-to-rejection QA gate** — requires proof, not claims |
| `/spec-panel` | **Multi-expert orchestrator**: IEEE 830 audit + spec smells + cross-cutting concerns + parallel expert panel. Pre-implementation gate — routes to `/spec-update` then `/spec-to-impl` |
| `/code-audit` | **Multi-agent orchestrator**: 10-dimension parallel analysis with model-routed experts and quality scoring |
| `/arch-review` | Clean architecture review — dependency direction, transaction boundaries, no-business-logic-in-controllers, circuit breaker presence, value-object discipline. Produces findings + optional fix-plan mode |
| `/test-plan` | Risk-based test strategy with coverage matrix |
| `/security-review` | **Parallel expert panel**: Auth, Injection, Data Privacy, Abuse analysts |
| `/performance-review` | **Parallel expert panel**: Backend, DB, Frontend, Infrastructure performance |
| `/ux-review` | **Parallel expert panel**: UX Strategist, A11y Expert, Interaction Designer, Visual Designer |
| `/docs-review` | Documentation clarity, correctness, and consistency review |
| `/metrics-review` | Analytics instrumentation and data quality audit |
| `/tech-debt-assessment` | Inventory, categorize, and prioritize technical debt |
| `/debug-triage` | Bug triage with parallel hypothesis investigation |

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

### Meta / Custom Skill Maintenance (1 skill)
| Skill | What it does |
|-------|-------------|
| `/superpowers-integrator` | **Meta-skill**: audits and upgrades custom skills to integrate with the [superpowers](https://github.com/anthropics/claude-plugins-official) development workflow. Classifies a skill (code-generator / reviewer / refactor / debugger / planner / money-critical / sql), runs a per-class checklist, and inserts the correct "Before You Start" workflow block. Re-runnable — when superpowers evolves, update `references/skill-class-taxonomy.md` + `templates/blocks.md` and re-run against all skills for a single-command pack re-sync. |

---

## Superpowers Integration

Every code-generation skill in this pack is wired into the [superpowers](https://github.com/anthropics/claude-plugins-official) plugin's development workflow. Skills don't run in isolation — they chain through a rigid phase sequence:

```
brainstorming  →  writing-plans  →  using-git-worktrees  →  test-driven-development
                                                                   │
                                                                   ▼
                                                         (invoke domain skill)
                                                                   │
                                                                   ▼
                                                         subagent-driven-development
                                                         OR dispatching-parallel-agents
                                                                   │
                                                                   ▼
                                                         verification-before-completion
                                                                   │
                                                                   ▼
                                                         requesting-code-review
```

Different skill classes use different variants of this workflow (money-critical skills make every step mandatory; SQL skills replace TDD with "write verification SQL first"; reviewers skip pre-flight entirely). The full taxonomy lives in `skills/superpowers-integrator/references/skill-class-taxonomy.md` — one source of truth, re-runnable integration audit.

**When superpowers adds a new skill or you learn a better pattern**:
1. Edit `skills/superpowers-integrator/references/skill-class-taxonomy.md` and/or `templates/blocks.md`
2. Run `/superpowers-integrator skills/*/ --audit-only` to find drift
3. Run `/superpowers-integrator skills/*/` to apply upgrades
4. Re-install to `~/.claude/skills/` — the whole pack is re-synced in one pass.

---

## Architecture

### Parallel Execution Model

Skills maximize concurrency at every level:

```
Orchestrator Skills (spec-to-impl, ui-design, code-audit, spec-panel)
├── Wave-based dispatch: independent agents run concurrently
├── Dependency gating: dependent agents wait for prerequisites
├── Background agents: low-priority work runs non-blocking
└── Worktree isolation: parallel code changes without conflicts

Review Skills (security-review, performance-review, ux-review)
├── Parallel expert panels: 3-4 specialist agents per review
├── Phase 1 (sequential): establish shared context
├── Phase 2 (parallel): independent expert analysis
└── Phase 3 (sequential): synthesize findings

Workflow Skills (finalize, verify-impl)
├── Parallel lint/test: multi-stack runs concurrently
├── Parallel verification: API + DB + UI + Mobile layers
└── Background agents: documentation generation non-blocking
```

### Agent Model Routing

Skills route agents to optimal models for cost-efficiency:

| Model | Used For | Skills |
|-------|----------|--------|
| **Opus** | Architecture, security, deep reasoning, design review | ARCH, SEC, DBA, SKEPTIC, COMP_ARCH |
| **Sonnet** | Implementation, analysis, code generation | BE, FE, QA, DEVOPS, lint/test agents |
| **Haiku** | Documentation, lightweight generation | TECH_WRITER, COPY, Typesense design |

### Skill Chaining & Handoff Protocol

Skills produce structured output that downstream skills consume automatically:

```
/prd            →  prd                    →  /design-doc, /spec-to-impl, /ui-design
/design-doc     →  design-doc             →  /spec-to-impl, /test-plan, /security-review
/ui-design      →  ui-design + testids   →  /spec-to-impl (FE), /verify-impl, /figma-to-code
/data-design    →  data-design           →  /spec-to-impl (DBA), /migration-plan
/spec-to-impl   →  code + test-plan      →  /verify-impl, /finalize, /code-audit
/verify-impl    →  verification          →  /finalize, /evidence-review
/finalize       →  commit + PR           →  /pr-review, /release-notes
```

Each skill writes a handoff artifact to `claudedocs/handoff-<skill>-<timestamp>.yaml` containing: produced artifacts, quality assessment, and context for the next skill.

### Memory & Learning

Skills save reusable patterns to Claude Code's memory system after execution:
- **Architecture decisions** that worked well for specific spec types
- **Performance baselines** and optimization patterns per project
- **Security patterns** specific to the project's auth model
- **Review findings** that should inform future work
- **Agent routing** that proved effective (which agents needed opus vs sonnet)

This enables future skill runs to benefit from accumulated project knowledge.

### Claude Code Features Leveraged

| Feature | How Skills Use It |
|---------|-------------------|
| **Agent tool with subagent_type** | Orchestrator skills launch specialized agents |
| **Parallel Agent calls** | Multiple agents in a single message for concurrent execution |
| **Background agents** (`run_in_background`) | Non-blocking low-priority work |
| **Worktree isolation** | Conflict-free parallel code changes |
| **Context forking** (`context: fork`) | Complex skills run in isolated context |
| **Effort levels** | Skills declare `effort: high\|medium` for reasoning depth |
| **Model routing** | Per-agent model selection (opus/sonnet/haiku) |
| **Task management** | Real-time progress tracking visible to user |
| **Memory system** | Cross-session learning and pattern persistence |
| **MCP integration** | Figma (design extraction), Stitch (screen generation), Playwright (UI verification) |
| **Agent Teams** (experimental) | Direct agent-to-agent communication for tightly-coupled specs |

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

# 2. Write requirements (multi-agent: problem analyst + requirements engineer + metrics designer)
/prd Payment links — merchants can generate shareable payment URLs

# 3. Design the system
/design-doc @claudedocs/PRD-payment-links.md

# 4. Design the UI (6 parallel agents: UX Lead, UI Designer, Component Architect, A11y, Copy, Design System)
/ui-design @claudedocs/DESIGN-DOC-payment-links.md

# 5. Design the data layer (parallel: Postgres + Mongo + Elastic designers)
/data-design @claudedocs/DESIGN-DOC-payment-links.md

# 6. Map all paths before coding
/flow-map @claudedocs/DESIGN-DOC-payment-links.md

# 7. Implement everything (14 agent types, wave-based parallel execution, worktree isolation)
/spec-to-impl claudedocs/DESIGN-DOC-payment-links.md

# 8. Verify the implementation (parallel: API + DB + UI + Mobile layers)
/verify-impl

# 9. Final quality gate (default-to-rejection)
/evidence-review

# 10. Ship it (parallel lint/test, conventional commit, PR)
/finalize
```

Each step discovers the previous step's output automatically (via `claudedocs/handoff-*.yaml`).

#### Example: Quick bug fix

```bash
/debug-triage "NullPointerException in PaymentService.processRefund()"
# → Fix the bug (parallel hypothesis investigation if 3+ hypotheses)
/finalize
```

#### Example: Code quality audit

```bash
# 10-dimension parallel analysis: smells, SOLID, duplication, algorithms, security, performance, patterns, architecture, tech fitness, devil's advocate
/code-audit src/payment/
```

#### Example: Security + Performance review (parallel panels)

```bash
# 4 parallel security experts: Auth, Injection, Data Privacy, Abuse
/security-review src/api/auth/

# 4 parallel perf experts: Backend, DB, Frontend, Infrastructure
/performance-review src/payment/
```

#### Example: Mobile feature

```bash
/mobile-dev --platform flutter "Add biometric authentication"
/spec-to-impl claudedocs/PRD-biometric-auth.md
/verify-impl --mobile
/finalize
```

### Comprehensive skills (multi-agent orchestrators)

Six skills orchestrate parallel agent teams:

| Skill | Agents | Execution Pattern |
|-------|--------|-------------------|
| `/spec-to-impl` | 14 types (ARCH, BE, FE, Flutter, RN, Android, QA, DBA, DEVOPS, SEC, OBS, DESIGN, ANGULARJS, TECH_WRITER) | Wave-based with worktree isolation |
| `/ui-design` | 6 types (UX Lead, UI Designer, Component Architect, A11y, Copy, Design System) | 4-wave parallel design |
| `/code-audit` | 10 types (LEAD, ARCH, SMELL, DUP, ALGO, SEC, PERF, PATTERN, TECH, SKEPTIC) | Parallel 10-dimension analysis |
| `/spec-panel` | Variable (fixed + domain-activated experts + devil's advocate) | Parallel expert panel |
| `/verify-impl` | 4 types (API, DB, UI, Mobile) | Parallel verification layers |
| `/figma-to-code` | Phase-based (Design Manifest → Code Generation) | Multi-phase with MCP |

### Evidence-based quality gate

`/evidence-review` defaults to **NEEDS WORK** — the opposite of typical reviews:

**Automatic FAIL triggers:**
- Zero issues reported (impossible for real implementations)
- "Tests pass" without actual test runner output
- Screenshots from a design tool, not the running app
- Perfect scores without supporting documentation

**Rating scale:** REJECT → NEEDS WORK → CONDITIONAL PASS → PASS

### Post-implementation finalization

`/finalize` handles everything after coding is done:

**Pipeline:** Scan → Parallel Lint → Parallel Test → Simplify → Clean → Stage → Commit → PR

- Detects project stacks and runs language-appropriate linters **in parallel**
- Runs test suites **concurrently** across detected languages
- Optional pre-commit quality sweep (reuse, quality, efficiency agents)
- Creates conventional commit with correct type and scope
- Creates PR with summary and test evidence

---

## End-to-End Use Case: Merchant Payment Links

This walkthrough shows every skill in action for a realistic feature — from initial idea through production operations. Each step shows what happens behind the scenes, what artifacts are produced, and how skills chain together automatically.

**Scenario**: A fintech platform wants to let merchants generate shareable payment links that customers can use to pay via web or mobile.

---

### Phase 1: Discovery (Day 1)

#### Step 1 — Validate the opportunity

```
> /opportunity-assessment "Payment links for merchants — generate shareable URLs that accept payments"
```

**What happens:**
- Analyzes market fit, competitive landscape, and strategic alignment
- Estimates cost/benefit and identifies risks
- Produces a scored recommendation: BUILD / DEFER / KILL

**Artifacts produced:**
```
claudedocs/payment-links-opportunity-assessment.md
claudedocs/handoff-opportunity-assessment-20260327T0900.yaml
```

**Handoff manifest signals:** `suggested_next: [prd, decision-matrix]`

#### Step 2 — Competitive context (optional, parallel with Step 1)

```
> /competitive-analysis "Payment link products: Stripe, Square, PayPal.me, Razorpay"
```

**What happens:**
- Researches each competitor's payment link implementation
- Compares features, pricing, developer experience, limitations
- Identifies differentiation opportunities

**Artifacts produced:**
```
claudedocs/payment-links-competitive-analysis.md
claudedocs/handoff-competitive-analysis-20260327T0930.yaml
```

---

### Phase 2: Planning (Day 1-2)

#### Step 3 — Write the PRD

```
> /prd Payment links — merchants generate shareable payment URLs with configurable amounts, expiry, and branding
```

**What happens behind the scenes (multi-agent):**
1. `PROBLEM_ANALYST` (opus) — deep-dives on merchant pain, validates "why now"
2. Three agents run **in parallel**:
   - `REQUIREMENTS_ENGINEER` (sonnet) — writes functional requirements with Given/When/Then acceptance criteria
   - `METRICS_DESIGNER` (opus) — defines success metrics with baselines, targets, timelines
   - `EDGE_CASE_ANALYST` (sonnet) — enumerates boundary conditions, error states, abuse scenarios
3. Synthesis — combines into unified PRD with Definition of Ready checklist

**Artifacts produced:**
```
claudedocs/payment-links-prd.md          # Full PRD with 12 FRs, 8 NFRs, 34 acceptance criteria
claudedocs/handoff-prd-payment-links-20260327T1100.yaml
```

**Key PRD sections:**
- Problem statement + "why now" validation
- 3 user personas (merchant admin, end customer, platform ops)
- 12 functional requirements with Given/When/Then criteria
- Per-feature NFRs (payment submission < 200ms p95, link generation < 500ms)
- UI component state matrices (default, loading, error, success, expired, disabled)
- Dependency matrix with owners and risk ratings
- Rollout plan: feature flag → 5% → 25% → 100%

#### Step 4 — Expert panel review of the spec

```
> /spec-panel claudedocs/payment-links-prd.md
```

**What happens (parallel expert panel):**
1. Phase 0: Asks 3-5 clarifying questions, waits for answers
2. Phase 1: Deep research — codebase investigation + internet research
3. Phase 2: IEEE 830 quality audit + spec smells scanner + cross-cutting concerns checklist
4. Phase 3: **Parallel expert panel** — domain experts (payments, compliance, UX) + devil's advocate all analyze simultaneously
5. Phase 4: Quality scoring (1-100) with actionable recommendations

**Artifacts produced:**
```
claudedocs/payment-links-spec-panel.md   # Expert findings, quality score, recommendations
claudedocs/handoff-spec-panel-20260327T1300.yaml
```

The panel might surface: "PCI compliance implications for storing payment link metadata — spec doesn't address data classification" → feeds back into PRD refinement.

#### Step 5 — System design

```
> /design-doc claudedocs/payment-links-prd.md
```

**What happens:**
- Reads PRD + panel analysis (auto-discovered via handoff manifests)
- Designs architecture: API contracts, data model, sequence diagrams, deployment
- Evaluates alternatives with tradeoff analysis
- Produces design doc with ADR for key decisions

**Artifacts produced:**
```
claudedocs/payment-links-design-doc.md
claudedocs/handoff-design-doc-20260327T1500.yaml
```

#### Step 6 — Parallel planning skills (Steps 6a-6e run concurrently)

**6a. UI Design** — 6 agents in 4 parallel waves

```
> /ui-design claudedocs/payment-links-prd.md
```

**What happens (wave-based parallel execution):**
```
Wave 1 (sequential):  UX_LEAD (opus) — surface extraction, IA mapping, user flows
    ↓
Wave 2 (parallel):    UI_DESIGNER (sonnet) + COPY (haiku) — wireframes + microcopy simultaneously
    ↓
Wave 3 (parallel):    COMP_ARCH (opus) + A11Y (sonnet) — component specs + accessibility review
    ↓
Wave 4 (sequential):  UX_LEAD — synthesis and design handoff
```

**Artifacts produced:**
```
design/DESIGN.md                          # Design tokens, typography, color system
design/screens/                           # ASCII wireframes for every screen + every state
design/components/component-tree.md       # Component hierarchy with props and state models
design/components/testid-registry.md      # 44 stable testIDs for Playwright verification
design/a11y-audit.md                      # WCAG 2.2 AA compliance audit
design/copy-spec.md                       # All labels, errors, empty states, tooltips
claudedocs/handoff-ui-design-20260327T1600.yaml
```

**6b. Data Design** — parallel store analysis

```
> /data-design claudedocs/payment-links-design-doc.md
```

**What happens (parallel per-store):**
```
Phase 1: Requirements analysis (sequential)
    ↓
Phase 2: Parallel store design
  ┌──────────────────┬──────────────────┐
  │ POSTGRES_DESIGNER│ ELASTIC_DESIGNER │
  │ (opus)           │ (sonnet)         │
  └────────┬─────────┴────────┬─────────┘
           ↓                  ↓
Phase 3: Cross-store sync strategy (sequential)
```

**6c. API Design**

```
> /api-design claudedocs/payment-links-design-doc.md
```

**6d. Flow Map**

```
> /flow-map claudedocs/payment-links-design-doc.md
```

Maps every path: happy path, expired link, invalid amount, duplicate payment, concurrent access, network timeout, partial failure, recovery.

**6e. Ticket Breakdown**

```
> /ticket-breakdown claudedocs/payment-links-prd.md
```

Breaks into 3 epics, 14 tickets with acceptance criteria, dependencies, and story points.

---

### Phase 3: Implementation (Day 2-3)

#### Step 7 — Implement from spec

```
> /spec-to-impl claudedocs/payment-links-design-doc.md claudedocs/payment-links-prd.md
```

**What happens (multi-agent orchestrator with 14 agent types):**

**Phase 0 — DESIGN CONTEXT** (if Figma URL provided):
- `DESIGN` agent (sonnet) extracts tokens, components, and layouts from Figma via MCP

**Phase 1 — PARSE:**
- Reads all spec files + all upstream handoff manifests
- Extracts requirements, APIs, entities, UI screens
- Runs `mvn compile` / `npm run build` to verify the project builds

**Phase 2 — PLAN:**
- `ARCH` (opus) creates the task board with dependency graph
- Assigns tasks to agents: BE, FE, DBA, QA, DEVOPS, OBS
- Generates `e2e/test-plan.yaml` for verify-impl
- Groups tasks into execution waves based on dependencies

**Phase 3 — EXECUTE (wave-based, parallel, worktree-isolated):**

```
Wave 1 — Foundation (parallel, worktree isolation)
  ┌──────────┬──────────┬──────────┐
  │ DBA      │ DEVOPS   │ OBS      │
  │ (opus)   │ (sonnet) │ (sonnet) │
  │ Schema + │ Docker + │ Logging +│
  │ migration│ CI/CD    │ metrics  │
  └────┬─────┴────┬─────┴────┬─────┘
       └──────────┼──────────┘
                  ↓
Wave 2 — API Contract (sequential)
  ARCH (opus) — defines shared interfaces, API standards contract
                  ↓
Wave 3 — Backend + Frontend (parallel, worktree isolation)
  ┌──────────────────┬──────────────────┐
  │ BE (sonnet)      │ FE (sonnet)      │
  │ 3 controllers    │ 4 React pages    │
  │ 3 services       │ 12 components    │
  │ 2 repositories   │ API client       │
  │ validation logic │ form handling    │
  └────────┬─────────┴────────┬─────────┘
           └──────────────────┘
                  ↓
Wave 4 — Testing (parallel)
  ┌──────────────────┬──────────────────┐
  │ QA (sonnet)      │ SEC (opus)       │
  │ Unit tests       │ Security review  │
  │ Integration tests│ OWASP checklist  │
  │ E2E test plan    │ Auth/authz audit │
  └────────┬─────────┴────────┬─────────┘
           └──────────────────┘
                  ↓
Wave 5 — Documentation (background)
  TECH_WRITER (haiku) — API docs, README updates, OpenAPI spec
```

**Background agents** run non-blocking: TECH_WRITER starts during Wave 3, OBS instrumentation runs during Wave 3.

**Evidence-based wave gates**: Each wave must produce real build/test output before the next wave starts. "Tests pass" without `mvn test` stdout = automatic gate failure.

**3-retry budget**: If an agent fails, it gets 3 attempts with escalation: retry → reassign → decompose into smaller tasks → defer to human.

**Artifacts produced:**
```
src/main/java/com/app/payment/link/       # 8 Java files (controllers, services, DTOs, repos)
src/main/resources/db/changelog/           # 2 Liquibase migration files
src/test/java/com/app/payment/link/       # 12 unit test files
src/test-integration/                      # 3 integration test files
src/main/webapp/src/pages/PaymentLinks/   # 4 React page components
src/main/webapp/src/components/           # 12 React UI components with testIDs
e2e/test-plan.yaml                        # 8 test cases for verify-impl
docker-compose.override.yml               # Service additions
.github/workflows/payment-links.yml       # CI pipeline
docs/api/payment-links-openapi.yaml       # OpenAPI 3.1 spec
claudedocs/handoff-spec-to-impl-20260328T1000.yaml
```

---

### Phase 4: Verification (Day 3)

#### Step 8 — Live verification

```
> /verify-impl
```

**What happens (4 verification layers in parallel):**

```
Phase 1: Environment discovery (sequential)
  API: http://localhost:8080  ✅ UP
  Frontend: http://localhost:3000  ✅ UP
  Database: localhost:5432/appdb  ✅ UP
    ↓
Phase 2: Parallel verification
  ┌──────────────┬──────────────┬──────────────┐
  │ VERIFY_API   │ VERIFY_DB    │ VERIFY_UI    │
  │ (sonnet)     │ (sonnet)     │ (sonnet)     │
  │ 24 HTTP calls│ 16 SQL checks│ 8 Playwright │
  │ auth, CRUD,  │ row exists,  │ flows with   │
  │ validation,  │ field values,│ screenshots  │
  │ error codes  │ referential  │ per test case│
  │              │ integrity    │              │
  └──────┬───────┴──────┬───────┴──────┬───────┘
         └──────────────┼──────────────┘
                        ↓
Phase 3: Evidence synthesis (sequential)
```

**Output:**
```
╔═══════════════════════════════════════════════════╗
║     VERIFY-IMPL REPORT — Payment Links           ║
╠═══════════════════════════════════════════════════╣
║  Layer     │ Checks │ Passed │ Failed │ Status   ║
╠═══════════════════════════════════════════════════╣
║  API       │   24   │   23   │   1    │ ❌ ISSUE ║
║  Database  │   16   │   16   │   0    │ ✅ CLEAN ║
║  UI        │    8   │    8   │   0    │ ✅ CLEAN ║
╠═══════════════════════════════════════════════════╣
║  OVERALL   │   48   │   47   │   1    │ ❌       ║
╚═══════════════════════════════════════════════════╝

❌ FAILURE: PUT /api/v1/payment-links/:id/expire → 500
   Root cause: NullPointerException — missing null check when link already expired
   Fix: Add guard clause in PaymentLinkService.expire():42
```

The fix is applied, verify-impl is re-run (`/verify-impl --tc TC-005`), and now all 48 checks pass.

```
e2e/reports/verify-20260328T1400.log
e2e/verify-impl/screenshots/                 # 8 screenshots as evidence
claudedocs/handoff-verify-impl-20260328T1400.yaml
```

---

### Phase 5: Quality Review (Day 3-4)

#### Step 9 — Code audit

```
> /code-audit src/main/java/com/app/payment/link/
```

**What happens (10 agents in parallel):**
- SMELL + DUP + ALGO + SEC + PERF + PATTERN + ARCH + TECH + SKEPTIC all analyze simultaneously
- LEAD (opus) synthesizes into quality scorecard

**Result:** Quality Score: 8.1/10 — 0 CRITICAL, 1 HIGH (missing rate limiting on link creation), 3 MEDIUM, 2 POSITIVE.

#### Step 10 — Security review

```
> /security-review src/main/java/com/app/payment/link/
```

**What happens (4 parallel security experts):**
- AUTH_EXPERT: validates JWT enforcement on all endpoints
- INJECTION_ANALYST: checks parameterized queries, input sanitization
- DATA_PRIVACY: verifies no PII in logs, proper data classification
- ABUSE_ANALYST: checks rate limiting, enumeration protection

#### Step 11 — Evidence review (quality gate)

```
> /evidence-review
```

**Default verdict: NEEDS WORK** until proven otherwise.

Checks for:
- Real test runner output (not just "tests pass")
- Real screenshots from running app (not mockups)
- Real DB query results (not assumed state)
- All P0 requirements have evidence across all layers

**Verdict:** CONDITIONAL PASS — rate limiting finding from code-audit must be fixed first.

---

### Phase 6: Ship (Day 4)

#### Step 12 — Finalize

```
> /finalize payment-links
```

**What happens:**
```
Phase 1: SCAN — 23 changed files, 0 orphaned worktrees
    ↓
Phase 2: Parallel lint
  ┌──────────────────┬──────────────────┐
  │ Java: mvn        │ TS/React: eslint │
  │ checkstyle:check │ + tsc --noEmit   │
  └────────┬─────────┴────────┬─────────┘
    ↓
Phase 3: Parallel test
  ┌──────────────────┬──────────────────┐
  │ Java: mvn test   │ React: vitest    │
  │ 47/47 passed     │ 23/23 passed     │
  └────────┬─────────┴────────┬─────────┘
    ↓
Phase 4: CLEAN → STAGE → COMMIT → PR
```

**Output:**
```
✅ Lint: 0 errors
✅ Tests: 70/70 passed
✅ No secrets in diff
✅ Conventional commit: feat(payment-links): add merchant payment link generation with expiry and branding
✅ PR #234 created: https://github.com/org/repo/pull/234
```

#### Step 13 — Release notes

```
> /release-notes v2.4.0
```

Generates user-facing release notes, internal engineering notes, and known limitations.

---

### Phase 7: Operations (Ongoing)

#### Step 14 — Monitoring plan

```
> /monitoring-plan payment-links-service
```

**Produces:**
- Golden signals: latency (p50/p95/p99), error rate, saturation, traffic
- SLOs: 99.9% availability, < 200ms p95 link creation, < 500ms p95 payment processing
- Alerts: error rate > 1% for 5min, latency p99 > 2s, payment failure rate > 5%
- Grafana dashboard spec with panel definitions

#### Step 15 — Runbook

```
> /runbook payment-links-service
```

**Produces:** Deployment procedure, scaling playbook, failure recovery steps, common operations guide.

---

### What the handoff chain looks like

Each skill reads upstream artifacts automatically. After the full workflow, `claudedocs/` contains:

```
claudedocs/
├── payment-links-opportunity-assessment.md
├── payment-links-competitive-analysis.md
├── payment-links-prd.md
├── payment-links-spec-panel.md
├── payment-links-design-doc.md
├── payment-links-data-design.md
├── payment-links-api-design.md
├── payment-links-flow-map.md
├── payment-links-ticket-breakdown.md
├── payment-links-code-audit.md
├── payment-links-security-review.md
├── handoff-opportunity-assessment-20260327T0900.yaml
├── handoff-competitive-analysis-20260327T0930.yaml
├── handoff-prd-payment-links-20260327T1100.yaml
├── handoff-spec-panel-20260327T1300.yaml
├── handoff-design-doc-20260327T1500.yaml
├── handoff-ui-design-20260327T1600.yaml
├── handoff-data-design-20260327T1630.yaml
├── handoff-spec-to-impl-20260328T1000.yaml
├── handoff-verify-impl-20260328T1400.yaml
├── handoff-finalize-20260328T1600.yaml
└── .archive/                                    # Archived after finalize
```

Each handoff YAML contains: source skill, produced artifacts with paths, quality status, and `suggested_next` skills — enabling fully automatic chaining.

### Agents involved across the full workflow

| Phase | Skills | Total agents spawned | Parallel agents |
|-------|--------|---------------------|-----------------|
| Discovery | opportunity-assessment, competitive-analysis | 0 (thin skills) | — |
| Planning | prd, spec-panel, design-doc, ui-design, data-design, api-design, flow-map, ticket-breakdown | ~18 | 6 (ui-design), 4 (prd), 2 (data-design) |
| Implementation | spec-to-impl | ~14 per wave | 3-5 per wave |
| Verification | verify-impl | 3 | 3 (API + DB + UI) |
| Quality | code-audit, security-review, evidence-review | ~14 | 10 (code-audit), 4 (security) |
| Ship | finalize | 2 (lint + test) | 2 |
| Operations | monitoring-plan, runbook | 0 (thin skills) | — |

**Total: ~50+ agent invocations, heavily parallelized across 15 skills.**

---

## Lifecycle

```
Discover         Plan              Build              Quality            Complete         Operate
─────────        ──────            ─────              ───────            ────────         ───────
/opportunity  →  /prd          →  /ui-design       →  /evidence-     →  /finalize     →  /monitoring
-assessment      /design-doc      /flow-map            review            (commit+PR)      -plan
/competitive  →  /adr             /spec-to-impl      /pr-review     →  /release-     →  /runbook
-analysis        /flow-map        /figma-to-code     /test-plan        notes         →  /incident-
                 /ui-design       /mobile-dev        /security-     →  /go-to-          response
                 /api-design      /verify-impl       review            market        →  /postmortem
                 /data-design                        /performance-
                 /search-design                      review
                 /infra-design                       /ux-review
                 /ticket-                            /code-audit
                 breakdown                           /spec-panel
                 /decision-                          /metrics-
                 matrix                              review
                 /migration-                         /tech-debt-
                 plan                                assessment
                 /experiment-                        /debug-
                 design                              triage
```

---

## Customization

### Adapt to your team

1. **Edit repo conventions** — Fill in `skills/repo-conventions/references/*` with your actual architecture, API style, and testing standards
2. **Tune triggers** — Modify the `description` field in each skill's frontmatter to match your vocabulary
3. **Swap templates** — Replace templates with your org's existing formats
4. **Adjust quality bars** — Modify anti-patterns and criteria to match your standards
5. **Adjust model routing** — Update agent model assignments in orchestrator skills to match your cost/quality preferences

### Create your own skill

```
my-skill/
├── SKILL.md          # Required: frontmatter + methodology
├── agents/           # Optional: agent persona definitions
├── references/       # Optional: reference documentation
└── templates/        # Optional: output templates
    └── output.md
```

Every skill follows this structure:

```yaml
---
name: my-skill
description: When to trigger this skill...
argument-hint: "[context]"
effort: high          # Optional: high|medium for reasoning depth
context: fork         # Optional: run in isolated context (for complex skills)
---

# My Skill

## What I'll do
## Inputs I'll use
## How I'll think about this
## Anti-patterns to flag
## Quality bar
## Workflow context
## Learning & Memory
## Output contract
```

---

## Contributing

1. Create a folder in `skills/` with your skill name (kebab-case)
2. Add a `SKILL.md` following the standard structure
3. Add agent personas in `agents/` for multi-agent skills
4. Add templates in `templates/` if the skill produces a document
5. Update `skills/INDEX.md` with your skill in the appropriate category
6. Submit a PR

---

## License

MIT — use, modify, and distribute freely. See [LICENSE](LICENSE).
