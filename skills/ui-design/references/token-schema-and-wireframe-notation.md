# Design Token Schema

Naming convention for all design tokens. Tokens are implemented as CSS custom properties (React), ThemeExtension (Flutter), StyleSheet constants (React Native), or CSS classes (AngularJS).

---

## Colour Tokens

```css
/* Semantic roles — map to primitive colours per theme */
--color-primary           /* main brand CTA, active indicators */
--color-primary-hover     /* hover state of primary */
--color-primary-subtle    /* low-emphasis primary tint (backgrounds) */

--color-surface-1         /* page background */
--color-surface-2         /* card / panel / sidebar background */
--color-surface-3         /* input / hover / subtle container background */
--color-surface-overlay   /* modal backdrop */

--color-border            /* dividers, input borders */
--color-border-focus      /* focus ring colour */

--color-text-primary      /* headings, body content */
--color-text-secondary    /* metadata, supporting text */
--color-text-disabled     /* disabled state text */
--color-text-inverse      /* text on dark/coloured backgrounds */
--color-text-link         /* hyperlinks */

--color-success           /* PAID, confirmed, positive states */
--color-success-subtle    /* success background tint */
--color-warning           /* PENDING, caution states */
--color-warning-subtle    /* warning background tint */
--color-error             /* FAILED, validation errors */
--color-error-subtle      /* error background tint */
--color-info              /* informational banners */
--color-info-subtle       /* info background tint */
```

## Status Badge Colours

```
PENDING   → text: --color-warning        bg: --color-warning-subtle
PAID      → text: --color-success        bg: --color-success-subtle
EXPIRED   → text: --color-text-secondary bg: --color-surface-3
FAILED    → text: --color-error          bg: --color-error-subtle
CANCELLED → text: --color-text-disabled  bg: --color-surface-3
ACTIVE    → text: --color-primary        bg: --color-primary-subtle
```

## Tailwind Config Mapping (React)

```js
// tailwind.config.js
theme: {
  extend: {
    colors: {
      primary:    'var(--color-primary)',
      'surface-1':'var(--color-surface-1)',
      'surface-2':'var(--color-surface-2)',
      'surface-3':'var(--color-surface-3)',
      border:     'var(--color-border)',
      'text-primary':   'var(--color-text-primary)',
      'text-secondary': 'var(--color-text-secondary)',
      success:    'var(--color-success)',
      warning:    'var(--color-warning)',
      error:      'var(--color-error)',
      info:       'var(--color-info)',
    },
    fontSize: {
      'display': ['2rem',    { lineHeight: '2.5rem', fontWeight: '700' }],
      'h1':      ['1.5rem',  { lineHeight: '2rem',   fontWeight: '600' }],
      'h2':      ['1.25rem', { lineHeight: '1.75rem',fontWeight: '600' }],
      'body':    ['1rem',    { lineHeight: '1.5rem', fontWeight: '400' }],
      'body-sm': ['0.875rem',{ lineHeight: '1.25rem',fontWeight: '400' }],
      'label':   ['0.75rem', { lineHeight: '1rem',   fontWeight: '500' }],
    },
    boxShadow: {
      'level-1': '0 1px 3px rgba(0,0,0,0.08)',
      'level-2': '0 4px 12px rgba(0,0,0,0.12)',
      'level-3': '0 8px 24px rgba(0,0,0,0.16)',
    },
    borderRadius: {
      sm: '4px',
      md: '8px',
      lg: '12px',
    },
    transitionDuration: {
      fast: '100ms',
      base: '200ms',
      slow: '350ms',
    },
  }
}
```

## Flutter Theme Mapping

```dart
// theme/app_tokens.dart
class AppTokens extends ThemeExtension<AppTokens> {
  final Color primary;
  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;
  // ... etc
}
```

---

# Wireframe Notation Reference

## Box Drawing Characters

```
Single borders:    ┌ ─ ┐ │ └ ─ ┘ ├ ┤ ┬ ┴ ┼
Double borders:    ╔ ═ ╗ ║ ╚ ═ ╝ ╠ ╣ ╦ ╩ ╬
Heavy borders:     ┏ ━ ┓ ┃ ┗ ━ ┛
```

## Region Labels

```
┌─ REGION NAME ──────────────┐   ← labelled container
│                            │
└────────────────────────────┘

╔═ MODAL / ELEVATED ════════╗    ← elevated surface (modal, dropdown)
║                           ║
╚═══════════════════════════╝
```

## Skeleton / Loading

```
░░░░░░░░░░░░░░░░░░░░░   ← skeleton text line (full width)
░░░░░░░░░░░░░            ← skeleton text line (partial)
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ← skeleton image / avatar block
```

## Interactive Elements

```
[Button Label]      ← primary button
[input field____]   ← text input
[dropdown ▾]        ← select / dropdown
[● Radio]           ← radio button
[✓ Checkbox]        ← checkbox
[═══●════════]      ← toggle (on)
[════════●═══]      ← toggle (off)
[🔍 Search...]      ← search input
```

## Icons and Badges

```
[●]     ← status indicator dot
[← ]    ← back navigation
[→ ]    ← forward / chevron
[⋮]     ← overflow menu
[✕]     ← close / dismiss
[+]     ← add / create
[↑]     ← sort ascending
[↓]     ← sort descending
```
