---
name: prd
description: Write or refine a Product Requirements Document: problem, goals, users, scope, non-goals, UX notes, success metrics, rollout, and risks. Triggers: "write a PRD", "requirements", "feature brief", "product spec".
argument-hint: "[feature / problem]"
---

# PRD

## What I'll do
Turn a rough idea into a clear PRD that engineering, design, and stakeholders can align on.

## Minimal clarifications (only if needed)
- Target user/persona
- Problem statement in one sentence
- Desired outcome (how we'll measure success)
- Constraints (timeline/platform/compliance)
- Dependencies or blocked-on items

## How I'll think about this
1. **Start with the problem, not the solution**: Articulate user pain clearly before proposing anything. If the problem isn't compelling, the feature shouldn't exist.
2. **Validate the "why now"**: What changed that makes this urgent? New data, user feedback, competitive pressure, or technical enablement?
3. **Define users precisely**: Not "users" — which users, doing what, in what context? Different personas may need different solutions.
4. **Scope ruthlessly**: Non-goals are as important as goals. Explicitly state what this feature will NOT do to prevent scope creep.
5. **Quantify success**: "Improve retention" is not a metric. "Increase 7-day retention from 40% to 48% within 3 months" is.
6. **Think about failure modes**: What happens if this feature is misused? What if adoption is low? What's the rollback plan?

## Anti-patterns to flag
- Writing a solution disguised as requirements ("We need a modal that shows X" instead of "Users need to understand X before proceeding")
- Listing features without explaining what problem each solves
- Vague success metrics ("improve user experience")
- Missing non-goals (leads to unbounded scope)
- Ignoring edge cases and error states in UX requirements

## Quality bar
- Every requirement traces back to a user problem or business goal
- Success metrics are specific, measurable, and time-bound
- Non-goals section exists and is substantive
- Rollout plan includes feature flags, staged release, and rollback
- Open questions are listed honestly (not hidden)

## Workflow context
- Typically follows: `/opportunity-assessment`, `/competitive-analysis`
- Feeds into: `/design-doc`, `/ticket-breakdown`, `/experiment-design`
- Related: `/user-flow` (UX requirements)

## Output
Use the template at `templates/prd.md`.

Also include:
- **Open questions** (what we still need to decide)
- **Risks & mitigations**
- **Instrumentation plan** (events + metrics)
- **Rollout plan** (flags, staged release, fallback)

## Output contract
```yaml
produces:
  - type: "prd"
    format: "markdown"
    path: "claudedocs/<feature>-prd.md"
    sections: [problem, goals, users, requirements, metrics, scope]
```
