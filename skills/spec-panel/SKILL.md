---
name: spec-panel
description: >
  Use this skill whenever a specification, PRD, BRD, design doc, or RFC needs rigorous multi-expert review BEFORE implementation begins. ALWAYS trigger on: "spec panel", "expert review", "panel analysis", "spec analysis", "expert panel review", "review this spec", "audit the PRD", "spec quality check", "is this spec complete", "IEEE 830 audit", "spec smells", "devil's advocate on this spec", "review before we build". Implicit triggers: user pastes a PRD/BRD/spec and asks "what do you think", "any gaps", "is this ready to build", "should we implement this", "am I missing anything"; user wants a second opinion before committing engineering effort; user is deciding whether to proceed to spec-to-impl; user mentions specific concerns about requirements quality, ambiguity, or feasibility; user shows a spec with TBDs, "handle this somehow", or other vague language.
  Produces a structured findings report with IEEE 830 quality scoring (8 attributes), a spec-smells scan for red-flag language, a cross-cutting concerns checklist (security, performance, observability, compliance), and a multi-expert panel critique with a devil's advocate. Combines codebase investigation, internet research, and domain expertise. This is the gate BEFORE `spec-to-impl` — run this when the spec is drafted but not yet being implemented. Does NOT write code. Does NOT modify the spec in place — produces a separate analysis report that feeds `spec-update` (for spec rewrites) or `spec-to-impl` (for implementation).
argument-hint: "[spec document or @file]"
context: fork
agent: general-purpose
effort: high
---

# Spec Panel Analysis

## Before You Start — Superpowers Workflow

This skill is read-only — it reviews an existing spec/PRD and produces a findings report, never inline fixes or implementation code. It sits at a specific point in the superpowers workflow, immediately before implementation begins.

**Before invoking this skill**: nothing. Reviewers analyze existing work and don't need brainstorming or planning upfront.

**Invoke this skill** (`spec-panel`) to audit a specification document through an expert panel lens — IEEE 830 attributes, spec smells, cross-cutting concerns, and domain-expert critique with a devil's advocate. Produces findings with severity ratings and specific line references.

**After findings are produced**:

1. **superpowers:systematic-debugging** — MANDATORY per CRITICAL/HIGH finding. Understand WHY the gap exists (missing context? unclear stakeholder? legacy assumption?) before proposing a fix. Do not skip to recommendations from findings alone.
2. **superpowers:writing-plans** — turn the findings into an ordered remediation plan: which spec sections to rewrite first, which ambiguities to resolve with stakeholders, which gaps to defer.
3. **Chain to `/spec-update`** to apply the agreed changes to the spec document (preserves spec-panel output contract).
4. **Chain to `/spec-to-impl`** only AFTER the spec has been updated and all CRITICAL findings are resolved. Do NOT proceed to implementation with unresolved CRITICAL findings.
5. **superpowers:verification-before-completion** — quality gate. Re-run spec-panel after spec-update to confirm findings are closed.

**Hard rule**: this skill NEVER produces implementation code in the same invocation. It produces spec-review findings. Implementation happens in a separate pass through `/spec-to-impl` — and only after the spec has passed the quality gate.

**Pre-implementation gate**: if the user tries to invoke `/spec-to-impl` on a spec that has unresolved CRITICAL findings from spec-panel, refuse politely and route them back to spec-update first. Specs with critical ambiguities produce ambiguous implementations.

---

## What I'll do
Conduct a rigorous, multi-expert analysis of a specification document. This is NOT a quick review — it's a thorough investigation combining codebase research, internet research, requirements quality analysis, and domain expert perspectives into an actionable implementation plan with quantified quality scoring.

## Inputs I'll use (ask only if missing)
- The specification document to analyze (file path or inline content)
- Goal: new feature, refactor, audit, or bug fix?
- Scope: full implementation, backend only, review only?
- Audience: engineering team, product stakeholders, or both?
- Timeline pressure: sprint deadline, exploratory, production incident?
- Constraints: tech debt to work around, APIs that can't change, compliance requirements?

## How I'll think about this

### Phase 0: Clarification (ALWAYS do this first)

Before any analysis, ask clarifying questions. Understand context that isn't obvious from the document. Ask 3-5 focused questions maximum — skip questions the spec already answers. Wait for answers before proceeding.

### Phase 1: Deep Research

