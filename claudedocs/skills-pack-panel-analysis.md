# Panel Analysis: Claude Skills Pack Enhancement
**Date:** 2026-03-16
**Spec:** Full skills pack (34 skills) + agency-agents inspiration + stack expansion
**Status:** IMPLEMENTED (20/20 DONE)

## Recommendation Tracker
| # | Recommendation | Priority | Status | Category |
|---|---------------|----------|--------|----------|
| R-01 | Create `/finalize` skill (lint → test → commit → PR) | Must-do | DONE | New Skill |
| R-02 | Create `/mobile-dev` skill (Flutter, React Native, Android) | Must-do | DONE | New Skill |
| R-03 | Create `/handoff` auto-guidance skill for inter-skill context | Must-do | DONE | New Skill |
| R-04 | Create `/flow-map` skill (pre-implementation path mapping) | Should-do | DONE | New Skill |
| R-05 | Create `/evidence-review` skill (default-to-rejection QA) | Should-do | DONE | New Skill |
| R-06 | Create `/infra-design` skill (Docker, K8s, Terraform) | Should-do | DONE | New Skill |
| R-07 | Create `/data-design` skill (Postgres, Elastic, Mongo, Typesense) | Should-do | DONE | New Skill |
| R-08 | Create `/search-design` skill (Elasticsearch, Typesense) | Nice-to-have | DONE | New Skill |
| R-09 | Add retry-budget + escalation protocol to spec-to-impl | Must-do | DONE | Enhancement |
| R-10 | Add evidence-based verification to spec-to-impl wave gates | Must-do | DONE | Enhancement |
| R-11 | Add cleanup phase to spec-to-impl (worktree, temp files, PR) | Must-do | DONE | Enhancement |
| R-12 | Add duplicate-detection pass to spec-to-impl integration review | Must-do | DONE | Enhancement |
| R-13 | Add existing-code-scan mandate to spec-to-impl agent dispatch | Must-do | DONE | Enhancement |
| R-14 | Expand tech stack inference table across all implementation skills | Should-do | DONE | Enhancement |
| R-15 | Add structured output contracts to all thin skills | Should-do | DONE | Enhancement |
| R-16 | Add definition_of_done with evidence requirements to verify-impl | Should-do | DONE | Enhancement |
| R-17 | Add flutter/mobile layer to verify-impl | Should-do | DONE | Enhancement |
| R-18 | Add AngularJS + Flutter + RN + Android agent personas | Should-do | DONE | Enhancement |
| R-19 | Create skill-chaining index in INDEX.md with input/output contracts | Should-do | DONE | Enhancement |
| R-20 | Add MongoDB/Elastic/Typesense check types to verify-impl DB layer | Nice-to-have | DONE | Enhancement |

---

## Phase 1: Deep Research Summary

### 1A: Codebase Investigation Findings

**Current State:**
- 34 skills total: 32 "thin" (44-83 lines), 2 "comprehensive" (527-673 lines)
- Consistent frontmatter: `name`, `description`, `argument-hint`, optional `disable-model-invocation`
- Consistent body structure: What I'll do → Inputs → How I'll think → Anti-patterns → Quality bar → Workflow context → Output
- Clear lifecycle chain: Discover → Plan → Build → Quality → Release → Operate
- 6 manual-only skills (pr-review, release-notes, incident-response, postmortem, stakeholder-update, sprint-retro)
- 1 auto-guidance skill (repo-conventions)

**Critical Gaps Identified:**
1. **No Build → Quality bridge** — spec-to-impl produces code but there's no automated path to commit, PR, or cleanup
2. **No mobile stack coverage** — Flutter, React Native, Android entirely absent despite being user's active stack
3. **No inter-skill handoff protocol** — skills reference each other in "Workflow context" but there's no structured output contract
4. **No data layer skills** — PostgreSQL, Elasticsearch, MongoDB, Typesense have no dedicated design skills
5. **No infrastructure design skills** — Docker, K8s, Terraform patterns missing as standalone skills
6. **spec-to-impl doesn't mandate existing code review** — agents can create duplicate patterns
7. **spec-to-impl has no cleanup phase** — worktrees, temp files, branches left behind
8. **spec-to-impl has no retry budget** — failing agents loop indefinitely or halt without escalation
9. **verify-impl only covers PostgreSQL** — no MongoDB, Elastic, or Typesense verification

### 1B: External Research Findings

**From agency-agents (github.com/msitarzewski/agency-agents, 48.8k stars):**

