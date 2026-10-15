# Accessibility standards (WCAG 2.2 AA baseline)

Use the product's stated standard if it is stricter. Levels in brackets are WCAG conformance levels.

## Color and contrast

- Normal text: **4.5:1**. Large text (24px regular, or 18.66px bold and up): **3:1** [AA].
- UI component boundaries, focus indicators, and meaningful graphics: **3:1** [AA].
- Placeholder text is text: 4.5:1, and never the only label.
- Color is never the only cue [A]. Status, errors, odds or price movement, required fields, and
  chart series also carry text, an icon or glyph, a pattern, or a shape.
- Re-check every pair in each theme (light, dark, high contrast); a pair that passes in light mode
  often fails in dark mode.

## Motion and flashing

- Nothing flashes more than three times per second [A].
- Auto-moving, blinking, or auto-updating content that lasts more than 5 seconds can be paused,
  stopped, or hidden [A] (carousels, tickers, live animations).
- Honor reduced-motion settings (`prefers-reduced-motion`, Flutter `disableAnimations`, React
  Native `isReduceMotionEnabled`): replace slide, scale, pulse, and parallax with an instant change
  or a short opacity fade, and keep the information the animation carried.

## Keyboard and focus

- Every interactive element is reachable and operable by keyboard [A]; no keyboard traps except
  an intentional modal trap with Escape to close.
- Focus order follows reading order (respect RTL layouts).
- Focus is always visible and not hidden behind sticky headers, footers, or banners [AA].
- Escape closes modals, menus, and tooltips; arrow keys move within composite widgets (menus,
  tabs, radio groups); Enter or Space activates.
- Provide a way to bypass repeated blocks (skip link or landmarks) [A].
- Modal opens: focus moves inside. Modal closes: focus returns to the trigger. Route change: focus
  moves to the main heading or content.

## Pointer and touch

- Target size at least 24x24 CSS px or equivalent spacing [AA]; platform guidance is larger
  (Apple 44x44 pt, Material 48x48 dp) and should apply to primary and money actions.
- Any drag interaction has a single-pointer alternative [AA].
- Tooltip-only or hover-only information is also reachable by focus and touch.

## Forms and errors

- Every input has a programmatic label; errors are linked with `aria-describedby` and described in
  text [A].
- Do not ask for information the user already entered in the same flow [A].
- Authentication does not require a cognitive test (memorizing, transcribing) without an
  alternative such as paste or a password manager [AA].
- Help mechanisms appear in the same relative place across pages [A].

## Screen readers

- Images: meaningful `alt`, or `alt=""` and hidden when decorative. Icon-only buttons have a name.
- Status updates use a polite live region; only urgent errors use assertive.
- `aria-current="page"` for current nav item; `aria-busy` on a region while it loads.
- Disabled controls explain why nearby in text.

## Contrast quick reference

| Background | Foreground | Ratio | Normal text AA | Normal text AAA |
|---|---|---|---|---|
| #FFFFFF | #000000 | 21:1 | PASS | PASS |
| #FFFFFF | #767676 | 4.54:1 | PASS | FAIL |
| #FFFFFF | #959595 | 3.0:1 | FAIL (large text only) | FAIL |
| #1A1A1A | #F5F5F5 | 15.96:1 | PASS | PASS |
| #1A1A1A | #A3A3A3 | 6.9:1 | PASS | FAIL |
| #1A1A1A | #737373 | 3.67:1 | FAIL (large text only) | FAIL |

## Common mistakes

1. Color alone for state, with no icon or text.
2. Placeholder used as the label.
3. Custom dropdowns, checkboxes, or tabs without keyboard handling or roles.
4. Infinite scroll with no keyboard-reachable "Load more" and no preserved position.
5. Auto-playing media or animation with no pause and no reduced-motion path.
6. Toasts for critical errors, or auto-dismissing messages the user must act on.