**Phase 1 is non-negotiable and must complete before any analysis.** A spec reviewed without context is a guess. You MUST gather real evidence from the codebase, existing docs, and up-to-date library documentation before producing findings. If any Phase 1 step cannot be completed, surface it as a blocker — do not fabricate context.

**1A: Codebase Investigation (MANDATORY — read real files, not guesses)**

Use the `Read`, `Glob`, and `Grep` tools. Do NOT rely on the spec's claims about what the code does — verify everything.

- **Read the project root markers first**: `CLAUDE.md`, `README.md`, `package.json` / `build.gradle*` / `pom.xml` to detect stack, build system, and conventions
- **Map relevant directories**: use `Glob` to enumerate files matching the spec's domain (e.g., `**/payment/**`, `**/user/**`). Target files mentioned by name in the spec.
- **Read every file the spec references by name**: if the spec says "we'll modify UserService", read UserService and all its collaborators (direct imports + reverse-imports via `Grep`).
- **Search for existing implementations of the feature**: `Grep` for keywords from the spec (e.g., "password reset", "token", "refund"). The feature may already exist partially.
- **Check git history on affected files**: `git log --oneline -20 -- <path>` for each touched file. `git blame` to identify recent authors. Changes in the last 30 days often indicate active work that conflicts with the spec.
- **Identify existing patterns and conventions**: naming (camelCase vs snake_case), error handling (`ProblemDetail`, `Result<T>`, exceptions), dependency injection style (constructor vs field), testing conventions (JUnit 5 vs JUnit 4, Testcontainers usage), data access (Spring Data JDBC vs JPA vs jOOQ).
- **Find discrepancies** between what the spec claims and what the code actually does. These are first-class findings in the report.
- **For each project-level marker found, extract and quote** the relevant conventions in the final report so reviewers can see what the spec must conform to.

Minimum evidence required before Phase 2:
- [ ] Read project `CLAUDE.md` (or equivalent) — or note explicitly if absent
- [ ] Read build file to confirm stack versions (Java, Spring Boot, Node, React, etc.)
- [ ] Read at least 3 files that the spec touches or is adjacent to
- [ ] Run `git log` on touched paths
- [ ] Search for prior art with `Grep`

If the spec references code that doesn't exist yet, say so — do not pretend it does.

**1B: Existing Docs & Prior Art (MANDATORY — do not skip)**

Existing documentation often contains decisions that constrain the spec. Read them before reviewing.

Use `Glob` + `Read` to locate and consume:

- **ADRs** (`docs/adr/**/*.md`, `claudedocs/adr-*.md`, or wherever the project keeps them) — any ADR touching the spec's domain is binding context
- **Design docs / RFCs** (`docs/design/**/*.md`, `docs/rfcs/**/*.md`) — especially anything mentioning the entities or flows in the spec
- **Prior spec analyses** (`claudedocs/*-panel-analysis.md`) — check whether this spec has been reviewed before and what was flagged
- **PRDs** (`docs/prd/**/*.md`) — upstream context from product
- **Runbooks, onboarding docs, architecture guides** — convention sources
- **API docs / OpenAPI specs** already in the project — the spec may contradict an existing contract
- **Test fixtures and existing test cases** — edge cases the team has already thought about
- **Migration files** (`src/main/resources/db/**/*.sql`) — schema reality
- **CHANGELOG.md / release-notes** — recent domain changes that affect this spec

For every relevant doc found, note: **[DOC-REF]** `<path>` → `<one-line relevance>` in the final report. Conflicts between this spec and existing ADRs are HIGH severity findings.

**1C: External Research with Tools (use context7 FIRST, then web)**

Training data is often out of date. Use real tools:

**context7 MCP** (`mcp__context7__resolve-library-id`, `mcp__context7__query-docs`) — **use this FIRST for every library, framework, SDK, or API mentioned in the spec**. Training-data knowledge about Spring Boot 4, React 19, Next.js 15, Temporal 1.26+, etc. may be wrong or stale. Explicit trigger cases:

- Spec mentions a framework → resolve its library ID, query current docs for the pattern
- Spec mentions an SDK method → query for current API signature
- Spec mentions a version (e.g., "Spring Boot 3") → query for version-specific guidance, check if still supported
- Spec defers a decision to "use the latest best practice" → query for what "latest" actually means today

