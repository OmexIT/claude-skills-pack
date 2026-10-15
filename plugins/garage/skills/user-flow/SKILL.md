---
name: user-flow
description: "Use when the user wants user journeys mapped through a feature or product: user flow, user journey, flow diagram, decision points, friction, error states, or edge cases."
---

# User flow

Map what a person goes through to reach a goal: where they enter, what they see, what they
decide, where they get stuck, and how they recover. Output is a journey a designer can draw
screens from.

## Workflow context
- Boundary: this is the user's view (screens, choices, messages, friction). `flow-map` is the
  system's view (states, failure classes, concurrency, cleanup) and turns each path into a test case.
  Here a failure is described as the user experiences it ("payment did not go through, card kept").
- Follows `prd`. Feeds `ui-design` (screens), `flow-map` (system paths), `ux-review`, `test-plan`.

## Inputs (ask only if missing)
- The user goal, persona (new or returning, role, permissions), and entry points.
- Platforms and accessibility requirements.

## How to map it
1. **Start from the goal, not the UI**: "invite a teammate", not "click invite".
2. **Every step's states**: loading, empty, partial, error, success, and "nothing happened".
3. **Decision points**: what the user must know to choose, the default, and whether they can undo.
4. **Error recovery**: each error the user can hit has a way forward that keeps their input. An
   error with no recovery is a dead end; flag it.
5. **Entry and interruption**: deep links, notifications, emails, search; leaving mid-flow and
   coming back. Say what is preserved.
6. **Permissions**: what a user without access sees at each step.
7. **Money steps**: the user sees amount, fees, and outcome before confirming; a pending or
   unknown result is shown as pending with what happens next, never as failed or done.

## Anti-patterns to flag
- Happy path only; "Something went wrong" with no next step.
- Flows that lose data on interruption or session expiry.
- Choices without the information needed to make them.
- Keyboard traps or steps a screen reader cannot follow.
- Assuming every user starts at the home page.

## Quality bar
- Every step lists its states, and every error has a recovery path.
- Decision points list the information the user needs.
- User-visible edge cases noted: permissions, expired session, slow connection, interruption,
  someone else changing the same item.
- Accessibility noted per step (focus on step change, announcements, non-color cues).
- A designer or engineer can work from it without asking what happens next.

## Output
Fill `assets/user-flow.md`.

## Output contract
```yaml
produces:
  - type: "user-flow"
    format: "markdown"
    path: "claudedocs/<feature>-user-flow.md"
    sections: [journeys, decision_points, error_states, edge_cases]
    handoff: "Write claudedocs/handoff-user-flow-<timestamp>.yaml - suggest: flow-map, ux-review, ui-design"
```
