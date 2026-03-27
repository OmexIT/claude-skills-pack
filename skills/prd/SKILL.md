---
name: prd
description: Write or refine a Product Requirements Document: problem, goals, users, scope, non-goals, UX notes, success metrics, rollout, and risks. Triggers: "write a PRD", "requirements", "feature brief", "product spec".
argument-hint: "[feature / problem]"
effort: high
---

# PRD

## What I'll do
Turn a rough idea into a clear PRD that engineering, design, and stakeholders can align on. Every functional requirement gets acceptance criteria, edge cases, and per-feature NFRs.

## Minimal clarifications (only if needed)
- Target user/persona
- Problem statement in one sentence
- Desired outcome (how we'll measure success)
- Constraints (timeline/platform/compliance)
- Dependencies or blocked-on items

## Multi-Agent PRD Generation

For complex features, decompose PRD generation across specialist agents:

### Agent Roster

| Agent | Model | Responsibility |
|---|---|---|
| `PROBLEM_ANALYST` | `opus` | User pain analysis, competitive context, "why now" validation |
| `REQUIREMENTS_ENGINEER` | `sonnet` | Functional requirements with Given/When/Then acceptance criteria |
| `METRICS_DESIGNER` | `opus` | Quantifiable success metrics with baselines, targets, timelines |
| `EDGE_CASE_ANALYST` | `sonnet` | Boundary conditions, error states, abuse scenarios |

### Execution Pattern

```
Phase 1: Problem + user analysis (PROBLEM_ANALYST — sequential)
    ↓
Phase 2: Parallel requirement generation
  ┌──────────────────┬──────────────────┬──────────────────┐
  │ REQUIREMENTS     │ METRICS          │ EDGE_CASE        │
  │ _ENGINEER        │ _DESIGNER        │ _ANALYST         │
  └────────┬─────────┴────────┬─────────┴────────┬─────────┘
           └──────────────────┼──────────────────┘
                              ↓
Phase 3: PRD synthesis + Definition of Ready check (sequential)
```

- Phase 1 establishes shared context (problem, users, scope) before parallel work
- Phase 2 agents work independently on orthogonal PRD sections
- METRICS_DESIGNER needs problem context but not requirement details — can run in parallel
- EDGE_CASE_ANALYST can run with `run_in_background: true` if time-constrained

## How I'll think about this
1. **Start with the problem, not the solution**: Articulate user pain clearly before proposing anything. If the problem isn't compelling, the feature shouldn't exist.
2. **Validate the "why now"**: What changed that makes this urgent? New data, user feedback, competitive pressure, or technical enablement?
3. **Define users precisely**: Not "users" — which users, doing what, in what context? Different personas may need different solutions.
4. **Scope ruthlessly**: Non-goals are as important as goals. Explicitly state what this feature will NOT do to prevent scope creep.
5. **Quantify success**: "Improve retention" is not a metric. "Increase 7-day retention from 40% to 48% within 3 months" is.
6. **Think about failure modes**: What happens if this feature is misused? What if adoption is low? What's the rollback plan?
7. **Acceptance criteria per requirement**: Every P0 functional requirement needs Given/When/Then criteria. If you can't write acceptance criteria, the requirement isn't specific enough.
8. **Edge cases are requirements**: For every feature, enumerate what happens at the boundaries — empty states, maximum values, concurrent access, expired sessions, missing permissions. Each is a testable scenario.
9. **NFRs per feature, not just global**: "The system should be fast" is useless. "FR-003 (payment submission) must respond in < 200ms p95" is actionable.
10. **UI components are specifications**: If the PRD references UI, each significant component needs props, states, and interactions defined — not just a vague description.

## Anti-patterns to flag
- Writing a solution disguised as requirements ("We need a modal that shows X" instead of "Users need to understand X before proceeding")
- Listing features without explaining what problem each solves
- Vague success metrics ("improve user experience")
- Missing non-goals (leads to unbounded scope)
- Ignoring edge cases and error states in UX requirements
- Requirements without acceptance criteria (untestable)
- Global NFRs without per-feature targets (unmeasurable)
- UI descriptions without states (loading, empty, error, success)
- Dependencies listed without owners or status (unaccountable)
- Open questions without owners or due dates (never resolved)

## Quality bar
- Every P0 requirement has acceptance criteria in Given/When/Then format
- Every P0 requirement has at least 2 edge cases documented
- Every requirement that touches UI lists component states (default, loading, empty, error)
- NFRs are specified per feature where applicable (performance, security, accessibility)
- Success metrics have baselines, targets, and timelines — not just descriptions
- Dependencies have owners and risk assessments
- Rollout plan includes feature flags, staged release, and rollback trigger
- Open questions have owners and due dates
- Definition of Ready checklist at the end passes

## Workflow context
- Typically follows: `/opportunity-assessment`, `/competitive-analysis`
- Feeds into: `/design-doc`, `/ticket-breakdown`, `/spec-to-impl`, `/ui-design`, `/spec-panel`
- Related: `/user-flow` (UX requirements), `/experiment-design` (A/B test design)

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

## Output contract
```yaml
produces:
  - type: "prd"
    format: "markdown"
    path: "claudedocs/<feature>-prd.md"
    sections: [problem, goals, users, requirements, acceptance_criteria, edge_cases, nfrs, ui_specs, data_model, metrics, dependencies, integrations, rollout, instrumentation, risks, definition_of_ready]
    handoff: "Write claudedocs/handoff-prd-<feature>-<timestamp>.yaml — suggest: design-doc, ticket-breakdown, spec-to-impl, ui-design"
```