**WebSearch / WebFetch** for:
- CVEs and security advisories for dependencies the spec introduces
- RFCs / IETF drafts relevant to the protocol or data format
- NIST / OWASP guidance for security-sensitive flows (auth, crypto, PII, payment)
- Regulatory references (GDPR, PCI-DSS, PSD2, HIPAA) when the domain is finance/health/EU
- Reference implementations in well-known open-source projects
- ThoughtWorks Technology Radar status for key dependencies

**Sourcegraph MCP** (if connected, `mcp__sourcegraph__*`) for searching across public open-source implementations of the same pattern.

**Rules**:
- Cite every source with a link in the final report
- Do NOT invent URLs — only cite what you actually fetched
- Synthesize findings into actionable insights, not link dumps
- When context7 and web search disagree, trust context7 (it queries current docs)
- Quote the exact version number you verified against

**1D: Stack Version Verification**

After context7 research, run `/stack-check` (or detect manually) against the project and compare to what the spec assumes:

- Does the spec assume Java 21 but the project is Java 25?
- Does the spec reference Spring Boot 3 APIs but the project is on Spring Boot 4?
- Does the spec reference deprecated APIs?
- Is the spec's target framework version still supported?

Any mismatch is at minimum a MEDIUM finding — often HIGH if it blocks implementation.

**1E: Context Manifest (mandatory output of Phase 1)**

Before proceeding to Phase 2, produce this manifest and include it in the final report:

```
CONTEXT MANIFEST — <spec name>
==============================

CODEBASE EVIDENCE
  Files read:          <n>   [list]
  Entities touched:    <list>
  Existing impl found: yes/no — <brief>
  Git activity (30d):  <n> commits, <n> authors, flags: <e.g. concurrent refactor>
  Conventions detected: [naming, DI style, error handling, testing, data access]
  Discrepancies vs spec: <n> — see findings

DOC EVIDENCE
  CLAUDE.md:           read / absent
  ADRs:                [list of relevant ADR paths]
  Design docs:         [list]
  Prior analyses:      [list, especially prior spec-panel output on this spec]
  Schema (migrations): [key files]
  API contract:        [OpenAPI path or absent]

EXTERNAL RESEARCH
  context7 queries:    [library @ version → finding]
  WebSearch queries:   [query → key finding]
  CVEs surfaced:       <n>
  Standards consulted: [OWASP / NIST / RFC ####]

STACK VERIFICATION
  Project stack:       Java <v>, Spring Boot <v>, <etc>
  Spec assumes:        <versions>
  Mismatches:          <list or "none">

BLOCKERS FROM PHASE 1
  <anything that prevents reliable review — surface here, do not proceed silently>
```

**Do not start Phase 2 until the Context Manifest is produced.** A Phase 2 finding that isn't backed by evidence from Phase 1 is speculation and must be marked as such.

### Phase 2: Spec Quality Audit

Before the expert panel, run a systematic quality check.

**2A: IEEE 830 Quality Attributes**

Score each attribute 1-10 with specific evidence:

| Attribute | Score | Evidence |
|-----------|-------|----------|
| **Correct** — Every requirement reflects an actual system need | | |
| **Unambiguous** — Each requirement has exactly one interpretation | | |
| **Complete** — All requirements included, no TBDs or gaps | | |
| **Consistent** — No requirements contradict each other | | |
| **Ranked** — Prioritized by importance and stability | | |
| **Verifiable** — Each requirement can be tested via a finite process | | |
| **Modifiable** — Easy to change without cascading updates | | |
| **Traceable** — Bidirectional: backward to source, forward to design/test | | |

**2B: Spec Smells Scanner**

Scan the spec for red-flag language that signals ambiguity or incompleteness:

| Smell Category | Red-flag Words | Found? | Location |
|----------------|---------------|--------|----------|
| Unquantified scope | all, always, every, never, none | | |
| Vague frequency | most, many, several, some, usually, normally, often | | |
| Vague adjectives | easy, user-friendly, fast, flexible, robust, efficient, seamless, intuitive | | |
| Weak verbs | handle, improve, provide, support, maximize, optimize, manage, process | | |
| Uncertainty markers | should, can, could, may, might, if possible, as needed, TBD | | |
| Implementation leak | use [specific technology], implement via, built with | | |

Every flagged instance must be rewritten into a concrete, testable requirement.

**2C: Cross-Cutting Concerns Checklist**

