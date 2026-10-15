# Platform patterns

Detect the project's actual stack, versions, and libraries first. Extend what the codebase already
uses; the defaults below are only for greenfield work or when the project has no convention.

## Web (React, the default)

- Files: `.tsx` components, props as TypeScript interfaces, component + hook + types co-located.
- State: the project's server-state and client-state libraries (greenfield default: a query cache
  such as React Query for server state, local state first, a small store only when shared).
- Styling: the project's system (Tailwind, CSS modules, CSS-in-JS). Tokens as CSS custom
  properties consumed by that system.
- Accessibility: native elements first (`button`, `label`, `input`), ARIA only to fill gaps.
- Test locators: Playwright or Testing Library `getByRole`, `getByLabel`, `getByText`;
  `data-testid` only as the justified fallback in `ui-selector-conventions.md`.

## Flutter

- Widget tree in `.dart`, parameters as named constructor arguments.
- State: whatever the project uses (Riverpod, BLoC, Provider); do not introduce a second one.
- Tokens: `ThemeExtension` on top of the Material 3 `ThemeData`; no hard-coded colors or sizes.
- Layout: `LayoutBuilder` and `MediaQuery`; never fixed pixel widths. Respect safe-area insets.
- Accessibility: `Semantics` labels on custom interactive widgets, `ExcludeSemantics` for
  decoration, `MergeSemantics` for compound rows. Honor `MediaQuery.disableAnimations` and text
  scaling.
- Test locators: `find.bySemanticsLabel`, `find.text`, `find.byType`; `find.byKey(ValueKey(...))`
  only as the fallback.

## React Native

- `.tsx` components; platform files (`.ios.tsx`, `.android.tsx`) only where behavior differs.
- State and styling: the project's choice (StyleSheet, NativeWind, a theme provider).
- Layout: flexbox and `useWindowDimensions`; no absolute positioning for page layout.
- Accessibility: `accessibilityRole` and `accessibilityLabel` (or `role` and `aria-label` on
  versions that support them), `accessibilityState` for selected or disabled. Check
  `AccessibilityInfo.isReduceMotionEnabled()` before animating.
- Test locators: React Native Testing Library `getByRole`, `getByLabelText`, `getByText`;
  `testID` only as the fallback (in Detox, prefer `by.label` or `by.text` over `by.id`).

## AngularJS (legacy)

- Components as `.component.js` + template, bindings as the API, services for shared state.
- Styling: the project's CSS conventions (often BEM), not Tailwind.
- AngularJS and Protractor are both end of life. Design for the existing app, and use the
  project's current E2E runner (Playwright or Cypress if a migration has started) with semantic
  locators.

## Touch targets and navigation

- Follow the platform: Apple HIG 44x44 pt, Material 48x48 dp. The WCAG 2.2 AA floor is 24x24 CSS px
  with spacing; primary and money actions should meet the platform size.
- Navigation pattern (bottom tabs, side nav, back gestures) follows platform conventions and the
  existing app, with a visible alternative to every gesture.
