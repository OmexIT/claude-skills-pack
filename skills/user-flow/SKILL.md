---
name: user-flow
description: Map user journeys through a feature or product, identifying key paths, decision points, friction, error states, and edge cases. Triggers: "user flow", "user journey", "flow diagram", "happy path", "user path".
argument-hint: "[feature / user goal]"
---

# User flow

## What I'll do
Map the complete user journey for a feature — from entry point through completion — including happy paths, error states, edge cases, and decision points.

## Inputs I'll use (ask only if missing)
- The user goal (what are they trying to accomplish?)
- Entry points (how do they get here?)
- User persona (new vs returning, role, permissions)
- Constraints (platforms, accessibility requirements)

## How I'll think about this
1. **Start with the user's goal, not the UI**: "User wants to invite a teammate" not "User clicks the invite button." The goal determines the flow; the UI implements it.
2. **Map every state, not just the happy path**: Loading, empty, partial, error, success, and "nothing happened" states. Users spend more time in non-happy states than you think.
3. **Identify decision points**: Where does the user make a choice? What information do they need to make it? What happens if they choose wrong? Can they undo it?
4. **Trace error recovery**: When something fails, can the user understand what went wrong and fix it without starting over? Error states without recovery paths are dead ends.
5. **Consider entry and exit points**: Users don't always start at the beginning. They arrive via deep links, notifications, emails, search results. They leave mid-flow. Design for interruption and resumption.
6. **Check permission boundaries**: What happens when a user without the right permissions reaches a step? Do they see a helpful message or a broken page?

## Anti-patterns to flag
- Flows that only consider the happy path
- Error states that say "Something went wrong" without actionable guidance
- Flows that can't be resumed after interruption (lost form data, expired state)
- Decision points without enough context for the user to choose
- Accessibility dead ends (keyboard traps, missing screen reader context)
- Assuming all users enter from the home page

## Quality bar
- Every state is accounted for: loading, empty, partial, error, success
- Error states include recovery paths (not just error messages)
- Decision points list what information the user needs
- Edge cases are identified (permissions, concurrent edits, expired sessions, slow connections)
- Accessibility considerations are noted at each step
- Flow can be handed to a designer or engineer without ambiguity

## Workflow context
- Typically follows: `/prd` (UX requirements)
- Feeds into: `/design-doc` (technical implementation), `/test-plan` (test scenarios), `/ux-review`
- Related: `/experiment-design` (measuring flow effectiveness)

## Output
Fill `templates/user-flow.md`.