Verify each concern is explicitly addressed or intentionally scoped out:

| Concern | Addressed? | Where in Spec | Gap Severity |
|---------|-----------|---------------|--------------|
| **Security** — Auth model, encryption, input validation, secrets | | | |
| **Observability** — Metrics, logging, tracing, alerting, SLOs | | | |
| **Accessibility** — WCAG 2.2 AA, keyboard nav, screen readers | | | |
| **Internationalization** — Locale, currency, date/time, RTL | | | |
| **Data Privacy** — PII classification, GDPR/CCPA, retention, consent | | | |
| **Backward Compatibility** — API versioning, schema migration, client matrix | | | |
| **Rollback Strategy** — Deployment rollback, data rollback, time-to-rollback | | | |
| **Feature Flags** — Gradual rollout, kill switch, flag cleanup timeline | | | |
| **Error Handling** — Failure modes, retry policies, circuit breakers, fallbacks | | | |
| **Performance** — Latency targets, throughput, capacity, scalability | | | |
| **Caching** — Strategy, invalidation, TTLs, consistency impact | | | |
| **Rate Limiting** — Throttling, quotas, abuse prevention | | | |
| **Disaster Recovery** — Failover, RTO/RPO, data integrity verification | | | |
| **Multi-tenancy** — Isolation, data segregation, tenant-specific config | | | |

Mark N/A for genuinely irrelevant concerns. Missing concerns with MEDIUM+ severity become expert panel findings.

**2D: Alternatives Considered Check**

Every spec must answer: "Why this approach and not another?" Verify:
- At least 2 alternatives were evaluated
- Each alternative has clear trade-offs documented (pros, cons, why rejected)
- The chosen approach has explicit rationale, not just "it felt right"

If the spec lacks alternatives, flag as a CRITICAL finding — it means the design space was not explored.

### Phase 3: Expert Panel Analysis

**Severity Classification (used by all experts):**

| Level | Definition | Action |
|-------|-----------|--------|
| **CRITICAL** | Blocks delivery, causes data loss, security vulnerability, or fundamental design flaw | Must fix before implementation starts |
| **HIGH** | Will cause bugs, performance issues, or significant rework if not addressed | Must fix before feature ships |
| **MEDIUM** | Creates tech debt, testing gaps, or operational risk | Should fix, schedule if time-constrained |
| **LOW** | Improves polish, developer experience, or documentation quality | Nice-to-have, defer if needed |

**Structured Finding Format (every expert uses this):**

```
[SEVERITY] Issue title
├─ Issue: What's wrong, with specific location in spec
├─ Impact: What happens if not addressed
├─ Recommendation: Concrete fix (file, function, specific change)
└─ Rationale: Why this matters (cite framework, pattern, or research)
```

**Fixed Experts (always included):**

| Expert | Domain | Focuses on |
|--------|--------|------------|
| **Karl Wiegers** | Requirements Quality | Completeness, testability, ambiguity, missing acceptance criteria, contradictions. Uses IEEE 830 + SMART criteria. |
| **Martin Fowler** | Architecture & Design | Integration gaps, coupling issues, missing abstractions, pattern fitness. Checks for alternatives considered. |
| **Gojko Adzic** | Specification by Example | Concrete Given/When/Then scenarios, edge cases the spec doesn't address. Every requirement must have at least one executable example. |
| **Lisa Crispin** | Testing & Quality | Test gaps, untested paths, broken assumptions, regression risks. Maps the testing pyramid for this feature. |
| **Michael Nygard** | Operational Concerns | Failure modes, deployment risks, monitoring gaps, data migration safety, circuit breakers, bulkheads, timeouts. |

**Devil's Advocate (always included):**

| Expert | Domain | Focuses on |
|--------|--------|------------|
| **The Skeptic** | Fundamental Challenge | Challenges the spec's premise. Asks: "Should we build this at all?", "What if we did nothing?", "What's the simplest thing that could work?", "What assumption, if wrong, makes this entire spec invalid?" |

The Skeptic's role is to prevent groupthink and rubber-stamping. They must produce at least 2 challenges to the spec's fundamental approach, not just implementation details.

**Domain Experts (activated based on spec content):**