| Pattern | What It Is | Transferability |
|---------|-----------|-----------------|
| **Default-to-Rejection QA** | "Reality Checker" agent that defaults to NEEDS WORK, requires evidence to approve | HIGH — directly addresses "unfinished work" pain point |
| **Dev-QA Loop with 3-Retry Budget** | Structured retry: fail → specific feedback → retry (max 3) → escalate to reassign/decompose/revise/defer | HIGH — prevents infinite loops in spec-to-impl |
| **7 Structured Handoff Templates** | Standard, QA Pass, QA Fail, Escalation, Phase Gate, Sprint, Incident | HIGH — addresses "no proper skill handover chain" pain point |
| **Evidence-Over-Claims** | EvidenceQA mandates screenshots, test output as proof; claims without evidence auto-fail | HIGH — addresses "not properly tested" pain point |
| **Workflow Architect** | Pre-implementation mapping of ALL paths (happy, failure, timeout, recovery) as trees | MEDIUM — useful new skill, maps to /flow-map |
| **NEXUS Phase Gates** | Every phase has mandatory evidence-based quality gate before advancing | MEDIUM — spec-to-impl has wave gates but lacks evidence requirements |
| **Agent Linting** | CI validates agent definitions have required fields and sufficient content | LOW — nice-to-have for skill quality |
| **Memory-Tagged Handoffs** | Persistent memories tagged with project + receiving agent name | LOW — Claude Code memory handles this natively |

**From web research (Claude Code ecosystem):**

| Finding | Source | Actionability |
|---------|--------|---------------|
| Progressive disclosure in skills (metadata ~100 tokens, body on activation) | code.claude.com/docs | Already practiced — thin skills follow this |
| `/simplify` spawns 3 parallel review agents (reuse, quality, efficiency) | Anthropic built-in skill | Pattern to adopt for /evidence-review |
| `isolation: worktree` on subagents for automatic worktree management | Claude Code subagent API | Simplify spec-to-impl worktree setup |
| `!command` preprocessor for dynamic context injection | Claude Code skill syntax | Useful for handoff skill |
| Agent Skills Standard (agentskills.io) adopted by 25+ tools | agentskills.io/specification | Compatibility consideration for distribution |
| No mobile development skills exist in any major skills repo | Ecosystem gap analysis | Opportunity to fill real gap |
| Artifact-based chaining via known file paths | Common pattern | Foundation for handoff protocol |

### 1C: Recommended Reading

1. **agency-agents NEXUS Strategy** — `github.com/msitarzewski/agency-agents/tree/main/strategy` — Orchestration framework with handoff templates
2. **Claude Code Subagents** — `code.claude.com/docs/en/sub-agents` — Isolation modes, context passing
3. **Agent Skills Specification** — `agentskills.io/specification` — Interoperability standard
4. **Anthropic Skills Repository** — `github.com/anthropics/skills` — Official skill examples with bundled scripts
5. **Claude Code Hooks** — `code.claude.com/docs/en/hooks` — PostToolUse for auto-lint, SessionEnd for cleanup

---

## Phase 2: Expert Panel Analysis

### Fixed Experts

#### Karl Wiegers (Requirements Quality)

**Finding W-1: Skills lack input/output contracts (CRITICAL)**
Every thin skill says "Workflow context: comes after X, feeds Y" but never defines WHAT is passed. There's no structured output format that the next skill can parse. This means chaining is aspirational, not functional.
- **Action:** Define explicit output schemas for each skill. At minimum: output file path, format (markdown/yaml/json), and key sections the next skill expects.

**Finding W-2: spec-to-impl definition_of_done is vague**
Tasks have `definition_of_done` but it's just "TC-001, TC-002 must pass." No definition of what evidence constitutes "pass" — screenshot? Test output? Green CI? An agent can claim tests pass without proof.
- **Action:** Every task's definition_of_done must specify: evidence type (test output, screenshot, build log), evidence location (file path), and verification command.

**Finding W-3: No acceptance criteria for thin skills themselves**
How do you know if `/prd` produced a GOOD PRD vs a mediocre one? The "Quality bar" section lists criteria but nothing enforces them. There's no self-review step.
- **Action:** Add a "Self-Review Checklist" to each skill that the skill itself must evaluate before presenting output to the user.

#### Martin Fowler (Architecture & Design)

**Finding F-1: Missing abstraction layer between skills (CRITICAL)**
Skills are independent markdown files with no shared protocol. Each one reinvents context passing. The architecture needs a "skill bus" — a standard way to declare inputs, produce outputs, and chain.
- **Action:** Create a `/handoff` auto-guidance skill that defines the standard artifact format (frontmatter with skill_source, timestamp, output_type + body).

