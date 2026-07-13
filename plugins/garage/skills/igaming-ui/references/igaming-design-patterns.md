# iGaming interface patterns

Use these patterns with the product's design system, user research, accessibility standard,
approved regulatory requirements, and jurisdiction configuration. They are not a substitute for
legal or responsible-gambling review.

## Odds and market states

- Use tabular numerals so changing odds do not reflow the layout.
- Respect the user's configured decimal, fractional, or American odds format.
- Show an odds change with redundant cues: direction glyph or text, semantic color token, and a
  brief non-blocking transition. Color alone is insufficient.
- Honor `prefers-reduced-motion`; when reduced motion is requested, update the cue without flashing
  or pulsing.
- Keep open, suspended, settled, and void states explicit. A suspended market remains visible,
  clearly locked, and unavailable for selection.
- Use theme tokens such as `--color-odds-increased` rather than hard-coded red or green values.
- Touch targets follow the product's accessibility baseline and platform guidance. Preserve enough
  spacing to avoid accidental bet selection.

## Live state

- A text or icon cue identifies live content without relying on color.
- Live score, timer, and odds updates reserve layout space and use tabular numerals.
- Do not show a spinner for every tick. Keep the last confirmed state visible while reconnecting
  and expose delayed or disconnected status.
- Animations are optional, subtle, and disabled or reduced under the user's motion preference.

## Bet slip

- Make the slip discoverable from the main betting journey. Choose panel, sheet, or page from the
  actual responsive layout, not a universal navigation rule.
- Show stake, current odds, potential return, currency, and any changed or suspended selections
  before confirmation.
- If odds change, follow the product's approved acceptance policy and require clear user action
  when necessary. Do not silently accept worse odds.
- Explain why placement is unavailable. Never use a disabled primary action without an adjacent
  reason and recovery path.
- Prevent duplicate submission. An unknown placement result remains pending until authoritative
  reconciliation; it is not shown as failed merely because the client timed out.
- Use the appropriate numeric input mode without removing validation, locale handling, or an
  accessible label.

## Wallet and balance

- Loading can use a size-stable skeleton, but preserve accessible status text.
- A cached balance is labeled stale with its last-updated time and a retry path.
- While balance authority is unavailable, disable bet placement, deposit, withdrawal, and transfer
  actions that depend on it unless an approved offline mutation design proves safety.
- Never show a cached value as current or turn a timeout into a zero balance.
- Use tabular numerals, explicit currency, and the asset's authoritative scale.

## Casino grids

- Preserve image dimensions to avoid layout shift and lazy-load media with meaningful alt behavior.
- Choose card ratio, hover, badges, and category layout from the content and design system.
- Hover-only actions must also be keyboard and touch accessible.
- Virtualized or infinite grids expose loading, end, empty, and failure states and retain focus
  predictably.
- Do not animate jackpot or balance values when motion is reduced. Never imply a guarantee of
  winning through animation or copy.

## Responsible gambling and compliance

- Implement the exact approved requirements for each jurisdiction and product. Record the legal or
  compliance source of truth and do not invent universal placement, timing, or interaction rules.
- Help, limits, cooling-off, self-exclusion, reality-check, and session controls must be findable,
  accessible, and testable wherever the applicable requirement demands them.
- Avoid manipulative urgency, concealment, obstructive cancellation, or visual treatment that
  pressures users to increase spend.
- A control that changes a regulated limit or exclusion state needs clear confirmation, outcome,
  effective time, and recovery or support guidance.
- Localized copy and age, identity, and jurisdiction rules come from approved product and legal
  artifacts, not this reference.

## Responsive and accessibility checks

- Verify the actual supported breakpoints, zoom, text resizing, keyboard flow, screen-reader names,
  focus order, high contrast, and reduced motion.
- Do not mandate bottom navigation, swipe gestures, haptics, pull-to-refresh, or one-tap betting.
  Add them only when product evidence and platform conventions support them, with an accessible
  alternative.
- Selector guidance lives in `../../../references/ui-selector-conventions.md`.
