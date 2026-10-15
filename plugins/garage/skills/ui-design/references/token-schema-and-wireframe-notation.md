# Design token schema

One naming scheme across the skill: `--<category>-<role>-<modifier>`. If the project already has
tokens, extend its names instead of introducing these. Tokens ship as CSS custom properties (web),
a `ThemeExtension` (Flutter), or theme constants (React Native); see `platform-patterns.md`.

## Color roles (each has a light and a dark value)

```
SURFACE   --color-surface-page | -default | -elevated | -subtle (inputs, hover) | -overlay (scrim)
TEXT      --color-text-primary | -secondary | -muted | -disabled | -inverse | -link
BORDER    --color-border-default | -strong | -focus
BRAND     --color-brand-primary | -primary-hover | -primary-subtle | -secondary
STATUS    --color-{success|warning|error|info}-bg | -text | -border
```

Components consume semantic tokens only; primitives (`blue-500`) exist only to define them.

## Status mapping

Every status pairs color with a text label and, where space allows, an icon. Color alone fails
WCAG 1.4.1.

```
PENDING   text --color-warning-text   bg --color-warning-bg   + "Pending" + clock icon
PAID      text --color-success-text   bg --color-success-bg   + "Paid" + check icon
FAILED    text --color-error-text     bg --color-error-bg     + "Failed" + alert icon
EXPIRED   text --color-text-secondary bg --color-surface-subtle + "Expired"
CANCELLED text --color-text-disabled  bg --color-surface-subtle + "Cancelled"
ACTIVE    text --color-brand-primary  bg --color-brand-primary-subtle + "Active"
```

## Type, space, shape, motion

```
TYPE      --font-{display|heading|body|mono}; scale display-*, heading-*, body-*, caption, label
          numbers that update in place (amounts, odds, timers) use tabular numerals
SPACE     4px base: --spacing-1 (4) ... --spacing-20 (80); semantic --spacing-component-*, -section-*
RADIUS    --radius-{none|sm|md|lg|xl|full}
ELEVATION --shadow-{xs|sm|md|lg}; in dark themes express elevation with lighter surfaces
MOTION    --motion-duration-{fast|base|slow} (about 100 / 200 / 350ms), --motion-easing-standard
          under reduced motion: durations collapse to 0 or an opacity-only fade
```

## Tailwind mapping (web projects already on Tailwind)

```js
theme: { extend: {
  colors: {
    'surface-page': 'var(--color-surface-page)', 'surface-default': 'var(--color-surface-default)',
    'text-primary': 'var(--color-text-primary)', 'brand-primary': 'var(--color-brand-primary)',
    'error-text': 'var(--color-error-text)', 'error-bg': 'var(--color-error-bg)',
    // one entry per semantic token
  },
  transitionDuration: { fast: 'var(--motion-duration-fast)', base: 'var(--motion-duration-base)' },
}}
```

Pair with `motion-safe:` / `motion-reduce:` variants (or a global reduced-motion rule) so
animations respect the user setting.

---

# Wireframe notation

## Symbols

```
Containers:  ┌─ REGION ─┐ │ └─┘          labelled region
Elevated:    ╔═ MODAL ══╗ ║ ╚═╝          modal, dropdown, sheet
Skeleton:    ░░░░░░░░░░ (text line)  ▓▓▓▓ (image or avatar block)
Controls:    [Button]  [input____]  [select v]  (o) radio  [x] checkbox  [on|off] toggle
Icons:       [<] back  [>] chevron  [:] overflow  [x] close  [+] add  [^] [v] sort
Status:      [*] status dot, always with a text label beside it
```

## Example: list screen with spec sidebar

```
┌───────────────────────────────────────────────┐  SCR-001: Money Request List
│ ╔═══════════════════════════════════════════╗ │  Viewport: 375px mobile / 1280px desktop
│ ║ [<]  Money Requests       [+ New Request] ║ │  Regions:
│ ╚═══════════════════════════════════════════╝ │    A: Top bar   56px, surface-elevated
│ ┌─ FILTER BAR ──────────────────────────────┐ │    B: Filters   48px, surface-default
│ │ [All v] [Pending v] [Date v]  [Search..]  │ │    C: List      flex column, scroll
│ └───────────────────────────────────────────┘ │
│ ┌─ LIST ITEM (repeat) ──────────────────────┐ │  States:
│ │ [Avatar] John Doe          KES 5,000  [>] │ │    loading: 3 skeleton rows
│ │          Oct 12 . [*] Pending             │ │    empty:   explanation + CTA
│ └───────────────────────────────────────────┘ │    error:   inline banner + Retry
└───────────────────────────────────────────────┘
```

## State frames

```
[EMPTY]              [LOADING]            [ERROR]
┌────────────────┐   ┌────────────────┐   ┌────────────────┐
│ No requests yet│   │ ░░░░░░░░░░░░░░ │   │ ╔════════════╗ │
│ Requests you   │   │ ░░░░░░░░       │   │ ║ Could not  ║ │
│ send show here │   │ ░░░░░░░░░░░░░░ │   │ ║ load data  ║ │
│ [+ New Request]│   │ ░░░░░░░░░      │   │ ╚════════════╝ │
└────────────────┘   └────────────────┘   │ [Retry]        │
                                          └────────────────┘
```