| Expert | Activated when spec involves | Focuses on |
|--------|------------------------------|------------|
| **Roy Fielding** | API design or integration | REST constraints, resource modeling, versioning, error contracts |
| **Martin Kleppmann** | Database or data modeling | Consistency guarantees, migration safety, schema evolution |
| **Dan Abramov** | Frontend/UI | Component composition, state management, rendering performance |
| **Troy Hunt** | Security, auth, compliance | OWASP risks, auth flows, data exposure, secrets management |
| **Pat Helland** | Payments, fintech, transactions | Idempotency, exactly-once semantics, compensation patterns, ledger integrity |
| **Greg Young** | Event-driven architecture | Event design, projection strategy, eventual consistency, replay safety |
| **Bernd Ruecker** | Workflow orchestration | Saga vs orchestration, compensation, timeout handling, workflow versioning |
| **Charity Majors** | DevOps, deployment, infrastructure | SLOs, alerting philosophy, deployment safety, canary patterns |
| **Marty Cagan** | Product/UX decisions | Solving the right problem, discovery gaps |
| **Guillermo Rauch** | Mobile or cross-platform | SSR vs CSR, edge deployment, hydration strategy, performance budget |

State which domain experts are activated and why. Each expert provides 2-5 specific, actionable findings using the structured format above — not generic advice.

### Parallel Expert Execution

Expert panel members execute their analysis **in parallel**:
- Launch all activated experts as separate Agent calls in a single message
- Fixed experts (IEEE Auditor, Spec Smells Scanner, Cross-Cutting Reviewer) always run
- Domain-activated experts (based on spec content) run in parallel alongside fixed experts
- Devil's Advocate runs after initial findings are collected (needs findings to challenge)

**Model routing for experts:**

| Expert | Model | Rationale |
|---|---|---|
| Domain experts | `opus` | Deep domain reasoning |
| IEEE Auditor | `sonnet` | Systematic checklist evaluation |
| Spec Smells Scanner | `sonnet` | Pattern matching against red flags |
| Cross-Cutting Reviewer | `sonnet` | Checklist-driven gap analysis |
| Devil's Advocate | `opus` | Independent critical thinking |
| Internet Researcher | `sonnet` | Web search + synthesis |

### Phase 4: Quality Score

Produce an overall spec quality scorecard:

| Dimension | Score (1-10) | Key Issue |
|-----------|-------------|-----------|
| **Requirements Clarity** — Language precision and freedom from ambiguity | | |
| **Completeness** — Coverage of functional, non-functional, and edge cases | | |
| **Testability** — Every requirement has measurable acceptance criteria | | |
| **Architectural Soundness** — Design patterns, boundaries, and coupling | | |
| **Operational Readiness** — Monitoring, failure modes, rollback, deployment | | |
| **Cross-Cutting Coverage** — Security, a11y, i18n, privacy, compatibility | | |
| **Overall** | | |

Scoring guide:
- **9-10**: Production-ready, minimal revisions needed
- **7-8**: Solid foundation, address HIGH findings before implementation
- **5-6**: Significant gaps, requires another review cycle after revisions
- **3-4**: Major rework needed, do not start implementation
- **1-2**: Fundamentally flawed, restart from problem statement

### Phase 5: Consolidated Findings

**Current State Summary:**

| Layer | Current State | What Spec Says | Gap | Severity |
|-------|--------------|----------------|-----|----------|

**Risk Register:**

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|

**Implementation Plan:**

| # | Task | Files to Create/Modify | Effort | Dependencies | Expert Source |
|---|------|----------------------|--------|--------------|---------------|

**Recommended Priority:**
- **Must-do (blocks delivery):** tasks that must be done before the feature can ship
- **Should-do (blocks quality):** tasks that prevent bugs, security issues, or tech debt
- **Nice-to-have (improves polish):** tasks that make the feature better but aren't blocking

**Recommended Reading:** references from Phase 1C the team should review.

### Phase 6: Save Recommendations

Save the full analysis to:

```
claudedocs/<spec-name>-panel-analysis.md
```

Include a recommendation tracker at the top:

```markdown
# Panel Analysis: <spec name>
**Date:** <today>
**Spec:** <path to original spec>
**Status:** IN REVIEW
**Quality Score:** <overall>/10

## Recommendation Tracker
| # | Recommendation | Severity | Status | Owner | Notes |
|---|---------------|----------|--------|-------|-------|
```

Set all statuses to `PENDING`.

Tell the user: "Analysis saved to claudedocs/<name>-panel-analysis.md. To action recommendations, run: /spec-update @claudedocs/<name>-panel-analysis.md"

