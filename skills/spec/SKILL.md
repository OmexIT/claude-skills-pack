---
name: spec
description: >
  Use when defining or changing WHAT to build - a new feature idea, a PRD to write or update,
  or scope that needs challenging before implementation starts.
argument-hint: "[feature idea or path-to-existing-prd]"
---

# Product spec (PRD-first)

PRDs are law in these repos: code follows the PRD, and divergence found later is a bug to flag - not a precedent to follow.

## Mode detection
- **Challenge** - user is unsure whether to build: run only the scope gate, report, stop.
- **Create** - no PRD covers this area.
- **Update** (most common) - a PRD exists: surgical edits only.

## Scope gate (always, before writing anything)
Answer in five lines; recommend kill or shrink when answers are weak:
1. What user problem does this solve - who, doing what, blocked how?
2. What is the smallest version that solves it? Everything else goes to "later".
3. Can existing functionality already do this?
4. Cost vs measurable business value: implementation + operational + maintenance, against what it directly contributes to the core product.
5. Why now?

## Create mode
- Clarify only what's genuinely missing - one question at a time, multiple-choice where possible (persona, problem, success measure, constraints).
- Find the repo's PRD home (`docs/prd/`, `docs/prd.md`, `PRODUCT.md`) and match its structure; otherwise use `references/prd-template.md`.
- Every P0 requirement: Given/When/Then acceptance criteria + ≥2 edge cases. NFRs per feature, not global. Non-goals are mandatory.
- State system-of-record and ownership boundaries explicitly ("Service A is the system of record for loans; this service must not evolve into a loan-management system").
- Include a negative-constraints section: what must NOT be built or changed.

## Update mode
- Read the PRD and the source of truth (design doc, implementation, decision) first; produce a change map before editing.
- Preserve requirement IDs - update content, not IDs. Mark superseded requirements; never delete silently. Insert with sub-IDs (FR-017a). Add a version + change-log entry. Update cross-references.
- After editing, validate against the codebase: implemented-but-undocumented features, descoped requirements, contract drift.

## Self-review - spec smells
Flag before presenting: solution masquerading as requirement · vague metric ("improve UX") · missing non-goals · requirement without testable criteria · TBD without owner · "while we're at it" scope creep.

Run the Definition-of-Ready checklist from the template. Present for approval - implementation starts only from an approved spec, via `plan`.
