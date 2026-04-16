---
name: prd
description: "Writes or updates a Product Requirements Document with acceptance criteria, edge cases, and per-feature NFRs. Supports creating new PRDs from scratch and surgically updating existing PRDs to match implementation changes. Use when writing a PRD, updating the PRD, defining requirements, creating a feature brief, or drafting a product spec."
argument-hint: "[feature / problem / path-to-existing-prd]"
effort: high
---

# PRD

## What I'll do
Turn a rough idea into a clear PRD — or update an existing PRD to reflect design decisions and implementation changes. Every functional requirement gets acceptance criteria, edge cases, and per-feature NFRs.

## Mode Detection

**Detect mode from arguments:**
- **Create mode:** No existing PRD path given, or user says "write a PRD for..."
- **Update mode:** User provides an existing PRD path, or says "update the PRD", "sync the PRD with..."

The mode determines the workflow. Both modes produce the same quality output.

## Minimal clarifications

**Create mode:**
- Target user/persona
- Problem statement in one sentence
- Desired outcome (how we'll measure success)
- Constraints (timeline/platform/compliance)
- Dependencies or blocked-on items

**Update mode:**
- What changed (design doc, implementation, decision — the source of truth)
- Which sections are affected
- Whether requirement IDs should be preserved or renumbered

---

## Create Mode Workflow

### Step 1: Understand the problem
1. Read any existing docs the user provides (design docs, specs, notes)
2. Explore the codebase for relevant context (existing modules, patterns, conventions)
3. Ask clarifying questions — one at a time, multiple choice when possible

### Step 2: Draft the PRD
1. Use the template at `templates/prd.md`
2. Write all sections, scaling detail to complexity
3. Every P0 requirement gets Given/When/Then acceptance criteria
4. Every P0 requirement gets at least 2 edge cases
5. NFRs specified per feature, not just global

### Step 3: Self-review
Run the Definition of Ready checklist from the template. Fix gaps inline.

### Step 4: User review
Present the PRD and wait for approval before considering it done.

---

## Update Mode Workflow

Updating an existing PRD is fundamentally different from creating one.

### Step 1: Map the change scope

1. **Read the existing PRD** — understand the current structure, section numbering, requirement IDs
2. **Read the source of truth** — the design doc, implementation, or decision record that drives the update
3. **Map affected sections** — use an Explore subagent to identify which PRD sections, requirement IDs, and business rules need updating

Produce a **change map** before editing:
```
Section 3.4 (Order Lifecycle): FR-016 through FR-021 — REPLACE/UPDATE
Section 5.1 (Business Rules): BR-001 through BR-006 — UPDATE + ADD new rules
Section 7.2 (Data Model): ADD new tables
Section 8.2 (User Flow): REWRITE
```

### Step 2: Apply surgical edits

**Rules for updating:**
- **Preserve requirement IDs** — update content, not IDs. Downstream artifacts reference these IDs.
- **Mark superseded requirements** — don't delete them. Add: "**Superseded** — merged into FR-018 via SigningStrategy pattern (v1.1)"
- **Add new requirements** with sub-IDs (FR-017a, FR-017b) to avoid renumbering
- **Update the version and change log:**
  ```
  | Version | Date | Author | Changes |
  |---------|------|--------|---------|
  | 1.1 | 2026-03-29 | Engineering | Order flow redesign: new state machine |
  ```
- **Preserve all unrelated sections** — do NOT touch sections outside the change scope
- **Update cross-references** — ensure consistency across changed sections

### Step 3: Codebase-aware validation

After editing, verify against the implementation:
- Do requirement IDs still align with what's built?
- Are there implemented features not captured in the PRD?
- Are there PRD requirements that were descoped?
- Do API contracts and data model sketches match actual endpoints and schema?

Use an Explore subagent to spot-check.

### Step 4: Self-review + user review

Run the Definition of Ready checklist, then present for user approval.

---

## P0 Requirement Example

A concrete example of a well-formed P0 requirement:

### FR-003: Session timeout with unsaved changes

**Description:** When a user's session expires while they have unsaved form data, the system preserves their input and prompts re-authentication.
**User story:** US-002
**Priority:** P0

**Acceptance criteria:**
```gherkin
Given a user has unsaved changes in a form
When their session token expires
Then the system displays a re-authentication modal without navigating away
And after successful re-authentication, the form retains all unsaved data

Given a user has unsaved changes in a form
When their session token expires and re-authentication fails 3 times
Then the system saves a local draft and redirects to the login page
And displays a banner on next login: "You have a recovered draft from <timestamp>"
```

**Edge cases and error states:**
| Scenario | Expected behavior |
|---|---|
| User has unsaved changes across multiple tabs | Each tab independently prompts re-auth; drafts saved per-tab |
| Local storage is full when saving draft | Show warning: "Could not save draft — copy your work before logging in again" |
| Session expires during file upload | Cancel upload gracefully; resume after re-auth if file is still available |

**Non-functional requirements (this feature):**
- **Performance:** Re-auth modal renders in < 100ms; draft save completes in < 50ms
- **Security:** Local drafts encrypted at rest; cleared after 24 hours or successful recovery
- **Accessibility:** Re-auth modal traps focus, announces via screen reader, supports keyboard-only flow

---

## Requirements Principles and Quality Gates

These principles guide both writing and reviewing requirements. Flag violations during self-review.

**Problem-first thinking:**
- Articulate user pain before proposing solutions. If the problem isn't compelling, the feature shouldn't exist.
- Validate the "why now" — what changed that makes this urgent?
- Define users precisely: which users, doing what, in what context?

**Rigorous scoping:**
- Non-goals are as important as goals. Missing non-goals lead to unbounded scope.
- "Improve retention" is not a metric. "Increase 7-day retention from 40% to 48% within 3 months" is.
- Never list features without explaining what problem each solves.

**Testable requirements:**
- Every P0 requirement has Given/When/Then acceptance criteria. If you can't write criteria, the requirement isn't specific enough.
- Edge cases are requirements: empty states, max values, concurrent access, expired sessions, missing permissions.
- NFRs per feature, not just global: "FR-003 must respond in < 200ms p95" is actionable; "the system should be fast" is not.
- UI requirements list all component states (default, loading, empty, error, success).

**Completeness checks:**
- Success metrics have baselines, targets, and timelines
- Dependencies have owners and risk assessments
- Rollout plan includes feature flags, staged release, and rollback trigger
- Open questions have owners and due dates
- Definition of Ready checklist passes

**Anti-patterns to flag:**
- Writing a solution disguised as requirements
- Vague success metrics ("improve user experience")
- Requirements without acceptance criteria (untestable)
- Global NFRs without per-feature targets (unmeasurable)
- Dependencies listed without owners or status (unaccountable)
- Open questions without due dates (never resolved)

**Update-mode specific checks:**
- Superseded requirements marked, not silently deleted (breaks traceability)
- Requirement IDs preserved, not renumbered (breaks downstream references)
- PRD validated against actual implementation (prevents new drift)
- Unrelated sections left untouched (prevents scope creep)
- Change log entry added with version, date, and summary
- New requirements use sub-IDs (FR-017a) to preserve numbering
- Cross-references updated consistently

## PRDs are living documents

Implementation always reveals things the original PRD didn't anticipate. Update mode exists to acknowledge and capture drift rather than pretending the original PRD was right. Think about failure modes: what happens if misused? What if adoption is low? What's the rollback plan?

---

## Template Structure Reference

The output uses the template at `templates/prd.md`. Key sections for reference if the template file is unavailable:

1. **Summary** — One paragraph: what, who, outcome
2. **Problem** — User pain, evidence table, why now
3. **Goals** — Table with metric, target, timeline per goal
4. **Non-goals** — Explicit exclusions with rationale
5. **Users and personas** — Primary/secondary with current behavior and pain level
6. **User stories** — ID, persona, action, outcome, priority
7. **Scope** — In scope, out of scope, future considerations
8. **Functional requirements** — Each with acceptance criteria (Given/When/Then), edge case table, per-feature NFRs
9. **UI requirements** — Screens/states matrix, component specs, responsive behavior
10. **Data model sketch** — Entities, key fields, relationships, storage
11. **Global NFRs** — Performance, reliability, security, privacy, accessibility, localization, compatibility
12. **Success metrics** — Primary metric with baseline/target/timeline, secondary metrics, guardrails
13. **Dependencies** — Dependency matrix (owner, status, risk) and integration points (trigger, payload, auth, failure behavior)
14. **Rollout plan** — Feature flags, staged rollout table, rollback plan
15. **Analytics and instrumentation** — Events, dashboards, alerts
16. **Risks and mitigations** — Likelihood/impact matrix
17. **Open questions** — Owner, due date, resolution status
18. **Definition of Ready checklist** — Must pass before implementation begins

## Workflow context
- Typically follows: `/opportunity-assessment`, `/competitive-analysis`, `/spec-panel`
- Feeds into: `/design-doc`, `/ticket-breakdown`, `/spec-to-impl`, `/ui-design`
- Related: `/user-flow` (UX requirements), `/experiment-design` (A/B test design)
- **Update mode typically follows:** `/design-doc`, `/spec-to-impl`, implementation completion

## Learning & Memory

After PRD completes, save:
- User personas and pain points specific to this product area
- Requirements patterns that proved well-structured for downstream consumers
- Common gaps caught during Definition of Ready review
- Stakeholder feedback patterns (what they typically push back on)
- **Update mode:** Which sections drifted most from implementation and why

## Output contract
```yaml
produces:
  - type: "prd"
    format: "markdown"
    path: "claudedocs/<feature>-prd.md"
    sections: [problem, goals, users, requirements, acceptance_criteria, edge_cases, nfrs, ui_specs, data_model, metrics, dependencies, integrations, rollout, instrumentation, risks, definition_of_ready]
    handoff: "Write claudedocs/handoff-prd-<feature>-<timestamp>.yaml — suggest: design-doc, ticket-breakdown, spec-to-impl, ui-design"
```
