---
name: prd
description: "Use when the user wants to write a PRD, product spec, or feature brief, capture requirements, or update an existing PRD to match design or implementation changes."
---

# PRD

A PRD records what to build and why: problem, scope, testable requirements, and how success is judged. It does not choose an architecture (`design-doc`) or record a single technical decision (`adr`).

## Mode
- **Create**: no PRD covers this area.
- **Update**: a PRD exists ("update the PRD", "sync the PRD with ..."). Surgical edits only.

## Create
1. Read what the user provided and the relevant code. Ask only what is missing, one question at a time, multiple choice where possible: target user, the problem in one sentence, success measure, constraints.
2. Scope gate before drafting: who is blocked and how, the smallest version that solves it, whether existing functionality already does it, and why now. Recommend shrinking or dropping the idea when the answers are weak.
3. If the repo has a PRD home (`docs/prd/`, `PRODUCT.md`), match its structure. Otherwise use `assets/prd.md` and keep only the conditional sections this feature needs.

## Update
1. Read the PRD and the live evidence behind the change: code, design doc, ADRs, recorded decisions, external contracts.
2. Classify every divergence before editing:
   - **Code defect**: the PRD is right and the code is wrong. Leave the PRD; report the defect.
   - **Undocumented approved change**: update the PRD and cite the decision or evidence.
   - **Stale spec**: the requirement no longer reflects intent; revise it or mark it superseded.
   - **Unresolved decision**: do not pick a side; add an open question with an owner.
3. Write a change map (section, requirement IDs, action, classification). Confirm it with the user when it touches many sections or any P0.
4. Edit: preserve requirement IDs and change content, not numbers. Mark superseded requirements instead of deleting them ("Superseded by FR-018 in v1.2"). Insert new ones with sub-IDs (FR-017a). Add a change-log row naming the evidence. Fix cross-references. Leave unrelated sections alone.
5. Re-check against the code: implemented but undocumented behavior, descoped requirements, contract drift. Search the code directly; delegate the search only when the codebase is large.

## Rules
- Requirements state observable behavior, not mechanisms. Every non-trivial P0 has Given/When/Then criteria and at least two materially different edge cases; do not pad an atomic rule with filler.
- Non-goals are mandatory. When the feature touches another team's data or a provider, name the system of record and what this feature must not own.
- Success measures have a baseline (or a plan to get one), a target, and a window.
- NFRs only for categories this feature changes, each with a way to verify it. No feature flag, analytics plan, or staged rollout unless the feature has a present need and an owner.
- Flag before presenting: a solution posing as a requirement, a vague metric, missing non-goals, an untestable requirement, a TBD without an owner, "while we're at it" scope.
- Run the template's Definition of ready, then present for approval when the repository workflow expects it.

## Workflow context
- `prd` defines what and why; `design-doc` decides how; `adr` records one decision; `spec-panel` reviews readiness.
- Upstream: `opportunity-assessment`, `competitive-analysis`. Downstream: `design-doc`, `ticket-breakdown`, `spec-to-impl`, `ui-design`.
- Run update mode when `design-doc`, `spec-to-impl`, or a finished build changes what was planned.

## Output contract
```yaml
produces:
  - type: "prd"
    format: "markdown"
    path: "claudedocs/<feature>-prd.md"
    sections: [problem, goals, users, requirements, acceptance_criteria, edge_cases, nfrs, ui_specs, data_model, metrics, dependencies, integrations, rollout, instrumentation, risks, definition_of_ready]
    handoff: "Write claudedocs/handoff-prd-<feature>-<timestamp>.yaml - suggest: design-doc, ticket-breakdown, spec-to-impl, ui-design"
```
