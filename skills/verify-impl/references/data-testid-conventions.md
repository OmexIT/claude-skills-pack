# Data Test ID Conventions

Use stable selectors for product behavior, not layout or styling.

## Naming

- Format: `<area>-<element>-<intent>`.
- Use lowercase kebab case.
- Prefer domain nouns: `payment-link-create-submit`, `ledger-entry-row`, `user-menu-open`.
- Avoid text labels, CSS class names, generated IDs, and visual positions.

## Placement

- Put the test ID on the element the user interacts with.
- For repeated rows, put a base test ID on the row and domain identifiers in accessible text or attributes.
- For dialogs, include IDs for the trigger, dialog root, primary action, cancel action, and error region.

## Required IDs

Every verified flow should expose IDs for:

- Page or panel root.
- Primary submit/continue action.
- Destructive action confirmation.
- Loading state.
- Empty state.
- Error alert or validation summary.
- Repeated collection rows.

## Examples

```tsx
<main data-testid="payment-links-page">
  <button data-testid="payment-link-create-open">Create link</button>
  <form data-testid="payment-link-create-form">
    <button data-testid="payment-link-create-submit">Create</button>
  </form>
  <div role="alert" data-testid="payment-link-create-error" />
</main>
```

## Review Checklist

- Selectors survive copy changes.
- Selectors survive visual redesign.
- Selectors map to user-visible behavior.
- No selector depends on array index unless ordering is the behavior under test.