## Anti-patterns
- **Skipping Phase 0** — Jumping straight into analysis without understanding context
- **Trusting the spec** — Accepting claims about current state without verifying against actual code
- **Generic advice** — "Improve error handling" instead of "Add circuit breaker in PaymentService.processRefund() — currently throws unhandled NPE when refund exceeds original amount"
- **Uncited recommendations** — Making claims without tracing to the expert or research source
- **Reviewing in isolation** — Not checking git history, related files, or existing patterns
- **Non-actionable findings** — If it can't be acted on, it's not a finding
- **Rubber-stamping** — Giving high scores to complex specs without deep scrutiny. The bigger the spec, the more scrutiny it deserves
- **Bikeshedding** — Spending analysis time on trivial naming/formatting while ignoring architectural concerns
- **Implementation manual without rationale** — Describing "how to build it" without explaining "why this way and not another"
- **Ignoring NFRs** — Treating non-functional requirements (performance, security, observability) as afterthoughts. 50% of product defects originate in requirements, and NFRs are the most commonly under-specified
- **Groupthink** — All experts agreeing without The Skeptic challenging the fundamental approach

## Quality bar
- Every finding uses the structured format: Issue → Severity → Impact → Recommendation → Rationale
- Every finding traces to an expert or research source
- IEEE 830 quality attributes were scored with specific evidence
- Spec smells scanner ran and flagged vague/ambiguous language with rewrites
- Cross-cutting concerns checklist was completed (no blank rows — mark N/A or flag gap)
- Alternatives considered were verified or their absence flagged as CRITICAL
- The Skeptic challenged the spec's premise with at least 2 fundamental questions
- Quality scorecard was produced with scores per dimension
- Clarifying questions were asked and answered before analysis began
- Codebase investigation verified spec claims against actual code
- Internet research produced cited sources, not opinions
- Implementation plan has clear priorities, dependencies, and effort estimates

## Workflow context

**Upstream skills that feed into this:**
- `/prd` — PRD document to analyze
- `/design-doc` — Design document / RFC to review
- `/api-design` — API specification to evaluate
- `/data-design` — Data architecture to assess
- `/flow-map` — System flow paths to validate
- `/ui-design` — UI design artifacts to review

**Downstream skills that consume this output:**
- `/spec-update` — Action recommendations from panel analysis
- `/spec-to-impl` — Implementation from analyzed spec
- `/ticket-breakdown` — Break analyzed spec into tickets
- `/test-plan` — Test planning informed by expert findings

### Learning & Memory

After analysis completes, save:
- Domain patterns specific to this project's industry vertical
- Common spec gaps that were found (to proactively check in future specs)
- Expert recommendations that the team accepted (validated patterns)
- Spec quality benchmarks for this project

---

## Output contract

```yaml
produces:
  - type: "panel-analysis"
    format: "markdown"
    path: "claudedocs/<spec-name>-panel-analysis.md"
    sections:
      - clarification-answers
      - codebase-findings
      - internet-research
      - ieee-830-quality-audit
      - spec-smells-report
      - cross-cutting-concerns-checklist
      - alternatives-considered-check
      - expert-panel-findings
      - skeptic-challenges
      - quality-scorecard
      - current-state-summary
      - risk-register
      - implementation-plan
      - recommended-priority
      - recommended-reading
      - recommendation-tracker
  handoff: "Run superpowers:systematic-debugging per CRITICAL finding. Write claudedocs/handoff-spec-panel-<timestamp>.yaml — suggest: spec-update (apply recommendations), spec-to-impl (ONLY after CRITICAL findings are resolved), ticket-breakdown (turn analysis into tickets), superpowers:writing-plans (remediation plan)"
```

## Anti-patterns (never do these)

- Producing implementation code inline — this skill reviews, never implements
- Skipping clarification questions and guessing stakeholder intent
- Rubber-stamping a spec — if everything scores 9/10, re-examine; specs almost always have hidden gaps
- Chaining directly to `/spec-to-impl` when CRITICAL findings exist — route through `/spec-update` first
- Writing a remediation plan without first running `superpowers:systematic-debugging` on each CRITICAL finding to understand root cause
- Running this skill on an incomplete or clearly-draft spec — request the user finish the draft first, then review
- Modifying the spec file in place — always produce a separate analysis document that the user can review before applying changes
