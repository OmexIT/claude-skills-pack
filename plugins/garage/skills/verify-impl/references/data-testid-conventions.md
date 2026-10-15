# UI selector conventions

Tests locate controls the way a user or assistive technology identifies them. Stable selectors
start with accessible UI, not test-only attributes.

## Locator priority

1. Role plus accessible name: `getByRole('button', { name: 'Create link' })`.
2. Associated label for form controls: `getByLabel('Amount')`.
3. Visible text, alt text, or another user-facing semantic when appropriate.
4. A stable test ID only when semantic selection is insufficient.

Justified test-ID cases: a canvas region, virtualized repeated content, a composite widget with no
distinct accessible child, localized dynamic text, or a non-interactive state probe that cannot be
expressed semantically. If a role or label cannot find an interactive control, first check whether
the control is inaccessible.

## Test-ID grammar (fallback only)

- Format: `<surface>-<flow>-<element>[-<state>]`, lowercase kebab case, domain language:
  `payment-link-create-result`.
- Put the ID on the element or state region being asserted, not a visual wrapper.
- Never encode CSS classes, array indexes, internal database IDs, secrets, or personal data.
- Repeated rows may append a stable public resource ID when the scenario needs a specific row.

## Examples

```tsx
<label htmlFor="amount">Amount</label>
<input id="amount" inputMode="decimal" />
<button type="submit">Create link</button>
<div role="alert">Amount is required</div>

<canvas aria-label="Live match momentum" data-testid="live-match-momentum-canvas" />
```

## Review checklist

- Interactive elements have correct roles, accessible names, keyboard behavior, and state.
- Each test uses the highest available locator priority.
- Each test ID has a stated reason a semantic locator is insufficient.
- Selectors do not depend on DOM nesting, styling, visual position, or incidental copy.
