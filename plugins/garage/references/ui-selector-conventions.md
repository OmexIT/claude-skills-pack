# UI selector conventions

Tests should locate controls the way a user or assistive technology identifies them. Stable
selectors begin with accessible UI, not extra test-only attributes.

## Locator priority

1. Role plus accessible name: `getByRole('button', { name: 'Create link' })`.
2. Associated label for form controls: `getByLabel('Amount')`.
3. Visible text, alt text, or another user-facing semantic when appropriate.
4. A stable test ID only when semantic selection is insufficient or intentionally unstable.

Common justified test-ID cases include a canvas region, virtualized repeated content, a composite
widget with no distinct accessible child, localized dynamic text, or a non-interactive state probe
that cannot be expressed semantically. If a role or label cannot find an interactive control,
first check whether the control is inaccessible.

## Test-ID grammar

- Format: `<surface>-<flow>-<element>[-<state>]` in lowercase kebab case.
- Use domain language: `payment-link-create-result`, `bet-slip-odds-change`.
- Put the ID on the element or state region being asserted, not a visual wrapper.
- Keep it stable across layout and copy changes.
- Do not encode CSS classes, array indexes, internal database IDs, secrets, or personal data.
- Repeated rows may append a stable public resource ID when the scenario needs a specific row.

## Examples

Prefer semantics:

```tsx
<label htmlFor="stake">Stake</label>
<input id="stake" inputMode="decimal" />
<button type="submit">Place bet</button>
<div role="alert">Odds changed</div>
```

Use a test ID only for the part that lacks a suitable semantic contract:

```tsx
<canvas
  aria-label="Live match momentum"
  data-testid="live-match-momentum-canvas"
/>
```

## Review checklist

- Interactive elements have correct roles, accessible names, keyboard behavior, and state.
- The test uses the highest available locator priority.
- Each test ID has a specific reason a semantic locator is insufficient.
- Selectors do not depend on DOM nesting, styling, visual position, or incidental copy.
- Dynamic selectors use a stable public domain key and expose no sensitive data.