**Finding F-2: Implementation skills assume Java/Spring Boot**
spec-to-impl's agent personas are hardcoded to Java. The FE agent assumes React. But the user also works with Flutter, Android, AngularJS. The architecture should support stack-polymorphic agents.
- **Action:** Expand the tech stack inference table. Add agent personas for: Flutter Engineer, Android Engineer, AngularJS Engineer. Make agent selection conditional on detected/declared stack.

**Finding F-3: No separation between "what to build" and "how to verify"**
spec-to-impl generates a test plan AND implements code AND verifies. This conflates three concerns. The test plan should be independently consumable.
- **Action:** The test plan is already written to `e2e/test-plan.yaml` — this is good. Strengthen the contract so verify-impl can also consume plans produced manually or by other tools.

#### Gojko Adzic (Specification by Example)

**Finding A-1: Missing scenario — "Agent produces duplicate code"**
Given: A Spring Boot project with an existing `BaseController` pattern
When: spec-to-impl dispatches a BE agent to implement a new controller
Then: The agent should find and reuse `BaseController`, NOT create a parallel pattern

This scenario is currently unaddressed. Agents don't scan for existing patterns before writing.
- **Action:** Add mandatory "Codebase Scan" step to every implementation agent's dispatch prompt: "Before writing ANY new class, search for existing patterns: controllers, services, repositories, DTOs. List found patterns and confirm you will extend them, not duplicate."

**Finding A-2: Missing scenario — "Skill chain breaks mid-flow"**
Given: User runs `/prd` → `/design-doc` → `/spec-to-impl`
When: `/spec-to-impl` starts, it doesn't know `/prd` and `/design-doc` outputs exist
Then: It re-asks the user for context that was already produced

This breaks the flow. Each skill should discover prior skill outputs.
- **Action:** Skills should check `claudedocs/` for recent artifacts from upstream skills before asking questions. The handoff protocol should make this automatic.

**Finding A-3: Missing scenario — "Implementation complete but no commit"**
Given: spec-to-impl finishes all waves and integration review passes
When: User expects the work to be committed and a PR created
Then: Nothing happens — the user must manually commit

This is explicitly called out as a pain point.
- **Action:** Create `/finalize` skill that chains: lint → test → stage → commit → PR creation.

#### Lisa Crispin (Testing & Quality)

