---
name: spec-panel
description: >
  Expert panel spec analysis — domain experts, internet research, clarifying questions,
  and actionable recommendations. Triggers: "spec panel", "expert review", "panel analysis",
  "spec analysis", "expert panel review".
argument-hint: "[spec document or @file]"
---

# Spec Panel Analysis

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

**1A: Codebase Investigation**
- Map the full directory structure relevant to this spec
- Read ALL files mentioned in the spec — don't assume, verify
- Check git history for recent changes to related files
- Identify existing patterns, conventions, and abstractions already in use
- Find discrepancies between what the spec claims and what the code actually does

**1B: Internet Research**
- Best practices for the core technical patterns in this spec
- Known pitfalls for the technologies involved
- Security advisories for any new dependencies the spec introduces
- Alternative approaches used by established projects solving the same problem
- Relevant documentation for frameworks/libraries referenced in the spec

Cite sources. Don't just search — synthesize findings into actionable insights.

**1C: Document Recommendations**
- Official documentation pages the team should read before implementation
- Blog posts or case studies from companies who solved similar problems
- GitHub repos with reference implementations worth studying
- RFCs or ADRs from the ecosystem that inform the design

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
```
