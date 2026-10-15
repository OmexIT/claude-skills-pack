---
name: ux-review
description: "Use when the user wants a UI design or implementation evaluated for usability: UX review, heuristic evaluation, accessibility audit, cognitive walkthrough, or is this usable."
---

# UX review

> Delegation, model labels, and task tracking below use Claude Code notation. In Codex or another client, follow `../../references/cross-client.md`.

Evaluate a design or a running implementation from the user's side: can the target user complete
their task, understand what happened, recover from mistakes, and do it with assistive technology?
The output is findings and recommendations, not a redesign.

## Workflow context
- Boundary: `ui-design` creates design artifacts and its review mode checks them against the
  design system before build. This skill judges usability and accessibility of any design or
  built UI; fixes that need new screens or tokens go back to `ui-design` revision.
- Follows `user-flow`, `prd`, `ui-design`. Feeds `ticket-breakdown` (fix tickets) and code review.

## Inputs (ask only if missing)
- The UI: screens, mockups, a URL or running app, Figma link, or `design/` artifacts.
- Target user, their goal, and context (device, new or experienced, assistive technology needs).
- Known pain points.

## Gather evidence
- Running UI with browser tools available: walk the task, capture the accessibility tree or
  snapshot, keyboard-only pass, zoom to 200%, and reduced-motion and dark-theme checks where
  supported. Without tools, review what was provided and say what could not be verified.
- Evidence can be a screenshot, accessibility snapshot, DOM or code excerpt, measured contrast
  ratio, step-by-step reproduction, or a reproducible absence (no label, no focus state).

## Lenses and fan-out

| Lens | Model | Focus |
|---|---|---|
| `UX_STRATEGIST` | `opus` | Task completion, IA, flow efficiency, cognitive walkthrough |
| `A11Y_EXPERT` | `sonnet` | WCAG 2.2 AA, keyboard, screen readers, contrast, motion |
| `INTERACTION_DESIGNER` | `sonnet` | Feedback, errors and recovery, state transitions |
| `VISUAL_DESIGNER` | `sonnet` | Hierarchy, consistency, spacing, typography |

For a single screen, component, or short flow, apply all four lenses inline in one pass. Fan out
in parallel only for a multi-screen product or several long flows, and only where the client
supports subagents; then deduplicate overlapping findings before reporting.

## Method
1. **Cognitive walkthrough** for each step of the user's task: will they know what to do, notice
   the right control, understand the feedback, and recover from a mistake?
2. **Nielsen's heuristics**: status visibility, real-world match, control and freedom,
   consistency, error prevention, recognition over recall, flexibility, minimal design, error
   recovery, help.
3. **Accessibility (WCAG 2.2 AA)**:
   - Contrast 4.5:1 text, 3:1 large text and UI boundaries, in every theme.
   - Color is never the only cue for status, errors, required fields, or changes.
   - Every control reachable and operable by keyboard, with a visible focus not hidden by sticky
     elements; logical focus order; focus managed on dialogs and route changes.
   - Controls have roles and accessible names; inputs have labels; errors are linked to fields.
   - Target size at least 24x24 CSS px (platform guidance 44pt or 48dp); drag has an alternative.
   - Motion honors reduced-motion settings; nothing flashes more than three times a second;
     auto-updating content can be paused.
4. **Error and money experience**: errors say what happened and what to do and keep the user's
   input; money or irreversible actions are confirmed, show pending until confirmed, and never
   present a stale balance as current.
5. **Consistency** with the rest of the product's patterns and terminology.

## Anti-patterns to flag
- Disabled buttons with no visible reason.
- Modals for non-critical information; toasts for critical errors.
- Infinite scroll with no position persistence or keyboard-reachable "load more".
- Required fields marked only by color; placeholder used as the label.
- Hover-only information or actions.

## Quality bar
- Every finding: what is wrong, who is affected, evidence, severity, and a fix.
- Accessibility findings tagged with WCAG criterion and level (A before AA before AAA).
- Usability problems separated from preference; strengths noted.
- A review with few or no findings is valid when the evidence covers the task; state what was
  covered and what was not.

## Output
Fill `assets/ux-review.md`.

## Output contract
```yaml
produces:
  - type: "ux-review"
    format: "markdown"
    path: "claudedocs/<feature>-ux-review.md"
    sections: [heuristics, accessibility, cognitive_walkthrough, recommendations]
    handoff: "Write claudedocs/handoff-ux-review-<timestamp>.yaml - suggest: ticket-breakdown, code-review"
```
