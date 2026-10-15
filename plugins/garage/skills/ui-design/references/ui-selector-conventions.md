# UI selector conventions

Tests locate controls the way a user or assistive technology does. Stable selectors start with
accessible UI, not test-only attributes.

## Locator priority

1. Role plus accessible name: `getByRole('button', { name: 'Create link' })`.
2. Associated label for form controls: `getByLabel('Amount')`.
3. Visible text, alt text, or another user-facing semantic.
4. A stable test ID only when semantic selection is insufficient.

Justified test-ID cases: a canvas region, virtualized repeated content, a composite widget with no
distinct accessible child, localized dynamic text, or a non-interactive state probe that cannot be
expressed semantically. If a role or label cannot find an interactive control, fix the control's
accessibility first; do not paper over it with a test ID.

## Test-ID grammar (fallback only)

- `<surface>-<flow>-<element>[-<state>]`, lowercase kebab case, domain language
  (`payment-link-create-result`, `bet-slip-odds-change`).
- On the element or state region being asserted, not a visual wrapper.
- Stable across layout and copy changes; no CSS classes, array indexes, internal database IDs,
  secrets, or personal data. Repeated rows may append a stable public resource ID.

## Selector registry (`design/components/testid-registry.md`)

One row per element a test must reach: screen, element, primary locator (role + name or label),
fallback test ID if any, and the reason the fallback is needed. Changing a name or test ID in the
registry means updating the tests that use it (for example `e2e/test-plan.yaml`).

## Review checklist

- Interactive elements have correct roles, accessible names, keyboard behavior, and state.
- Each test ID has a stated reason a semantic locator is insufficient.
- Selectors do not depend on DOM nesting, styling, visual position, or incidental copy.

Platform equivalents (Flutter, React Native) are in `platform-patterns.md`.