**Finding C-1: No testing for Flutter/mobile (CRITICAL for user's stack)**
verify-impl has three layers: API (curl), DB (psql), UI (Playwright). None cover:
- Flutter widget tests
- Android instrumented tests
- React Native component tests
- Mobile screenshot comparison
- Device-specific responsive testing
- **Action:** Add a fourth verification layer: Mobile (flutter test, ./gradlew connectedAndroidTest, device emulation via Chrome DevTools MCP).

**Finding C-2: verify-impl DB layer only covers PostgreSQL**
The user also uses MongoDB, Elasticsearch, and Typesense. These need verification patterns:
- MongoDB: `mongosh` queries for document existence, field values, index verification
- Elasticsearch: `curl` to `_search` and `_cat/indices` endpoints
- Typesense: `curl` to `/collections` and `/documents/search` endpoints
- **Action:** Add NoSQL and search engine check types to the DB verification layer schema.

**Finding C-3: No regression test tracking across skill invocations**
If spec-to-impl creates 50 tests and they all pass, there's no baseline saved. Next time verify-impl runs, there's no way to detect regressions (tests that previously passed now failing).
- **Action:** verify-impl should persist results to `e2e/reports/` with timestamps. Compare against previous run to flag regressions.

#### Michael Nygard (Operational Concerns)

**Finding N-1: spec-to-impl worktree cleanup is unreliable**
The skill describes cleanup in the integration review section but it's manual bash commands. If any wave fails or the user interrupts, worktrees are orphaned. `.worktrees/` accumulates stale branches.
- **Action:** Add explicit cleanup phase with `git worktree prune` and branch cleanup. Run cleanup even on failure/interruption. The `/finalize` skill should also check for orphaned worktrees.

**Finding N-2: No resource budget for spec-to-impl execution**
spec-to-impl can spawn 8+ parallel agents, each consuming significant tokens. There's no budget tracking, no "this will cost approximately X tokens" warning, no circuit breaker for runaway execution.
- **Action:** Add estimated token budget per wave in the plan output. Add circuit breaker: if 3 agents in same wave fail, halt and report rather than retrying indefinitely.

**Finding N-3: No rollback path after spec-to-impl**
If the implemented feature is wrong, there's no quick way to undo everything. Worktrees are merged into main with no tagged checkpoint.
- **Action:** Create a git tag `pre-spec-to-impl-<timestamp>` before Wave 1. Document rollback command: `git reset --hard pre-spec-to-impl-<timestamp>`.

### Domain Experts Activated

#### Bernd Ruecker (Workflow Patterns) — activated for skill chaining and orchestration

**Finding R-1: Skill chaining is ad-hoc, needs saga pattern**
The skill lifecycle (Discover → Plan → Build → Quality → Release) is a workflow, but there's no compensation (rollback) when a step fails mid-chain. If `/spec-to-impl` fails after merging 3 of 5 agent branches, the repo is in a partial state.
- **Action:** Implement checkpoint pattern: tag git state before each wave. On failure, offer rollback to last clean checkpoint.

**Finding R-2: Missing handoff verification**
Agency-agents' NEXUS framework mandates that every handoff includes: what was done, what to do next, acceptance criteria, and quality expectations. Current skills just say "see /test-plan for what comes next."
- **Action:** Each skill should write a structured handoff artifact to `claudedocs/handoff-<skill-name>-<timestamp>.md` with: produced artifacts, quality assessment, suggested next skill, and context for that skill.

#### Dan Abramov (React Architecture) — activated for frontend/mobile skill gaps

**Finding D-1: No AngularJS-specific patterns**
The user maintains AngularJS applications but the FE agent only knows React. AngularJS has fundamentally different patterns: directives, services, $scope, dependency injection via strings.
- **Action:** Add AngularJS agent persona to `be-fe-qa-dba-devops.md`. Cover: component architecture (1.5+ style), service patterns, $http vs $resource, migration path to Angular/React.

**Finding D-2: No Flutter or React Native agent personas**
Mobile development has unique concerns: platform-specific APIs, navigation stacks, state management (BLoC, Riverpod, Redux), hot reload workflow, platform channels, app store submission.
- **Action:** Create `/mobile-dev` skill with Flutter Engineer and React Native Engineer personas. Include: widget test patterns, integration test patterns, platform channel testing, device-specific verification.

#### Martin Kleppmann (Data Systems) — activated for database diversity

**Finding K-1: Data modeling skill needed for polyglot persistence**
The user runs PostgreSQL (relational), MongoDB (document), Elasticsearch (search), and Typesense (search). Schema design for each is fundamentally different. One `/data-design` skill should cover:
- Relational: normalization, indexes, migrations (Liquibase)
- Document: embedding vs referencing, schema validation, aggregation pipelines
- Search: mapping design, analyzers, index lifecycle, relevance tuning
- **Action:** Create `/data-design` skill covering all four data stores with cross-store consistency patterns.

**Finding K-2: DBA agent persona is PostgreSQL-only**
The spec-to-impl DBA agent writes Liquibase changesets for PostgreSQL. When the project uses MongoDB or Elasticsearch, the DBA agent produces wrong artifacts.
- **Action:** Expand DBA agent persona to cover: MongoDB migrations (mongomigrate/mongosh scripts), Elasticsearch index templates, Typesense collection schemas.

---

## Phase 3: Consolidated Findings

### Current State Summary

| Layer | Current State | Gap | Severity |
|-------|--------------|-----|----------|
| **Skill Chaining** | Skills reference each other in "Workflow context" text | No structured input/output contracts, no artifact-based handoff, no discovery of prior outputs | CRITICAL |
| **Post-Implementation** | spec-to-impl ends at integration review | No commit, no PR, no cleanup, no branch pruning | CRITICAL |
| **Code Reuse** | Agent dispatch prompt says "write implementation" | No mandate to scan existing patterns before writing new code | CRITICAL |
| **Mobile Stack** | Not covered | Flutter, React Native, Android entirely missing | CRITICAL |
| **Quality Verification** | verify-impl requires evidence but spec-to-impl doesn't | Wave gates accept agent self-reports without evidence | HIGH |
| **Retry/Escalation** | spec-to-impl halts on failure | No retry budget, no structured escalation paths | HIGH |
| **Data Layer** | DBA agent is PostgreSQL-only | MongoDB, Elasticsearch, Typesense not covered | HIGH |
| **Infrastructure** | No dedicated skill | Docker, K8s, Terraform design patterns missing | MEDIUM |
| **AngularJS** | Not covered by FE agent | FE agent persona only knows React | MEDIUM |
| **Rollback** | No checkpoint mechanism | Failed spec-to-impl leaves repo in partial state | MEDIUM |

### Risk Register

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|
| 1 | Agent creates duplicate patterns instead of reusing existing code | HIGH | HIGH | R-13: Mandatory codebase scan in agent dispatch |
| 2 | spec-to-impl leaves orphaned worktrees/branches on failure | HIGH | MEDIUM | R-11: Cleanup phase + /finalize skill |
| 3 | Skill chain breaks because downstream skill doesn't know upstream output exists | HIGH | HIGH | R-03: /handoff auto-guidance + R-15: output contracts |
| 4 | Implementation "done" but not committed or PR'd | HIGH | HIGH | R-01: /finalize skill |
| 5 | Agent claims tests pass but didn't actually run them | MEDIUM | HIGH | R-10: Evidence-based wave gates |
| 6 | Failing agent loops indefinitely consuming tokens | MEDIUM | MEDIUM | R-09: 3-retry budget with escalation |
| 7 | Flutter/mobile features can't be verified | HIGH | HIGH | R-02, R-17: Mobile dev skill + verify layer |
| 8 | MongoDB/Elastic data integrity not verifiable | MEDIUM | MEDIUM | R-20: NoSQL check types in verify-impl |
| 9 | Failed multi-wave implementation can't be rolled back | LOW | HIGH | Checkpoint tagging before Wave 1 |
| 10 | AngularJS project gets React-style implementation | MEDIUM | HIGH | R-18: AngularJS agent persona |

### Implementation Plan

#### Must-Do (blocks delivery)

| # | Task | New/Modify | Effort | Dependencies | Expert Source |
|---|------|-----------|--------|--------------|---------------|
| R-01 | Create `/finalize` skill: lint → test → commit → PR → cleanup | New: `skills/finalize/SKILL.md` | M | None | Adzic A-3, Nygard N-1 |
| R-02 | Create `/mobile-dev` skill: Flutter, React Native, Android patterns | New: `skills/mobile-dev/SKILL.md` | L | None | Crispin C-1, Abramov D-2 |
| R-03 | Create `/handoff` auto-guidance: inter-skill artifact protocol | New: `skills/handoff/SKILL.md` | M | None | Fowler F-1, Wiegers W-1, Ruecker R-2 |
| R-09 | Add 3-retry budget + 4 escalation paths to spec-to-impl | Modify: `skills/spec-to-impl/SKILL.md` §4.3 | S | None | agency-agents Dev-QA Loop |
| R-10 | Add evidence requirements to wave gates (test output, build logs) | Modify: `skills/spec-to-impl/SKILL.md` §4.3 | S | None | agency-agents Evidence-Over-Claims |
| R-11 | Add cleanup phase: worktree prune, branch delete, temp files, git tag | Modify: `skills/spec-to-impl/SKILL.md` §7 | S | None | Nygard N-1, N-3 |
| R-12 | Add duplicate-detection pass to integration review | Modify: `skills/spec-to-impl/SKILL.md` §7.1 | S | None | Adzic A-1 |
| R-13 | Add mandatory codebase scan to agent dispatch template | Modify: `skills/spec-to-impl/templates/dispatch-prompt.md` | S | None | Adzic A-1 |

#### Should-Do (blocks quality)

| # | Task | New/Modify | Effort | Dependencies | Expert Source |
|---|------|-----------|--------|--------------|---------------|
| R-04 | Create `/flow-map` skill: pre-implementation path mapping | New: `skills/flow-map/SKILL.md` | M | None | agency-agents Workflow Architect |
| R-05 | Create `/evidence-review` skill: default-to-rejection QA | New: `skills/evidence-review/SKILL.md` | M | None | agency-agents Reality Checker |
| R-06 | Create `/infra-design` skill: Docker, K8s, Terraform patterns | New: `skills/infra-design/SKILL.md` | M | None | Nygard, user stack |
| R-07 | Create `/data-design` skill: Postgres + Mongo + Elastic + Typesense | New: `skills/data-design/SKILL.md` | L | None | Kleppmann K-1 |
| R-14 | Expand tech stack inference to cover full user stack | Modify: `skills/spec-to-impl/SKILL.md` §8 | S | None | Fowler F-2 |
| R-15 | Add structured output contracts to all thin skills | Modify: All 32 thin `SKILL.md` files | L | R-03 | Wiegers W-1 |
| R-16 | Add evidence-type specification to verify-impl definition_of_done | Modify: `skills/verify-impl/SKILL.md` §5 | S | None | Wiegers W-2 |
| R-17 | Add Flutter/mobile verification layer to verify-impl | Modify: `skills/verify-impl/SKILL.md` §4 + new script | M | R-02 | Crispin C-1 |
| R-18 | Add AngularJS + Flutter + Android agent personas | Modify: `skills/spec-to-impl/agents/be-fe-qa-dba-devops.md` | M | None | Abramov D-1 |
| R-19 | Create skill-chaining index with input/output contracts in INDEX.md | Modify: `skills/INDEX.md` | M | R-03, R-15 | Fowler F-1 |

#### Nice-to-Have (improves polish)

| # | Task | New/Modify | Effort | Dependencies | Expert Source |
|---|------|-----------|--------|--------------|---------------|
| R-08 | Create `/search-design` skill: Elasticsearch + Typesense specifics | New: `skills/search-design/SKILL.md` | M | None | Kleppmann K-1 |
| R-20 | Add MongoDB/Elastic/Typesense check types to verify-impl DB layer | Modify: `skills/verify-impl/SKILL.md` §3 + references | M | R-07 | Crispin C-2 |

---

## New Skills Blueprint

### /finalize — Post-Implementation Completion
```
Trigger: "finalize", "commit this", "wrap up", "create PR", "ship it"
Purpose: Automated completion workflow after implementation

Flow:
1. SCAN — detect uncommitted changes, orphaned worktrees, temp files
2. LINT — run language-appropriate linters (checkstyle, eslint, dart analyze)
3. TEST — run test suites, verify all pass, report coverage
4. CLEAN — prune worktrees, delete temp branches, remove build artifacts
5. STAGE — selective git add (exclude .env, credentials, build dirs)
6. COMMIT — conventional commit with scope from changed files
7. PR — create PR via gh with summary from changes + test results

Evidence required at each step (build on agency-agents pattern):
- Lint: actual linter output (not "linting passed")
- Test: actual test runner output with pass/fail counts
- Clean: git worktree list showing no orphans
- Commit: git log showing the commit
- PR: gh pr view URL
```

### /mobile-dev — Mobile Development Patterns
```
Trigger: "mobile", "flutter", "react native", "android", "ios"
Purpose: Stack-aware mobile development guidance and implementation

Covers:
- Flutter: BLoC/Riverpod state management, widget composition, platform channels,
  golden tests, integration tests, flavor management, build runner
- React Native: Navigation patterns, native modules, Hermes optimization,
  Detox E2E testing, CodePush, Metro bundler config
- Android (Kotlin): Jetpack Compose, ViewModel/LiveData, Room DB, Hilt DI,
  Espresso tests, Gradle build variants, ProGuard rules
- Cross-cutting: App store submission checklist, deep linking, push notifications,
  offline-first patterns, responsive layouts, accessibility (TalkBack/VoiceOver)

Anti-patterns:
- Platform-specific code in shared layer
- Missing null safety (Flutter)
- Blocking the UI thread
- Hardcoded dimensions instead of responsive
```

### /handoff — Inter-Skill Artifact Protocol (auto-guidance)
```
user-invocable: false
Purpose: Defines how skills discover and consume prior skill outputs

Protocol:
1. Every skill that produces output writes a handoff artifact:
   claudedocs/handoff-<skill-name>-<timestamp>.yaml

2. Handoff artifact schema:
   source_skill: "prd"
   timestamp: "2026-03-16T10:00:00Z"
   artifacts:
     - path: "claudedocs/PRD-feature-x.md"
       type: "prd"
       sections: [problem, goals, requirements, metrics]
   quality_assessment: "Complete, 0 ambiguities"
   suggested_next: ["design-doc", "ticket-breakdown"]
   context_for_next:
     design-doc: "Focus on API design — 3 new endpoints identified"
     ticket-breakdown: "12 FRs extracted, P0: 4, P1: 6, P2: 2"

3. Every skill, on activation, checks claudedocs/handoff-*.yaml
   for recent artifacts from upstream skills before asking questions.

4. Skills consume artifacts by reading the referenced paths,
   NOT by relying on conversation context.
```

### /flow-map — Pre-Implementation Path Mapping
```
Trigger: "flow map", "map the flows", "what are all the paths"
Purpose: Map ALL system paths before writing code (inspired by agency-agents Workflow Architect)

Output: Tree-structured specification covering:
- Happy paths (primary user flows)
- Validation failures (every input that can fail)
- Auth failures (every permission check)
- Network failures (every external call that can timeout)
- Concurrency conflicts (every race condition possible)
- Recovery paths (what happens after each failure)
- Cleanup inventory (resources to release on every exit path)

Format: Mermaid state diagrams + table of states with entry/exit conditions

Why before implementation:
- Every path becomes a test case
- Every failure mode gets explicit handling
- Nothing is "TODO: handle error later"
```

### /evidence-review — Default-to-Rejection QA
```
Trigger: "evidence review", "prove it works", "show me proof"
Purpose: Final quality gate that defaults to REJECT (inspired by agency-agents Reality Checker)

Philosophy: "NEEDS WORK until proven otherwise"

Automatic FAIL triggers:
- Zero issues reported (impossible for any real implementation)
- Claims without evidence (test output, screenshots, logs)
- Specs listed as "implemented" without verification command
- Perfect scores without supporting documentation

Evidence types accepted:
- Test runner output (actual stdout, not "all tests pass")
- Screenshots (Playwright, device emulator)
- Build logs (compilation output)
- API response bodies (curl output)
- DB query results (psql/mongosh output)
- Coverage reports (with line-level detail)

Rating: REJECT / NEEDS WORK / CONDITIONAL PASS / PASS
(PASS requires evidence for every P0 and P1 requirement)
```

### /infra-design — Infrastructure Architecture
```
Trigger: "infra design", "infrastructure", "deployment architecture", "k8s design"
Purpose: Design container, orchestration, and IaC patterns

Covers:
- Docker: Multi-stage builds, layer optimization, security scanning, compose patterns
- Kubernetes: Resource design (Deployment/StatefulSet/Job), HPA, PDB, NetworkPolicy,
  Ingress patterns, ConfigMap/Secret management, RBAC
- Terraform: Module structure, state management, workspace strategy,
  environment promotion, drift detection
- Cross-cutting: CI/CD pipeline design, secret rotation, blue-green/canary deployment,
  health check patterns, log aggregation, metric collection

Anti-patterns:
- Privileged containers
- Hardcoded replicas (use HPA)
- Terraform state in git
- No resource limits
- Single point of failure
```

### /data-design — Polyglot Data Architecture
```
Trigger: "data design", "database design", "schema design", "data model"
Purpose: Design data layer across PostgreSQL, MongoDB, Elasticsearch, Typesense

Covers:
- PostgreSQL: Normalization, indexing strategy, partitioning, RLS, Liquibase migrations,
  query optimization (EXPLAIN ANALYZE), connection pooling
- MongoDB: Document modeling (embed vs reference decision framework), schema validation,
  aggregation pipelines, index strategy, change streams, migration scripts
- Elasticsearch: Index design, mapping types, analyzer chains, alias strategy,
  index lifecycle management, search relevance tuning, reindexing patterns
- Typesense: Collection schema, search parameters, faceting, synonyms,
  curation rules, import strategies
- Cross-store: Consistency patterns, sync strategies (CDC, dual-write, event-driven),
  which store for which query pattern, data lifecycle

Anti-patterns:
- MongoDB: Unbounded arrays, no schema validation
- Elasticsearch: Mapping explosions, nested queries at scale
- PostgreSQL: Missing indexes on FKs, no connection pooling
- Cross-store: Synchronous dual-writes
```

---

## Enhancement Details for Existing Skills

### spec-to-impl: Retry Budget + Escalation (R-09)

Add to §4.3 after Wave Gate rules:

```markdown
### 4.3.1 Agent Retry Protocol

When an agent fails (tests failing, build errors, incomplete output):

ATTEMPT 1: Re-dispatch with specific feedback from failure
ATTEMPT 2: Re-dispatch with simplified scope (split task if needed)
ATTEMPT 3: Re-dispatch with explicit examples of expected output

If all 3 attempts fail → ESCALATE:
  ├─ REASSIGN — different agent type (e.g., ARCH takes over from BE)
  ├─ DECOMPOSE — split into 2-3 smaller tasks
  ├─ REVISE — modify the spec requirement (surface to user)
  └─ DEFER — mark as P2, continue with remaining tasks

Never retry more than 3 times. Never loop without new information.
Track attempt count in task board:

║ TASK-006 ║ Payment Service ║ BE ║ ❌ Attempt 2/3 ║ ❌ 3 FAILING ║
```

### spec-to-impl: Evidence-Based Wave Gates (R-10)

Replace the wave gate checklist with:

```markdown
WAVE GATE CHECK (evidence required)
====================================
[ ] All tasks: Impl ✅ Done
[ ] All tasks: Tests written (no 🚫)
[ ] All tasks: Test runner output captured in --- TEST REPORT --- block
    ⛔ "Tests should pass" without output = automatic gate FAIL
[ ] All tasks: Build log shows zero errors (actual output, not claim)
[ ] All tasks: No compilation warnings on new code
[ ] ARCH has reviewed outputs for contract compliance
[ ] Evidence artifacts saved to .spec-to-impl/evidence/wave-N/
```

### spec-to-impl: Mandatory Codebase Scan (R-13)

Add to dispatch prompt template before "YOUR TASK(S)":

```markdown
## MANDATORY: Codebase Scan (do this FIRST)

Before writing ANY new class, interface, or component:

1. Search for existing patterns in the codebase:
   - Controllers: find existing base classes, response patterns, error handling
   - Services: find existing service patterns, transaction handling, logging
   - Repositories: find existing data access patterns, custom queries
   - DTOs: find existing request/response patterns, validation annotations
   - Components: find existing component patterns, shared utilities, hooks

2. List what you found:
   EXISTING PATTERNS FOUND:
   - BaseController with standard error handling at src/main/java/.../BaseController.java
   - ApiResponse<T> envelope at src/main/java/.../ApiResponse.java
   - ... (list all relevant existing patterns)

3. Confirm: "I will EXTEND these patterns, not create parallel ones."

⛔ Creating a new pattern when an existing one covers the same concern is a
   BLOCKING issue. Reuse first. Extract and generalize if needed. Create new
   only when existing patterns genuinely don't fit.
```

### spec-to-impl: Cleanup Phase (R-11)

Add new section §7.2 after Integration Checks:

```markdown
### 7.2 Cleanup & Finalization

After integration review passes:

1. GIT CHECKPOINT
   git tag "pre-merge-spec-to-impl-$(date +%Y%m%d-%H%M%S)"

2. WORKTREE CLEANUP
   git worktree list                    # verify all merged
   git worktree prune                   # remove stale entries
   rm -rf .worktrees/                   # remove directory
   # Delete merged feature branches
   git branch --merged main | grep feature/ | xargs git branch -d

3. TEMP FILE CLEANUP
   rm -f .spec-to-impl/evidence/**     # keep structure, clear contents
   rm -f e2e/.captures.json            # ephemeral test data

4. SUGGEST FINALIZE
   Output: "Implementation complete. Run /finalize to lint, test, commit, and PR."
```

### spec-to-impl: Expanded Tech Stack (R-14)

Replace §8 table with:

```markdown
| Layer | Default | Alternatives |
|---|---|---|
| Backend | Java 21 + Spring Boot 3.x | — |
| Frontend (Web) | React 18 + TypeScript + Tailwind | AngularJS (legacy), Angular 17+ |
| Frontend (Mobile) | Flutter 3.x + Dart | React Native + TypeScript, Android (Kotlin) |
| Database (Relational) | PostgreSQL | — |
| Database (Document) | MongoDB | — |
| Search | Elasticsearch | Typesense |
| Auth | JWT / OAuth2 | — |
| Containerization | Docker + Docker Compose | — |
| Orchestration | Kubernetes | — |
| IaC | Terraform | — |
| Messaging | Kafka (if async flows) | — |
| BE Testing | JUnit 5 + Mockito | — |
| FE Testing (Web) | Vitest + RTL | Karma + Jasmine (AngularJS) |
| FE Testing (Mobile) | Flutter: widget + integration tests | RN: Detox, Android: Espresso |
| E2E Testing | Playwright (Chromium) | — |
| API Style | REST (OpenAPI 3.x) | — |
| Migrations (SQL) | Liquibase | — |
| Migrations (Mongo) | mongosh scripts | — |
```

---

## Recommended Priority Order

### Phase 1 — Immediate (address pain points)
1. **R-13** — Codebase scan mandate (prevents duplicate code) — **XS effort**
2. **R-09** — Retry budget + escalation (prevents infinite loops) — **S effort**
3. **R-10** — Evidence-based wave gates (prevents false "done") — **S effort**
4. **R-11** — Cleanup phase (prevents orphaned worktrees) — **S effort**
5. **R-01** — `/finalize` skill (commit + PR workflow) — **M effort**

### Phase 2 — Stack Coverage
6. **R-02** — `/mobile-dev` skill — **L effort**
7. **R-14** — Expanded tech stack table — **S effort**
8. **R-18** — New agent personas (Flutter, Android, AngularJS) — **M effort**
9. **R-07** — `/data-design` skill — **L effort**
10. **R-06** — `/infra-design` skill — **M effort**

### Phase 3 — Workflow Quality
11. **R-03** — `/handoff` auto-guidance — **M effort**
12. **R-04** — `/flow-map` skill — **M effort**
13. **R-05** — `/evidence-review` skill — **M effort**
14. **R-12** — Duplicate detection in integration review — **S effort**
15. **R-15** — Output contracts on all thin skills — **L effort**

### Phase 4 — Polish
16. **R-16** — Evidence types in verify-impl — **S effort**
17. **R-17** — Mobile verification layer — **M effort**
18. **R-19** — Skill-chaining index — **M effort**
19. **R-20** — NoSQL/search check types — **M effort**
20. **R-08** — `/search-design` skill — **M effort**

---

## Sources

- [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) — NEXUS framework, handoff templates, Reality Checker, Evidence Collector patterns
- [Claude Code Documentation](https://code.claude.com/docs/en/skills) — Skill structure, subagents, hooks
- [Agent Skills Specification](https://agentskills.io/specification) — Interoperability standard
- [Anthropic Skills Repository](https://github.com/anthropics/skills) — Official skill examples
