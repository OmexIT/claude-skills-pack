---
name: ux-review
description: Evaluate a UI/UX design or implementation using heuristic analysis, accessibility audit, and cognitive walkthrough. Triggers: "UX review", "usability review", "heuristic evaluation", "accessibility audit", "is this usable".
argument-hint: "[feature / screen / URL / mockup]"
---

# UX review

## What I'll do
Evaluate a design or implementation for usability, accessibility, and user experience quality using established heuristic frameworks.

## Inputs I'll use (ask only if missing)
- Screen, mockup, URL, or description of the UI
- Target user persona and their goal
- Context: mobile/desktop, new user/experienced, accessibility requirements
- Known pain points or areas of concern

## How I'll think about this
1. **Nielsen's 10 heuristics**: Systematically check visibility of system status, match between system and real world, user control, consistency, error prevention, recognition over recall, flexibility, aesthetic design, error recovery, and help/documentation.
2. **Cognitive walkthrough**: For each step in the user's task, ask: Will the user know what to do? Will they notice the right action? Will they understand the feedback? Can they recover from mistakes?
3. **Accessibility (WCAG)**: Check keyboard navigation, screen reader compatibility, color contrast, text sizing, focus management, and alternative text. Accessibility isn't optional.
4. **Information hierarchy**: Is the most important information most prominent? Can users scan and find what they need? Is the visual hierarchy guiding attention correctly?
5. **Error experience**: When things go wrong, is the error message helpful? Does it explain what happened, why, and what to do? Can users recover without losing their work?
6. **Consistency audit**: Does this screen follow the same patterns as the rest of the product? Inconsistency creates cognitive load.

## Heuristic checklist
### Visibility of system status
- [ ] User knows where they are in the application
- [ ] Loading states are visible and informative
- [ ] Actions provide immediate feedback
- [ ] Progress indicators exist for long operations

### User control and freedom
- [ ] Undo/redo is available for destructive actions
- [ ] Cancel is always accessible
- [ ] Users can navigate back without losing data
- [ ] Confirmation dialogs for irreversible actions

### Consistency and standards
- [ ] UI patterns match platform conventions
- [ ] Same actions look the same across the product
- [ ] Terminology is consistent throughout
- [ ] Icons have consistent meaning

### Error prevention and recovery
- [ ] Inputs are validated before submission (client-side)
- [ ] Destructive actions require confirmation
- [ ] Error messages are specific and actionable
- [ ] Users can recover from errors without restarting

### Accessibility
- [ ] Color contrast meets WCAG AA (4.5:1 text, 3:1 large text)
- [ ] All interactive elements are keyboard accessible
- [ ] Focus order is logical and visible
- [ ] Images have meaningful alt text
- [ ] Form fields have associated labels
- [ ] Screen reader can navigate and understand the page

## Anti-patterns to flag
- Disabled buttons without explanation (why can't I click this?)
- Modal dialogs for non-critical information
- Infinite scroll without "back to top" or position persistence
- Required fields not marked, or marked only with color
- Toast notifications for critical errors (easy to miss)
- Tiny tap targets on mobile (<44px)

## Quality bar
- Every finding includes: what's wrong, who's affected, severity, and a fix suggestion
- Accessibility issues are prioritized (WCAG A > AA > AAA)
- Findings distinguish between usability issues and personal preference
- Positive patterns are noted (not just problems)
- Screen-specific and consistent with the rest of the product

## Workflow context
- Typically follows: `/user-flow`, `/prd` (UI requirements)
- Feeds into: `/ticket-breakdown` (UX fix tickets), `/pr-review` (implementation review)
- Related: `/docs-review` (content clarity overlaps)

## Output
Fill `templates/ux-review.md`.
