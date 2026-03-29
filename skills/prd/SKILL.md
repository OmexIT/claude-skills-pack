---
name: prd
description: Write or update a Product Requirements Document. Supports both creating new PRDs from scratch and surgically updating existing PRDs to match implementation changes. Triggers: "write a PRD", "update the PRD", "requirements", "feature brief", "product spec".
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

This is the critical addition. Updating an existing PRD is fundamentally different from creating one.

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
- **Preserve requirement IDs** — update content, not IDs. Downstream artifacts (test plans, tickets, traceability) reference these IDs.
- **Mark superseded requirements** — don't delete them silently. Add: "**Superseded** — merged into FR-018 via SigningStrategy pattern (v1.1)"
- **Add new requirements** with sub-IDs when possible — FR-017a, FR-017b — to avoid renumbering everything
- **Update the version and change log** — add an entry at the top:
  ```
  | Version | Date | Author | Changes |
  |---------|------|--------|---------|
  | 1.1 | 2026-03-29 | Engineering | Order flow redesign: new state machine, prerequisites, profiles |
  ```
- **Preserve all unrelated sections** — do NOT touch sections outside the change scope
- **Update cross-references** — if Section 3.4 mentions Section 5.1, and both changed, ensure consistency

### Step 3: Codebase-aware validation

**After editing, verify against the implementation:**
- Do the requirement IDs still align with what's actually built?
- Are there implemented features not captured in the PRD?
- Are there PRD requirements that were descoped during implementation?
- Do the API contracts in the PRD match the actual endpoints?
- Do the data model sketches match the actual schema?

This step catches drift between PRD and reality. Use an Explore subagent to spot-check.

### Step 4: Self-review + user review

Same as create mode — run the Definition of Ready checklist, then present for user approval.

---

## How I'll think about this

1. **Start with the problem, not the solution**: Articulate user pain clearly before proposing anything. If the problem isn't compelling, the feature shouldn't exist.
2. **Validate the "why now"**: What changed that makes this urgent?
3. **Define users precisely**: Not "users" — which users, doing what, in what context?
4. **Scope ruthlessly**: Non-goals are as important as goals.
5. **Quantify success**: "Improve retention" is not a metric. "Increase 7-day retention from 40% to 48% within 3 months" is.
6. **Think about failure modes**: What happens if misused? What if adoption is low? Rollback plan?
7. **Acceptance criteria per requirement**: Every P0 needs Given/When/Then. If you can't write criteria, the requirement isn't specific enough.
8. **Edge cases are requirements**: Empty states, max values, concurrent access, expired sessions, missing permissions.
9. **NFRs per feature, not just global**: "FR-003 must respond in < 200ms p95" is actionable. "The system should be fast" is not.
10. **PRDs are living documents**: They drift from reality. Update mode exists because implementation always reveals things the original PRD didn't anticipate. Acknowledge and capture the drift rather than pretending the original PRD was right.

## Anti-patterns to flag
- Writing a solution disguised as requirements
- Listing features without explaining what problem each solves
- Vague success metrics ("improve user experience")
- Missing non-goals (leads to unbounded scope)
- Ignoring edge cases and error states in UX requirements
- Requirements without acceptance criteria (untestable)
- Global NFRs without per-feature targets (unmeasurable)
- UI descriptions without states (loading, empty, error, success)
- Dependencies listed without owners or status (unaccountable)
- Open questions without owners or due dates (never resolved)
- **Update-mode specific:**
  - Silently deleting superseded requirements (breaks traceability)
  - Renumbering all requirement IDs (breaks downstream references)
  - Updating the PRD without reading the actual implementation (creates new drift)
  - Touching unrelated sections "while we're at it" (scope creep)

## Quality bar
- Every P0 requirement has acceptance criteria in Given/When/Then format
- Every P0 requirement has at least 2 edge cases documented
- Every requirement that touches UI lists component states (default, loading, empty, error)
- NFRs are specified per feature where applicable (performance, security, accessibility)
- Success metrics have baselines, targets, and timelines
- Dependencies have owners and risk assessments
- Rollout plan includes feature flags, staged release, and rollback trigger
- Open questions have owners and due dates
- Definition of Ready checklist at the end passes
- **Update-mode specific:**
  - Change log entry added with version, date, and summary
  - Superseded requirements marked (not deleted)
  - New requirements use sub-IDs (FR-017a) to preserve numbering
  - Cross-references updated consistently

## Workflow context
- Typically follows: `/opportunity-assessment`, `/competitive-analysis`, `/spec-panel`
- Feeds into: `/design-doc`, `/ticket-breakdown`, `/spec-to-impl`, `/ui-design`
- Related: `/user-flow` (UX requirements), `/experiment-design` (A/B test design)
- **Update mode typically follows:** `/design-doc`, `/spec-to-impl`, implementation completion

## Output
Use the template at `templates/prd.md`.

The template enforces:
- **Acceptance criteria** (Given/When/Then) per functional requirement
- **Edge cases and error states** per requirement
- **Per-feature NFRs** (performance, security, accessibility targets)
- **UI component specs** (props, states, interactions, accessibility)
- **Dependency matrix** (owner, status, risk if delayed)
- **Definition of Ready checklist** (must pass before implementation)

## Learning & Memory

After PRD completes, save:
- User personas and pain points specific to this product area
- Requirements patterns that proved well-structured for downstream consumers
- Common gaps that were caught during Definition of Ready review
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
